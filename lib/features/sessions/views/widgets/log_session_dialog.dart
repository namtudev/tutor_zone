import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutor_zone/core/common_widgets/app_snackbar.dart';
import 'package:tutor_zone/features/sessions/controllers/sessions_controller.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/students/controllers/students_controller.dart';

/// Dialog for logging a new session
class LogSessionDialog extends ConsumerStatefulWidget {
  /// Pre-select student if provided
  final String? studentId;

  /// Creates a new [LogSessionDialog] with optional student ID
  const LogSessionDialog({super.key, this.studentId});

  @override
  ConsumerState<LogSessionDialog> createState() => _LogSessionDialogState();
}

class _LogSessionDialogState extends ConsumerState<LogSessionDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedStudentId;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  PaymentStatus _payStatus = PaymentStatus.unpaid;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
    _selectedDate = DateTime.now();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LOG SESSION', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student
                      Text('Student', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildStudentDropdown(),

                      const SizedBox(height: 32),

                      // Date & Time
                      Text('Date & Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTimePicker('Start Time', _startTime, (time) => setState(() => _startTime = time))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTimePicker('End Time', _endTime, (time) => setState(() => _endTime = time))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDurationInfo(),

                      const SizedBox(height: 32),

                      // Session Details
                      Text('Session Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Payment Status', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<PaymentStatus>(
                              segments: const [
                                ButtonSegment(value: PaymentStatus.paid, label: Text('Paid'), icon: Icon(Icons.check_circle_outline)),
                                ButtonSegment(value: PaymentStatus.unpaid, label: Text('Unpaid'), icon: Icon(Icons.schedule)),
                              ],
                              selected: {_payStatus},
                              onSelectionChanged: (value) => setState(() => _payStatus = value.first),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSessionCost(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _saveSession, child: const Text('Save Session')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDropdown() {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return const Text('No students available. Please add a student first.');
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedStudentId,
          decoration: InputDecoration(
            labelText: 'Select Student',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          items: students.map((student) {
            return DropdownMenuItem(
              value: student.id,
              child: Text(student.name),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedStudentId = value),
          validator: (value) => value == null ? 'Please select a student' : null,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading students: $error'),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Date',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: _selectedDate == null ? '' : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      validator: (value) => _selectedDate == null ? 'Please select a date' : null,
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, Function(TimeOfDay) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        suffixIcon: const Icon(Icons.access_time),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: time == null ? '' : time.format(context),
      ),
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          onChanged(pickedTime);
        }
      },
      validator: (value) => time == null ? 'Please select $label' : null,
    );
  }

  Widget _buildDurationInfo() {
    if (_startTime == null || _endTime == null) {
      return const SizedBox.shrink();
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    final durationMinutes = endMinutes - startMinutes;

    if (durationMinutes <= 0) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Text(
              'End time must be after start time',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final hours = durationMinutes / 60.0;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Text(
            'Duration: ${hours.toStringAsFixed(1)} hours',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCost() {
    if (_selectedStudentId == null || _startTime == null || _endTime == null) {
      return const SizedBox.shrink();
    }

    final studentsAsync = ref.watch(studentsStreamProvider);
    return studentsAsync.when(
      data: (students) {
        final student = students.where((s) => s.id == _selectedStudentId).firstOrNull;
        if (student == null) return const SizedBox.shrink();

        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
        final durationMinutes = endMinutes - startMinutes;

        if (durationMinutes <= 0) return const SizedBox.shrink();

        final hours = durationMinutes / 60.0;
        final cost = hours * student.hourlyRateDollars;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session Cost:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                '\$${cost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null || _selectedDate == null || _startTime == null || _endTime == null) return;

    // Validate end time is after start time
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      context.showErrorSnackBar('End time must be after start time');
      return;
    }

    // Get student to get rate snapshot
    final studentsAsync = ref.read(studentsStreamProvider);
    final students = studentsAsync.value;
    if (students == null) return;

    final student = students.where((s) => s.id == _selectedStudentId).firstOrNull;
    if (student == null) return;

    // Build DateTime objects
    final start = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final end = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    // Call controller method (updates state internally)
    final controller = ref.read(sessionsControllerProvider.notifier);
    controller.createSession(
      studentId: _selectedStudentId!,
      start: start,
      end: end,
      rateSnapshotCents: student.hourlyRateCents,
      payStatus: _payStatus,
    );

    // Watch state to check result
    final result = ref.watch(sessionsControllerProvider);

    if (!mounted) return;

    if (result.hasError) {
      context.showErrorSnackBar('Error: ${result.error}');
    } else {
      Navigator.of(context).pop();
      context.showSuccessSnackBar('Session logged successfully');
    }
  }
}
