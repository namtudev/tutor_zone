# Riverpod v3 & Freezed v3 Best Practices Guide (Generator Approach)

**Last Updated**: January 19, 2025
**Riverpod Version**: 3.0+
**Freezed Version**: 3.0+
**Approach**: Code Generation Only

---

## Table of Contents

1. [Overview](#overview)
2. [Setup and Dependencies](#setup-and-dependencies)
3. [Riverpod v3 Best Practices](#riverpod-v3-best-practices)
   - [Basic Provider Patterns](#basic-provider-patterns)
   - [Notifier Classes](#notifier-classes)
   - [Async Providers](#async-providers)
   - [Family Providers (Parameters)](#family-providers-parameters)
   - [State Management Patterns](#state-management-patterns)
   - [Error Handling](#error-handling)
   - [Provider Dependencies](#provider-dependencies)
4. [Freezed v3 Best Practices](#freezed-v3-best-practices)
   - [Basic Data Classes](#basic-data-classes)
   - [Union Types (Sealed Classes)](#union-types-sealed-classes)
   - [Pattern Matching](#pattern-matching)
   - [JSON Serialization](#json-serialization)
   - [Deep Copy](#deep-copy)
   - [Custom Methods](#custom-methods)
5. [Integration: Riverpod + Freezed](#integration-riverpod--freezed)
6. [Common Patterns and Use Cases](#common-patterns-and-use-cases)
7. [Migration Notes](#migration-notes)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This guide focuses exclusively on the **code generation approach** for Riverpod v3 and Freezed v3. Both libraries have evolved to embrace Dart 3's features, including sealed classes and pattern matching, resulting in cleaner, more type-safe code.

**Key Philosophy**:
- Use `@riverpod` annotation for all providers
- Use `sealed` or `abstract` keywords for Freezed classes
- Leverage Dart 3 pattern matching instead of generated `.map`/`.when` methods
- Embrace simplified APIs (no type parameters on `Ref`, no `AutoDispose` prefix)

---

## Setup and Dependencies

### pubspec.yaml

```yaml
name: tutor_zone
description: A professional Flutter application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.9.2 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.0.3
  riverpod_annotation: ^3.0.3

  # Immutable Models
  freezed_annotation: ^3.1.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.7.1
  riverpod_generator: ^3.0.3
  freezed: ^3.2.3
  json_serializable: ^6.11.1

  # Linting
  flutter_lints: ^5.0.0
  custom_lint: ^0.8.0
  riverpod_lint: ^3.0.3
  freezed_lint: ^0.2.0
```

### Running Code Generation

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
flutter pub run build_runner watch --delete-conflicting-outputs

# Short version
dart run build_runner watch -d
```

### File Structure

Every file using code generation should follow this pattern:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// For Freezed (data models)
part 'filename.freezed.dart';
part 'filename.g.dart'; // If using JSON serialization

// For Riverpod (providers)
part 'filename.g.dart';

// Your code here
```

---

## Riverpod v3 Best Practices

### Basic Provider Patterns

#### Simple Synchronous Provider (Functional)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// Simple value provider
@riverpod
String appTitle(Ref ref) {
  return 'Tutor Zone';
}

// Computed value provider
@riverpod
int totalCredits(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.credits ?? 0;
}

// Provider with dependencies
@riverpod
String greeting(Ref ref) {
  final name = ref.watch(userNameProvider);
  final title = ref.watch(appTitleProvider);
  return '$title - Welcome, $name!';
}
```

**Usage in Widget**:
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(appTitleProvider);
    return Text(title);
  }
}
```

#### Provider with Parameters (Family)

In Riverpod v3, you no longer use `family` - just add parameters to your provider function.

```dart
// Simple parameterized provider
@riverpod
Future<Student> fetchStudent(Ref ref, {required String studentId}) async {
  final api = ref.watch(apiServiceProvider);
  return api.getStudent(studentId);
}

// Multiple parameters with defaults
@riverpod
Future<List<Session>> fetchSessions(
  Ref ref, {
  required String userId,
  int page = 1,
  int limit = 20,
}) async {
  final api = ref.watch(apiServiceProvider);
  return api.getSessions(userId: userId, page: page, limit: limit);
}

// Generic provider
@riverpod
T multiply<T extends num>(Ref ref, T a, T b) {
  return (a * b) as T;
}
```

**Usage**:
```dart
// In widget
final student = ref.watch(fetchStudentProvider(studentId: 'abc123'));
final sessions = ref.watch(fetchSessionsProvider(userId: userId, page: 1));
final result = ref.watch(multiplyProvider<int>(2, 3)); // 6
```

### Notifier Classes

Notifiers are the recommended way to manage mutable state in Riverpod v3.

#### Basic Synchronous Notifier

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() {
    // Initialize state here
    return 0;
  }

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }

  void reset() {
    state = 0;
  }
}
```

**Usage**:
```dart
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final controller = ref.read(counterProvider.notifier);

    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: controller.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

#### Notifier with Dependencies

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  List<Todo> build() {
    // Watch other providers
    final userId = ref.watch(currentUserIdProvider);

    // Listen to changes and react
    ref.listen(syncStatusProvider, (previous, next) {
      if (next == SyncStatus.synced) {
        logInfo('Todos synced successfully');
      }
    });

    // Return initial state
    return [];
  }

  void addTodo(String description) {
    state = [
      ...state,
      Todo(
        id: DateTime.now().millisecondsSinceEpoch,
        description: description,
        completed: false,
      ),
    ];
  }

  void toggleTodo(int id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(completed: !todo.completed)
        else
          todo,
    ];
  }

  void removeTodo(int id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}
```

#### Notifier with Parameters (Former FamilyNotifier)

In Riverpod v3, `FamilyNotifier` is removed. Use constructor parameters instead.

```dart
// Before (Riverpod v2)
class CounterNotifier extends FamilyNotifier<int, String> {
  @override
  int build(String arg) {
    return 0;
  }
}

// After (Riverpod v3)
@riverpod
class Counter extends _$Counter {
  Counter(this.userId);

  final String userId;

  @override
  int build() {
    // Use this.userId here
    return 0;
  }

  void increment() {
    state++;
  }
}
```

**Note**: With code generation, parameters are handled automatically:

```dart
@riverpod
class StudentController extends _$StudentController {
  @override
  Student build(String studentId) {
    // studentId is automatically available as a parameter
    // Load student data
    final repo = ref.watch(studentRepositoryProvider);
    return repo.getStudent(studentId);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }
}
```

**Usage**:
```dart
final student = ref.watch(studentControllerProvider('student-123'));
final controller = ref.read(studentControllerProvider('student-123').notifier);
controller.updateName('New Name');
```

### Async Providers

#### Future Provider (Functional)

```dart
@riverpod
Future<User> currentUser(Ref ref) async {
  final api = ref.watch(apiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return api.getUser(userId);
}

// With error handling
@riverpod
Future<List<Student>> studentList(Ref ref) async {
  try {
    final api = ref.watch(apiServiceProvider);
    return await api.getStudents();
  } catch (e, stack) {
    logError('Failed to fetch students', e, stack);
    rethrow;
  }
}
```

#### AsyncNotifier (Class-based)

```dart
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<User> build() async {
    // Async initialization
    final userId = ref.watch(currentUserIdProvider);
    final api = ref.watch(apiServiceProvider);

    return await api.getUser(userId);
  }

  Future<void> updateProfile(String name, String email) async {
    // Set loading state
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      final updatedUser = await api.updateUser(
        name: name,
        email: email,
      );
      return updatedUser;
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      final api = ref.read(apiServiceProvider);
      return await api.getUser(userId);
    });
  }
}
```

**Usage**:
```dart
class UserProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      data: (user) => Text('Hello, ${user.name}'),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

#### Stream Provider

```dart
@riverpod
Stream<int> timer(Ref ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (count) => count,
  );
}

// Real-world example: Firestore stream
@riverpod
Stream<List<Session>> liveSessions(Ref ref, String userId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('sessions')
      .where('userId', isEqualTo: userId)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Session.fromJson(doc.data()))
          .toList());
}
```

#### StreamNotifier

```dart
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  Stream<List<Message>> build(String chatId) {
    final firestore = ref.watch(firestoreProvider);

    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String content) async {
    final firestore = ref.read(firestoreProvider);
    final userId = ref.read(currentUserIdProvider);

    await firestore
        .collection('chats')
        .doc(arg) // chatId from build parameter
        .collection('messages')
        .add({
      'content': content,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
```

### State Management Patterns

#### Loading States

```dart
@riverpod
class DataLoader extends _$DataLoader {
  @override
  AsyncValue<List<Item>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      return await api.fetchItems();
    });
  }
}
```

#### Pagination

```dart
@riverpod
class PaginatedStudents extends _$PaginatedStudents {
  @override
  Future<List<Student>> build() async {
    return _fetchPage(1);
  }

  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final currentData = state.value ?? [];
    state = AsyncValue.data(currentData); // Keep current data visible

    _currentPage++;
    final newData = await _fetchPage(_currentPage);

    if (newData.isEmpty || newData.length < 20) {
      _hasMore = false;
    }

    state = AsyncValue.data([...currentData, ...newData]);
  }

  Future<List<Student>> _fetchPage(int page) async {
    final api = ref.read(apiServiceProvider);
    return await api.getStudents(page: page, limit: 20);
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();

    final data = await _fetchPage(1);
    state = AsyncValue.data(data);
  }
}
```

#### Form State Management

```dart
@freezed
class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool isLoading,
    @Default(false) bool obscurePassword,
    String? emailError,
    String? passwordError,
    String? generalError,
  }) = _LoginFormState;
}

@riverpod
class LoginForm extends _$LoginForm {
  @override
  LoginFormState build() {
    return const LoginFormState();
  }

  void setEmail(String email) {
    state = state.copyWith(
      email: email,
      emailError: null,
    );
  }

  void setPassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: null,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(
      obscurePassword: !state.obscurePassword,
    );
  }

  Future<bool> submit() async {
    if (!_validate()) return false;

    state = state.copyWith(isLoading: true, generalError: null);

    try {
      final auth = ref.read(authServiceProvider);
      await auth.login(
        email: state.email,
        password: state.password,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: e.toString(),
      );
      return false;
    }
  }

  bool _validate() {
    String? emailError;
    String? passwordError;

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!state.email.contains('@')) {
      emailError = 'Invalid email format';
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
    } else if (state.password.length < 8) {
      passwordError = 'Password must be at least 8 characters';
    }

    if (emailError != null || passwordError != null) {
      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      );
      return false;
    }

    return true;
  }
}
```

### Error Handling

#### ProviderException Wrapper

In Riverpod v3, all provider errors are wrapped in `ProviderException`.

```dart
// Reading provider errors
try {
  final user = await ref.read(userProvider.future);
} on ProviderException catch (e) {
  if (e.exception is NetworkException) {
    // Handle network error
  } else if (e.exception is AuthException) {
    // Handle auth error
  }
}

// Using AsyncValue (no changes needed)
final userAsync = ref.watch(userProvider);
userAsync.when(
  data: (user) => Text(user.name),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) {
    // error is automatically unwrapped from ProviderException
    if (error is NetworkException) {
      return const Text('Network error');
    }
    return Text('Error: $error');
  },
);
```

#### Retry Configuration

Riverpod v3 enables automatic retry by default. You can customize it:

```dart
// Disable retry globally in ProviderScope
ProviderScope(
  retry: (retryCount, error) => null, // Never retry
  child: MyApp(),
)

// Disable retry for specific provider
Duration? retry(int retryCount, Object error) => null;

@Riverpod(retry: retry)
class TodoList extends _$TodoList {
  @override
  List<Todo> build() => [];
}

// Custom retry logic
Duration? customRetry(int retryCount, Object error) {
  // Don't retry on specific errors
  if (error is AuthException) return null;

  // Max 5 retries
  if (retryCount > 5) return null;

  // Exponential backoff
  return Duration(seconds: retryCount * 2);
}

@Riverpod(retry: customRetry)
Future<User> currentUser(Ref ref) async {
  // Implementation
}
```

### Provider Dependencies

Use the `dependencies` parameter to declare scoped providers:

```dart
// Root (non-scoped) provider
@riverpod
ApiService apiService(Ref ref) {
  return ApiService();
}

// Scoped provider
@Riverpod(dependencies: [])
String selectedStudentId(Ref ref) {
  return '';
}

// Provider that uses scoped provider
@Riverpod(dependencies: [selectedStudentId])
Future<Student> currentStudent(Ref ref) async {
  final studentId = ref.watch(selectedStudentIdProvider);
  final api = ref.watch(apiServiceProvider);
  return api.getStudent(studentId);
}

// Widget using scoped provider
@Dependencies([selectedStudentId])
class StudentView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ref.watch(selectedStudentIdProvider);
    return Text('Student: $studentId');
  }
}

// Override scoped provider
ProviderScope(
  overrides: [
    selectedStudentIdProvider.overrideWithValue('student-123'),
  ],
  child: StudentView(),
)
```

---

## Freezed v3 Best Practices

### Basic Data Classes

#### Simple Immutable Class

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart'; // For JSON serialization

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    int? age,
    @Default(false) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**Key Changes in v3**:
- Requires `abstract` or `sealed` keyword
- No changes to factory constructor syntax

#### Using copyWith

```dart
final user = User(
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  age: 30,
);

// Create new instance with modified fields
final updatedUser = user.copyWith(name: 'Jane Doe');
// User(id: '1', name: 'Jane Doe', email: 'john@example.com', age: 30)

// Set field to null
final userWithoutAge = user.copyWith(age: null);
// User(id: '1', name: 'John Doe', email: 'john@example.com', age: null)
```

### Union Types (Sealed Classes)

Union types represent mutually exclusive states. Use `sealed` keyword for unions.

#### Basic Union

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loading() = Loading;
  const factory AuthState.authenticated(User user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

#### Result Type Pattern

```dart
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String error, [StackTrace? stackTrace]) = Failure<T>;
  const factory Result.loading() = Loading<T>;
}

// Usage
Result<User> userResult = Result.success(user);
Result<List<Student>> studentsResult = Result.failure('Network error');
```

#### Network Response Pattern

```dart
@freezed
sealed class NetworkResponse<T> with _$NetworkResponse<T> {
  const factory NetworkResponse.data(T value) = Data<T>;
  const factory NetworkResponse.loading() = LoadingResponse<T>;
  const factory NetworkResponse.error([String? message]) = ErrorResponse<T>;
}
```

### Pattern Matching

**CRITICAL**: Freezed v3 no longer generates `.when`, `.map`, `.maybeWhen`, or `.maybeMap` methods. Use Dart 3's built-in pattern matching instead.

#### Switch Expression (Recommended)

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.authenticated(User user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
}

// Pattern matching with switch expression
String getMessage(AuthState state) {
  return switch (state) {
    Initial() => 'Initializing...',
    Authenticated(:final user) => 'Welcome, ${user.name}!',
    Unauthenticated() => 'Please sign in',
  };
}
```

#### If-Case Statement

```dart
void handleState(AuthState state) {
  if (state case Authenticated(:final user)) {
    print('User: ${user.name}');
  } else if (state case Unauthenticated()) {
    print('Not logged in');
  } else {
    print('Initializing');
  }
}
```

#### Pattern Matching in Widgets

```dart
class AuthWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return switch (authState) {
      Initial() => const CircularProgressIndicator(),
      Authenticated(:final user) => Text('Hello, ${user.name}'),
      Unauthenticated() => const LoginButton(),
    };
  }
}
```

#### Destructuring Multiple Properties

```dart
@freezed
sealed class Example with _$Example {
  const factory Example.person(String name, int age) = Person;
  const factory Example.city(String name, int population) = City;
}

void handleExample(Example example) {
  switch (example) {
    case Person(:final name, :final age):
      print('Person: $name, $age years old');
    case City(:final name, :final population):
      print('City: $name, population $population');
  }
}
```

#### Shared Properties

When properties are common across all union cases, they can be accessed directly:

```dart
@freezed
sealed class Example with _$Example {
  const factory Example.person(String name, int age) = Person;
  const factory Example.city(String name, int population) = City;
}

void printName(Example example) {
  // 'name' is accessible because it's in all cases
  print(example.name);

  // Can also use copyWith on shared properties
  final renamed = example.copyWith(name: 'New Name');
}
```

### JSON Serialization

#### Basic JSON Support

```dart
@freezed
abstract class Student with _$Student {
  const factory Student({
    required String id,
    required String name,
    required int age,
    @Default([]) List<String> subjects,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
}

// Usage
final json = {
  'id': '123',
  'name': 'Alice',
  'age': 16,
  'subjects': ['Math', 'Science'],
};

final student = Student.fromJson(json);
final backToJson = student.toJson();
```

#### JSON Key Customization

```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    @JsonKey(name: 'user_name') required String username,
    @JsonKey(name: 'email_address') required String email,
    @JsonKey(includeIfNull: false) String? phoneNumber,
    @JsonKey(defaultValue: 0) int credits,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

#### Union Type JSON Serialization

```dart
@freezed
sealed class ApiResponse with _$ApiResponse {
  const factory ApiResponse.success(Map<String, dynamic> data) = Success;
  const factory ApiResponse.error(String message, int code) = Error;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
}

// Generated JSON includes discriminator field
// { "runtimeType": "success", "data": {...} }
// { "runtimeType": "error", "message": "...", "code": 404 }
```

#### Custom JSON Converters

```dart
class TimestampConverter implements JsonConverter<DateTime, int> {
  const TimestampConverter();

  @override
  DateTime fromJson(int json) {
    return DateTime.fromMillisecondsSinceEpoch(json);
  }

  @override
  int toJson(DateTime object) {
    return object.millisecondsSinceEpoch;
  }
}

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String name,
    @TimestampConverter() required DateTime timestamp,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
```

### Deep Copy

Freezed provides deep copy syntax for nested objects:

```dart
@freezed
abstract class Company with _$Company {
  const factory Company({
    String? name,
    required Director director,
  }) = _Company;
}

@freezed
abstract class Director with _$Director {
  const factory Director({
    String? name,
    Assistant? assistant,
  }) = _Director;
}

@freezed
abstract class Assistant with _$Assistant {
  const factory Assistant({
    String? name,
    int? age,
  }) = _Assistant;
}

// Usage
final company = Company(
  name: 'Google',
  director: Director(
    name: 'John',
    assistant: Assistant(name: 'Jane', age: 25),
  ),
);

// Traditional nested copyWith
final updated1 = company.copyWith(
  director: company.director.copyWith(
    assistant: company.director.assistant?.copyWith(
      name: 'John Smith',
    ),
  ),
);

// Deep copy syntax (more concise)
final updated2 = company.copyWith.director.assistant(name: 'John Smith');

// Update director's name
final updated3 = company.copyWith.director(name: 'Jane Doe');

// Handle nullable nested properties
final updated4 = company.copyWith.director.assistant?.call(age: 30);
```

### Custom Methods

Add custom methods to Freezed classes using a private constructor:

```dart
@freezed
abstract class User with _$User {
  const User._(); // Private constructor for custom methods

  const factory User({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    @Default(0) int credits,
  }) = _User;

  // Custom getters
  String get fullName => '$firstName $lastName';
  bool get hasCredits => credits > 0;

  // Custom methods
  bool canPurchase(int amount) {
    return credits >= amount;
  }

  String displayName() {
    return fullName;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Usage
final user = User(
  id: '1',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  credits: 100,
);

print(user.fullName); // John Doe
print(user.canPurchase(50)); // true
```

#### Custom Methods in Union Types

```dart
@freezed
sealed class PaymentStatus with _$PaymentStatus {
  const PaymentStatus._();

  const factory PaymentStatus.pending() = Pending;
  const factory PaymentStatus.processing(String transactionId) = Processing;
  const factory PaymentStatus.completed(String receipt) = Completed;
  const factory PaymentStatus.failed(String reason) = Failed;

  // Custom methods available on all cases
  bool get isFinalized => switch (this) {
    Completed() => true,
    Failed() => true,
    _ => false,
  };

  String get displayText => switch (this) {
    Pending() => 'Payment pending',
    Processing(:final transactionId) => 'Processing: $transactionId',
    Completed(:final receipt) => 'Completed: $receipt',
    Failed(:final reason) => 'Failed: $reason',
  };
}
```

---

## Integration: Riverpod + Freezed

### Typical Pattern

```dart
// models/student.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
abstract class Student with _$Student {
  const factory Student({
    required String id,
    required String name,
    required int age,
    required String email,
    @Default([]) List<String> enrolledCourses,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
}

// controllers/student_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/models/student.dart';

part 'student_controller.g.dart';

@riverpod
class StudentController extends _$StudentController {
  @override
  Future<Student> build(String studentId) async {
    final api = ref.watch(apiServiceProvider);
    return await api.getStudent(studentId);
  }

  Future<void> updateName(String name) async {
    // Optimistic update
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(name: name));
    }

    // Server update
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      return await api.updateStudent(
        studentId: arg,
        name: name,
      );
    });
  }

  Future<void> enrollCourse(String courseName) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(
      current.copyWith(
        enrolledCourses: [...current.enrolledCourses, courseName],
      ),
    );

    await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      await api.enrollStudent(
        studentId: arg,
        courseName: courseName,
      );
    });
  }
}
```

### Form State with Freezed + Riverpod

```dart
// Form state model
@freezed
class RegistrationFormState with _$RegistrationFormState {
  const factory RegistrationFormState({
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(false) bool agreeToTerms,
    @Default(false) bool isSubmitting,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? generalError,
  }) = _RegistrationFormState;
}

// Form controller
@riverpod
class RegistrationForm extends _$RegistrationForm {
  @override
  RegistrationFormState build() {
    return const RegistrationFormState();
  }

  void setName(String name) {
    state = state.copyWith(name: name, nameError: null);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  void setConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password, confirmPasswordError: null);
  }

  void setAgreeToTerms(bool value) {
    state = state.copyWith(agreeToTerms: value);
  }

  Future<bool> submit() async {
    if (!_validate()) return false;

    state = state.copyWith(isSubmitting: true, generalError: null);

    try {
      final auth = ref.read(authServiceProvider);
      await auth.register(
        name: state.name,
        email: state.email,
        password: state.password,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        generalError: e.toString(),
      );
      return false;
    }
  }

  bool _validate() {
    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmPasswordError;

    if (state.name.isEmpty) {
      nameError = 'Name is required';
    }

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!state.email.contains('@')) {
      emailError = 'Invalid email format';
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
    } else if (state.password.length < 8) {
      passwordError = 'Password must be at least 8 characters';
    }

    if (state.password != state.confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    if (!state.agreeToTerms) {
      return false;
    }

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      state = state.copyWith(
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      );
      return false;
    }

    return true;
  }
}
```

---

## Common Patterns and Use Cases

### Repository Pattern

```dart
// models/todo.dart
@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String description,
    @Default(false) bool completed,
    DateTime? dueDate,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

// repositories/todo_repository.dart
@riverpod
TodoRepository todoRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return TodoRepository(firestore);
}

class TodoRepository {
  TodoRepository(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<Todo>> fetchTodos(String userId) async {
    final snapshot = await firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => Todo.fromJson(doc.data()))
        .toList();
  }

  Future<void> addTodo(String userId, Todo todo) async {
    await firestore
        .collection('todos')
        .doc(todo.id)
        .set(todo.toJson()..['userId'] = userId);
  }

  Future<void> updateTodo(Todo todo) async {
    await firestore
        .collection('todos')
        .doc(todo.id)
        .update(todo.toJson());
  }

  Future<void> deleteTodo(String id) async {
    await firestore.collection('todos').doc(id).delete();
  }
}

// controllers/todo_controller.dart
@riverpod
class TodoController extends _$TodoController {
  @override
  Future<List<Todo>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    final repo = ref.watch(todoRepositoryProvider);
    return await repo.fetchTodos(userId);
  }

  Future<void> addTodo(String description, {DateTime? dueDate}) async {
    final userId = ref.read(currentUserIdProvider);
    final repo = ref.read(todoRepositoryProvider);

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      dueDate: dueDate,
    );

    // Optimistic update
    state.whenData((todos) {
      state = AsyncValue.data([...todos, todo]);
    });

    // Server update
    await repo.addTodo(userId, todo);
  }

  Future<void> toggleTodo(String id) async {
    final repo = ref.read(todoRepositoryProvider);

    state.whenData((todos) {
      final updatedTodos = todos.map((todo) {
        if (todo.id == id) {
          final updated = todo.copyWith(completed: !todo.completed);
          repo.updateTodo(updated);
          return updated;
        }
        return todo;
      }).toList();

      state = AsyncValue.data(updatedTodos);
    });
  }

  Future<void> deleteTodo(String id) async {
    final repo = ref.read(todoRepositoryProvider);

    state.whenData((todos) {
      state = AsyncValue.data(
        todos.where((todo) => todo.id != id).toList(),
      );
    });

    await repo.deleteTodo(id);
  }
}
```

### Network Request State

```dart
@freezed
sealed class ApiState<T> with _$ApiState<T> {
  const factory ApiState.idle() = Idle<T>;
  const factory ApiState.loading() = ApiLoading<T>;
  const factory ApiState.success(T data) = ApiSuccess<T>;
  const factory ApiState.error(String message) = ApiError<T>;
}

@riverpod
class DataFetcher extends _$DataFetcher {
  @override
  ApiState<List<Student>> build() {
    return const ApiState.idle();
  }

  Future<void> fetchStudents() async {
    state = const ApiState.loading();

    try {
      final api = ref.read(apiServiceProvider);
      final students = await api.getStudents();
      state = ApiState.success(students);
    } catch (e) {
      state = ApiState.error(e.toString());
    }
  }

  void reset() {
    state = const ApiState.idle();
  }
}

// In widget
final dataState = ref.watch(dataFetcherProvider);

return switch (dataState) {
  Idle() => ElevatedButton(
      onPressed: () => ref.read(dataFetcherProvider.notifier).fetchStudents(),
      child: const Text('Load Data'),
    ),
  ApiLoading() => const CircularProgressIndicator(),
  ApiSuccess(:final data) => ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => Text(data[index].name),
    ),
  ApiError(:final message) => Text('Error: $message'),
};
```

### Navigation State

```dart
@freezed
sealed class AppRoute with _$AppRoute {
  const factory AppRoute.splash() = SplashRoute;
  const factory AppRoute.login() = LoginRoute;
  const factory AppRoute.home() = HomeRoute;
  const factory AppRoute.studentDetails(String studentId) = StudentDetailsRoute;
  const factory AppRoute.settings() = SettingsRoute;
}

@riverpod
class NavigationController extends _$NavigationController {
  @override
  AppRoute build() {
    return const AppRoute.splash();
  }

  void navigateToLogin() {
    state = const AppRoute.login();
  }

  void navigateToHome() {
    state = const AppRoute.home();
  }

  void navigateToStudentDetails(String studentId) {
    state = AppRoute.studentDetails(studentId);
  }

  void navigateToSettings() {
    state = const AppRoute.settings();
  }
}

// In widget
final route = ref.watch(navigationControllerProvider);

return switch (route) {
  SplashRoute() => const SplashScreen(),
  LoginRoute() => const LoginScreen(),
  HomeRoute() => const HomeScreen(),
  StudentDetailsRoute(:final studentId) => StudentDetailsScreen(studentId: studentId),
  SettingsRoute() => const SettingsScreen(),
};
```

---

## Migration Notes

### Riverpod v2 → v3

1. **Ref Type Parameters Removed**
   ```dart
   // Before
   @riverpod
   int example(ExampleRef ref) { }

   // After
   @riverpod
   int example(Ref ref) { }
   ```

2. **AutoDispose Removed**
   ```dart
   // Before
   class MyNotifier extends AutoDisposeNotifier<int> { }

   // After (just remove AutoDispose)
   class MyNotifier extends Notifier<int> { }
   ```

3. **FamilyNotifier Removed**
   ```dart
   // Before
   class Counter extends FamilyNotifier<int, String> {
     @override
     int build(String arg) { }
   }

   // After
   class Counter extends Notifier<int> {
     Counter(this.arg);
     final String arg;

     @override
     int build() { }
   }

   // Or with code generation
   @riverpod
   class Counter extends _$Counter {
     @override
     int build(String arg) { } // arg is automatically available
   }
   ```

4. **ProviderException Wrapping**
   ```dart
   // Before
   try {
     await ref.read(provider.future);
   } on NotFoundException { }

   // After
   try {
     await ref.read(provider.future);
   } on ProviderException catch (e) {
     if (e.exception is NotFoundException) { }
   }
   ```

5. **Automatic Retry**
   ```dart
   // Disable globally
   ProviderScope(
     retry: (retryCount, error) => null,
     child: MyApp(),
   )

   // Custom per-provider
   @Riverpod(retry: customRetryFunction)
   class MyProvider extends _$MyProvider { }
   ```

### Freezed v2 → v3

1. **Sealed/Abstract Keyword Required**
   ```dart
   // Before
   @freezed
   class Person with _$Person { }

   // After (simple class)
   @freezed
   abstract class Person with _$Person { }

   // After (union type)
   @freezed
   sealed class Result with _$Result { }
   ```

2. **Pattern Matching Instead of .when/.map**
   ```dart
   // Before
   final result = model.map(
     first: (value) => 'first ${value.a}',
     second: (value) => 'second ${value.b}',
   );

   // After
   final result = switch (model) {
     First(:final a) => 'first $a',
     Second(:final b) => 'second $b',
   };
   ```

---

## Troubleshooting

### Code Generation Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Common Errors

#### "Missing part directive"
```dart
// Add to top of file
part 'filename.freezed.dart';
part 'filename.g.dart'; // If using JSON serialization
```

#### "Class must extend _$ClassName"
```dart
// Correct
@riverpod
class Example extends _$Example {
  @override
  int build() => 0;
}
```

#### "Build method not found"
```dart
// All notifiers must have build()
@riverpod
class Example extends _$Example {
  @override
  int build() { // Required
    return 0;
  }
}
```

#### Freezed class requires sealed/abstract
```dart
// Wrong
@freezed
class Person with _$Person { }

// Correct
@freezed
abstract class Person with _$Person { }

// Or for union types
@freezed
sealed class Result with _$Result { }
```

### Build.yaml Configuration

Create `build.yaml` in project root for custom configuration:

```yaml
targets:
  $default:
    builders:
      # Riverpod configuration
      riverpod_generator:
        options:
          provider_name_prefix: ""
          provider_name_suffix: "Provider"
          provider_family_name_suffix: "Provider"
          provider_name_strip_pattern: "Notifier$"

      # Freezed configuration
      freezed:
        options:
          # Format generated files (can slow down generation)
          format: true
          # Disable copyWith/== globally
          # copy_with: false
          # equal: false
          # Union type JSON configuration
          # union_key: type
          # union_value_case: pascal
```

---

## Summary

### Key Takeaways

1. **Always use code generation** - No manual provider creation
2. **Riverpod v3 simplifications**:
   - `Ref` has no type parameters
   - No `AutoDispose` prefix needed
   - No `Family` variants - use parameters directly
   - Errors wrapped in `ProviderException`
   - Auto-retry enabled by default

3. **Freezed v3 requirements**:
   - Use `sealed` or `abstract` keyword
   - Pattern matching with Dart 3 syntax
   - No `.when`/`.map` generated methods

4. **Best practices**:
   - Use Notifier classes for mutable state
   - Use functional providers for computed values
   - Leverage pattern matching for union types
   - Use deep copy syntax for nested models
   - Always run code generation before building

### Quick Reference

```dart
// Riverpod provider
@riverpod
String example(Ref ref) => 'Hello';

// Riverpod notifier
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  void increment() => state++;
}

// Freezed data class
@freezed
abstract class User with _$User {
  const factory User({required String name}) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Freezed union
@freezed
sealed class Result with _$Result {
  const factory Result.success(int value) = Success;
  const factory Result.error(String message) = Error;
}

// Pattern matching
final message = switch (result) {
  Success(:final value) => 'Success: $value',
  Error(:final message) => 'Error: $message',
};
```

---

**End of Guide**

For more information:
- [Riverpod Documentation](https://riverpod.dev)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- Project files: `doc/riverpod_v3`, `doc/freezed_v3`
