import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/session_local_data_source.dart';

void main() {
  group('SessionLocalDataSource Tests', () {
    late Database db;
    late SessionLocalDataSource dataSource;

    setUpAll(() {
      // Initialize Talker for logging in tests
      initializeTalker();
    });

    setUp(() async {
      // Create in-memory database for testing (use unique name for each test)
      db = await databaseFactoryMemory.openDatabase('test_${DateTime.now().millisecondsSinceEpoch}.db');
      dataSource = SessionLocalDataSource(db);
    });

    tearDown(() async {
      await db.close();
    });

    // Helper to create test session
    Session createTestSession({
      String id = 'session-1',
      String studentId = 'student-1',
      DateTime? start,
      DateTime? end,
      int rateSnapshotCents = 4000,
      PaymentStatus payStatus = PaymentStatus.unpaid,
    }) {
      final now = DateTime.now();
      return Session.create(
        id: id,
        studentId: studentId,
        start: start ?? now.add(const Duration(days: 1)),
        end: end ?? now.add(const Duration(days: 1, hours: 1)),
        rateSnapshotCents: rateSnapshotCents,
      ).copyWith(payStatus: payStatus);
    }

    group('CRUD Operations', () {
      test('create should save session to database', () async {
        // Arrange
        final session = createTestSession();

        // Act
        final result = await dataSource.create(session);

        // Assert
        expect(result, session);
        final retrieved = await dataSource.getById(session.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, session.id);
        expect(retrieved.studentId, session.studentId);
      });

      test('getById should return session when exists', () async {
        // Arrange
        final session = createTestSession();
        await dataSource.create(session);

        // Act
        final result = await dataSource.getById(session.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, session.id);
      });

      test('getById should return null when session does not exist', () async {
        // Act
        final result = await dataSource.getById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('getAll should return all sessions', () async {
        // Arrange
        final session1 = createTestSession();
        final session2 = createTestSession(id: 'session-2');
        final session3 = createTestSession(id: 'session-3');
        await dataSource.create(session1);
        await dataSource.create(session2);
        await dataSource.create(session3);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result.length, 3);
        expect(result.map((s) => s.id), containsAll(['session-1', 'session-2', 'session-3']));
      });

      test('update should modify existing session', () async {
        // Arrange
        final session = createTestSession();
        await dataSource.create(session);
        final updated = session.copyWith(rateSnapshotCents: 5000);

        // Act
        final result = await dataSource.update(updated);

        // Assert
        expect(result.rateSnapshotCents, 5000);

        final retrieved = await dataSource.getById(session.id);
        expect(retrieved!.rateSnapshotCents, 5000);
      });

      test('update should throw when session does not exist', () {
        // Arrange
        final session = createTestSession();

        // Act & Assert
        expect(
          () => dataSource.update(session),
          throwsA(isA<Exception>()),
        );
      });

      test('updatePayStatus should update session payment status', () async {
        // Arrange
        final session = createTestSession();
        await dataSource.create(session);

        // Act
        await dataSource.updatePayStatus(session.id, 'paid');

        // Assert
        final retrieved = await dataSource.getById(session.id);
        expect(retrieved!.payStatus, PaymentStatus.paid);
      });

      test('delete should remove session from database', () async {
        // Arrange
        final session = createTestSession();
        await dataSource.create(session);

        // Act
        await dataSource.delete(session.id);

        // Assert
        final retrieved = await dataSource.getById(session.id);
        expect(retrieved, isNull);
      });

      test('deleteByStudentId should remove all sessions for student', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2'));
        await dataSource.create(createTestSession(id: 'session-3', studentId: 'student-2'));

        // Act
        await dataSource.deleteByStudentId('student-1');

        // Assert
        final all = await dataSource.getAll();
        expect(all.length, 1);
        expect(all.first.id, 'session-3');
      });

      test('deleteAll should remove all sessions', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2'));
        await dataSource.create(createTestSession(id: 'session-3'));

        // Act
        await dataSource.deleteAll();

        // Assert
        final result = await dataSource.getAll();
        expect(result, isEmpty);
      });
    });

    group('Query Operations', () {
      test('getByStudentId should return sessions for specific student sorted by start time', () async {
        // Arrange
        final now = DateTime.now();
        await dataSource.create(createTestSession(
          start: now.add(const Duration(days: 3)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-2',
          start: now.add(const Duration(days: 1)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-3',
          studentId: 'student-2',
          start: now.add(const Duration(days: 2)),
        ));

        // Act
        final result = await dataSource.getByStudentId('student-1');

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['session-1', 'session-2']));
        // Most recent first (descending)
        expect(result[0].id, 'session-1');
        expect(result[1].id, 'session-2');
      });

      test('getUpcomingSessions should return future sessions sorted ascending', () async {
        // Arrange
        final now = DateTime.now();
        await dataSource.create(createTestSession(
          start: now.add(const Duration(days: 2)),
          end: now.add(const Duration(days: 2, hours: 1)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-2',
          start: now.subtract(const Duration(days: 1)),
          end: now.subtract(const Duration(hours: 23)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-3',
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 1, hours: 1)),
        ));

        // Act
        final result = await dataSource.getUpcomingSessions();

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['session-1', 'session-3']));
        // Soonest first (ascending)
        expect(result[0].id, 'session-3');
        expect(result[1].id, 'session-1');
      });

      test('getPastSessions should return past sessions sorted descending', () async {
        // Arrange
        final now = DateTime.now();
        await dataSource.create(createTestSession(
          start: now.subtract(const Duration(days: 2)),
          end: now.subtract(const Duration(days: 2)).add(const Duration(hours: 1)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-2',
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 1, hours: 1)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-3',
          start: now.subtract(const Duration(days: 1)),
          end: now.subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
        ));

        // Act
        final result = await dataSource.getPastSessions();

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['session-1', 'session-3']));
        // Most recent first (descending)
        expect(result[0].id, 'session-3');
        expect(result[1].id, 'session-1');
      });

      test('getUnpaidSessions should return only unpaid sessions', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2', payStatus: PaymentStatus.paid));
        await dataSource.create(createTestSession(id: 'session-3'));

        // Act
        final result = await dataSource.getUnpaidSessions();

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['session-1', 'session-3']));
      });

      test('getUnpaidSessionsByStudentId should return unpaid sessions for specific student', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2', payStatus: PaymentStatus.paid));
        await dataSource.create(createTestSession(id: 'session-3', studentId: 'student-2'));

        // Act
        final result = await dataSource.getUnpaidSessionsByStudentId('student-1');

        // Assert
        expect(result.length, 1);
        expect(result.first.id, 'session-1');
      });

      test('getSessionsInRange should return sessions within date range', () async {
        // Arrange
        final now = DateTime.now();
        final startDate = now.add(const Duration(days: 1));
        final endDate = now.add(const Duration(days: 3));

        await dataSource.create(createTestSession(
          start: now.add(const Duration(days: 2)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-2',
          start: now.add(const Duration(days: 5)),
        ));
        await dataSource.create(createTestSession(
          id: 'session-3',
          start: now.add(const Duration(hours: 12)),
        ));

        // Act
        final result = await dataSource.getSessionsInRange(
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(result.length, 1);
        expect(result.first.id, 'session-1');
      });
    });

    group('Utility Operations', () {
      test('exists should return true when session exists', () async {
        // Arrange
        final session = createTestSession();
        await dataSource.create(session);

        // Act
        final result = await dataSource.exists(session.id);

        // Assert
        expect(result, true);
      });

      test('exists should return false when session does not exist', () async {
        // Act
        final result = await dataSource.exists('non-existent');

        // Assert
        expect(result, false);
      });

      test('count should return correct number of sessions', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2'));
        await dataSource.create(createTestSession(id: 'session-3'));

        // Act
        final result = await dataSource.count();

        // Assert
        expect(result, 3);
      });

      test('countByStudentId should return correct number of sessions for student', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2'));
        await dataSource.create(createTestSession(id: 'session-3', studentId: 'student-2'));

        // Act
        final result = await dataSource.countByStudentId('student-1');

        // Assert
        expect(result, 2);
      });
    });

    group('Stream Operations', () {
      test('watchAll should emit all sessions sorted by start time', () async {
        // Arrange
        final now = DateTime.now();
        await dataSource.create(createTestSession(start: now.add(const Duration(days: 1))));
        await dataSource.create(createTestSession(id: 'session-2', start: now.add(const Duration(days: 3))));
        await dataSource.create(createTestSession(id: 'session-3', start: now.add(const Duration(days: 2))));

        // Act
        final stream = dataSource.watchAll();

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<Session>>((sessions) {
            return sessions.length == 3 &&
                sessions[0].id == 'session-2' && // Most recent first (descending)
                sessions[1].id == 'session-3' &&
                sessions[2].id == 'session-1';
          })),
        );
      });

      test('watchById should emit session when exists', () async {
        // Arrange
        final session = createTestSession();
        await dataSource.create(session);

        // Act
        final stream = dataSource.watchById(session.id);

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<Session?>((s) => s != null && s.id == session.id)),
        );
      });

      test('watchByStudentId should emit sessions for specific student', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2'));
        await dataSource.create(createTestSession(id: 'session-3', studentId: 'student-2'));

        // Act
        final stream = dataSource.watchByStudentId('student-1');

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<Session>>((sessions) {
            return sessions.length == 2 &&
                sessions.every((s) => s.studentId == 'student-1');
          })),
        );
      });

      test('watchUnpaidSessions should emit only unpaid sessions', () async {
        // Arrange
        await dataSource.create(createTestSession());
        await dataSource.create(createTestSession(id: 'session-2', payStatus: PaymentStatus.paid));
        await dataSource.create(createTestSession(id: 'session-3'));

        // Act
        final stream = dataSource.watchUnpaidSessions();

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<Session>>((sessions) {
            return sessions.length == 2 &&
                sessions.every((s) => s.payStatus == PaymentStatus.unpaid);
          })),
        );
      });
    });
  });
}

