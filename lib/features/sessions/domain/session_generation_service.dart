import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/domain/allocation_service.dart';
import 'package:tutor_zone/features/sessions/models/data/recurring_schedule.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/recurring_schedule_local_data_source.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/session_local_data_source.dart';
import 'package:uuid/uuid.dart';

part 'session_generation_service.g.dart';

/// Service for generating sessions from recurring schedules.
@riverpod
SessionGenerationService sessionGenerationService(Ref ref) {
  final sessionDataSource = ref.watch(sessionLocalDataSourceProvider);
  final scheduleDataSource = ref.watch(recurringScheduleLocalDataSourceProvider);
  final allocationService = ref.watch(allocationServiceProvider);
  return SessionGenerationService(sessionDataSource, scheduleDataSource, allocationService);
}

/// Provides session generation logic from recurring schedules.
///
/// Generates sessions 8 weeks ahead based on active recurring schedules.
/// Implements idempotency to prevent duplicate session generation.
class SessionGenerationService {
  final SessionLocalDataSource _sessionDataSource;
  final RecurringScheduleLocalDataSource _scheduleDataSource;
  final AllocationService _allocationService;
  final _uuid = const Uuid();

  /// Creates a new [SessionGenerationService] with the given dependencies.
  SessionGenerationService(
    this._sessionDataSource,
    this._scheduleDataSource,
    this._allocationService,
  );

  /// Generate sessions for all active recurring schedules.
  ///
  /// Generates sessions 8 weeks ahead from [startDate] (defaults to now).
  /// Skips sessions that already exist at the same date/time for the student.
  ///
  /// Returns the number of sessions generated.
  Future<int> generateAllSessions({
    DateTime? startDate,
    int weeksAhead = 8,
  }) async {
    try {
      final start = startDate ?? DateTime.now();
      logInfo('Generating sessions for all active schedules from $start, $weeksAhead weeks ahead');

      // Get all active recurring schedules
      final schedules = await _scheduleDataSource.getActive();

      if (schedules.isEmpty) {
        logInfo('No active recurring schedules found');
        return 0;
      }

      var totalGenerated = 0;

      for (final schedule in schedules) {
        final generated = await generateSessionsForSchedule(
          schedule,
          startDate: start,
          weeksAhead: weeksAhead,
        );
        totalGenerated += generated;
      }

      logInfo('Generated $totalGenerated sessions from ${schedules.length} schedules');
      return totalGenerated;
    } catch (e, stack) {
      logError('Failed to generate all sessions', e, stack);
      rethrow;
    }
  }

  /// Generate sessions for a specific recurring schedule.
  ///
  /// Generates sessions 8 weeks ahead from [startDate] (defaults to now).
  /// Skips sessions that already exist at the same date/time for the student.
  ///
  /// Returns the number of sessions generated.
  Future<int> generateSessionsForSchedule(
    RecurringSchedule schedule, {
    DateTime? startDate,
    int weeksAhead = 8,
  }) async {
    try {
      if (!schedule.isActive) {
        logWarning('Skipping inactive schedule: ${schedule.id}');
        return 0;
      }

      final start = startDate ?? DateTime.now();
      logInfo('Generating sessions for schedule ${schedule.id} (${schedule.weekdayName} ${schedule.formattedTimeRange})');

      // Generate session dates using the schedule's helper method
      final sessionDates = schedule.generateSessionDates(
        weeksAhead: weeksAhead,
        from: start,
      );

      if (sessionDates.isEmpty) {
        logInfo('No future sessions to generate for schedule ${schedule.id}');
        return 0;
      }

      // Get existing sessions for this student to check for duplicates
      final existingSessions = await _sessionDataSource.getByStudentId(schedule.studentId);

      var generatedCount = 0;

      for (final sessionStart in sessionDates) {
        // Calculate session end time
        final duration = schedule.durationHours;
        final sessionEnd = sessionStart.add(Duration(minutes: (duration * 60).round()));

        // Check if session already exists at this date/time
        final isDuplicate = _checkForDuplicate(
          existingSessions,
          sessionStart,
          sessionEnd,
        );

        if (isDuplicate) {
          logDebug('Skipping duplicate session at $sessionStart for student ${schedule.studentId}');
          continue;
        }

        // Create new session
        final session = Session.create(
          id: _uuid.v4(),
          studentId: schedule.studentId,
          start: sessionStart,
          end: sessionEnd,
          rateSnapshotCents: schedule.rateSnapshotCents,
          // attendance defaults to completed
          // payStatus defaults to unpaid
        );

        await _sessionDataSource.create(session);
        generatedCount++;
      }

      logInfo('Generated $generatedCount sessions for schedule ${schedule.id}');

      // Trigger allocation check if sessions were generated
      if (generatedCount > 0) {
        final allocatedCount = await _allocationService.runAllocationAfterGeneration(schedule.studentId);
        if (allocatedCount > 0) {
          logInfo('Auto-allocated $allocatedCount sessions for student ${schedule.studentId}');
        }
      }

      return generatedCount;
    } catch (e, stack) {
      logError('Failed to generate sessions for schedule ${schedule.id}', e, stack);
      rethrow;
    }
  }

  /// Generate sessions for a specific student.
  ///
  /// Generates sessions for all active recurring schedules of the student.
  ///
  /// Returns the number of sessions generated.
  Future<int> generateSessionsForStudent(
    String studentId, {
    DateTime? startDate,
    int weeksAhead = 8,
  }) async {
    try {
      final start = startDate ?? DateTime.now();
      logInfo('Generating sessions for student $studentId from $start, $weeksAhead weeks ahead');

      // Get active recurring schedules for this student
      final schedules = await _scheduleDataSource.getActiveByStudentId(studentId);

      if (schedules.isEmpty) {
        logInfo('No active recurring schedules found for student $studentId');
        return 0;
      }

      var totalGenerated = 0;

      for (final schedule in schedules) {
        final generated = await generateSessionsForSchedule(
          schedule,
          startDate: start,
          weeksAhead: weeksAhead,
        );
        totalGenerated += generated;
      }

      logInfo('Generated $totalGenerated sessions for student $studentId from ${schedules.length} schedules');
      return totalGenerated;
    } catch (e, stack) {
      logError('Failed to generate sessions for student $studentId', e, stack);
      rethrow;
    }
  }

  /// Check if a session already exists at the given date/time for the student.
  ///
  /// Returns true if a duplicate is found (same start and end time).
  bool _checkForDuplicate(
    List<Session> existingSessions,
    DateTime start,
    DateTime end,
  ) {
    return existingSessions.any((session) {
      final sessionStart = DateTime.parse(session.start);
      final sessionEnd = DateTime.parse(session.end);

      // Check if start and end times match exactly
      return sessionStart.isAtSameMomentAs(start) && sessionEnd.isAtSameMomentAs(end);
    });
  }

  /// Delete future generated sessions for a specific recurring schedule.
  ///
  /// Useful when a schedule is modified or deleted.
  /// Only deletes sessions that haven't been completed yet.
  ///
  /// Returns the number of sessions deleted.
  Future<int> deleteFutureSessionsForSchedule(String scheduleId) async {
    try {
      logInfo('Deleting future sessions for schedule $scheduleId');

      // Get the schedule to find the student
      final schedule = await _scheduleDataSource.getById(scheduleId);
      if (schedule == null) {
        logWarning('Schedule not found: $scheduleId');
        return 0;
      }

      // Get all sessions for this student
      final sessions = await _sessionDataSource.getByStudentId(schedule.studentId);

      // Filter for future sessions that match this schedule's weekday and time
      final now = DateTime.now();
      var deletedCount = 0;

      for (final session in sessions) {
        final sessionStart = DateTime.parse(session.start);

        // Only delete future sessions
        if (sessionStart.isBefore(now)) continue;

        // Check if this session matches the schedule's weekday and time
        if (_sessionMatchesSchedule(session, schedule)) {
          await _sessionDataSource.delete(session.id);
          deletedCount++;
        }
      }

      logInfo('Deleted $deletedCount future sessions for schedule $scheduleId');
      return deletedCount;
    } catch (e, stack) {
      logError('Failed to delete future sessions for schedule $scheduleId', e, stack);
      rethrow;
    }
  }

  /// Check if a session matches a recurring schedule's pattern.
  bool _sessionMatchesSchedule(Session session, RecurringSchedule schedule) {
    final sessionStart = DateTime.parse(session.start);
    final sessionEnd = DateTime.parse(session.end);

    // Check weekday
    if (sessionStart.weekday != schedule.weekday) return false;

    // Check start time (HH:mm)
    final sessionStartTime = '${sessionStart.hour.toString().padLeft(2, '0')}:${sessionStart.minute.toString().padLeft(2, '0')}';
    if (sessionStartTime != schedule.startLocal) return false;

    // Check end time (HH:mm)
    final sessionEndTime = '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}';
    if (sessionEndTime != schedule.endLocal) return false;

    return true;
  }
}

