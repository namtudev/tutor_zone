import 'package:flutter/material.dart';

/// Monthly summary screen with charts and analytics
class MonthlySummaryScreen extends StatelessWidget {
  const MonthlySummaryScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'reports';

  @override
  Widget build(BuildContext context) {
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
                  Text('OCTOBER 2024', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                children: const [
                  _StatCard(title: 'TOTAL HOURS', value: '68 hrs', subtitle: '42 sessions', icon: Icons.schedule),
                  _StatCard(title: 'PAID INCOME', value: '\$2,420', subtitle: '34 sessions', icon: Icons.attach_money),
                  _StatCard(title: 'UNPAID', value: '\$320', subtitle: '8 sessions', icon: Icons.warning_amber_outlined, isWarning: true),
                  _StatCard(title: 'STUDENTS', value: '12', subtitle: 'active', icon: Icons.people),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Income by week chart
          Text('INCOME BY WEEK', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          const _IncomeChart(),

          const SizedBox(height: 32),

          // Top students
          Text('TOP STUDENTS BY HOURS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          const _TopStudentsTable(),

          const SizedBox(height: 32),

          // Subject breakdown
          Text('SUBJECT BREAKDOWN', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          const _SubjectBreakdown(),
        ],
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

class _IncomeChart extends StatelessWidget {
  const _IncomeChart();

  @override
  Widget build(BuildContext context) {
    final weekData = [
      _WeekData(week: 'Week 1', amount: 700),
      _WeekData(week: 'Week 2', amount: 650),
      _WeekData(week: 'Week 3', amount: 550),
      _WeekData(week: 'Week 4', amount: 520),
    ];

    const maxAmount = 800;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weekData.map((data) {
                  final heightPercent = data.amount / maxAmount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('\$${data.amount}', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Container(
                            height: 200 * heightPercent,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekData.map((data) => Text(data.week, style: Theme.of(context).textTheme.labelSmall)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStudentsTable extends StatelessWidget {
  const _TopStudentsTable();

  @override
  Widget build(BuildContext context) {
    final students = [
      _StudentSummary(rank: 1, name: 'Sarah Chen', hours: 16, amount: 640, unpaid: 80),
      _StudentSummary(rank: 2, name: 'Mike Johnson', hours: 14, amount: 700, unpaid: 0),
      _StudentSummary(rank: 3, name: 'Alex Kumar', hours: 12, amount: 720, unpaid: 120),
      _StudentSummary(rank: 4, name: 'Emma Davis', hours: 10, amount: 400, unpaid: 40),
      _StudentSummary(rank: 5, name: 'James Wilson', hours: 8, amount: 320, unpaid: 0),
    ];

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
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: students
                  .map(
                    (student) => DataRow(
                      cells: [
                        DataCell(Text('${student.rank}')),
                        DataCell(Text(student.name)),
                        DataCell(Text('${student.hours} hrs')),
                        DataCell(Text('\$${student.amount}')),
                        DataCell(
                          Text(
                            student.unpaid > 0 ? '\$${student.unpaid} unpaid' : 'All paid',
                            style: TextStyle(color: student.unpaid > 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
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
                final student = students[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${student.rank}')),
                  title: Text(student.name),
                  subtitle: Text('${student.hours} hrs • \$${student.amount}'),
                  trailing: Text(
                    student.unpaid > 0 ? '\$${student.unpaid} unpaid' : 'All paid',
                    style: TextStyle(color: student.unpaid > 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class _SubjectBreakdown extends StatelessWidget {
  const _SubjectBreakdown();

  @override
  Widget build(BuildContext context) {
    final subjects = [
      _SubjectData(name: 'Mathematics', percentage: 35),
      _SubjectData(name: 'Physics', percentage: 25),
      _SubjectData(name: 'Computer Sci', percentage: 20),
      _SubjectData(name: 'Chemistry', percentage: 20),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: subjects.map((subject) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${subject.percentage}%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: subject.percentage / 100, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _WeekData {
  final String week;
  final int amount;

  _WeekData({required this.week, required this.amount});
}

class _StudentSummary {
  final int rank;
  final String name;
  final int hours;
  final int amount;
  final int unpaid;

  _StudentSummary({required this.rank, required this.name, required this.hours, required this.amount, required this.unpaid});
}

class _SubjectData {
  final String name;
  final int percentage;

  _SubjectData({required this.name, required this.percentage});
}
