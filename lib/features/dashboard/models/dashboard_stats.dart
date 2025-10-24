import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';

part 'dashboard_stats.freezed.dart';

/// Dashboard statistics model
@freezed
sealed class DashboardStats with _$DashboardStats {
  const DashboardStats._();

  /// Dashboard statistics with all data
  const factory DashboardStats({
    /// Total income this month (in cents)
    required int monthIncomeCents,

    /// Total hours this month
    required double monthHours,

    /// Total unpaid amount (in cents)
    required int unpaidAmountCents,

    /// Number of unpaid sessions
    required int unpaidSessionCount,

    /// Total hours this week
    required double weekHours,

    /// Number of sessions this week
    required int weekSessionCount,

    /// Today's sessions
    required List<Session> todaySessions,

    /// Top students this month (by hours)
    required List<StudentStats> topStudents,
  }) = _DashboardStats;

  /// Get month income in dollars
  double get monthIncomeDollars => monthIncomeCents / 100.0;

  /// Get unpaid amount in dollars
  double get unpaidAmountDollars => unpaidAmountCents / 100.0;
}

/// Student statistics for dashboard
@freezed
sealed class StudentStats with _$StudentStats {
  const StudentStats._();

  /// Student statistics
  const factory StudentStats({
    /// Student data
    required Student student,

    /// Total hours this month
    required double hours,

    /// Total amount this month (in cents)
    required int amountCents,

    /// Progress (0.0 to 1.0) relative to top student
    required double progress,
  }) = _StudentStats;

  /// Get amount in dollars
  double get amountDollars => amountCents / 100.0;
}
