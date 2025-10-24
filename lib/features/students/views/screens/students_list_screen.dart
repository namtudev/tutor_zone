import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_zone/features/students/controllers/students_controller.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/views/widgets/add_edit_student_dialog.dart';

/// Students list screen with search, filter, and sort capabilities
class StudentsListScreen extends ConsumerStatefulWidget {
  /// Creates a new [StudentsListScreen]
  const StudentsListScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'students';

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsStreamProvider);

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
                      child: SearchBar(
                        hintText: 'Search students...',
                        leading: const Icon(Icons.search),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => _showAddStudentDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Student'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterChip(label: const Text('All'), selected: true, onSelected: (value) {}),
                    const SizedBox(width: 8),
                    FilterChip(label: const Text('Sort: A-Z'), selected: true, onSelected: (value) {}),
                  ],
                ),
              ],
            ),
          ),

          // Students list
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                // Filter students by search query
                final filteredStudents = _searchQuery.isEmpty
                    ? students
                    : students.where((s) {
                        return s.name.toLowerCase().contains(_searchQuery);
                      }).toList();

                if (filteredStudents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No students yet' : 'No students found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty ? 'Add your first student to get started' : 'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 800;
                    if (isWide) {
                      return _StudentsTable(students: filteredStudents);
                    } else {
                      return _StudentsCardList(students: filteredStudents);
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error loading students', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          studentsAsync.whenData((students) {
                final filteredCount = _searchQuery.isEmpty
                    ? students.length
                    : students.where((s) {
                        return s.name.toLowerCase().contains(_searchQuery);
                      }).length;

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                  ),
                  child: Text(
                    'Showing $filteredCount of ${students.length} students',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).value ??
              const SizedBox.shrink(),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditStudentDialog(),
    );
  }
}

/// Table view for wide screens
class _StudentsTable extends StatelessWidget {
  final List<Student> students;

  const _StudentsTable({required this.students});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Rate')),
            DataColumn(label: Text('Balance')),
            DataColumn(label: Text('Actions')),
          ],
          rows: students.map((student) {
            return DataRow(
              onSelectChanged: (_) => _navigateToProfile(context, student.id),
              cells: [
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                DataCell(Text('\$${student.hourlyRateDollars.toStringAsFixed(2)}/hr')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${student.hasNegativeBalance ? "-" : "+"}\$${student.balanceDollars.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: student.hasNegativeBalance
                              ? Theme.of(context).colorScheme.error
                              : student.hasPositiveBalance
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        student.balanceStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _navigateToProfile(context, student.id),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String studentId) {
    context.go('/students/$studentId');
  }
}

/// Card list view for mobile
class _StudentsCardList extends StatelessWidget {
  final List<Student> students;

  const _StudentsCardList({required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];

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
                Text('\$${student.hourlyRateDollars.toStringAsFixed(2)}/hr'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${student.hasNegativeBalance ? "-" : "+"}\$${student.balanceDollars.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: student.hasNegativeBalance
                            ? Theme.of(context).colorScheme.error
                            : student.hasPositiveBalance
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('(${student.balanceStatus})', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => context.go('/students/${student.id}'),
            ),
            isThreeLine: true,
            onTap: () => context.go('/students/${student.id}'),
          ),
        );
      },
    );
  }
}
