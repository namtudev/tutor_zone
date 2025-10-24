import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tutor_zone/core/access_mode/app_access_mode.dart';
import 'package:tutor_zone/core/access_mode/data_cleanup_service.dart';
import 'package:tutor_zone/core/common_widgets/app_snackbar.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/core/mock_config/fake_data_seeder.dart';
import 'package:tutor_zone/flavors.dart';
import 'package:tutor_zone/router/route_config.dart';

/// Settings screen for user preferences and configuration
class SettingsScreen extends ConsumerWidget {
  /// Creates a new [SettingsScreen]
  const SettingsScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessModeAsync = ref.watch(appAccessModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Access Mode Section
            Text('ACCESS MODE', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          accessModeAsync.maybeWhen(
                            data: (mode) => mode == AppAccessMode.local ? Icons.offline_pin : Icons.cloud,
                            orElse: () => Icons.help_outline,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Mode',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              accessModeAsync.when(
                                data: (mode) => Text(
                                  mode == AppAccessMode.local ? 'Local (Offline)' : 'Cloud (Online)',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                loading: () => const Text('Loading...'),
                                error: (error, stack) => const Text('Error loading mode'),
                              ),
                            ],
                          ),
                        ),
                        accessModeAsync.maybeWhen(
                          data: (mode) => Switch(
                            value: mode == AppAccessMode.cloud,
                            onChanged: (value) => _showModeSwitchDialog(
                              context,
                              ref,
                              value ? AppAccessMode.cloud : AppAccessMode.local,
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      accessModeAsync.maybeWhen(
                        data: (mode) => mode == AppAccessMode.local
                            ? 'All data is stored locally on this device. No internet connection required.'
                            : 'Data is synced to the cloud. Requires internet connection and authentication.',
                        orElse: () => '',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

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

            // Developer Options Section (dev mode only)
            if (F.config.isDev) ...[
              Text('DEVELOPER OPTIONS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.science, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fake Data', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 4),
                                Text(
                                  'Load sample data for testing and development',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          FilledButton.tonal(
                            onPressed: () => _loadFakeData(context, ref),
                            child: const Text('Load Fake Data'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => _clearAllData(context, ref),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            ),
                            child: const Text('Clear All Data'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

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

  /// Show dialog to confirm mode switch with data loss warning
  void _showModeSwitchDialog(BuildContext context, WidgetRef ref, AppAccessMode newMode) {
    final currentMode = ref
        .read(appAccessModeProvider)
        .maybeWhen(
          data: (mode) => mode,
          orElse: () => AppAccessMode.local,
        );

    // Don't show dialog if switching to same mode
    if (currentMode == newMode) return;

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: Text('Switch to ${newMode == AppAccessMode.local ? 'Local' : 'Cloud'} Mode?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Switching modes will clear all current data on this device.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. Make sure to export your data first if needed.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            child: const Text('Switch Mode'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        _performModeSwitch(context, ref, newMode);
      }
    });
  }

  /// Perform the actual mode switch and cleanup
  Future<void> _performModeSwitch(BuildContext context, WidgetRef ref, AppAccessMode newMode) async {
    // Capture navigator before async gap
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Switching modes...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Clear data based on mode switch direction
      final dataCleanupService = ref.read(dataCleanupServiceProvider);

      if (newMode == AppAccessMode.cloud) {
        // Switching to cloud: clear local Sembast data
        logInfo('Switching to cloud mode: clearing local data');
        await dataCleanupService.clearLocalData();
      } else {
        // Switching to local: clear Firebase cache and sign out
        logInfo('Switching to local mode: clearing cloud data');
        await dataCleanupService.clearCloudData();
      }

      // Switch the mode
      await ref.read(appAccessModeProvider.notifier).setMode(newMode);

      // Close loading dialog
      navigator.pop();

      // Navigate to appropriate screen
      if (newMode == AppAccessMode.local) {
        router.go(Routes.dashboard.path);
      } else {
        router.go(Routes.signIn.path);
      }

      // Show success message
      if (context.mounted) {
        context.showSuccessSnackBar('Switched to ${newMode == AppAccessMode.local ? 'Local' : 'Cloud'} mode');
      }
    } catch (e) {
      // Close loading dialog if still open
      navigator.pop();

      // Show error message
      if (context.mounted) {
        context.showErrorSnackBar('Failed to switch mode: $e');
      }
    }
  }

  /// Load fake data into database (dev mode only)
  Future<void> _loadFakeData(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Load Fake Data'),
        content: const Text(
          'This will add sample students, sessions, and payments to your database. '
          'This action cannot be undone automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Load Data'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading fake data...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Load fake data
      final seeder = ref.read(fakeDataSeederProvider);
      await seeder.seedAll();

      // Show success message
      if (context.mounted) {
        // Close loading dialog if still open
        Navigator.of(context, rootNavigator: true).pop();
        context.showSuccessSnackBar('Fake data loaded successfully');
      }
    } catch (e, stack) {
      logError('Failed to load fake data', e, stack);

      // Show error message
      if (context.mounted) {
        // Close loading dialog if still open
        Navigator.of(context, rootNavigator: true).pop();
        context.showErrorSnackBar('Failed to load fake data: $e');
      }
    }
  }

  /// Clear all data from database (dev mode only)
  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    // Capture theme early for dialog styling
    final theme = Theme.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all students, sessions, and payments from your local database. '
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Capture navigator after async gap
    final navigator = Navigator.of(context);

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Clearing all data...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Clear all data
      final seeder = ref.read(fakeDataSeederProvider);
      await seeder.clearAll();

      // Close loading dialog
      navigator.pop();

      // Show success message
      if (context.mounted) {
        context.showSuccessSnackBar('All data cleared successfully');
      }
    } catch (e, stack) {
      logError('Failed to clear data', e, stack);

      // Close loading dialog if still open
      navigator.pop();

      // Show error message
      if (context.mounted) {
        context.showErrorSnackBar('Failed to clear data: $e');
      }
    }
  }
}
