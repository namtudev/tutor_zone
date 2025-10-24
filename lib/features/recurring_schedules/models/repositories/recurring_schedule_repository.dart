import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/features/recurring_schedules/models/data/recurring_schedule.dart';
import 'package:tutor_zone/features/recurring_schedules/models/data_sources/recurring_schedule_local_data_source.dart';

part 'recurring_schedule_repository.g.dart';

/// Provider for RecurringScheduleRepository based on access mode
@riverpod
RecurringScheduleRepository recurringScheduleRepository(Ref ref) {
  // TODO: Check app access mode (local vs cloud) from settings
  // For Phase 1, always use local repository
  final localDataSource = ref.watch(recurringScheduleLocalDataSourceProvider);
  return RecurringScheduleRepositoryLocal(localDataSource);
}

/// Abstract repository interface for recurring schedule operations.
///
/// Provides a consistent API regardless of data source (local Sembast or cloud Firestore).
abstract class RecurringScheduleRepository {
  /// Create a new recurring schedule
  Future<RecurringSchedule> create(RecurringSchedule schedule);

  /// Get recurring schedule by ID
  Future<RecurringSchedule?> getById(String id);

  /// Get all recurring schedules
  Future<List<RecurringSchedule>> getAll();

  /// Get recurring schedules by student ID
  Future<List<RecurringSchedule>> getByStudentId(String studentId);

  /// Get active recurring schedules
  Future<List<RecurringSchedule>> getActive();

  /// Get active recurring schedules by student ID
  Future<List<RecurringSchedule>> getActiveByStudentId(String studentId);

  /// Get inactive recurring schedules
  Future<List<RecurringSchedule>> getInactive();

  /// Update an existing recurring schedule
  Future<RecurringSchedule> update(RecurringSchedule schedule);

  /// Delete a recurring schedule by ID
  Future<void> delete(String id);

  /// Delete all recurring schedules for a student
  Future<void> deleteByStudentId(String studentId);

  /// Check if recurring schedule exists
  Future<bool> exists(String id);

  /// Get count of all recurring schedules
  Future<int> count();

  /// Get count of recurring schedules by student ID
  Future<int> countByStudentId(String studentId);

  /// Stream of all recurring schedules (sorted by weekday, then start time)
  Stream<List<RecurringSchedule>> watchAll();

  /// Stream of a single recurring schedule by ID
  Stream<RecurringSchedule?> watchById(String id);

  /// Stream of recurring schedules by student ID
  Stream<List<RecurringSchedule>> watchByStudentId(String studentId);

  /// Stream of active recurring schedules
  Stream<List<RecurringSchedule>> watchActive();

  /// Stream of active recurring schedules by student ID
  Stream<List<RecurringSchedule>> watchActiveByStudentId(String studentId);
}

/// Local implementation using Sembast
class RecurringScheduleRepositoryLocal implements RecurringScheduleRepository {
  final RecurringScheduleLocalDataSource _dataSource;

  /// Creates a new [RecurringScheduleRepositoryLocal] with the given data source.
  RecurringScheduleRepositoryLocal(this._dataSource);

  @override
  Future<RecurringSchedule> create(RecurringSchedule schedule) => _dataSource.create(schedule);

  @override
  Future<RecurringSchedule?> getById(String id) => _dataSource.getById(id);

  @override
  Future<List<RecurringSchedule>> getAll() => _dataSource.getAll();

  @override
  Future<List<RecurringSchedule>> getByStudentId(String studentId) => _dataSource.getByStudentId(studentId);

  @override
  Future<List<RecurringSchedule>> getActive() => _dataSource.getActive();

  @override
  Future<List<RecurringSchedule>> getActiveByStudentId(String studentId) => _dataSource.getActiveByStudentId(studentId);

  @override
  Future<List<RecurringSchedule>> getInactive() => _dataSource.getInactive();

  @override
  Future<RecurringSchedule> update(RecurringSchedule schedule) => _dataSource.update(schedule);

  @override
  Future<void> delete(String id) => _dataSource.delete(id);

  @override
  Future<void> deleteByStudentId(String studentId) => _dataSource.deleteByStudentId(studentId);

  @override
  Future<bool> exists(String id) => _dataSource.exists(id);

  @override
  Future<int> count() => _dataSource.count();

  @override
  Future<int> countByStudentId(String studentId) => _dataSource.countByStudentId(studentId);

  @override
  Stream<List<RecurringSchedule>> watchAll() => _dataSource.watchAll();

  @override
  Stream<RecurringSchedule?> watchById(String id) => _dataSource.watchById(id);

  @override
  Stream<List<RecurringSchedule>> watchByStudentId(String studentId) => _dataSource.watchByStudentId(studentId);

  @override
  Stream<List<RecurringSchedule>> watchActive() => _dataSource.watchActive();

  @override
  Stream<List<RecurringSchedule>> watchActiveByStudentId(String studentId) => _dataSource.watchActiveByStudentId(studentId);
}

/// Cloud implementation using Firestore (Phase 2)
class RecurringScheduleRepositoryCloud implements RecurringScheduleRepository {
  @override
  Future<RecurringSchedule> create(RecurringSchedule schedule) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<RecurringSchedule?> getById(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<RecurringSchedule>> getAll() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<RecurringSchedule>> getByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<RecurringSchedule>> getActive() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<RecurringSchedule>> getActiveByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<RecurringSchedule>> getInactive() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<RecurringSchedule> update(RecurringSchedule schedule) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<void> deleteByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<bool> exists(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<int> count() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<int> countByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<List<RecurringSchedule>> watchAll() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<RecurringSchedule?> watchById(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<List<RecurringSchedule>> watchByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<List<RecurringSchedule>> watchActive() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<List<RecurringSchedule>> watchActiveByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }
}

