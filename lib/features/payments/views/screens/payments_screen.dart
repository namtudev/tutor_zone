import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tutor_zone/features/payments/views/widgets/record_payment_dialog.dart';
import 'package:tutor_zone/features/sessions/controllers/sessions_controller.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/students/controllers/students_controller.dart';

/// Payments and balances screen showing unpaid sessions and student balances
class PaymentsScreen extends ConsumerWidget {
  /// Creates a new [PaymentsScreen]
  const PaymentsScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'payments';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unpaidSessionsAsync = ref.watch(unpaidSessionsStreamProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUMMARY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),

          // Summary cards with live data
          unpaidSessionsAsync.when(
            data: (unpaidSessions) => studentsAsync.when(
              data: (students) {
                // Calculate totals
                final totalOwed = unpaidSessions.fold<int>(0, (sum, session) => sum + session.amountCents);
                final totalPrepaid = students.where((s) => s.balanceCents > 0).fold<int>(0, (sum, s) => sum + s.balanceCents);
                final netBalance = totalPrepaid - totalOwed;
                final studentsWithDebt = students.where((s) => s.balanceCents < 0).length;
                final studentsWithCredit = students.where((s) => s.balanceCents > 0).length;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 800 ? 3 : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: constraints.maxWidth >= 800 ? 2.5 : 3.5,
                      children: [
                        _SummaryCard(
                          title: 'TOTAL OWED',
                          value: '\$${(totalOwed / 100).toStringAsFixed(2)}',
                          subtitle: '${unpaidSessions.length} sessions',
                          icon: Icons.payment,
                          isError: true,
                        ),
                        _SummaryCard(
                          title: 'PREPAID CREDIT',
                          value: '\$${(totalPrepaid / 100).toStringAsFixed(2)}',
                          subtitle: '$studentsWithCredit student${studentsWithCredit != 1 ? 's' : ''}',
                          icon: Icons.account_balance_wallet,
                        ),
                        _SummaryCard(
                          title: 'NET BALANCE',
                          value: '${netBalance < 0 ? '-' : '+'}\$${(netBalance.abs() / 100).toStringAsFixed(2)}',
                          subtitle: '$studentsWithDebt student${studentsWithDebt != 1 ? 's' : ''} owe',
                          icon: Icons.analytics,
                          isError: netBalance < 0,
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error loading students: $error')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error loading sessions: $error')),
          ),

          const SizedBox(height: 24),
          Text('UNPAID BY MONTH', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          const _UnpaidByMonthSummary(),
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

class _UnpaidSessionsList extends ConsumerWidget {
  const _UnpaidSessionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unpaidSessionsAsync = ref.watch(unpaidSessionsStreamProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);

    return unpaidSessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('No unpaid sessions', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('All sessions are paid up!', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        }

        return studentsAsync.when(
          data: (students) {
            // Create a map of student IDs to names for quick lookup
            final studentMap = {for (final s in students) s.id: s.name};

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
                      rows: sessions.map((session) {
                        final studentName = studentMap[session.studentId] ?? 'Unknown';
                        final sessionDate = DateTime.parse(session.start);
                        final daysAgo = DateTime.now().difference(sessionDate).inDays;
                        final dateStr = DateFormat('MMM dd').format(sessionDate);

                        return DataRow(
                          cells: [
                            DataCell(Checkbox(value: false, onChanged: (value) {})),
                            DataCell(Text(studentName)),
                            DataCell(Text(dateStr)),
                            DataCell(Text('${session.durationHours.toStringAsFixed(1)} hrs')),
                            DataCell(Text('\$${session.amountDollars.toStringAsFixed(2)}')),
                            DataCell(Text('$daysAgo days')),
                          ],
                        );
                      }).toList(),
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
                        final studentName = studentMap[session.studentId] ?? 'Unknown';
                        final sessionDate = DateTime.parse(session.start);
                        final daysAgo = DateTime.now().difference(sessionDate).inDays;
                        final dateStr = DateFormat('MMM dd').format(sessionDate);

                        return CheckboxListTile(
                          value: false,
                          onChanged: (value) {},
                          title: Text(studentName),
                          subtitle: Text('$dateStr • ${session.durationHours.toStringAsFixed(1)} hrs • \$${session.amountDollars.toStringAsFixed(2)}'),
                          secondary: Text('${daysAgo}d'),
                        );
                      },
                    ),
                  );
                }
              },
            );
          },
          loading: () => const Card(child: Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))),
          error: (error, stack) => Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $error'))),
        );
      },
      loading: () => const Card(child: Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))),
      error: (error, stack) => Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $error'))),
    );
  }
}

class _StudentBalancesList extends ConsumerWidget {
  const _StudentBalancesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final unpaidSessionsAsync = ref.watch(unpaidSessionsStreamProvider);

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('No students yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Add students to track balances', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        }

        return unpaidSessionsAsync.when(
          data: (unpaidSessions) {
            // Calculate owed amount per student
            final owedByStudent = <String, int>{};
            for (final session in unpaidSessions) {
              owedByStudent[session.studentId] = (owedByStudent[session.studentId] ?? 0) + session.amountCents;
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                if (isWide) {
                  return Card(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student')),
                        DataColumn(label: Text('Owed')),
                        DataColumn(label: Text('Balance')),
                        DataColumn(label: Text('Net')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: students.map((student) {
                        final owed = owedByStudent[student.id] ?? 0;
                        final balance = student.balanceCents;
                        final net = balance - owed;

                        return DataRow(
                          cells: [
                            DataCell(Text(student.name)),
                            DataCell(Text('\$${(owed / 100).toStringAsFixed(2)}')),
                            DataCell(Text('\$${student.balanceDollars.toStringAsFixed(2)}')),
                            DataCell(
                              Text(
                                '${net > 0 ? "+" : ""}\$${(net.abs() / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: net < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              FilledButton.tonal(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => RecordPaymentDialog(
                                      studentId: student.id,
                                    ),
                                  );
                                },
                                child: Text(net < 0 ? 'Collect' : 'View'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
                        final owed = owedByStudent[student.id] ?? 0;
                        final balance = student.balanceCents;
                        final net = balance - owed;

                        return ListTile(
                          title: Text(student.name),
                          subtitle: Text('Owed: \$${(owed / 100).toStringAsFixed(2)} • Balance: \$${student.balanceDollars.toStringAsFixed(2)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${net > 0 ? "+" : ""}\$${(net.abs() / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: net < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => RecordPaymentDialog(
                                      studentId: student.id,
                                    ),
                                  );
                                },
                                child: Text(net < 0 ? 'Collect' : 'View'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            );
          },
          loading: () => const Card(child: Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))),
          error: (error, stack) => Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $error'))),
        );
      },
      loading: () => const Card(child: Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))),
      error: (error, stack) => Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $error'))),
    );
  }
}

/// Widget showing unpaid sessions grouped by month
class _UnpaidByMonthSummary extends ConsumerWidget {
  const _UnpaidByMonthSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unpaidSessionsAsync = ref.watch(unpaidSessionsStreamProvider);

    return unpaidSessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No unpaid sessions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          );
        }

        // Group sessions by month
        final sessionsByMonth = <String, List<Session>>{};
        final now = DateTime.now();

        for (final session in sessions) {
          final sessionDate = DateTime.parse(session.start);
          final monthKey = DateFormat('yyyy-MM').format(sessionDate);
          sessionsByMonth.putIfAbsent(monthKey, () => []).add(session);
        }

        // Sort months in descending order (most recent first)
        final sortedMonths = sessionsByMonth.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        // Calculate total until now
        final totalUntilNow = sessions.fold<int>(
          0,
          (sum, session) => sum + session.amountCents,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total until now
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total Until Now',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${(totalUntilNow / 100).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Monthly breakdown
                ...sortedMonths.map((monthKey) {
                  final monthSessions = sessionsByMonth[monthKey]!;
                  final monthTotal = monthSessions.fold<int>(
                    0,
                    (sum, session) => sum + session.amountCents,
                  );
                  final monthDate = DateTime.parse('$monthKey-01');
                  final monthLabel = DateFormat('MMMM yyyy').format(monthDate);

                  // Check if this is the current month
                  final isCurrentMonth = monthKey == DateFormat('yyyy-MM').format(now);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCurrentMonth ? Icons.today : Icons.calendar_month,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              monthLabel,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                                  ),
                            ),
                            if (isCurrentMonth) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Current',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${monthSessions.length} session${monthSessions.length != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '\$${(monthTotal / 100).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
