import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_zone/core/common_widgets/app_snackbar.dart';
import 'package:tutor_zone/features/sessions/controllers/sessions_controller.dart';
import 'package:tutor_zone/features/sessions/views/widgets/log_session_dialog.dart';
import 'package:tutor_zone/features/students/controllers/students_controller.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/views/widgets/add_edit_student_dialog.dart';

/// Student profile screen showing details and session history
class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({
    required this.studentId,
    super.key,
  });

  /// Route name for navigation
  static const String routeName = 'student-profile';

  /// Student ID from route parameters
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentStreamProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: studentAsync.whenData((student) => Text(student?.name ?? 'Student Profile')).value ??
            const Text('Student Profile'),
        actions: [
          studentAsync.whenData((student) {
            if (student == null) return const SizedBox.shrink();
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, student),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref, student),
                ),
              ],
            );
          }).value ?? const SizedBox.shrink(),
        ],
      ),
      body: studentAsync.when(
        data: (student) {
          if (student == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Student not found', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/students'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Students'),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return _WideLayout(student: student);
              } else {
                return _NarrowLayout(student: student);
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
              Text('Error loading student', style: Theme.of(context).textTheme.titleMedium),
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
    );
  }

  void _showEditDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AddEditStudentDialog(student: student),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(studentsControllerProvider.notifier).deleteStudent(student.id);
      final result = ref.watch(studentsControllerProvider);
      if (!context.mounted) return;

      if (result.hasError) {
        context.showErrorSnackBar('Error deleting student: ${result.error}');
      } else {
        context.go('/students');
        context.showSuccessSnackBar('Student deleted successfully');
      }
    }
  }
}

class _WideLayout extends StatelessWidget {
  final Student student;

  const _WideLayout({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _StudentInfoCard(student: student),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _SessionHistoryCard(studentId: student.id)),
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final Student student;

  const _NarrowLayout({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _StudentInfoCard(student: student),
          const SizedBox(height: 16),
          _SessionHistoryCard(studentId: student.id),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  final Student student;

  const _StudentInfoCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final balanceColor = student.hasNegativeBalance
        ? Theme.of(context).colorScheme.errorContainer
        : student.hasPositiveBalance
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest;

    final balanceTextColor = student.hasNegativeBalance
        ? Theme.of(context).colorScheme.onErrorContainer
        : student.hasPositiveBalance
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface;

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
            Text(
              student.name.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.attach_money, text: '\$${student.hourlyRateDollars.toStringAsFixed(2)}/hour'),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today,
              text: 'Started: ${_formatDate(student.createdAt)}',
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: balanceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT BALANCE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: balanceTextColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${student.hasNegativeBalance ? "-" : student.hasPositiveBalance ? "+" : ""}\$${student.balanceDollars.abs().toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: balanceTextColor,
                            ),
                      ),
                      Text(
                        student.balanceStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: balanceTextColor),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Implement record payment dialog (Phase 1 - Task 4)
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Record Payment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return isoDate;
    }
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

class _SessionHistoryCard extends ConsumerWidget {
  final String studentId;

  const _SessionHistoryCard({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    FilledButton.tonalIcon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => LogSessionDialog(studentId: studentId),
                        );
                      },
                      icon: const Icon(Icons.note_add),
                      label: const Text('Add Session'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.timer), label: const Text('Timer')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SessionHistoryList(studentId: studentId),
          ],
        ),
      ),
    );
  }
}

class _SessionHistoryList extends ConsumerWidget {
  final String studentId;

  const _SessionHistoryList({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsByStudentStreamProvider(studentId));

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click "Add Session" to log your first session',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

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
                          Text(session.formattedDate, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 16),
                          Text(session.formattedTimeRange),
                          const SizedBox(width: 16),
                          Text('${session.durationHours.toStringAsFixed(1)} hrs'),
                          const SizedBox(width: 16),
                          Text('\$${session.amountDollars.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
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
                          backgroundColor: session.isPaid
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.errorContainer,
                        ),
                        if (!session.isPaid) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              final controller = ref.read(sessionsControllerProvider.notifier);
                              final result = await controller.markSessionAsPaid(session.id);

                              if (!context.mounted) return;

                              if (result.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${result.error}'),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Session marked as paid')),
                                );
                              }
                            },
                            child: const Text('Pay'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading sessions: $error'),
      ),
    );
  }
}
