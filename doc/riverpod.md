### Add Dart Riverpod Dependency

Source: https://riverpod.dev/docs/introduction/getting_started

Installs the core `riverpod` package along with development dependencies `custom_lint` and `riverpod_lint` for Dart-only projects.

```bash
dart pub add riverpod
dart pub add dev:custom_lint
dart pub add dev:riverpod_lint
```

--------------------------------

### Add Dart Riverpod with Code Generation

Source: https://riverpod.dev/docs/introduction/getting_started

Installs `riverpod`, `riverpod_annotation`, and code generation tools (`riverpod_generator`, `build_runner`), plus linters for Dart-only projects.

```bash
dart pub add riverpod
dart pub add riverpod_annotation
dart pub add dev:riverpod_generator
dart pub add dev:build_runner
dart pub add dev:custom_lint
dart pub add dev:riverpod_lint
```

--------------------------------

### Add Flutter Riverpod with Code Generation

Source: https://riverpod.dev/docs/introduction/getting_started

Installs `flutter_riverpod`, `riverpod_annotation`, and code generation tools (`riverpod_generator`, `build_runner`), plus linters for Flutter projects.

```bash
flutter pub add flutter_riverpod
flutter pub add riverpod_annotation
flutter pub add dev:riverpod_generator
flutter pub add dev:build_runner
flutter pub add dev:custom_lint
flutter pub add dev:riverpod_lint
```

--------------------------------

### Add Flutter Riverpod and Dev Dependencies

Source: https://riverpod.dev/docs/introduction/getting_started

Installs the `flutter_riverpod` package along with development dependencies `custom_lint` and `riverpod_lint` for Flutter projects.

```bash
flutter pub add flutter_riverpod
flutter pub add dev:custom_lint
flutter pub add dev:riverpod_lint
```

--------------------------------

### Flutter Riverpod with Hooks Hello World

Source: https://riverpod.dev/docs/introduction/getting_started

This example shows how to use Riverpod with flutter_hooks in a Flutter application. It demonstrates using `useState` hook alongside Riverpod providers.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
final helloWorldProvider = Provider((_) => 'Hello world');

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend HookConsumerWidget instead of HookWidget, which is exposed by Riverpod
class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use hooks inside HookConsumerWidget
    final counter = useState(0);

    final String value = ref.watch(helloWorldProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: Text('$value ${counter.value}'),
        ),
      ),
    );
  }
}

```

--------------------------------

### Add Flutter Hooks Riverpod with Code Generation

Source: https://riverpod.dev/docs/introduction/getting_started

Installs `hooks_riverpod`, `flutter_hooks`, `riverpod_annotation`, and code generation tools (`riverpod_generator`, `build_runner`), plus linters for Flutter projects.

```bash
flutter pub add hooks_riverpod
flutter pub add flutter_hooks
flutter pub add riverpod_annotation
flutter pub add dev:riverpod_generator
flutter pub add dev:build_runner
flutter pub add dev:custom_lint
flutter pub add dev:riverpod_lint
```

--------------------------------

### Flutter Riverpod Generator Hello World

Source: https://riverpod.dev/docs/introduction/getting_started

This example utilizes `riverpod_generator` to automatically generate Riverpod providers for a Flutter application. It simplifies provider creation and usage.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
@riverpod
String helloWorld(Ref ref) {
  return 'Hello world';
}

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String value = ref.watch(helloWorldProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: Text(value),
        ),
      ),
    );
  }
}

```

--------------------------------

### Add Flutter Hooks Riverpod and Dev Dependencies

Source: https://riverpod.dev/docs/introduction/getting_started

Installs the `hooks_riverpod` and `flutter_hooks` packages, along with development dependencies `custom_lint` and `riverpod_lint` for Flutter projects.

```bash
flutter pub add hooks_riverpod
flutter pub add flutter_hooks
flutter pub add dev:custom_lint
flutter pub add dev:riverpod_lint
```

--------------------------------

### Example Migration Suggestion (Bash)

Source: https://riverpod.dev/docs/migration/0.13.0_to_0

An example output from the `riverpod migrate` command, showing a suggested code change for updating state watching syntax.

```bash
Widget build(BuildContext context, ScopedReader watch) {
-  MyModel state = watch(provider.state);
+  MyModel state = watch(provider);
}

Accept change (y = yes, n = no [default], A = yes to all, q = quit)? 
```

--------------------------------

### Flutter Riverpod Generator with Hooks Hello World

Source: https://riverpod.dev/docs/introduction/getting_started

Combines `riverpod_generator` with `flutter_hooks` for efficient state management in Flutter. This example shows automatic provider generation and hook usage.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
@riverpod
String helloWorld(Ref ref) {
  return 'Hello world';
}

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend HookConsumerWidget instead of HookWidget, which is exposed by Riverpod
class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use hooks inside HookConsumerWidget
    final counter = useState(0);

    final String value = ref.watch(helloWorldProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: Text('$value ${counter.value}'),
        ),
      ),
    );
  }
}

```

--------------------------------

### Flutter Riverpod Hello World

Source: https://riverpod.dev/docs/introduction/getting_started

A basic Flutter application using Riverpod to display 'Hello world'. It demonstrates creating a provider and accessing its value within a ConsumerWidget.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
final helloWorldProvider = Provider((_) => 'Hello world');

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String value = ref.watch(helloWorldProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: Text(value),
        ),
      ),
    );
  }
}

```

--------------------------------

### Run Code Generator Watch Mode

Source: https://riverpod.dev/docs/introduction/getting_started

Starts the Riverpod code generator in watch mode, automatically recompiling when changes are detected. This is used for projects utilizing `riverpod_generator`.

```bash
dart run build_runner watch -d
```

--------------------------------

### Configure pubspec.yaml for Dart Riverpod

Source: https://riverpod.dev/docs/introduction/getting_started

Manually adds the core `riverpod` package and development dependencies like `custom_lint` and `riverpod_lint` to a Dart-only project's `pubspec.yaml` file.

```yaml
name: my_app_name
environment:
  sdk: ^3.8.0

dependencies:
  riverpod: ^3.0.0

dev_dependencies:
  custom_lint:
  riverpod_lint: ^3.0.0
```

--------------------------------

### Riverpod Provider for 'Hello world'

Source: https://riverpod.dev/docs/introduction/getting_started

This Dart code defines a simple Riverpod provider named 'helloWorldProvider' that exposes the string 'Hello world'. It demonstrates how to create a provider and read its value using a ProviderContainer.

```dart
import 'package:riverpod/riverpod.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
final helloWorldProvider = Provider((_) => 'Hello world');

void main() {
  // This object is where the state of our providers will be stored.
  final container = ProviderContainer();

  // Thanks to "container", we can read our provider.
  final value = container.read(helloWorldProvider);

  print(value); // Hello world
}
```

--------------------------------

### Enable custom_lint Plugin

Source: https://riverpod.dev/docs/introduction/getting_started

Configures the `analyzer` section in `analysis_options.yaml` to enable the `custom_lint` plugin, which is required for `riverpod_lint` to function.

```yaml
analyzer:
  plugins:
    - custom_lint
```

--------------------------------

### Configure pubspec.yaml for Dart Riverpod with Code Gen

Source: https://riverpod.dev/docs/introduction/getting_started

Manually adds `riverpod`, `riverpod_annotation`, code generation tools (`riverpod_generator`, `build_runner`), and linters to a Dart-only project's `pubspec.yaml`.

```yaml
name: my_app_name
environment:
  sdk: ^3.8.0

dependencies:
  riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

dev_dependencies:
  build_runner:
  custom_lint:
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0
```

--------------------------------

### Install Riverpod CLI (Bash)

Source: https://riverpod.dev/docs/migration/0.13.0_to_0

Command to install the Riverpod command-line interface globally using Dart's package manager.

```bash
dart pub global activate riverpod_cli
```

--------------------------------

### Configure pubspec.yaml for Flutter Riverpod

Source: https://riverpod.dev/docs/introduction/getting_started

Manually adds `flutter_riverpod` and development dependencies like `custom_lint` and `riverpod_lint` to a Flutter project's `pubspec.yaml` file.

```yaml
name: my_app_name
environment:
  sdk: ^3.8.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0

dev_dependencies:
  custom_lint:
  riverpod_lint: ^3.0.0
```

--------------------------------

### Riverpod: Fully Migrated Notifier with Code Generation

Source: https://riverpod.dev/docs/from_provider/quickstart

This Dart code shows the 'fully migrated' version of a provider using Riverpod's `Notifier` class and the `@riverpod` annotation for code generation, replacing the need for temporary extensions.

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  int build() => 0;

  void increment() => state++;
}
```

--------------------------------

### Run Custom Lint Check

Source: https://riverpod.dev/docs/introduction/getting_started

Executes the `custom_lint` command to check for linting errors and apply refactorings in the project, useful for CI or terminal checks.

```bash
dart run custom_lint
```

--------------------------------

### Riverpod Generator Provider for 'Hello world'

Source: https://riverpod.dev/docs/introduction/getting_started

This Dart code utilizes riverpod_annotation to generate a provider for the string 'Hello world'. It shows the usage of the @riverpod annotation and how to read the generated provider.

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
@riverpod
String helloWorld(Ref ref) {
  return 'Hello world';
}

void main() {
  // This object is where the state of our providers will be stored.
  final container = ProviderContainer();

  // Thanks to "container", we can read our provider.
  final value = container.read(helloWorldProvider);

  print(value); // Hello world
}
```

--------------------------------

### Riverpod: Exposing ChangeNotifier with Codegen Syntax

Source: https://riverpod.dev/docs/from_provider/quickstart

This Dart code demonstrates how to expose a `ChangeNotifier` using Riverpod's code generation syntax with the `@riverpod` annotation and the previously defined extension.

```dart
// ignore_for_file: unsupported_provider_value
@riverpod
MyNotifier example(Ref ref) {
  return ref.listenAndDisposeChangeNotifier(MyNotifier());
}
```

--------------------------------

### Configure pubspec.yaml for Flutter Riverpod with Code Gen

Source: https://riverpod.dev/docs/introduction/getting_started

Manually adds `flutter_riverpod`, `riverpod_annotation`, code generation tools (`riverpod_generator`, `build_runner`), and linters to a Flutter project's `pubspec.yaml`.

```yaml
name: my_app_name
environment:
  sdk: ^3.8.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

dev_dependencies:
  build_runner:
  custom_lint:
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0
```

--------------------------------

### Migrate ChangeNotifier to Riverpod's ChangeNotifierProvider

Source: https://riverpod.dev/docs/from_provider/quickstart

This snippet shows how to adapt an existing `ChangeNotifier` class to work with Riverpod's `ChangeNotifierProvider` for a smoother migration. It demonstrates the initial step of using `ChangeNotifier` within Riverpod.

```Dart
class MyNotifier extends ChangeNotifier {
  int state = 0;

  void increment() {
    state++;
    notifyListeners();
  }
}

final myNotifierProvider = ChangeNotifierProvider<MyNotifier>((ref) {
  return MyNotifier();
});

```

--------------------------------

### Fully Migrate ChangeNotifier to Riverpod's NotifierProvider

Source: https://riverpod.dev/docs/from_provider/quickstart

This snippet demonstrates the complete migration of a `ChangeNotifier` to Riverpod's modern `NotifierProvider`. It includes updating the class to extend `Notifier` and modifying the provider declaration.

```Dart
class MyNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final myNotifierProvider = NotifierProvider<MyNotifier, int>(MyNotifier.new);

```

--------------------------------

### Configure pubspec.yaml for Flutter Hooks Riverpod

Source: https://riverpod.dev/docs/introduction/getting_started

Manually adds `hooks_riverpod`, `flutter_hooks`, and development dependencies like `custom_lint` and `riverpod_lint` to a Flutter project's `pubspec.yaml` file.

```yaml
name: my_app_name
environment:
  sdk: ^3.8.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  hooks_riverpod: ^3.0.0
  flutter_hooks:

dev_dependencies:
  custom_lint:
  riverpod_lint: ^3.0.0
```

--------------------------------

### Riverpod: Extension for ChangeNotifierProvider Code Generation

Source: https://riverpod.dev/docs/from_provider/quickstart

This Dart extension method allows `ChangeNotifierProvider` to be used with Riverpod's code generation. It adds listeners and handles disposal for the `ChangeNotifier`.

```dart
extension ChangeNotifierWithCodeGenExtension on Ref {
  T listenAndDisposeChangeNotifier<T extends ChangeNotifier>(T notifier) {
    notifier.addListener(notifyListeners);
    onDispose(() => notifier.removeListener(notifyListeners));
    onDispose(notifier.dispose);
    return notifier;
  }
}
```

--------------------------------

### Configure pubspec.yaml for Flutter Hooks Riverpod with Code Gen

Source: https://riverpod.dev/docs/introduction/getting_started

Manually adds `hooks_riverpod`, `flutter_hooks`, `riverpod_annotation`, code generation tools (`riverpod_generator`, `build_runner`), and linters to a Flutter project's `pubspec.yaml`.

```yaml
name: my_app_name
environment:
  sdk: ^3.8.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  hooks_riverpod: ^3.0.0
  flutter_hooks:
  riverpod_annotation: ^3.0.0

dev_dependencies:
  build_runner:
  custom_lint:
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0
```

--------------------------------

### Install Riverpod CLI Tool

Source: https://riverpod.dev/docs/migration/0.14.0_to_1

Installs the Riverpod command-line interface tool globally using Dart's package manager. This tool is used for migrating Riverpod projects.

```bash
dart pub global activate riverpod_cli
```

--------------------------------

### Flutter MaterialApp with Riverpod State

Source: https://riverpod.dev/docs/introduction/getting_started

This snippet shows a basic Flutter MaterialApp widget displaying a value read from a Riverpod provider. It includes an AppBar and a Center widget with Text to display the state.

```dart
return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: Text('$value ${counter.value}'),
        ),
      ),
    );
  }
}
```

--------------------------------

### Synchronous, Future, and Stream Function Examples

Source: https://riverpod.dev/docs/concepts2/providers

Provides basic examples of synchronous, Future-based, and Stream-based functions in Dart. These illustrate the fundamental data flow types that Riverpod providers can encapsulate.

```dart
int synchronous() => 0;
Future<int> future() async => 0;
Stream<int> stream() => Stream.value(0);

```

--------------------------------

### Safely Handle Asynchronous Data with Riverpod

Source: https://riverpod.dev/docs/index

This example demonstrates how Riverpod safely handles asynchronous data loading and errors. The `configurations` provider fetches configuration data from a JSON file. The `Example` widget uses `ref.watch` to observe the `configurationsProvider` and employs a switch statement to display either the loaded data, an error message, or a loading indicator, ensuring a robust UI.

```Dart
@riverpod  
Future<Configuration> configurations(Ref ref) async {  
  final uri = Uri.parse('configs.json');  
  final rawJson = await File.fromUri(uri).readAsString();  
  
  return Configuration.fromJson(json.decode(rawJson));  
}  
  
class Example extends ConsumerWidget {  
  @override  
  Widget build(BuildContext context, WidgetRef ref) {  
    final configs = ref.watch(configurationsProvider);  
  
    // Use pattern matching to safely handle loading/error states  
    return switch (configs) {  
      AsyncData(:final value) => Text('data: ${value.host}'),  
      AsyncError(:final error) => Text('error: $error'),  
      _ => const CircularProgressIndicator(),  
    };  
  }  
}  
```

--------------------------------

### Run Riverpod Migration Tool (Bash)

Source: https://riverpod.dev/docs/migration/0.13.0_to_0

Command to execute the Riverpod migration tool within a project directory to automatically update syntax.

```bash
riverpod migrate
```

--------------------------------

### HookWidget Fade-In Animation Example

Source: https://riverpod.dev/docs/concepts/about_hooks

This example shows the equivalent fade-in animation implementation using Flutter hooks. It leverages `useAnimationController` and `useEffect` for managing the animation lifecycle and `useAnimation` to trigger rebuilds, offering a more concise solution.

```Dart
class FadeIn extends HookWidget {
  const FadeIn({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Create an AnimationController. The controller will automatically be
    // disposed when the widget is unmounted.
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    // useEffect is the equivalent of initState + didUpdateWidget + dispose.
    // The callback passed to useEffect is executed the first time the hook is
    // invoked, and then whenever the list passed as second parameter changes.
    // Since we pass an empty const list here, that's strictly equivalent to `initState`.
    useEffect(() {
      // start the animation when the widget is first rendered.
      animationController.forward();
      // We could optionally return some "dispose" logic here
      return null;
    }, const []);

    // Tell Flutter to rebuild this widget when the animation updates.
    // This is equivalent to AnimatedBuilder
    useAnimation(animationController);

    return Opacity(
      opacity: animationController.value,
      child: child,
    );
  }
}

```

--------------------------------

### AsyncNotifierProvider.family.autoDispose Example (New API)

Source: https://riverpod.dev/docs/migration/from_state_notifier

Shows the equivalent definition using the newer AsyncNotifierProvider.family.autoDispose. This version simplifies the Notifier class and provider setup, making the code more concise.

```dart
class BugsEncounteredNotifier extends AsyncNotifier<int> {
  BugsEncounteredNotifier(this.arg);
  final String arg;

  @override
  FutureOr<int> build() {
    return 99;
  }

  Future<void> fix(int amount) async {
    final old = await future;
    final result =
        await ref.read(taskTrackerProvider).fix(id: this.arg, fixed: amount);
    state = AsyncData(max(old - result, 0));
  }
}

final bugsEncounteredNotifierProvider = AsyncNotifierProvider.family
    .autoDispose<BugsEncounteredNotifier, int, String>(
  BugsEncounteredNotifier.new,
);

```

--------------------------------

### Simplify Ref and Remove Ref Subclasses (riverpod_generator Example)

Source: https://riverpod.dev/docs/3

Illustrates the migration for code-generated providers, showing how to use the unified `Ref` and `Notifier` properties instead of specific subclasses like `FutureProviderRef`.

```dart
// Before:
@riverpod
Future<int> value(ValueRef ref) async {
  ref.listen(anotherProvider, (previous, next) {
    ref.state++;
  });

  ref.listenSelf((previous, next) {
    print('Log: $previous -> $next');
  });

  ref.future.then((value) {
    print('Future: $value');
  });

  return 0;
}

// After
@riverpod
class Value extends _$Value {
  @override
  Future<int> build() async {
    ref.listen(anotherProvider, (previous, next) {
      ref.state++;
    });

    listenSelf((previous, next) {
      print('Log: $previous -> $next');
    });

    future.then((value) {
      print('Future: $value');
    });

    return 0;
  }
}
```

--------------------------------

### Define an Eagerly Initialized FutureProvider (riverpod_generator)

Source: https://riverpod.dev/docs/how_to/testing

This snippet demonstrates defining an eagerly initialized FutureProvider using the riverpod_generator package. It achieves the same result as the previous example but with code generation.

```dart
@riverpod
Future<String> example(Ref ref) async => 'Hello world';
```

--------------------------------

### ChangeNotifier Example in Riverpod

Source: https://riverpod.dev/docs/migration/from_change_notifier

This Dart code snippet demonstrates a typical implementation using Riverpod's ChangeNotifierProvider. It includes a `ChangeNotifier` class that manages a list of todos, handling loading and error states, and provides a method to add new todos. The example highlights potential design issues like manual state management and the need for `notifyListeners()`.

```dart
class MyChangeNotifier extends ChangeNotifier {
  MyChangeNotifier() {
    _init();
  }
  List<Todo> todos = [];
  bool isLoading = true;
  bool hasError = false;

  Future<void> _init() async {
    try {
      final json = await http.get('api/todos');
      todos = [...json.map(Todo.fromJson)];
    } on Exception {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final json = await http.post('api/todos');
      todos = [...json.map(Todo.fromJson)];
      hasError = false;
    } on Exception {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final myChangeProvider = ChangeNotifierProvider<MyChangeNotifier>((ref) {
  return MyChangeNotifier();
});

```

--------------------------------

### Simplify Ref and Remove Ref Subclasses (FutureProvider Example)

Source: https://riverpod.dev/docs/3

Demonstrates the migration from using specific Ref subclasses like FutureProviderRef to the unified Ref and Notifier properties. This includes changes in how `listenSelf` and `future` are accessed.

```dart
// Before:
final valueProvider = FutureProvider<int>((ref) async {
  ref.listen(anotherProvider, (previous, next) {
    ref.state++;
  });

  ref.listenSelf((previous, next) {
    print('Log: $previous -> $next');
  });

  ref.future.then((value) {
    print('Future: $value');
  });

  return 0;
});

// After
class Value extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    ref.listen(anotherProvider, (previous, next) {
      ref.state++;
    });

    listenSelf((previous, next) {
      print('Log: $previous -> $next');
    });

    future.then((value) {
      print('Future: $value');
    });

    return 0;
  }
}
final valueProvider = AsyncNotifierProvider<Value, int>(Value.new);
```

--------------------------------

### Define an Eagerly Initialized FutureProvider (riverpod)

Source: https://riverpod.dev/docs/how_to/testing

This snippet shows how to define a FutureProvider in Riverpod that initializes eagerly and returns a String. It's a basic example of a provider's declaration.

```dart
final exampleProvider = FutureProvider<String>((ref) async => 'Hello world');
```

--------------------------------

### Riverpod Synchronous Provider (Functional)

Source: https://riverpod.dev/docs/concepts/about_code_generation

Example of a synchronous Riverpod provider defined using the functional syntax with code generation. This approach is concise and suitable for simple state management where side-effects are not required.

```Dart
@riverpod
String example(Ref ref) {
  return 'foo';
}

```

--------------------------------

### Defining Multiple Providers in Riverpod

Source: https://riverpod.dev/docs/concepts2/providers

Provides examples of defining multiple independent providers in Riverpod, showcasing that providers of the same type can coexist without issues.

```dart
final cityProvider = Provider((ref) => 'London');
final countryProvider = Provider((ref) => 'England');
```

```dart
@riverpod
String city(Ref ref) => 'London';
@riverpod
String country(Ref ref) => 'England';
```

--------------------------------

### DON'T: Perform Side Effects During Provider Initialization

Source: https://riverpod.dev/docs/root/do_dont

Shows an example of performing a 'write' operation (like an HTTP POST request) during provider initialization, which is discouraged. Providers should primarily represent 'read' operations to avoid unexpected behavior.

```dart
final submitProvider = FutureProvider((ref) async {
  final formState = ref.watch(formState);

  // Bad: Providers should not be used for "write" operations.
  return http.post('https://my-api.com', body: formState.toJson());
});
```

--------------------------------

### StateNotifier Lifecycle Example (Old API)

Source: https://riverpod.dev/docs/migration/from_state_notifier

Demonstrates the lifecycle management of a StateNotifier in Riverpod using the older API. It includes timer-based updates, custom dispose logic, and reactive dependencies within the provider definition.

```dart
class MyNotifier extends StateNotifier<int> {
  MyNotifier(this.ref, this.period) : super(0) {
    // 1 init logic
    _timer = Timer.periodic(period, (t) => update()); // 2 side effect on init
  }
  final Duration period;
  final Ref ref;
  late final Timer _timer;

  Future<void> update() async {
    await ref.read(repositoryProvider).update(state + 1); // 3 mutation
    if (mounted) state++; // 4 check for mounted props
  }

  @override
  void dispose() {
    _timer.cancel(); // 5 custom dispose logic
    super.dispose();
  }
}

final myNotifierProvider = StateNotifierProvider<MyNotifier, int>((ref) {
  // 6 provider definition
  final period = ref.watch(durationProvider); // 7 reactive dependency logic
  return MyNotifier(ref, period); // 8 pipe down `ref`
});

```

--------------------------------

### Riverpod Async Stream Provider (Functional)

Source: https://riverpod.dev/docs/concepts/about_code_generation

Example of a Riverpod provider for Stream data using the functional syntax with code generation. It simplifies handling asynchronous data streams and their states.

```Dart
@riverpod
Stream<String> example(Ref ref) async* {
  yield 'foo';
}

```

--------------------------------

### Eagerly Initialize with @riverpod and Use requireValue

Source: https://riverpod.dev/docs/how_to/eager_initialization

This example shows eager initialization using the `@riverpod` annotation for a `FutureProvider`. It also demonstrates using `AsyncValue.requireValue` in a `ConsumerWidget` to access the provider's data directly, simplifying the process of reading initialized values.

```dart
// An eagerly initialized provider.
@riverpod
Future<String> example(Ref ref) async => 'Hello world';

class MyConsumer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(exampleProvider);

    /// If the provider was correctly eagerly initialized, then we can
    /// directly read the data with "requireValue".
    return Text(result.requireValue);
  }
}
```

--------------------------------

### Riverpod Data Fetching with Code Generation (riverpod_annotation, freezed)

Source: https://riverpod.dev/docs/how_to/pull_to_refresh

This snippet demonstrates using `riverpod_annotation` for automatic provider generation and `freezed` for immutable data classes. It simplifies the data fetching and model definition process compared to manual setup, while maintaining the same UI functionality.

```dart
import 'dart:convert';  
  
import 'package:flutter/material.dart';  
import 'package:flutter_riverpod/flutter_riverpod.dart';  
import 'package:freezed_annotation/freezed_annotation.dart';  
import 'package:http/http.dart' as http;  
import 'package:riverpod_annotation/riverpod_annotation.dart';  
  
part 'codegen.g.dart';  
part 'codegen.freezed.dart';  
  
void main() => runApp(ProviderScope(child: MyApp()));  
  
class MyApp extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(home: ActivityView());  
  }  
}  
  
class ActivityView extends ConsumerWidget {  
  @override  
  Widget build(BuildContext context, WidgetRef ref) {  
    final activity = ref.watch(activityProvider);  
  
    return Scaffold(  
      appBar: AppBar(title: const Text('Pull to refresh')),  
      body: RefreshIndicator(  
        onRefresh: () => ref.refresh(activityProvider.future),  
        child: ListView(  
          children: [  
            switch (activity) {  
              AsyncValue<Activity>(:final value?) => Text(value.activity),  
              AsyncValue(:final error?) => Text('Error: $error'),  
              _ => const CircularProgressIndicator(),  
            },  
          ],  
        ),  
      ),  
    );  
  }  
}  
  
@riverpod  
Future<Activity> activity(Ref ref) async {  
  final response = await http.get(  
    Uri.https('www.boredapi.com', '/api/activity'),  
  );  
  
  final json = jsonDecode(response.body) as Map;  
  return Activity.fromJson(Map.from(json));  
}  
  
@freezed  
sealed class Activity with _$Activity {  
  factory Activity({  
    required String activity,  
    required String type,  
    required int participants,  
    required double price,  
  }) = _Activity;  
  
  factory Activity.fromJson(Map<String, dynamic> json) =>  
      _$ActivityFromJson(json);  
}  
```

--------------------------------

### Riverpod Generator with Progress (Riverpod)

Source: https://riverpod.dev/docs/whats_new

Shows how to set an optional 'progress' property on AsyncLoading using the riverpod_generator package. This is the generator-based equivalent of the AsyncNotifier example.

```dart
import "package:riverpod_annotation/riverpod_annotation.dart";

// Assume User and fetchSomething are defined elsewhere

part 'my_notifier.g.dart';

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future<User> build() async {
    state = AsyncLoading(progress: .0);
    await fetchSomething();
    state = AsyncLoading(progress: 0.5);
    return User();
  }
}
```

--------------------------------

### Access StateNotifier Instance (Dart)

Source: https://riverpod.dev/docs/migration/0.13.0_to_0

Illustrates how to obtain the StateNotifier instance using the provider. The `notifier` property is now used to access the StateNotifier.

```dart
Widget build(BuildContext context, ScopedReader watch) {
  // Before
  // MyStateNotifier notifier = watch(provider);

  // After
  MyStateNotifier notifier = watch(provider.notifier);
}
```

--------------------------------

### Joke Model Class

Source: https://riverpod.dev/docs/tutorials/first_app

Defines the Joke data model with properties for type, setup, punchline, and id. Includes a `fromJson` factory constructor to parse JSON data into a Joke object.

```dart
class Joke {
  Joke({
    required this.type,
    required this.setup,
    required this.punchline,
    required this.id,
  });

  factory Joke.fromJson(Map<String, Object?> json) {
    return Joke(
      type: json['type']! as String,
      setup: json['setup']! as String,
      punchline: json['punchline']! as String,
      id: json['id']! as int,
    );
  }

  final String type;
  final String setup;
  final String punchline;
  final int id;
}
```

--------------------------------

### Testing Providers with Riverpod

Source: https://riverpod.dev/docs/from_provider/motivation

Demonstrates how to test Riverpod providers by overriding them with specific values in a test environment. This snippet shows the setup for a test case using `ProviderContainer` and `overrideWith`.

```Dart
void main() {
  test('it doubles the value correctly', () async {
    final container = ProviderContainer(
      overrides: [numberProvider.overrideWith((ref) => 9)],
    );
    final doubled = container.read(doubledProvider);
    expect(doubled, 9 * 2);
  });
}
```

--------------------------------

### Riverpod Codegen AsyncNotifier Example

Source: https://riverpod.dev/docs/migration/from_state_notifier

Illustrates the use of Riverpod's code generation with the @riverpod annotation for an AsyncNotifier. This approach further reduces boilerplate and integrates seamlessly with the build method parameters.

```dart
@riverpod
class BugsEncounteredNotifier extends _$BugsEncounteredNotifier {
  @override
  FutureOr<int> build(String featureId) {
    return 99;
  }

  Future<void> fix(int amount) async {
    final old = await future;
    final result = await ref
        .read(taskTrackerProvider)
        .fix(id: this.featureId, fixed: amount);
    state = AsyncData(max(old - result, 0));
  }
}

```

--------------------------------

### Eagerly Initialize Providers with ConsumerWidget

Source: https://riverpod.dev/docs/how_to/eager_initialization

This code snippet demonstrates how to eagerly initialize Riverpod providers by watching them in a `ConsumerWidget` placed directly under the `ProviderScope`. This ensures providers are initialized when the application starts, preventing lazy loading issues. It also shows how to return a child widget, preventing unnecessary rebuilds.

```dart
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _EagerInitialization(
      // TODO: Render your app here
      child: MaterialApp(),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize providers by watching them.
    // By using "watch", the provider will stay alive and not be disposed.
    ref.watch(myProvider);
    return child;
  }
}
```

--------------------------------

### Handle Loading and Error States for Eager Initialization

Source: https://riverpod.dev/docs/how_to/eager_initialization

This example shows how to handle loading and error states when eagerly initializing providers. The `_EagerInitialization` widget checks the state of the watched provider and displays a `CircularProgressIndicator` for loading or an error message if an error occurs, before rendering the child widget.

```dart
class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(myProvider);

    // Handle error states and loading states
    if (result.isLoading) {
      return const CircularProgressIndicator();
    } else if (result.hasError) {
      return const Text('Oopsy!');
    }

    return child;
  }
}
```

--------------------------------

### Riverpod Generator Provider with Debounce and Cancel Extension

Source: https://riverpod.dev/docs/how_to/cancel

This example shows how to use the `getDebouncedHttpClient` extension with Riverpod Generator's `@riverpod` annotation. It fetches activity data similarly to the previous example, benefiting from the combined debounce and cancel utility.

```dart
@riverpod
Future<Activity> activity(Ref ref) async {
  // We obtain an HTTP client using the extension we created earlier.
  final client = await ref.getDebouncedHttpClient();

  // We now use the client to make the request instead of the "get" function.
  // Our request will naturally be debounced and be cancelled if the user
  // leaves the page.
  final response = await client.get(
    Uri.https('www.boredapi.com', '/api/activity'),
  );

  final json = jsonDecode(response.body) as Map;
  return Activity.fromJson(Map.from(json));
}
```

--------------------------------

### Create Custom ProviderListenables with SyncProviderTransformerMixin

Source: https://riverpod.dev/docs/whats_new

Demonstrates how to create custom `ProviderListenable`s in Riverpod 3.0 using `SyncProviderTransformerMixin`. The example shows implementing a `where` condition for `provider.select` that filters updates based on a boolean callback.

```dart
final class Where<T> with SyncProviderTransformerMixin<T, T> {
  Where(this.source, this.where);
  @override
  final ProviderListenable<T> source;
  final bool Function(T previous, T value) where;

  @override
  ProviderTransformer<T, T> transform(
    ProviderTransformerContext<T, T> context,
  ) {
     return ProviderTransformer(
       initState: (_) => context.sourceState.requireValue,
       listener: (self, previous, next) {
         if (where(previous, next))
           self.state = next;
       },
     );
  }
}

extension<T> on ProviderListenable<T> {
  ProviderListenable<T> where(
    bool Function(T previous, T value) where,
  ) => Where<T>(this, where);
}
```

--------------------------------

### Define StateNotifier with StateNotifierProvider (Dart)

Source: https://riverpod.dev/docs/migration/0.13.0_to_0

Demonstrates the change in declaring a StateNotifierProvider. The new syntax requires an additional generic parameter for the state type.

```dart
class MyModel {}

class MyStateNotifier extends StateNotifier<MyModel> {
  MyStateNotifier(): super(MyModel());
}

// Before
// final provider = StateNotifierProvider<MyStateNotifier>((ref) {
//   return MyStateNotifier();
// });

// After
final provider = StateNotifierProvider<MyStateNotifier, MyModel>((ref) {
  return MyStateNotifier();
});
```

--------------------------------

### Fetch Activity Data with FutureProvider (Riverpod)

Source: https://riverpod.dev/docs/how_to/pull_to_refresh

Creates a Riverpod FutureProvider to asynchronously fetch a random activity from the Bored API. Handles HTTP GET requests and JSON decoding.

```dart
final activityProvider = FutureProvider.autoDispose<Activity>((ref) async {
  final response = await http.get(
    Uri.https('www.boredapi.com', '/api/activity'),
  );

  final json = jsonDecode(response.body) as Map;
  return Activity.fromJson(json);
});
```

--------------------------------

### StatefulWidget Fade-In Animation Example

Source: https://riverpod.dev/docs/concepts/about_hooks

This code snippet demonstrates how to implement a fade-in animation using a StatefulWidget in Flutter. It utilizes AnimationController and AnimatedBuilder to manage the animation and opacity of a child widget.

```Dart
class FadeIn extends StatefulWidget {
  const FadeIn({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Opacity(
          opacity: animationController.value,
          child: widget.child,
        );
      },
    );
  }
}

```

--------------------------------

### StateNotifierProvider.family.autoDispose Example (Old API)

Source: https://riverpod.dev/docs/migration/from_state_notifier

Demonstrates the definition of a StateNotifierProvider.family.autoDispose in Riverpod using the older API. It includes a Notifier class with explicit dependencies and state management.

```dart
class BugsEncounteredNotifier extends StateNotifier<AsyncValue<int>> {
  BugsEncounteredNotifier({
    required this.ref,
    required this.featureId,
  }) : super(const AsyncData(99));
  final String featureId;
  final Ref ref;

  Future<void> fix(int amount) async {
    state = await AsyncValue.guard(() async {
      final old = state.requireValue;
      final result =
          await ref.read(taskTrackerProvider).fix(id: featureId, fixed: amount);
      return max(old - result, 0);
    });
  }
}

final bugsEncounteredNotifierProvider = StateNotifierProvider.family
    .autoDispose<BugsEncounteredNotifier, AsyncValue<int>, String>((ref, id) {
  return BugsEncounteredNotifier(ref: ref, featureId: id);
});

```

--------------------------------

### Simplify Ref Usage in Code Generation

Source: https://riverpod.dev/docs/3

Shows how to migrate from using specific Ref subclasses like `ExampleRef` to the general `Ref` when using Riverpod's code generation.

```dart
@riverpod
-int example(ExampleRef ref) {
+int example(Ref ref) {
  // ...
}
```

--------------------------------

### Persist Riverpod Notifier State (Generated @riverpod)

Source: https://riverpod.dev/docs/concepts2/offline

This example shows how to persist the state of a Riverpod notifier using the generated `@riverpod` annotation. The `persist` method is called within the `build` method, similar to the previous example, requiring a storage provider, a unique key, and custom encoding/decoding logic for state serialization.

```dart
class Todo {
  Todo({required this.task});
  final String task;
}

@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    persist(
      // We pass in the previously created Storage.
      // Do not "await" this. Riverpod will handle it for you.
      ref.watch(storageProvider.future),
      // A unique identifier for this state.
      // If your provider receives parameters, make sure to encode those
      // in the key as well.
      key: 'todo_list',
      // Encode/decode the state. Here, we're using a basic JSON encoding.
      // You can use any encoding you want, as long as your Storage supports it.
      encode: (todos) => todos.map((todo) => {'task': todo.task}).toList(),
      decode: (json) => (json as List)
          .map((todo) => Todo(task: todo['task'] as String))
          .toList(),
    );

    // Regardless of whether some state was restored or not, we fetch the list of
    // todos from the server.
    return fetchTodosFromServer();
  }
}
```