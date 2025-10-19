import 'package:flutter/material.dart';

/// Session timer screen for tracking live tutoring sessions
class SessionTimerScreen extends StatelessWidget {
  const SessionTimerScreen({super.key});

  /// Route name for navigation
  static const String routeName = 'timer';

  @override
  Widget build(BuildContext context) {
    // Simulate timer running state
    const isRunning = false;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const Card(
            child: Padding(padding: EdgeInsets.all(32.0), child: isRunning ? _RunningTimerView() : _IdleTimerView()),
          ),
        ),
      ),
    );
  }
}

class _IdleTimerView extends StatelessWidget {
  const _IdleTimerView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Select Student', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const DropdownMenu<String>(
          label: Text('Choose a student'),
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 'sarah', label: 'Sarah Chen - Math (\$40/hr)'),
            DropdownMenuEntry(value: 'mike', label: 'Mike Johnson - Physics (\$50/hr)'),
            DropdownMenuEntry(value: 'emma', label: 'Emma Davis - Chemistry (\$40/hr)'),
            DropdownMenuEntry(value: 'alex', label: 'Alex Kumar - Computer Science (\$60/hr)'),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  '0:00:00',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontFeatures: [const FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow, size: 28),
          label: const Text('START SESSION'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), textStyle: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Quick Notes (optional)', style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Add notes about this session...',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}

class _RunningTimerView extends StatelessWidget {
  const _RunningTimerView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Sarah Chen - Math (\$40/hr)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 8),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  '0:47:23',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()],
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.pause),
              label: const Text('PAUSE'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.stop),
              label: const Text('STOP'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
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
                'Current Session Cost:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              Text(
                '\$31.56',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Quick Notes', style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Working on calculus derivatives...',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
