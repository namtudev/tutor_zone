import 'package:flutter/material.dart';

/// Students list screen with search, filter, and sort capabilities
class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'students';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and filters bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SearchBar(hintText: 'Search students...', leading: const Icon(Icons.search), onChanged: (value) {}),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add), label: const Text('Add Student')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterChip(label: const Text('All'), selected: true, onSelected: (value) {}),
                    const SizedBox(width: 8),
                    FilterChip(label: const Text('Sort: A-Z'), onSelected: (value) {}),
                  ],
                ),
              ],
            ),
          ),

          // Students list
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;
                if (isWide) {
                  return const _StudentsTable();
                } else {
                  return const _StudentsCardList();
                }
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: Text(
              'Showing 4 of 4 students',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Table view for wide screens
class _StudentsTable extends StatelessWidget {
  const _StudentsTable();

  @override
  Widget build(BuildContext context) {
    final students = _getStudentsData();

    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Subject')),
            DataColumn(label: Text('Rate')),
            DataColumn(label: Text('Balance')),
            DataColumn(label: Text('Last Session')),
          ],
          rows: students.map((student) {
            final isNegative = student.balance < 0;
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(student.email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                DataCell(Text(student.subject)),
                DataCell(Text('\$${student.rate}/hr')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${isNegative ? "-" : "+"}\$${student.balance.abs()}',
                        style: TextStyle(
                          color: isNegative ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(student.balanceNote, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                DataCell(Text(student.lastSession)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Card list view for mobile
class _StudentsCardList extends StatelessWidget {
  const _StudentsCardList();

  @override
  Widget build(BuildContext context) {
    final students = _getStudentsData();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final isNegative = student.balance < 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(student.email),
                const SizedBox(height: 4),
                Text('${student.subject} • \$${student.rate}/hr'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${isNegative ? "-" : "+"}\$${student.balance.abs()}',
                      style: TextStyle(
                        color: isNegative ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('(${student.balanceNote})', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            trailing: IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

class _StudentData {
  final String name;
  final String email;
  final String subject;
  final int rate;
  final int balance;
  final String balanceNote;
  final String lastSession;

  _StudentData({
    required this.name,
    required this.email,
    required this.subject,
    required this.rate,
    required this.balance,
    required this.balanceNote,
    required this.lastSession,
  });
}

List<_StudentData> _getStudentsData() {
  return [
    _StudentData(name: 'Sarah Chen', email: 'sarah@email.com', subject: 'Math', rate: 40, balance: -80, balanceNote: '2 hrs owed', lastSession: 'Oct 15, 2024'),
    _StudentData(
      name: 'Mike Johnson',
      email: 'mike.j@email.com',
      subject: 'Physics',
      rate: 50,
      balance: 100,
      balanceNote: '2 hrs credit',
      lastSession: 'Oct 18, 2024',
    ),
    _StudentData(
      name: 'Emma Davis',
      email: 'emma.d@email.com',
      subject: 'Chemistry',
      rate: 40,
      balance: 0,
      balanceNote: 'Balanced',
      lastSession: 'Oct 17, 2024',
    ),
    _StudentData(
      name: 'Alex Kumar',
      email: 'alex.k@email.com',
      subject: 'Computer Sci',
      rate: 60,
      balance: -120,
      balanceNote: '2 hrs owed',
      lastSession: 'Oct 10, 2024',
    ),
  ];
}
