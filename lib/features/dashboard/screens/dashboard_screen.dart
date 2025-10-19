import 'package:flutter/material.dart';

/// Dashboard screen showing overview statistics and today's sessions
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final crossAxisCount = isWide ? 3 : 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isWide ? 2.5 : 3.5,
                children: const [
                  _StatCard(title: 'THIS MONTH', value: '\$1,240', subtitle: '32 hours', icon: Icons.attach_money),
                  _StatCard(title: 'UNPAID', value: '\$320', subtitle: '8 sessions', icon: Icons.warning_amber_outlined, isWarning: true),
                  _StatCard(title: 'THIS WEEK', value: '18.5 hrs', subtitle: '12 sessions', icon: Icons.schedule),
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
              const _SessionsList(),

              const SizedBox(height: 24),

              // Top Students
              Text('TOP STUDENTS THIS MONTH', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              const _TopStudentsList(),
            ],
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

class _SessionsList extends StatelessWidget {
  const _SessionsList();

  @override
  Widget build(BuildContext context) {
    final sessions = [
      _SessionData(time: '2:00 PM', student: 'Sarah Chen', subject: 'Math', duration: '1.5 hrs', status: 'Unpaid', isUnpaid: true),
      _SessionData(time: '4:00 PM', student: 'Mike Johnson', subject: 'Physics', duration: '2.0 hrs', status: 'Paid', isUnpaid: false),
      _SessionData(time: '7:00 PM', student: 'Emma Davis', subject: 'Chemistry', duration: '1.0 hr', status: 'Scheduled', isUnpaid: false),
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sessions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(session.time, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ),
            title: Text(session.student),
            subtitle: Text('${session.subject} • ${session.duration}'),
            trailing: Chip(
              label: Text(session.status),
              backgroundColor: session.isUnpaid ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(color: session.isUnpaid ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        },
      ),
    );
  }
}

class _TopStudentsList extends StatelessWidget {
  const _TopStudentsList();

  @override
  Widget build(BuildContext context) {
    final students = [
      _StudentData(rank: 1, name: 'Sarah Chen', hours: 12, amount: 480, progress: 0.8),
      _StudentData(rank: 2, name: 'Mike Johnson', hours: 8, amount: 400, progress: 0.53),
      _StudentData(rank: 3, name: 'Emma Davis', hours: 6, amount: 240, progress: 0.4),
    ];

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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(value: student.progress, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
                const SizedBox(height: 4),
                Text('${student.hours} hrs • \$${student.amount}'),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}

class _SessionData {
  final String time;
  final String student;
  final String subject;
  final String duration;
  final String status;
  final bool isUnpaid;

  _SessionData({required this.time, required this.student, required this.subject, required this.duration, required this.status, required this.isUnpaid});
}

class _StudentData {
  final int rank;
  final String name;
  final int hours;
  final int amount;
  final double progress;

  _StudentData({required this.rank, required this.name, required this.hours, required this.amount, required this.progress});
}
