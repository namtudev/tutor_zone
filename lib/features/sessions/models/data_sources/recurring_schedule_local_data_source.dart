import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';

import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/core/local_storage/sembast_db.dart';
import 'package:tutor_zone/features/sessions/models/data/recurring_schedule.dart';

part 'recurring_schedule_local_data_source.g.dart';

/// Local data source for RecurringSchedule CRUD operations using Sembast.
@riverpod
RecurringScheduleLocalDataSource recurringScheduleLocalDataSource(Ref ref) {
  final db = ref.watch(sembastDatabaseProvider).requireValue;
  return RecurringScheduleLocalDataSource(db);
}

/// Provides CRUD operations for recurring schedules in Sembast database.
class RecurringScheduleLocalDataSource {
  final Database _db;

  /// Creates a new [RecurringScheduleLocalDataSource] with the given database.
  RecurringScheduleLocalDataSource(this._db);

  /// Create a new recurring schedule
  Future<RecurringSchedule> create(RecurringSchedule schedule) async {
    try {
      logInfo('Creating recurring schedule: ${schedule.id} for student ${schedule.studentId}');
      await recurringSchedulesStore.record(schedule.id).put(_db, schedule.toJson());
      return schedule;
    } catch (e, stack) {
      logError('Failed to create recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Get recurring schedule by ID
  Future<RecurringSchedule?> getById(String id) async {
    try {
      final json = await recurringSchedulesStore.record(id).get(_db);
      if (json == null) return null;
      return RecurringSchedule.fromJson(json);
    } catch (e, stack) {
      logError('Failed to get recurring schedule by ID: $id', e, stack);
      rethrow;
    }
  }

  /// Get all recurring schedules
  Future<List<RecurringSchedule>> getAll() async {
    try {
      final records = await recurringSchedulesStore.find(_db);
      return records.map((record) => RecurringSchedule.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get all recurring schedules', e, stack);
      rethrow;
    }
  }

  /// Get recurring schedules by student ID (sorted by weekday, then start time)
  Future<List<RecurringSchedule>> getByStudentId(String studentId) async {
    try {
      final finder = Finder(
        filter: Filter.equals('studentId', studentId),
        sortOrders: [
          SortOrder('weekday'),
          SortOrder('startLocal'),
        ],
      );
      final records = await recurringSchedulesStore.find(_db, finder: finder);
      return records.map((record) => RecurringSchedule.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get recurring schedules for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Get active recurring schedules
  Future<List<RecurringSchedule>> getActive() async {
    try {
      final finder = Finder(
        filter: Filter.equals('isActive', true),
        sortOrders: [
          SortOrder('weekday'),
          SortOrder('startLocal'),
        ],
      );
      final records = await recurringSchedulesStore.find(_db, finder: finder);
      return records.map((record) => RecurringSchedule.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get active recurring schedules', e, stack);
      rethrow;
    }
  }

  /// Get active recurring schedules for a specific student
  Future<List<RecurringSchedule>> getActiveByStudentId(String studentId) async {
    try {
      final finder = Finder(
        filter: Filter.and([
          Filter.equals('studentId', studentId),
          Filter.equals('isActive', true),
        ]),
        sortOrders: [
          SortOrder('weekday'),
          SortOrder('startLocal'),
        ],
      );
      final records = await recurringSchedulesStore.find(_db, finder: finder);
      return records.map((record) => RecurringSchedule.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get active recurring schedules for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Get recurring schedules by weekday
  Future<List<RecurringSchedule>> getByWeekday(int weekday) async {
    try {
      final finder = Finder(
        filter: Filter.equals('weekday', weekday),
        sortOrders: [SortOrder('startLocal')],
      );
      final records = await recurringSchedulesStore.find(_db, finder: finder);
      return records.map((record) => RecurringSchedule.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get recurring schedules for weekday: $weekday', e, stack);
      rethrow;
    }
  }

  /// Update an existing recurring schedule
  Future<RecurringSchedule> update(RecurringSchedule schedule) async {
    try {
      logInfo('Updating recurring schedule: ${schedule.id}');

      // Verify schedule exists
      final exists = await recurringSchedulesStore.record(schedule.id).exists(_db);
      if (!exists) {
        throw Exception('Recurring schedule not found: ${schedule.id}');
      }

      await recurringSchedulesStore.record(schedule.id).put(_db, schedule.toJson());
      return schedule;
    } catch (e, stack) {
      logError('Failed to update recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Update schedule active status
  Future<void> updateActiveStatus(String scheduleId, bool isActive) async {
    try {
      logInfo('Updating active status for schedule $scheduleId: $isActive');

      await recurringSchedulesStore.record(scheduleId).update(_db, {
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      logError('Failed to update schedule active status', e, stack);
      rethrow;
    }
  }

  /// Delete a recurring schedule by ID
  Future<void> delete(String id) async {
    try {
      logInfo('Deleting recurring schedule: $id');
      await recurringSchedulesStore.record(id).delete(_db);
    } catch (e, stack) {
      logError('Failed to delete recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Delete all recurring schedules for a student (for cascade deletion)
  Future<void> deleteByStudentId(String studentId) async {
    try {
      logInfo('Deleting all recurring schedules for student: $studentId');
      final finder = Finder(filter: Filter.equals('studentId', studentId));
      await recurringSchedulesStore.delete(_db, finder: finder);
    } catch (e, stack) {
      logError('Failed to delete recurring schedules for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Check if recurring schedule exists
  Future<bool> exists(String id) async {
    try {
      return await recurringSchedulesStore.record(id).exists(_db);
    } catch (e, stack) {
      logError('Failed to check if recurring schedule exists: $id', e, stack);
      rethrow;
    }
  }

  /// Get count of all recurring schedules
  Future<int> count() async {
    try {
      return await recurringSchedulesStore.count(_db);
    } catch (e, stack) {
      logError('Failed to count recurring schedules', e, stack);
      rethrow;
    }
  }

  /// Get count of recurring schedules for a student
  Future<int> countByStudentId(String studentId) async {
    try {
      return await recurringSchedulesStore.count(_db, filter: Filter.equals('studentId', studentId));
    } catch (e, stack) {
      logError('Failed to count recurring schedules for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Stream of all recurring schedules (sorted by weekday, then start time)
  Stream<List<RecurringSchedule>> watchAll() {
    final finder = Finder(sortOrders: [SortOrder('weekday'), SortOrder('startLocal')]);
    return recurringSchedulesStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => RecurringSchedule.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of a single recurring schedule by ID
  Stream<RecurringSchedule?> watchById(String id) {
    return recurringSchedulesStore.record(id).onSnapshot(_db).map((snapshot) {
      if (snapshot == null) return null;
      return RecurringSchedule.fromJson(snapshot.value);
    });
  }

  /// Stream of recurring schedules for a specific student
  Stream<List<RecurringSchedule>> watchByStudentId(String studentId) {
    final finder = Finder(
      filter: Filter.equals('studentId', studentId),
      sortOrders: [SortOrder('weekday'), SortOrder('startLocal')],
    );
    return recurringSchedulesStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => RecurringSchedule.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of active recurring schedules
  Stream<List<RecurringSchedule>> watchActive() {
    final finder = Finder(
      filter: Filter.equals('isActive', true),
      sortOrders: [SortOrder('weekday'), SortOrder('startLocal')],
    );
    return recurringSchedulesStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => RecurringSchedule.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of active recurring schedules for a specific student
  Stream<List<RecurringSchedule>> watchActiveByStudentId(String studentId) {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('studentId', studentId),
        Filter.equals('isActive', true),
      ]),
      sortOrders: [SortOrder('weekday'), SortOrder('startLocal')],
    );
    return recurringSchedulesStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => RecurringSchedule.fromJson(snapshot.value)).toList();
    });
  }

  /// Delete all recurring schedules (for testing/QA)
  Future<void> deleteAll() async {
    try {
      logWarning('Deleting all recurring schedules');
      await recurringSchedulesStore.delete(_db);
    } catch (e, stack) {
      logError('Failed to delete all recurring schedules', e, stack);
      rethrow;
    }
  }
}
