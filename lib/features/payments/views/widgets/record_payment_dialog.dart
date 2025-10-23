import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tutor_zone/features/balance/controllers/balance_controller.dart';
import 'package:tutor_zone/features/sessions/controllers/sessions_controller.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/students/controllers/students_controller.dart';

/// Dialog for recording a payment from a student
class RecordPaymentDialog extends ConsumerStatefulWidget {
  const RecordPaymentDialog({
    required this.studentId,
    super.key,
  });

  final String studentId;

  @override
  ConsumerState<RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentType = 'prepaid'; // 'prepaid' or 'adjustment'
  DateTime _paymentDate = DateTime.now();
  String? _paymentMethod;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(studentStreamProvider(widget.studentId));
    final sessionsAsync =
        ref.watch(sessionsByStudentStreamProvider(widget.studentId));
    return studentAsync.when(
      data: (student) {
        if (student == null) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text('Student not found'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        }

        return sessionsAsync.when(
          data: (sessions) {
            // Filter for unpaid sessions only
            final unpaidSessions = sessions
                .where((s) => s.payStatus == PaymentStatus.unpaid)
                .toList();

            final totalOwed = unpaidSessions.fold<int>(
              0,
              (sum, session) => sum + session.amountCents,
            );
            final balance = student.balanceCents;
            final net = balance - totalOwed;

            return Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RECORD PAYMENT',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Student info
                              Text(
                                'Student: ${student.name}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: net < 0
                                      ? Theme.of(context)
                                          .colorScheme
                                          .errorContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: net < 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Balance: \$${student.balanceDollars.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: net < 0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onErrorContainer
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (totalOwed > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Total Owed: \$${(totalOwed / 100).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: net < 0
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onErrorContainer
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                            Text(
                                              'Net: ${net < 0 ? "-" : "+"}\$${(net.abs() / 100).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: net < 0
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onErrorContainer
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Payment Type
                              Text(
                                'Payment Type',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'prepaid',
                                    label: Text('Add prepaid credit'),
                                  ),
                                  ButtonSegment(
                                    value: 'adjustment',
                                    label: Text('Balance adjustment'),
                                  ),
                                ],
                                selected: {_paymentType},
                                onSelectionChanged: _isSubmitting
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _paymentType = value.first;
                                        });
                                      },
                              ),

                              const SizedBox(height: 24),

                              // Amount Input
                              Text(
                                'Amount',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _amountController,
                                enabled: !_isSubmitting,
                                decoration: InputDecoration(
                                  labelText: _paymentType == 'prepaid'
                                      ? 'Payment Amount'
                                      : 'Adjustment Amount',
                                  hintText: _paymentType == 'prepaid'
                                      ? 'Enter positive amount'
                                      : 'Enter amount (+ or -)',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  prefixText: '\$ ',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  final amount = double.tryParse(value);
                                  if (amount == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (_paymentType == 'prepaid' &&
                                      amount <= 0) {
                                    return 'Payment amount must be positive';
                                  }
                                  if (amount == 0) {
                                    return 'Amount cannot be zero';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Payment Date
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Payment Date',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                controller: TextEditingController(
                                  text: DateFormat('MMM d, yyyy')
                                      .format(_paymentDate),
                                ),
                                onTap: _isSubmitting
                                    ? null
                                    : () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _paymentDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _paymentDate = date;
                                          });
                                        }
                                      },
                              ),

                              const SizedBox(height: 16),

                              // Payment Method
                              DropdownMenu<String>(
                                label: const Text('Payment Method (optional)'),
                                expandedInsets: EdgeInsets.zero,
                                enabled: !_isSubmitting,
                                initialSelection: _paymentMethod,
                                onSelected: (value) {
                                  setState(() {
                                    _paymentMethod = value;
                                  });
                                },
                                dropdownMenuEntries: const [
                                  DropdownMenuEntry(value: 'cash', label: 'Cash'),
                                  DropdownMenuEntry(
                                      value: 'check', label: 'Check'),
                                  DropdownMenuEntry(
                                      value: 'venmo', label: 'Venmo'),
                                  DropdownMenuEntry(
                                      value: 'paypal', label: 'PayPal'),
                                  DropdownMenuEntry(
                                      value: 'zelle', label: 'Zelle'),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Notes
                              TextFormField(
                                controller: _notesController,
                                enabled: !_isSubmitting,
                                decoration: InputDecoration(
                                  labelText: 'Notes (optional)',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Record Payment'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (error, stack) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading sessions: $error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error loading student: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final amountDollars = double.parse(_amountController.text);
      final amountCents = (amountDollars * 100).round();

      final controller = ref.read(balanceControllerProvider.notifier);

      if (_paymentType == 'prepaid') {
        await controller.recordPayment(
          studentId: widget.studentId,
          amountCents: amountCents,
        );
      } else {
        await controller.recordAdjustment(
          studentId: widget.studentId,
          amountCents: amountCents,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _paymentType == 'prepaid'
                  ? 'Payment recorded successfully'
                  : 'Adjustment recorded successfully',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
