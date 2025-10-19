import 'package:flutter/material.dart';

/// Student profile screen showing details and session history
class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({
    required this.studentId,
    super.key,
  });

  /// Route name for navigation
  static const String routeName = 'student-profile';

  /// Student ID from route parameters
  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          if (isWide) {
            return const _WideLayout();
          } else {
            return const _NarrowLayout();
          }
        },
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: [_StudentInfoCard(), SizedBox(height: 16), _NotesCard()])),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _SessionHistoryCard()),
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(children: [_StudentInfoCard(), SizedBox(height: 16), _SessionHistoryCard(), SizedBox(height: 16), _NotesCard()]),
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  const _StudentInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Text('SARAH CHEN', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const _InfoRow(icon: Icons.email, text: 'sarah@email.com'),
            const SizedBox(height: 8),
            const _InfoRow(icon: Icons.phone, text: '(555) 123-4567'),
            const SizedBox(height: 8),
            const _InfoRow(icon: Icons.book, text: 'Mathematics'),
            const SizedBox(height: 8),
            const _InfoRow(icon: Icons.attach_money, text: '\$40/hour'),
            const SizedBox(height: 8),
            const _InfoRow(icon: Icons.calendar_today, text: 'Started: Sept 1, 2024'),
            const SizedBox(height: 8),
            const _InfoRow(icon: Icons.schedule, text: 'Total Hours: 24'),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURRENT BALANCE', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer)),
                      const SizedBox(height: 4),
                      Text(
                        '-\$80',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                      Text('(2 hours owed)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer)),
                    ],
                  ),
                  FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.payment), label: const Text('Record Payment')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  const _SessionHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SESSION HISTORY', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.note_add), label: const Text('Add Session')),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.timer), label: const Text('Timer')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SessionHistoryList(),
          ],
        ),
      ),
    );
  }
}

class _SessionHistoryList extends StatelessWidget {
  const _SessionHistoryList();

  @override
  Widget build(BuildContext context) {
    final sessions = [
      _SessionData(date: 'Oct 15', time: '2:00-3:30pm', duration: '1.5 hrs', amount: 60, isPaid: false, notes: 'Worked on quadratic equations'),
      _SessionData(date: 'Oct 13', time: '2:00-3:00pm', duration: '1.0 hr', amount: 40, isPaid: true, notes: 'Algebra review and homework help'),
      _SessionData(date: 'Oct 10', time: '2:00-3:30pm', duration: '1.5 hrs', amount: 60, isPaid: true, notes: 'Introduction to trigonometry'),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(session.date, style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      Text(session.time),
                      const SizedBox(width: 16),
                      Text(session.duration),
                      const SizedBox(width: 16),
                      Text('\$${session.amount}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      avatar: Icon(
                        session.isPaid ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: session.isPaid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                      ),
                      label: Text(session.isPaid ? 'Paid' : 'Unpaid'),
                      backgroundColor: session.isPaid ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.errorContainer,
                    ),
                    if (!session.isPaid) ...[const SizedBox(width: 8), TextButton(onPressed: () {}, child: const Text('Pay'))],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Notes: ${session.notes}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        );
      },
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NOTES & GOALS', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Preparing for SAT Math. Focus areas:\n'
              '• Algebra II concepts\n'
              '• Trigonometry basics\n'
              '• Word problems\n'
              'Target score: 700+',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionData {
  final String date;
  final String time;
  final String duration;
  final int amount;
  final bool isPaid;
  final String notes;

  _SessionData({required this.date, required this.time, required this.duration, required this.amount, required this.isPaid, required this.notes});
}
