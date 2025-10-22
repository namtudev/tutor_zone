import 'package:freezed_annotation/freezed_annotation.dart';
part 'session.freezed.dart';
part 'session.g.dart';

/// Attendance status for a session
enum SessionAttendance {
  @JsonValue('completed')
  completed,
  @JsonValue('skipped')
  skipped,
}

/// Payment status for a session
enum PaymentStatus {
  @JsonValue('paid')
  paid,
  @JsonValue('unpaid')
  unpaid,
}

/// Session model representing a tutoring session.
///
/// Stores session information including student reference, timing,
/// attendance status, rate snapshot, and payment status.
///
/// Schema: SCHEMA.md - sessions store
@freezed
abstract class Session with _$Session {
  const Session._();

  const factory Session({
    /// Unique identifier (UUID)
    required String id,

    /// Foreign key to students.id
    required String studentId,

    /// Session start time (ISO8601 with timezone)
    required String start,

    /// Session end time (ISO8601 with timezone)
    required String end,

    /// Attendance status
    required SessionAttendance attendance,

    /// Hourly rate snapshot in cents (copied from student at creation)
    required int rateSnapshotCents,

    /// Session amount in cents (calculated: duration × rate)
    required int amountCents,

    /// Payment status
    required PaymentStatus payStatus,

    /// Timestamp when session was created (ISO8601)
    required String createdAt,

    /// Timestamp when session was last updated (ISO8601)
    required String updatedAt,
  }) = _Session;

  /// Create Session from JSON
  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  /// Get rate in dollars (for display)
  double get rateSnapshotDollars => rateSnapshotCents / 100.0;

  /// Get amount in dollars (for display)
  double get amountDollars => amountCents / 100.0;

  /// Get session duration in hours
  double get durationHours {
    final startTime = DateTime.parse(start);
    final endTime = DateTime.parse(end);
    return endTime.difference(startTime).inMinutes / 60.0;
  }

  /// Check if session is completed
  bool get isCompleted => attendance == SessionAttendance.completed;

  /// Check if session is skipped
  bool get isSkipped => attendance == SessionAttendance.skipped;

  /// Check if session is paid
  bool get isPaid => payStatus == PaymentStatus.paid;

  /// Check if session is unpaid
  bool get isUnpaid => payStatus == PaymentStatus.unpaid;

  /// Check if session is in the future
  bool get isFuture => DateTime.parse(start).isAfter(DateTime.now());

  /// Check if session is in the past
  bool get isPast => DateTime.parse(end).isBefore(DateTime.now());

  /// Get formatted date for display (e.g., "Jan 15, 2025")
  String get formattedDate {
    final date = DateTime.parse(start);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get formatted time range for display (e.g., "2:00 PM - 3:30 PM")
  String get formattedTimeRange {
    final startTime = DateTime.parse(start);
    final endTime = DateTime.parse(end);
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Create a new session with current timestamps
  ///
  /// Automatically calculates amountCents based on duration and rate.
  factory Session.create({
    required String id,
    required String studentId,
    required DateTime start,
    required DateTime end,
    required int rateSnapshotCents,
    SessionAttendance attendance = SessionAttendance.completed,
    PaymentStatus payStatus = PaymentStatus.unpaid,
  }) {
    final now = DateTime.now().toIso8601String();
    final durationHours = end.difference(start).inMinutes / 60.0;
    final amountCents = (durationHours * rateSnapshotCents).round();

    return Session(
      id: id,
      studentId: studentId,
      start: start.toIso8601String(),
      end: end.toIso8601String(),
      attendance: attendance,
      rateSnapshotCents: rateSnapshotCents,
      amountCents: amountCents,
      payStatus: payStatus,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update session with new timestamp
  ///
  /// Recalculates amountCents if start, end, or rate changes.
  Session update({
    DateTime? start,
    DateTime? end,
    SessionAttendance? attendance,
    int? rateSnapshotCents,
    PaymentStatus? payStatus,
  }) {
    final newStart = start ?? DateTime.parse(this.start);
    final newEnd = end ?? DateTime.parse(this.end);
    final newRate = rateSnapshotCents ?? this.rateSnapshotCents;

    final durationHours = newEnd.difference(newStart).inMinutes / 60.0;
    final newAmountCents = (durationHours * newRate).round();

    return copyWith(
      start: newStart.toIso8601String(),
      end: newEnd.toIso8601String(),
      attendance: attendance ?? this.attendance,
      rateSnapshotCents: newRate,
      amountCents: newAmountCents,
      payStatus: payStatus ?? this.payStatus,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Mark session as paid
  Session markAsPaid() {
    return copyWith(
      payStatus: PaymentStatus.paid,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Mark session as unpaid
  Session markAsUnpaid() {
    return copyWith(
      payStatus: PaymentStatus.unpaid,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Mark session as completed
  Session markAsCompleted() {
    return copyWith(
      attendance: SessionAttendance.completed,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Mark session as skipped (and set amount to 0)
  Session markAsSkipped() {
    return copyWith(
      attendance: SessionAttendance.skipped,
      amountCents: 0,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
