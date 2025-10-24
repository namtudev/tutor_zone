import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/reports/models/monthly_report.dart';
import 'package:tutor_zone/features/sessions/models/repositories/session_repository.dart';
import 'package:tutor_zone/features/students/models/repositories/student_repository.dart';

part 'monthly_report_controller.g.dart';

/// Provider for monthly report (current month)
@riverpod
Stream<MonthlyReport> currentMonthReport(Ref ref) async* {
  final now = DateTime.now();
  yield* monthReport(ref, year: now.year, month: now.month);
}

/// Provider for monthly report for a specific month
@riverpod
Stream<MonthlyReport> monthReport(
  Ref ref, {
  required int year,
  required int month,
}) async* {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final studentRepo = ref.watch(studentRepositoryProvider);

  // Watch all sessions and students
  final sessionsStream = sessionRepo.watchAll();
  final studentsStream = studentRepo.watchAll();

  await for (final sessions in sessionsStream) {
    final students = await studentsStream.first;

    try {
      final startOfMonth = DateTime(year, month);
      final endOfMonth = DateTime(year, month + 1);

      // Filter sessions for this month (completed only)
      final monthSessions = sessions.where((s) {
        final sessionDate = DateTime.parse(s.start);
        return sessionDate.isAfter(startOfMonth) && sessionDate.isBefore(endOfMonth) && s.isCompleted;
      }).toList();

      // Calculate total hours
      final totalHours = monthSessions.fold<double>(
        0.0,
        (sum, s) => sum + s.durationHours,
      );

      // Calculate paid income
      final paidSessions = monthSessions.where((s) => s.isPaid).toList();
      final paidIncomeCents = paidSessions.fold<int>(
        0,
        (sum, s) => sum + s.amountCents,
      );

      // Calculate unpaid amount
      final unpaidSessions = monthSessions.where((s) => s.isUnpaid).toList();
      final unpaidAmountCents = unpaidSessions.fold<int>(
        0,
        (sum, s) => sum + s.amountCents,
      );

      // Calculate average hourly rate
      final totalAmountCents = monthSessions.fold<int>(
        0,
        (sum, s) => sum + s.amountCents,
      );
      final avgHourlyRateCents = totalHours > 0 ? (totalAmountCents / totalHours).round() : 0;

      // Calculate top students
      final studentStatsMap = <String, _StudentStatsData>{};

      for (final session in monthSessions) {
        final existing = studentStatsMap[session.studentId];
        if (existing == null) {
          studentStatsMap[session.studentId] = _StudentStatsData(
            studentId: session.studentId,
            hours: session.durationHours,
            sessionCount: 1,
            amountCents: session.amountCents,
          );
        } else {
          studentStatsMap[session.studentId] = _StudentStatsData(
            studentId: session.studentId,
            hours: existing.hours + session.durationHours,
            sessionCount: existing.sessionCount + 1,
            amountCents: existing.amountCents + session.amountCents,
          );
        }
      }

      // Sort by hours and take top 5
      final sortedStats = studentStatsMap.values.toList()..sort((a, b) => b.hours.compareTo(a.hours));

      final topStats = sortedStats.take(5).toList();

      // Build MonthlyStudentStats with student data
      final topStudents = <MonthlyStudentStats>[];
      for (final stat in topStats) {
        final student = students.firstWhere(
          (s) => s.id == stat.studentId,
          orElse: () => throw Exception('Student not found: ${stat.studentId}'),
        );

        topStudents.add(
          MonthlyStudentStats(
            student: student,
            hours: stat.hours,
            sessionCount: stat.sessionCount,
            amountCents: stat.amountCents,
          ),
        );
      }

      yield MonthlyReport(
        yearMonth: '$year-${month.toString().padLeft(2, '0')}',
        totalHours: totalHours,
        totalSessions: monthSessions.length,
        paidIncomeCents: paidIncomeCents,
        paidSessionCount: paidSessions.length,
        unpaidAmountCents: unpaidAmountCents,
        unpaidSessionCount: unpaidSessions.length,
        avgHourlyRateCents: avgHourlyRateCents,
        topStudents: topStudents,
      );
    } catch (e, stack) {
      logError('Failed to calculate monthly report', e, stack);
      rethrow;
    }
  }
}

/// Internal class for aggregating student statistics
class _StudentStatsData {
  final String studentId;
  final double hours;
  final int sessionCount;
  final int amountCents;

  _StudentStatsData({
    required this.studentId,
    required this.hours,
    required this.sessionCount,
    required this.amountCents,
  });
}
