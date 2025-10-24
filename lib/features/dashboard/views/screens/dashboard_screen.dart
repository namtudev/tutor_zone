import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tutor_zone/core/common_widgets/fixed_height_delegate.dart';
import 'package:tutor_zone/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tutor_zone/features/dashboard/models/dashboard_stats.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';

/// Dashboard screen showing overview statistics and today's sessions
class DashboardScreen extends ConsumerWidget {
  /// Creates a new [DashboardScreen]
  const DashboardScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final crossAxisCount = isWide ? 3 : 1;

        return statsAsync.when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    height: 150,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(
                      title: 'THIS MONTH',
                      value: '\$${stats.monthIncomeDollars.toStringAsFixed(0)}',
                      subtitle: '${stats.monthHours.toStringAsFixed(1)} hours',
                      icon: Icons.attach_money,
                    ),
                    _StatCard(
                      title: 'UNPAID',
                      value: '\$${stats.unpaidAmountDollars.toStringAsFixed(0)}',
                      subtitle: '${stats.unpaidSessionCount} sessions',
                      icon: Icons.warning_amber_outlined,
                      isWarning: true,
                    ),
                    _StatCard(
                      title: 'THIS WEEK',
                      value: '${stats.weekHours.toStringAsFixed(1)} hrs',
                      subtitle: '${stats.weekSessionCount} sessions',
                      icon: Icons.schedule,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text('QUICK ACTIONS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickActionButton(icon: Icons.person_add, label: 'Add Student', onPressed: () {}),
                    _QuickActionButton(icon: Icons.timer, label: 'Start Timer', onPressed: () {}),
                    _QuickActionButton(icon: Icons.note_add, label: 'Log Session', onPressed: () {}),
                  ],
                ),

                const SizedBox(height: 24),

                // Today's Sessions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TODAY'S SESSIONS", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
                const SizedBox(height: 12),
                _SessionsList(sessions: stats.todaySessions),

                const SizedBox(height: 24),

                // Top Students
                Text('TOP STUDENTS THIS MONTH', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                _TopStudentsList(students: stats.topStudents),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Error loading dashboard: $error'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isWarning;

  const _StatCard({required this.title, required this.value, required this.subtitle, required this.icon, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: isWarning ? colorScheme.error : colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: isWarning ? colorScheme.error : null),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(onPressed: onPressed, icon: Icon(icon), label: Text(label));
  }
}

class _SessionsList extends ConsumerWidget {
  final List<Session> sessions;

  const _SessionsList({required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.event_available, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 8),
                Text(
                  'No sessions today',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sessions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final startTime = DateTime.parse(session.start);
          final timeFormat = DateFormat.jm(); // e.g., "2:00 PM"

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                timeFormat.format(startTime),
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text('Session ${session.id.substring(0, 8)}'), // Show session ID prefix
            subtitle: Text('${session.durationHours.toStringAsFixed(1)} hrs'),
            trailing: Chip(
              label: Text(
                session.isPaid
                    ? 'Paid'
                    : session.isFuture
                    ? 'Scheduled'
                    : 'Unpaid',
              ),
              backgroundColor: session.isUnpaid && !session.isFuture
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: session.isUnpaid && !session.isFuture ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopStudentsList extends StatelessWidget {
  final List<StudentStats> students;

  const _TopStudentsList({required this.students});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 8),
                Text(
                  'No student data this month',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final studentStat = students[index];
          final rank = index + 1;

          return ListTile(
            leading: CircleAvatar(child: Text('$rank')),
            title: Text(studentStat.student.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: studentStat.progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text('${studentStat.hours.toStringAsFixed(1)} hrs • \$${studentStat.amountDollars.toStringAsFixed(0)}'),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
