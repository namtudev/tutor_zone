import 'package:flutter/material.dart';

/// Settings screen for user preferences and configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'settings';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROFILE', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      controller: TextEditingController(text: 'John Doe'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      controller: TextEditingController(text: 'john.doe@email.com'),
                    ),
                    const SizedBox(height: 16),
                    const DropdownMenu<String>(
                      label: Text('Timezone'),
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: 'pt',
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'pt', label: 'Pacific Time (PT)'),
                        DropdownMenuEntry(value: 'mt', label: 'Mountain Time (MT)'),
                        DropdownMenuEntry(value: 'ct', label: 'Central Time (CT)'),
                        DropdownMenuEntry(value: 'et', label: 'Eastern Time (ET)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text('PREFERENCES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: DropdownMenu<String>(
                            label: Text('Default Session Duration'),
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: '1.0',
                            dropdownMenuEntries: [
                              DropdownMenuEntry(value: '0.5', label: '0.5 hours'),
                              DropdownMenuEntry(value: '1.0', label: '1.0 hours'),
                              DropdownMenuEntry(value: '1.5', label: '1.5 hours'),
                              DropdownMenuEntry(value: '2.0', label: '2.0 hours'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(
                          child: DropdownMenu<String>(
                            label: Text('Currency'),
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: 'usd',
                            dropdownMenuEntries: [
                              DropdownMenuEntry(value: 'usd', label: 'USD (\$)'),
                              DropdownMenuEntry(value: 'eur', label: 'EUR (€)'),
                              DropdownMenuEntry(value: 'gbp', label: 'GBP (£)'),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownMenu<String>(
                            label: Text('Week Starts On'),
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: 'monday',
                            dropdownMenuEntries: [
                              DropdownMenuEntry(value: 'sunday', label: 'Sunday'),
                              DropdownMenuEntry(value: 'monday', label: 'Monday'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    CheckboxListTile(
                      value: true,
                      onChanged: (value) {},
                      title: const Text('Send payment reminders after 7 days'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(value: true, onChanged: (value) {}, title: const Text('Auto-save timer sessions'), contentPadding: EdgeInsets.zero),
                    CheckboxListTile(
                      value: false,
                      onChanged: (value) {},
                      title: const Text('Show session notes on dashboard'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text('NOTIFICATIONS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CheckboxListTile(value: true, onChanged: (value) {}, title: const Text('Email weekly summary'), contentPadding: EdgeInsets.zero),
                    CheckboxListTile(value: true, onChanged: (value) {}, title: const Text('Payment received confirmations'), contentPadding: EdgeInsets.zero),
                    CheckboxListTile(
                      value: false,
                      onChanged: (value) {},
                      title: const Text('Session reminder (15 min before)'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(value: true, onChanged: (value) {}, title: const Text('Monthly report available'), contentPadding: EdgeInsets.zero),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text('APPEARANCE', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme Mode', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode)),
                        ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                        ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.settings_brightness)),
                      ],
                      selected: const {'system'},
                      onSelectionChanged: (value) {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text('DATA & PRIVACY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    FilledButton.tonal(onPressed: () {}, child: const Text('Export All Data')),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                      child: const Text('Delete Account'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(onPressed: () {}, child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: () {}, child: const Text('Save Settings')),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
