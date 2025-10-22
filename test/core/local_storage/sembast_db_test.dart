import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tutor_zone/core/local_storage/sembast_db.dart';

void main() {
  group('Sembast Database Smoke Tests', () {
    late Database testDb;

    setUp(() async {
      // Use in-memory database for testing
      testDb = await databaseFactoryMemory.openDatabase('test.db');
    });

    tearDown(() async {
      await testDb.close();
    });

    test('should initialize schema version on first boot', () async {
      // Initialize schema
      await _initializeSchemaForTest(testDb);

      // Verify schema state was created
      final schemaRecord = await schemaStateStore.record('current').get(testDb);
      
      expect(schemaRecord, isNotNull);
      expect(schemaRecord!['version'], equals(1));
      expect(schemaRecord['migratedAt'], isNotNull);
    });

    test('should have all required stores defined', () {
      // Verify all store references are accessible
      expect(schemaStateStore.name, equals('schema_state'));
      expect(studentsStore.name, equals('students'));
      expect(sessionsStore.name, equals('sessions'));
      expect(balanceChangesStore.name, equals('balance_changes'));
      expect(recurringSchedulesStore.name, equals('recurring_schedules'));
      expect(appPrefsStore.name, equals('app_prefs'));
    });

    test('should write and read from students store', () async {
      final studentData = {
        'id': 'test-uuid-123',
        'name': 'Test Student',
        'email': 'test@example.com',
        'phone': null,
        'hourlyRateCents': 4000,
        'balanceCents': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Write to store
      await studentsStore.record('test-uuid-123').put(testDb, studentData);

      // Read from store
      final retrieved = await studentsStore.record('test-uuid-123').get(testDb);

      expect(retrieved, isNotNull);
      expect(retrieved!['name'], equals('Test Student'));
      expect(retrieved['hourlyRateCents'], equals(4000));
    });

    test('should write and read from sessions store', () async {
      final sessionData = {
        'id': 'session-uuid-456',
        'studentId': 'test-uuid-123',
        'start': DateTime.now().toIso8601String(),
        'end': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'attendance': 'completed',
        'rateSnapshotCents': 4000,
        'amountCents': 4000,
        'payStatus': 'unpaid',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await sessionsStore.record('session-uuid-456').put(testDb, sessionData);
      final retrieved = await sessionsStore.record('session-uuid-456').get(testDb);

      expect(retrieved, isNotNull);
      expect(retrieved!['studentId'], equals('test-uuid-123'));
      expect(retrieved['attendance'], equals('completed'));
      expect(retrieved['payStatus'], equals('unpaid'));
    });

    test('should write and read from balance_changes store', () async {
      final balanceChangeData = {
        'id': 'balance-uuid-789',
        'studentId': 'test-uuid-123',
        'amountCents': 8000,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await balanceChangesStore.record('balance-uuid-789').put(testDb, balanceChangeData);
      final retrieved = await balanceChangesStore.record('balance-uuid-789').get(testDb);

      expect(retrieved, isNotNull);
      expect(retrieved!['amountCents'], equals(8000));
    });

    test('should write and read from recurring_schedules store', () async {
      final scheduleData = {
        'id': 'schedule-uuid-101',
        'studentId': 'test-uuid-123',
        'weekday': 1, // Monday
        'startLocal': '14:00',
        'endLocal': '15:00',
        'rateSnapshotCents': 4000,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await recurringSchedulesStore.record('schedule-uuid-101').put(testDb, scheduleData);
      final retrieved = await recurringSchedulesStore.record('schedule-uuid-101').get(testDb);

      expect(retrieved, isNotNull);
      expect(retrieved!['weekday'], equals(1));
      expect(retrieved['isActive'], equals(true));
    });

    test('should write and read from app_prefs store', () async {
      final prefData = {
        'key': 'app_access_mode',
        'value': 'local',
      };

      await appPrefsStore.record('app_access_mode').put(testDb, prefData);
      final retrieved = await appPrefsStore.record('app_access_mode').get(testDb);

      expect(retrieved, isNotNull);
      expect(retrieved!['value'], equals('local'));
    });

    test('should support transactions for atomic updates', () async {
      final studentId = 'student-txn-test';
      final sessionId = 'session-txn-test';

      // Create student and session in a transaction
      await testDb.transaction((txn) async {
        await studentsStore.record(studentId).put(txn, {
          'id': studentId,
          'name': 'Transaction Test',
          'hourlyRateCents': 5000,
          'balanceCents': 5000,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        await sessionsStore.record(sessionId).put(txn, {
          'id': sessionId,
          'studentId': studentId,
          'start': DateTime.now().toIso8601String(),
          'end': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'attendance': 'completed',
          'rateSnapshotCents': 5000,
          'amountCents': 5000,
          'payStatus': 'paid',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Update student balance in same transaction
        await studentsStore.record(studentId).update(txn, {
          'balanceCents': 0,
        });
      });

      // Verify both operations succeeded
      final student = await studentsStore.record(studentId).get(testDb);
      final session = await sessionsStore.record(sessionId).get(testDb);

      expect(student!['balanceCents'], equals(0));
      expect(session!['payStatus'], equals('paid'));
    });

    test('should support querying with filters', () async {
      // Add multiple students
      await studentsStore.record('student-1').put(testDb, {
        'id': 'student-1',
        'name': 'Alice',
        'hourlyRateCents': 4000,
        'balanceCents': -8000,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await studentsStore.record('student-2').put(testDb, {
        'id': 'student-2',
        'name': 'Bob',
        'hourlyRateCents': 5000,
        'balanceCents': 10000,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Query students with negative balance
      final finder = Finder(
        filter: Filter.lessThan('balanceCents', 0),
      );

      final records = await studentsStore.find(testDb, finder: finder);

      expect(records.length, equals(1));
      expect(records.first.value['name'], equals('Alice'));
    });
  });
}

/// Helper to initialize schema for testing (mirrors production logic).
Future<void> _initializeSchemaForTest(Database db) async {
  final schemaRecord = await schemaStateStore.record('current').get(db);
  
  if (schemaRecord == null) {
    await schemaStateStore.record('current').put(db, {
      'version': 1,
      'migratedAt': DateTime.now().toIso8601String(),
    });
  }
}

