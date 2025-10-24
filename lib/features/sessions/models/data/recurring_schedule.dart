import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_schedule.freezed.dart';
part 'recurring_schedule.g.dart';

/// RecurringSchedule model representing a weekly recurring tutoring session.
///
/// Stores recurring schedule information including student reference,
/// weekday, time range, rate snapshot, and active status.
///
/// Schema: SCHEMA.md - recurring_schedules store
@freezed
abstract class RecurringSchedule with _$RecurringSchedule {
  const RecurringSchedule._();

  /// Creates a new [RecurringSchedule] instance.
  const factory RecurringSchedule({
    /// Unique identifier (UUID)
    required String id,

    /// Foreign key to students.id
    required String studentId,

    /// Weekday (1 = Monday, 7 = Sunday)
    required int weekday,

    /// Start time in local format (HH:mm)
    required String startLocal,

    /// End time in local format (HH:mm)
    required String endLocal,

    /// Hourly rate snapshot in cents (copied from student at creation)
    required int rateSnapshotCents,

    /// Whether this schedule is active
    required bool isActive,

    /// Timestamp when schedule was created (ISO8601)
    required String createdAt,

    /// Timestamp when schedule was last updated (ISO8601)
    required String updatedAt,
  }) = _RecurringSchedule;

  /// Create RecurringSchedule from JSON
  factory RecurringSchedule.fromJson(Map<String, dynamic> json) => _$RecurringScheduleFromJson(json);

  /// Get rate in dollars (for display)
  double get rateSnapshotDollars => rateSnapshotCents / 100.0;

  /// Get weekday name
  String get weekdayName {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (weekday < 1 || weekday > 7) return 'Invalid';
    return weekdays[weekday - 1];
  }

  /// Get short weekday name (3 letters)
  String get weekdayShort {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekday < 1 || weekday > 7) return 'N/A';
    return weekdays[weekday - 1];
  }

  /// Get formatted time range for display (e.g., "2:00 PM - 3:30 PM")
  String get formattedTimeRange {
    return '${_formatLocalTime(startLocal)} - ${_formatLocalTime(endLocal)}';
  }

  /// Get duration in hours
  double get durationHours {
    final start = _parseLocalTime(startLocal);
    final end = _parseLocalTime(endLocal);
    return end.difference(start).inMinutes / 60.0;
  }

  /// Calculate estimated session amount in cents
  int get estimatedAmountCents {
    return (durationHours * rateSnapshotCents).round();
  }

  /// Get estimated amount in dollars
  double get estimatedAmountDollars => estimatedAmountCents / 100.0;

  /// Format local time string (HH:mm) to display format (h:mm AM/PM)
  String _formatLocalTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return timeStr;

    final hour24 = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final hour12 = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteStr $period';
  }

  /// Parse local time string (HH:mm) to DateTime (using today's date)
  DateTime _parseLocalTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return DateTime.now();

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Create a new recurring schedule with current timestamps
  factory RecurringSchedule.create({
    required String id,
    required String studentId,
    required int weekday,
    required String startLocal,
    required String endLocal,
    required int rateSnapshotCents,
    bool isActive = true,
  }) {
    assert(weekday >= 1 && weekday <= 7, 'Weekday must be between 1 (Mon) and 7 (Sun)');
    assert(_isValidTimeFormat(startLocal), 'startLocal must be in HH:mm format');
    assert(_isValidTimeFormat(endLocal), 'endLocal must be in HH:mm format');

    final now = DateTime.now().toIso8601String();

    return RecurringSchedule(
      id: id,
      studentId: studentId,
      weekday: weekday,
      startLocal: startLocal,
      endLocal: endLocal,
      rateSnapshotCents: rateSnapshotCents,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update recurring schedule with new timestamp
  RecurringSchedule update({
    int? weekday,
    String? startLocal,
    String? endLocal,
    int? rateSnapshotCents,
    bool? isActive,
  }) {
    if (weekday != null) {
      assert(weekday >= 1 && weekday <= 7, 'Weekday must be between 1 (Mon) and 7 (Sun)');
    }
    if (startLocal != null) {
      assert(_isValidTimeFormat(startLocal), 'startLocal must be in HH:mm format');
    }
    if (endLocal != null) {
      assert(_isValidTimeFormat(endLocal), 'endLocal must be in HH:mm format');
    }

    return copyWith(
      weekday: weekday ?? this.weekday,
      startLocal: startLocal ?? this.startLocal,
      endLocal: endLocal ?? this.endLocal,
      rateSnapshotCents: rateSnapshotCents ?? this.rateSnapshotCents,
      isActive: isActive ?? this.isActive,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Activate this schedule
  RecurringSchedule activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Deactivate this schedule
  RecurringSchedule deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Validate time format (HH:mm)
  static bool _isValidTimeFormat(String timeStr) {
    final regex = RegExp(r'^([0-1][0-9]|2[0-3]):([0-5][0-9])$');
    return regex.hasMatch(timeStr);
  }

  /// Get the next occurrence of this schedule from a given date
  DateTime getNextOccurrence({DateTime? from}) {
    final startDate = from ?? DateTime.now();
    final targetWeekday = weekday; // 1 = Monday, 7 = Sunday

    // Convert to DateTime weekday (1 = Monday, 7 = Sunday) - same as our schema
    final currentWeekday = startDate.weekday;

    // Calculate days until next occurrence
    var daysUntilNext = targetWeekday - currentWeekday;
    if (daysUntilNext <= 0) {
      daysUntilNext += 7; // Move to next week
    }

    final nextDate = startDate.add(Duration(days: daysUntilNext));

    // Parse start time
    final timeParts = startLocal.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(nextDate.year, nextDate.month, nextDate.day, hour, minute);
  }

  /// Generate session dates for the next N weeks
  List<DateTime> generateSessionDates({int weeksAhead = 8, DateTime? from}) {
    final startDate = from ?? DateTime.now();
    final sessions = <DateTime>[];

    for (var week = 0; week < weeksAhead; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      final nextOccurrence = getNextOccurrence(from: weekStart);

      // Only add if it's in the future
      if (nextOccurrence.isAfter(startDate)) {
        sessions.add(nextOccurrence);
      }
    }

    return sessions;
  }
}
