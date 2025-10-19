import 'package:flutter/material.dart';

/// Payments and balances screen showing unpaid sessions and student balances
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'payments';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUMMARY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 800 ? 3 : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth >= 800 ? 2.5 : 3.5,
                children: const [
                  _SummaryCard(title: 'TOTAL OWED', value: '\$320', subtitle: '8 sessions', icon: Icons.payment, isError: true),
                  _SummaryCard(title: 'PREPAID CREDIT', value: '\$100', subtitle: '1 student', icon: Icons.account_balance_wallet),
                  _SummaryCard(title: 'NET BALANCE', value: '-\$220', subtitle: '3 students owe', icon: Icons.analytics, isError: true),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('UNPAID SESSIONS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.check_circle_outline), label: const Text('Mark Selected as Paid')),
            ],
          ),
          const SizedBox(height: 12),
          const _UnpaidSessionsList(),
          const SizedBox(height: 24),
          Text('STUDENT BALANCES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          const _StudentBalancesList(),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isError;

  const _SummaryCard({required this.title, required this.value, required this.subtitle, required this.icon, this.isError = false});

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
                Icon(icon, size: 20, color: isError ? colorScheme.error : colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: isError ? colorScheme.error : null),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _UnpaidSessionsList extends StatelessWidget {
  const _UnpaidSessionsList();

  @override
  Widget build(BuildContext context) {
    final sessions = [
      _UnpaidSessionData(student: 'Sarah Chen', date: 'Oct 15', duration: '1.5 hrs', amount: 60, daysAgo: 3),
      _UnpaidSessionData(student: 'Sarah Chen', date: 'Oct 08', duration: '0.5 hr', amount: 20, daysAgo: 10),
      _UnpaidSessionData(student: 'Alex Kumar', date: 'Oct 10', duration: '2.0 hrs', amount: 120, daysAgo: 8),
      _UnpaidSessionData(student: 'Emma Davis', date: 'Oct 17', duration: '1.0 hr', amount: 40, daysAgo: 1),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          return Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('Student')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Duration')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Age')),
              ],
              rows: sessions
                  .map(
                    (session) => DataRow(
                      cells: [
                        DataCell(Checkbox(value: false, onChanged: (value) {})),
                        DataCell(Text(session.student)),
                        DataCell(Text(session.date)),
                        DataCell(Text(session.duration)),
                        DataCell(Text('\$${session.amount}')),
                        DataCell(Text('${session.daysAgo} days')),
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
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return CheckboxListTile(
                  value: false,
                  onChanged: (value) {},
                  title: Text(session.student),
                  subtitle: Text('${session.date} • ${session.duration} • \$${session.amount}'),
                  secondary: Text('${session.daysAgo}d'),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class _StudentBalancesList extends StatelessWidget {
  const _StudentBalancesList();

  @override
  Widget build(BuildContext context) {
    final balances = [
      _StudentBalanceData(name: 'Sarah Chen', owed: 80, prepaid: 0, netBalance: -80),
      _StudentBalanceData(name: 'Mike Johnson', owed: 0, prepaid: 100, netBalance: 100),
      _StudentBalanceData(name: 'Alex Kumar', owed: 120, prepaid: 0, netBalance: -120),
      _StudentBalanceData(name: 'Emma Davis', owed: 40, prepaid: 0, netBalance: -40),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          return Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Student')),
                DataColumn(label: Text('Owed')),
                DataColumn(label: Text('Prepaid')),
                DataColumn(label: Text('Net Balance')),
                DataColumn(label: Text('Action')),
              ],
              rows: balances
                  .map(
                    (balance) => DataRow(
                      cells: [
                        DataCell(Text(balance.name)),
                        DataCell(Text('\$${balance.owed}')),
                        DataCell(Text('\$${balance.prepaid}')),
                        DataCell(
                          Text(
                            '${balance.netBalance > 0 ? "+" : ""}\$${balance.netBalance}',
                            style: TextStyle(
                              color: balance.netBalance < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DataCell(FilledButton.tonal(onPressed: () {}, child: Text(balance.netBalance < 0 ? 'Collect' : 'View'))),
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
              itemCount: balances.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final balance = balances[index];
                return ListTile(
                  title: Text(balance.name),
                  subtitle: Text('Owed: \$${balance.owed} • Prepaid: \$${balance.prepaid}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${balance.netBalance > 0 ? "+" : ""}\$${balance.netBalance}',
                        style: TextStyle(
                          color: balance.netBalance < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(onPressed: () {}, child: Text(balance.netBalance < 0 ? 'Collect' : 'View')),
                    ],
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

class _UnpaidSessionData {
  final String student;
  final String date;
  final String duration;
  final int amount;
  final int daysAgo;

  _UnpaidSessionData({required this.student, required this.date, required this.duration, required this.amount, required this.daysAgo});
}

class _StudentBalanceData {
  final String name;
  final int owed;
  final int prepaid;
  final int netBalance;

  _StudentBalanceData({required this.name, required this.owed, required this.prepaid, required this.netBalance});
}
