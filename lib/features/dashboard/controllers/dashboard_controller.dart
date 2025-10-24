import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/dashboard/models/dashboard_stats.dart';
import 'package:tutor_zone/features/sessions/models/repositories/session_repository.dart';
import 'package:tutor_zone/features/students/models/repositories/student_repository.dart';

part 'dashboard_controller.g.dart';

/// Provider for dashboard statistics
@riverpod
Stream<DashboardStats> dashboardStats(Ref ref) async* {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final studentRepo = ref.watch(studentRepositoryProvider);

  // Watch all sessions and students
  final sessionsStream = sessionRepo.watchAll();
  final studentsStream = studentRepo.watchAll();

  await for (final sessions in sessionsStream) {
    final students = await studentsStream.first;

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = startOfToday.add(const Duration(days: 1));

      // Filter sessions for this month (completed and paid/unpaid)
      final monthSessions = sessions.where((s) {
        final sessionDate = DateTime.parse(s.start);
        return sessionDate.isAfter(startOfMonth) && sessionDate.isBefore(now) && s.isCompleted;
      }).toList();

      // Calculate month income (only paid sessions)
      final monthIncomeCents = monthSessions.where((s) => s.isPaid).fold<int>(0, (sum, s) => sum + s.amountCents);

      // Calculate month hours
      final monthHours = monthSessions.fold<double>(
        0.0,
        (sum, s) => sum + s.durationHours,
      );

      // Calculate unpaid sessions
      final unpaidSessions = sessions.where((s) => s.isUnpaid && s.isCompleted).toList();
      final unpaidAmountCents = unpaidSessions.fold<int>(
        0,
        (sum, s) => sum + s.amountCents,
      );

      // Filter sessions for this week
      final weekSessions = sessions.where((s) {
        final sessionDate = DateTime.parse(s.start);
        return sessionDate.isAfter(startOfWeek) && sessionDate.isBefore(now) && s.isCompleted;
      }).toList();

      final weekHours = weekSessions.fold<double>(
        0.0,
        (sum, s) => sum + s.durationHours,
      );

      // Filter today's sessions
      final todaySessions = sessions.where((s) {
        final sessionDate = DateTime.parse(s.start);
        return sessionDate.isAfter(startOfToday) && sessionDate.isBefore(endOfToday);
      }).toList();

      // Calculate top students this month
      final studentStatsMap = <String, _StudentStatsData>{};

      for (final session in monthSessions) {
        final existing = studentStatsMap[session.studentId];
        if (existing == null) {
          studentStatsMap[session.studentId] = _StudentStatsData(
            studentId: session.studentId,
            hours: session.durationHours,
            amountCents: session.amountCents,
          );
        } else {
          studentStatsMap[session.studentId] = _StudentStatsData(
            studentId: session.studentId,
            hours: existing.hours + session.durationHours,
            amountCents: existing.amountCents + session.amountCents,
          );
        }
      }

      // Sort by hours and take top 3
      final sortedStats = studentStatsMap.values.toList()..sort((a, b) => b.hours.compareTo(a.hours));

      final topStats = sortedStats.take(3).toList();
      final maxHours = topStats.isNotEmpty ? topStats.first.hours : 1.0;

      // Build StudentStats with student data
      final topStudents = <StudentStats>[];
      for (final stat in topStats) {
        final student = students.firstWhere(
          (s) => s.id == stat.studentId,
          orElse: () => throw Exception('Student not found: ${stat.studentId}'),
        );

        topStudents.add(
          StudentStats(
            student: student,
            hours: stat.hours,
            amountCents: stat.amountCents,
            progress: stat.hours / maxHours,
          ),
        );
      }

      yield DashboardStats(
        monthIncomeCents: monthIncomeCents,
        monthHours: monthHours,
        unpaidAmountCents: unpaidAmountCents,
        unpaidSessionCount: unpaidSessions.length,
        weekHours: weekHours,
        weekSessionCount: weekSessions.length,
        todaySessions: todaySessions,
        topStudents: topStudents,
      );
    } catch (e, stack) {
      logError('Failed to calculate dashboard stats', e, stack);
      rethrow;
    }
  }
}

/// Internal class for aggregating student statistics
class _StudentStatsData {
  final String studentId;
  final double hours;
  final int amountCents;

  _StudentStatsData({
    required this.studentId,
    required this.hours,
    required this.amountCents,
  });
}
