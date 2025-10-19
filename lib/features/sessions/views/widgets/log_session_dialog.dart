import 'package:flutter/material.dart';

/// Dialog for logging a new session
class LogSessionDialog extends StatelessWidget {
  const LogSessionDialog({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student
                    Text('Student', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const DropdownMenu<String>(
                      label: Text('Select Student'),
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'sarah', label: 'Sarah Chen - Math'),
                        DropdownMenuEntry(value: 'mike', label: 'Mike Johnson - Physics'),
                        DropdownMenuEntry(value: 'emma', label: 'Emma Davis - Chemistry'),
                        DropdownMenuEntry(value: 'alex', label: 'Alex Kumar - Computer Science'),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Date & Time
                    Text('Date & Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownMenu<String>(
                            label: const Text('Start Time'),
                            expandedInsets: EdgeInsets.zero,
                            dropdownMenuEntries: List.generate(
                              24,
                              (hour) => DropdownMenuEntry(value: '$hour:00', label: '${hour.toString().padLeft(2, '0')}:00'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownMenu<String>(
                            label: const Text('End Time'),
                            expandedInsets: EdgeInsets.zero,
                            dropdownMenuEntries: List.generate(
                              24,
                              (hour) => DropdownMenuEntry(value: '$hour:00', label: '${hour.toString().padLeft(2, '0')}:00'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: 1.5 hours',
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Session Details
                    Text('Session Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Session Notes',
                        hintText: 'What did you work on during this session?',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    Text('Payment Status', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'paid', label: Text('Paid'), icon: Icon(Icons.check_circle_outline)),
                              ButtonSegment(value: 'unpaid', label: Text('Unpaid'), icon: Icon(Icons.schedule)),
                            ],
                            selected: const {'unpaid'},
                            onSelectionChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Session Cost:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
                          ),
                          Text(
                            '\$60.00',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer),
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
                  FilledButton(onPressed: () {}, child: const Text('Save Session')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
