import 'package:flutter/material.dart';

/// Dialog for recording a payment from a student
class RecordPaymentDialog extends StatelessWidget {
  const RecordPaymentDialog({super.key});

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
                  Text('RECORD PAYMENT', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
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
                    Text('Student: Sarah Chen', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Current Balance: -\$80 (owed)',
                            style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Type
                    Text('Payment Type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'sessions', label: Text('Pay for completed sessions')),
                        ButtonSegment(value: 'prepaid', label: Text('Add prepaid credit')),
                      ],
                      selected: const {'sessions'},
                      onSelectionChanged: (value) {},
                    ),

                    const SizedBox(height: 24),

                    // Select Sessions
                    Text('Select Sessions to Mark as Paid', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: true,
                            onChanged: (value) {},
                            title: const Text('Oct 15, 2024'),
                            subtitle: const Text('1.5 hrs'),
                            secondary: const Text('\$60'),
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            value: true,
                            onChanged: (value) {},
                            title: const Text('Oct 08, 2024'),
                            subtitle: const Text('0.5 hr'),
                            secondary: const Text('\$20'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Details
                    Text('Payment Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 16)),
                          Text(
                            '\$80',
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Payment Date',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    const DropdownMenu<String>(
                      label: Text('Payment Method (optional)'),
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'cash', label: 'Cash'),
                        DropdownMenuEntry(value: 'check', label: 'Check'),
                        DropdownMenuEntry(value: 'venmo', label: 'Venmo'),
                        DropdownMenuEntry(value: 'paypal', label: 'PayPal'),
                        DropdownMenuEntry(value: 'zelle', label: 'Zelle'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onTertiaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'New Balance After Payment: \$0',
                            style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  FilledButton(onPressed: () {}, child: const Text('Record Payment')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
