import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_zone/core/common_widgets/app_snackbar.dart';
import 'package:tutor_zone/features/students/controllers/students_controller.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';

/// Dialog for adding or editing a student
class AddEditStudentDialog extends ConsumerStatefulWidget {
  final Student? student; // null = add mode, non-null = edit mode

  const AddEditStudentDialog({super.key, this.student});

  @override
  ConsumerState<AddEditStudentDialog> createState() => _AddEditStudentDialogState();
}

class _AddEditStudentDialogState extends ConsumerState<AddEditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;

  bool get _isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _rateController = TextEditingController(
      text: widget.student != null ? widget.student!.hourlyRateDollars.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(studentsControllerProvider).isLoading;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
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
                  Text(
                    _isEdit ? 'EDIT STUDENT' : 'ADD NEW STUDENT',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  ),
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
                      // Basic Information
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name *',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 32),

                      // Rate
                      Text(
                        'Hourly Rate',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rateController,
                        decoration: InputDecoration(
                          labelText: 'Hourly Rate *',
                          prefixText: '\$ ',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          helperText: 'Enter rate in dollars (e.g., 40.00)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Hourly rate is required';
                          }
                          final rate = double.tryParse(value);
                          if (rate == null || rate <= 0) {
                            return 'Enter a valid rate greater than 0';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
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
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: isLoading ? null : _saveStudent,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEdit ? 'Update Student' : 'Save Student'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(studentsControllerProvider.notifier);
    final name = _nameController.text.trim();
    final rateDollars = double.parse(_rateController.text.trim());
    final rateCents = (rateDollars * 100).round();

    if (_isEdit) {
      controller.updateStudent(
        id: widget.student!.id,
        name: name,
        hourlyRateCents: rateCents,
      );
    } else {
      controller.createStudent(
        name: name,
        hourlyRateCents: rateCents,
      );
    }
    final result = ref.watch(studentsControllerProvider);

    if (!mounted) return;

    if (result.hasError) {
      context.showErrorSnackBar(result.error.toString());
    } else {
      Navigator.of(context).pop();
      context.showSuccessSnackBar(_isEdit ? 'Student updated successfully' : 'Student created successfully');
    }
  }
}
