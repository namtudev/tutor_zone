import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/sessions/models/data/recurring_schedule.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/recurring_schedule_local_data_source.dart';

void main() {
  group('RecurringScheduleLocalDataSource Tests', () {
    late Database db;
    late RecurringScheduleLocalDataSource dataSource;

    setUpAll(() {
      // Initialize Talker for logging in tests
      initializeTalker();
    });

    setUp(() async {
      // Create in-memory database for testing (use unique name for each test)
      db = await databaseFactoryMemory.openDatabase('test_${DateTime.now().millisecondsSinceEpoch}.db');
      dataSource = RecurringScheduleLocalDataSource(db);
    });

    tearDown(() async {
      await db.close();
    });

    // Helper to create test recurring schedule
    RecurringSchedule createTestSchedule({
      String id = 'schedule-1',
      String studentId = 'student-1',
      int weekday = 1, // Monday
      String startLocal = '14:00',
      String endLocal = '15:00',
      int rateSnapshotCents = 4000,
      bool isActive = true,
    }) {
      return RecurringSchedule.create(
        id: id,
        studentId: studentId,
        weekday: weekday,
        startLocal: startLocal,
        endLocal: endLocal,
        rateSnapshotCents: rateSnapshotCents,
        isActive: isActive,
      );
    }

    group('CRUD Operations', () {
      test('create should save recurring schedule to database', () async {
        // Arrange
        final schedule = createTestSchedule();

        // Act
        final result = await dataSource.create(schedule);

        // Assert
        expect(result, schedule);
        final retrieved = await dataSource.getById(schedule.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, schedule.id);
        expect(retrieved.studentId, schedule.studentId);
        expect(retrieved.weekday, schedule.weekday);
      });

      test('getById should return schedule when exists', () async {
        // Arrange
        final schedule = createTestSchedule();
        await dataSource.create(schedule);

        // Act
        final result = await dataSource.getById(schedule.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, schedule.id);
      });

      test('getById should return null when schedule does not exist', () async {
        // Act
        final result = await dataSource.getById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('getAll should return all recurring schedules', () async {
        // Arrange
        final s1 = createTestSchedule();
        final s2 = createTestSchedule(id: 'schedule-2');
        final s3 = createTestSchedule(id: 'schedule-3');
        await dataSource.create(s1);
        await dataSource.create(s2);
        await dataSource.create(s3);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result.length, 3);
        expect(result.map((s) => s.id), containsAll(['schedule-1', 'schedule-2', 'schedule-3']));
      });

      test('update should modify existing schedule', () async {
        // Arrange
        final schedule = createTestSchedule();
        await dataSource.create(schedule);
        final updated = schedule.copyWith(startLocal: '15:00', endLocal: '16:00');

        // Act
        final result = await dataSource.update(updated);

        // Assert
        expect(result.startLocal, '15:00');
        expect(result.endLocal, '16:00');

        final retrieved = await dataSource.getById(schedule.id);
        expect(retrieved!.startLocal, '15:00');
        expect(retrieved.endLocal, '16:00');
      });

      test('update should throw when schedule does not exist', () {
        // Arrange
        final schedule = createTestSchedule();

        // Act & Assert
        expect(
          () => dataSource.update(schedule),
          throwsA(isA<Exception>()),
        );
      });

      test('updateActiveStatus should update schedule active status', () async {
        // Arrange
        final schedule = createTestSchedule();
        await dataSource.create(schedule);

        // Act
        await dataSource.updateActiveStatus(schedule.id, false);

        // Assert
        final retrieved = await dataSource.getById(schedule.id);
        expect(retrieved!.isActive, false);
      });

      test('delete should remove schedule from database', () async {
        // Arrange
        final schedule = createTestSchedule();
        await dataSource.create(schedule);

        // Act
        await dataSource.delete(schedule.id);

        // Assert
        final retrieved = await dataSource.getById(schedule.id);
        expect(retrieved, isNull);
      });

      test('deleteByStudentId should remove all schedules for student', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2'));
        await dataSource.create(createTestSchedule(id: 'schedule-3', studentId: 'student-2'));

        // Act
        await dataSource.deleteByStudentId('student-1');

        // Assert
        final all = await dataSource.getAll();
        expect(all.length, 1);
        expect(all.first.id, 'schedule-3');
      });

      test('deleteAll should remove all schedules', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2'));
        await dataSource.create(createTestSchedule(id: 'schedule-3'));

        // Act
        await dataSource.deleteAll();

        // Assert
        final result = await dataSource.getAll();
        expect(result, isEmpty);
      });
    });

    group('Query Operations', () {
      test('getByStudentId should return schedules for specific student sorted by weekday and time', () async {
        // Arrange
        await dataSource.create(createTestSchedule(weekday: 3));
        await dataSource.create(createTestSchedule(id: 'schedule-2', startLocal: '10:00'));
        await dataSource.create(createTestSchedule(id: 'schedule-3', studentId: 'student-2', weekday: 2, startLocal: '12:00'));

        // Act
        final result = await dataSource.getByStudentId('student-1');

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['schedule-1', 'schedule-2']));
        // Sorted by weekday, then start time
        expect(result[0].id, 'schedule-2'); // Monday 10:00
        expect(result[1].id, 'schedule-1'); // Wednesday 14:00
      });

      test('getActive should return only active schedules', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2', isActive: false));
        await dataSource.create(createTestSchedule(id: 'schedule-3'));

        // Act
        final result = await dataSource.getActive();

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['schedule-1', 'schedule-3']));
      });

      test('getActiveByStudentId should return active schedules for specific student', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2', isActive: false));
        await dataSource.create(createTestSchedule(id: 'schedule-3', studentId: 'student-2'));

        // Act
        final result = await dataSource.getActiveByStudentId('student-1');

        // Assert
        expect(result.length, 1);
        expect(result.first.id, 'schedule-1');
      });

      test('getByWeekday should return schedules for specific weekday', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2', startLocal: '10:00'));
        await dataSource.create(createTestSchedule(id: 'schedule-3', weekday: 2));

        // Act
        final result = await dataSource.getByWeekday(1);

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['schedule-1', 'schedule-2']));
        // Sorted by start time
        expect(result[0].id, 'schedule-2'); // 10:00
        expect(result[1].id, 'schedule-1'); // 14:00
      });
    });

    group('Utility Operations', () {
      test('exists should return true when schedule exists', () async {
        // Arrange
        final schedule = createTestSchedule();
        await dataSource.create(schedule);

        // Act
        final result = await dataSource.exists(schedule.id);

        // Assert
        expect(result, true);
      });

      test('exists should return false when schedule does not exist', () async {
        // Act
        final result = await dataSource.exists('non-existent');

        // Assert
        expect(result, false);
      });

      test('count should return correct number of schedules', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2'));
        await dataSource.create(createTestSchedule(id: 'schedule-3'));

        // Act
        final result = await dataSource.count();

        // Assert
        expect(result, 3);
      });

      test('countByStudentId should return correct number of schedules for student', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2'));
        await dataSource.create(createTestSchedule(id: 'schedule-3', studentId: 'student-2'));

        // Act
        final result = await dataSource.countByStudentId('student-1');

        // Assert
        expect(result, 2);
      });
    });

    group('Stream Operations', () {
      test('watchAll should emit all schedules sorted by weekday and time', () async {
        // Arrange
        await dataSource.create(createTestSchedule(weekday: 3));
        await dataSource.create(createTestSchedule(id: 'schedule-2'));
        await dataSource.create(createTestSchedule(id: 'schedule-3', weekday: 2));

        // Act
        final stream = dataSource.watchAll();

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<RecurringSchedule>>((schedules) {
            return schedules.length == 3 &&
                schedules[0].id == 'schedule-2' && // Monday
                schedules[1].id == 'schedule-3' && // Tuesday
                schedules[2].id == 'schedule-1';   // Wednesday
          })),
        );
      });

      test('watchById should emit schedule when exists', () async {
        // Arrange
        final schedule = createTestSchedule();
        await dataSource.create(schedule);

        // Act
        final stream = dataSource.watchById(schedule.id);

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<RecurringSchedule?>((s) => s != null && s.id == schedule.id)),
        );
      });

      test('watchByStudentId should emit schedules for specific student', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2'));
        await dataSource.create(createTestSchedule(id: 'schedule-3', studentId: 'student-2'));

        // Act
        final stream = dataSource.watchByStudentId('student-1');

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<RecurringSchedule>>((schedules) {
            return schedules.length == 2 &&
                schedules.every((s) => s.studentId == 'student-1');
          })),
        );
      });

      test('watchActive should emit only active schedules', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2', isActive: false));
        await dataSource.create(createTestSchedule(id: 'schedule-3'));

        // Act
        final stream = dataSource.watchActive();

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<RecurringSchedule>>((schedules) {
            return schedules.length == 2 &&
                schedules.every((s) => s.isActive);
          })),
        );
      });

      test('watchActiveByStudentId should emit active schedules for specific student', () async {
        // Arrange
        await dataSource.create(createTestSchedule());
        await dataSource.create(createTestSchedule(id: 'schedule-2', isActive: false));
        await dataSource.create(createTestSchedule(id: 'schedule-3', studentId: 'student-2'));

        // Act
        final stream = dataSource.watchActiveByStudentId('student-1');

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<RecurringSchedule>>((schedules) {
            return schedules.length == 1 &&
                schedules.first.id == 'schedule-1' &&
                schedules.first.isActive;
          })),
        );
      });
    });
  });
}

