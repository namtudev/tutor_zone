import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tutor_zone/features/reports/controllers/monthly_report_controller.dart';
import 'package:tutor_zone/features/reports/models/monthly_report.dart';

/// Monthly summary screen with charts and analytics
class MonthlySummaryScreen extends ConsumerWidget {
  /// Creates a new [MonthlySummaryScreen]
  const MonthlySummaryScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'reports';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(currentMonthReportProvider);

    return reportAsync.when(
      data: (report) {
        final now = DateTime.now();
        final monthName = DateFormat.yMMMM().format(now).toUpperCase();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                      Text(monthName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                    ],
                  ),
                  FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.file_download), label: const Text('Export')),
                ],
              ),
              const SizedBox(height: 24),

              // Summary cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 1200
                      ? 4
                      : constraints.maxWidth >= 600
                      ? 2
                      : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth >= 600 ? 2.5 : 3.5,
                    children: [
                      _StatCard(
                        title: 'TOTAL HOURS',
                        value: '${report.totalHours.toStringAsFixed(1)} hrs',
                        subtitle: '${report.totalSessions} sessions',
                        icon: Icons.schedule,
                      ),
                      _StatCard(
                        title: 'PAID INCOME',
                        value: '\$${report.paidIncomeDollars.toStringAsFixed(0)}',
                        subtitle: '${report.paidSessionCount} sessions',
                        icon: Icons.attach_money,
                      ),
                      _StatCard(
                        title: 'UNPAID',
                        value: '\$${report.unpaidAmountDollars.toStringAsFixed(0)}',
                        subtitle: '${report.unpaidSessionCount} sessions',
                        icon: Icons.warning_amber_outlined,
                        isWarning: true,
                      ),
                      _StatCard(
                        title: 'AVG RATE',
                        value: '\$${report.avgHourlyRateDollars.toStringAsFixed(0)}/hr',
                        subtitle: 'average',
                        icon: Icons.trending_up,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Top students
              Text('TOP STUDENTS BY HOURS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _TopStudentsTable(students: report.topStudents),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error loading report: $error'),
          ],
        ),
      ),
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

class _TopStudentsTable extends StatelessWidget {
  final List<MonthlyStudentStats> students;

  const _TopStudentsTable({required this.students});

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          return Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Rank')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Hours')),
                DataColumn(label: Text('Sessions')),
                DataColumn(label: Text('Amount')),
              ],
              rows: students.asMap().entries.map(
                (entry) {
                  final rank = entry.key + 1;
                  final student = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('$rank')),
                      DataCell(Text(student.student.name)),
                      DataCell(Text('${student.hours.toStringAsFixed(1)} hrs')),
                      DataCell(Text('${student.sessionCount}')),
                      DataCell(Text('\$${student.amountDollars.toStringAsFixed(0)}')),
                    ],
                  );
                },
              ).toList(),
            ),
          );
        } else {
          return Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rank = index + 1;
                final student = students[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('$rank')),
                  title: Text(student.student.name),
                  subtitle: Text('${student.hours.toStringAsFixed(1)} hrs • ${student.sessionCount} sessions'),
                  trailing: Text('\$${student.amountDollars.toStringAsFixed(0)}'),
                );
              },
            ),
          );
        }
      },
    );
  }
}
