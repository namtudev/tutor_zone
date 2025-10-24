import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';

part 'monthly_report.freezed.dart';

/// Monthly report statistics
@freezed
sealed class MonthlyReport with _$MonthlyReport {
  const MonthlyReport._();

  /// Monthly report with all statistics
  const factory MonthlyReport({
    /// Year and month (e.g., "2024-10")
    required String yearMonth,

    /// Total hours for the month
    required double totalHours,

    /// Total number of sessions
    required int totalSessions,

    /// Paid income (in cents)
    required int paidIncomeCents,

    /// Number of paid sessions
    required int paidSessionCount,

    /// Unpaid amount (in cents)
    required int unpaidAmountCents,

    /// Number of unpaid sessions
    required int unpaidSessionCount,

    /// Average hourly rate (in cents)
    required int avgHourlyRateCents,

    /// Top students by hours
    required List<MonthlyStudentStats> topStudents,
  }) = _MonthlyReport;

  /// Get paid income in dollars
  double get paidIncomeDollars => paidIncomeCents / 100.0;

  /// Get unpaid amount in dollars
  double get unpaidAmountDollars => unpaidAmountCents / 100.0;

  /// Get average hourly rate in dollars
  double get avgHourlyRateDollars => avgHourlyRateCents / 100.0;

  /// Get total income (paid + unpaid) in dollars
  double get totalIncomeDollars => (paidIncomeCents + unpaidAmountCents) / 100.0;
}

/// Student statistics for monthly report
@freezed
sealed class MonthlyStudentStats with _$MonthlyStudentStats {
  const MonthlyStudentStats._();

  /// Monthly student statistics
  const factory MonthlyStudentStats({
    /// Student data
    required Student student,

    /// Total hours this month
    required double hours,

    /// Total sessions this month
    required int sessionCount,

    /// Total amount this month (in cents)
    required int amountCents,
  }) = _MonthlyStudentStats;

  /// Get amount in dollars
  double get amountDollars => amountCents / 100.0;
}
