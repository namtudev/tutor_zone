import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/sessions/domain/session_generation_service.dart';
import 'package:tutor_zone/features/sessions/models/data/recurring_schedule.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/recurring_schedule_local_data_source.dart';
import 'package:uuid/uuid.dart';

part 'recurring_schedule_controller.g.dart';

const _uuid = Uuid();

/// Stream provider for all recurring schedules
@riverpod
Stream<List<RecurringSchedule>> recurringSchedulesStream(Ref ref) {
  final dataSource = ref.watch(recurringScheduleLocalDataSourceProvider);
  return dataSource.watchAll();
}

/// Stream provider for recurring schedules by student ID
@riverpod
Stream<List<RecurringSchedule>> recurringSchedulesByStudentStream(
  Ref ref,
  String studentId,
) {
  final dataSource = ref.watch(recurringScheduleLocalDataSourceProvider);
  return dataSource.watchByStudentId(studentId);
}

/// Stream provider for active recurring schedules
@riverpod
Stream<List<RecurringSchedule>> activeRecurringSchedulesStream(Ref ref) {
  final dataSource = ref.watch(recurringScheduleLocalDataSourceProvider);
  return dataSource.watchActive();
}

/// Stream provider for active recurring schedules by student ID
@riverpod
Stream<List<RecurringSchedule>> activeRecurringSchedulesByStudentStream(
  Ref ref,
  String studentId,
) {
  final dataSource = ref.watch(recurringScheduleLocalDataSourceProvider);
  return dataSource.watchActiveByStudentId(studentId);
}

/// Controller for recurring schedule operations.
///
/// Provides methods for creating, updating, and deleting recurring schedules,
/// as well as triggering session generation.
@riverpod
class RecurringScheduleController extends _$RecurringScheduleController {
  @override
  void build() {
    // No state needed - this is a stateless controller
  }

  /// Create a new recurring schedule
  Future<void> createSchedule({
    required String studentId,
    required int weekday,
    required String startLocal,
    required String endLocal,
    required int rateSnapshotCents,
    bool isActive = true,
  }) async {
    try {
      logInfo('Creating recurring schedule for student $studentId');

      final dataSource = ref.read(recurringScheduleLocalDataSourceProvider);

      final schedule = RecurringSchedule.create(
        id: _uuid.v4(),
        studentId: studentId,
        weekday: weekday,
        startLocal: startLocal,
        endLocal: endLocal,
        rateSnapshotCents: rateSnapshotCents,
        isActive: isActive,
      );

      await dataSource.create(schedule);

      logInfo('Created recurring schedule: ${schedule.id}');

      // Optionally generate sessions for this new schedule
      if (isActive) {
        await generateSessionsForSchedule(schedule.id);
      }
    } catch (e, stack) {
      logError('Failed to create recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Update an existing recurring schedule
  Future<void> updateSchedule({
    required String scheduleId,
    int? weekday,
    String? startLocal,
    String? endLocal,
    int? rateSnapshotCents,
    bool? isActive,
  }) async {
    try {
      logInfo('Updating recurring schedule: $scheduleId');

      final dataSource = ref.read(recurringScheduleLocalDataSourceProvider);

      // Get existing schedule
      final existing = await dataSource.getById(scheduleId);
      if (existing == null) {
        throw Exception('Recurring schedule not found: $scheduleId');
      }

      // Update schedule
      final updated = existing.update(
        weekday: weekday,
        startLocal: startLocal,
        endLocal: endLocal,
        rateSnapshotCents: rateSnapshotCents,
        isActive: isActive,
      );

      await dataSource.update(updated);

      logInfo('Updated recurring schedule: $scheduleId');

      // If schedule was modified (time/weekday changed), regenerate sessions
      if (weekday != null || startLocal != null || endLocal != null) {
        await regenerateSessionsForSchedule(scheduleId);
      }
    } catch (e, stack) {
      logError('Failed to update recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Delete a recurring schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      logInfo('Deleting recurring schedule: $scheduleId');

      final dataSource = ref.read(recurringScheduleLocalDataSourceProvider);
      final generationService = ref.read(sessionGenerationServiceProvider);

      // Delete future generated sessions first
      await generationService.deleteFutureSessionsForSchedule(scheduleId);

      // Delete the schedule
      await dataSource.delete(scheduleId);

      logInfo('Deleted recurring schedule: $scheduleId');
    } catch (e, stack) {
      logError('Failed to delete recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Activate a recurring schedule
  Future<void> activateSchedule(String scheduleId) async {
    try {
      logInfo('Activating recurring schedule: $scheduleId');

      final dataSource = ref.read(recurringScheduleLocalDataSourceProvider);

      // Get existing schedule
      final existing = await dataSource.getById(scheduleId);
      if (existing == null) {
        throw Exception('Recurring schedule not found: $scheduleId');
      }

      // Activate
      final activated = existing.activate();
      await dataSource.update(activated);

      logInfo('Activated recurring schedule: $scheduleId');

      // Generate sessions for the activated schedule
      await generateSessionsForSchedule(scheduleId);
    } catch (e, stack) {
      logError('Failed to activate recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Deactivate a recurring schedule
  Future<void> deactivateSchedule(String scheduleId) async {
    try {
      logInfo('Deactivating recurring schedule: $scheduleId');

      final dataSource = ref.read(recurringScheduleLocalDataSourceProvider);
      final generationService = ref.read(sessionGenerationServiceProvider);

      // Get existing schedule
      final existing = await dataSource.getById(scheduleId);
      if (existing == null) {
        throw Exception('Recurring schedule not found: $scheduleId');
      }

      // Delete future generated sessions
      await generationService.deleteFutureSessionsForSchedule(scheduleId);

      // Deactivate
      final deactivated = existing.deactivate();
      await dataSource.update(deactivated);

      logInfo('Deactivated recurring schedule: $scheduleId');
    } catch (e, stack) {
      logError('Failed to deactivate recurring schedule', e, stack);
      rethrow;
    }
  }

  /// Generate sessions for a specific recurring schedule
  ///
  /// This is a manual trigger for development/testing.
  Future<int> generateSessionsForSchedule(
    String scheduleId, {
    int weeksAhead = 8,
  }) async {
    try {
      logInfo('Manually generating sessions for schedule: $scheduleId');

      final dataSource = ref.read(recurringScheduleLocalDataSourceProvider);
      final generationService = ref.read(sessionGenerationServiceProvider);

      // Get the schedule
      final schedule = await dataSource.getById(scheduleId);
      if (schedule == null) {
        throw Exception('Recurring schedule not found: $scheduleId');
      }

      // Generate sessions
      final count = await generationService.generateSessionsForSchedule(
        schedule,
        weeksAhead: weeksAhead,
      );

      logInfo('Generated $count sessions for schedule $scheduleId');
      return count;
    } catch (e, stack) {
      logError('Failed to generate sessions for schedule', e, stack);
      rethrow;
    }
  }

  /// Generate sessions for a specific student
  ///
  /// This is a manual trigger for development/testing.
  Future<int> generateSessionsForStudent(
    String studentId, {
    int weeksAhead = 8,
  }) async {
    try {
      logInfo('Manually generating sessions for student: $studentId');

      final generationService = ref.read(sessionGenerationServiceProvider);

      final count = await generationService.generateSessionsForStudent(
        studentId,
        weeksAhead: weeksAhead,
      );

      logInfo('Generated $count sessions for student $studentId');
      return count;
    } catch (e, stack) {
      logError('Failed to generate sessions for student', e, stack);
      rethrow;
    }
  }

  /// Generate sessions for all active recurring schedules
  ///
  /// This is a manual trigger for development/testing.
  /// Useful for bulk generation or testing the generation engine.
  Future<int> generateAllSessions({int weeksAhead = 8}) async {
    try {
      logInfo('Manually generating sessions for all active schedules');

      final generationService = ref.read(sessionGenerationServiceProvider);

      final count = await generationService.generateAllSessions(
        weeksAhead: weeksAhead,
      );

      logInfo('Generated $count sessions from all active schedules');
      return count;
    } catch (e, stack) {
      logError('Failed to generate all sessions', e, stack);
      rethrow;
    }
  }

  /// Regenerate sessions for a schedule (delete future + generate new)
  ///
  /// Useful when a schedule's time or weekday changes.
  Future<int> regenerateSessionsForSchedule(
    String scheduleId, {
    int weeksAhead = 8,
  }) async {
    try {
      logInfo('Regenerating sessions for schedule: $scheduleId');

      final generationService = ref.read(sessionGenerationServiceProvider);

      // Delete future sessions
      final deleted = await generationService.deleteFutureSessionsForSchedule(scheduleId);
      logInfo('Deleted $deleted future sessions');

      // Generate new sessions
      final generated = await generateSessionsForSchedule(
        scheduleId,
        weeksAhead: weeksAhead,
      );

      logInfo('Regenerated sessions for schedule $scheduleId: deleted $deleted, generated $generated');
      return generated;
    } catch (e, stack) {
      logError('Failed to regenerate sessions for schedule', e, stack);
      rethrow;
    }
  }
}

