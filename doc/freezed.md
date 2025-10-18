### Install Freezed and Dependencies (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Installs the necessary packages for using Freezed in a Dart project, including `freezed_annotation`, `build_runner`, `freezed`, and optionally `json_annotation` and `json_serializable` for JSON support.

```console
dart pub add freezed_annotation
dart pub add dev:build_runner
dart pub add dev:freezed
# If you want to use freezed to generate fromJson/toJson, run:
dart pub add json_annotation
dart pub add dev:json_serializable
```

--------------------------------

### Install Freezed and Dependencies (Flutter)

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Installs the necessary packages for using Freezed in a Flutter project, including `freezed_annotation`, `build_runner`, `freezed`, and optionally `json_annotation` and `json_serializable` for JSON support.

```console
flutter pub add freezed_annotation
flutter pub add dev:build_runner
flutter pub add dev:freezed
# If you want to use freezed to generate fromJson/toJson, run:
flutter pub add json_annotation
flutter pub add dev:json_serializable
```

--------------------------------

### VSCode Freezed Extension Usage

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Provides examples of using the VSCode Freezed extension to enhance productivity. It includes shortcuts for building the project with `build_runner` and for quickly generating Freezed classes.

```plaintext
Build: Ctrl+Shift+B (Cmd+Shift+B on Mac)
Generate Freezed Class: Ctrl+Shift+P > 'Freezed 클래스 생성'
```

--------------------------------

### YAML Freezed Project-Wide Configuration: build.yaml

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Provides an example of a 'build.yaml' file to configure Freezed code generation behavior across an entire project, such as disabling 'copyWith' and 'equal' globally.

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          # Tells Freezed to format .freezed.dart files.
          # This can significantly slow down code-generation.
          # Disabling formatting will only work when opting into Dart 3.7 as a minimum
          # in your project SDK constraints.
          format: true
          # Disable the generation of copyWith/== for the entire project
          copy_with: false
          equal: false
```

--------------------------------

### Install Freezed and Build Runner for Dart

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Installs the necessary packages for using Freezed with build_runner in a Dart project. It includes dev dependencies for build_runner and freezed, and the freezed_annotation package. Optionally includes json_annotation and json_serializable for JSON support.

```console
dart pub add \
  dev:build_runner \
  freezed_annotation \
  dev:freezed
# if using freezed to generate fromJson/toJson, also add:
dart pub add json_annotation dev:json_serializable
```

--------------------------------

### Freezed Class Pattern Matching with when()

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Illustrates using the `when()` method with Freezed classes that have multiple factory constructors. This example shows how to match different factory constructor signatures and extract their parameters within the callback functions.

```dart
@freezed
abstract class Model with _$Model {
  factory Model.first(String a) = First;
  factory Model.second(int b, bool c) = Second;
}

var model = Model.first('42');

print(
  model.when(
    first: (String a) => 'first $a',
    second: (int b, bool c) => 'second $b $c'
  ),
);
```

--------------------------------

### Basic Freezed File Setup in Dart

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Sets up a Dart file to use Freezed by importing the necessary annotation package and declaring the part file for generated code. It also suggests importing flutter/foundation.dart for enhanced readability in Flutter's devtools.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_file.freezed.dart';

// CONSIDER also importing package:flutter/foundation.dart
```

--------------------------------

### Install Freezed and Build Runner for Flutter

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Installs the necessary packages for using Freezed with build_runner in a Flutter project. It includes dev dependencies for build_runner and freezed, and the freezed_annotation package. Optionally includes json_annotation and json_serializable for JSON support.

```console
flutter pub add \
  dev:build_runner \
  freezed_annotation \
  dev:freezed
# if using freezed to generate fromJson/toJson, also add:
flutter pub add json_annotation dev:json_serializable
```

--------------------------------

### IntelliJ/Android Studio Freezed Live Templates

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Details the use of live templates in IntelliJ IDEA and Android Studio for generating Freezed boilerplate code. It provides examples for creating a basic Freezed class and a `fromJson` method for `json_serializable`.

```dart
// freezedClass template
@freezed
class Demo with _$Demo {
}

// freezedFromJson template
factory Demo.fromJson(Map<String, dynamic> json) => _$DemoFromJson(json);
```

--------------------------------

### Basic Freezed Model Structure

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Example of a basic Freezed class definition in Dart. It includes necessary imports, `part` directives for generated files, and the `@freezed` annotation to define an abstract class for model creation.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'my_file.freezed.dart';
```

--------------------------------

### JSON: Example with Custom Union Key and Value Case

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Presents JSON objects reflecting the customized 'unionKey' and 'unionValueCase' settings. The 'type' field now indicates the constructor, with values like 'Default', 'SpecialCase', and 'Error'.

```json
[
  {
    "type": "Default",
    "a": "This JSON object will use constructor MyResponse()"
  },
  {
    "type": "SpecialCase",
    "a": "This JSON object will use constructor MyResponse.special()",
    "b": 42
  },
  {
    "type": "Error",
    "message": "This JSON object will use constructor MyResponse.error()"
  }
]
```

--------------------------------

### Dart Pattern Matching with Switch

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Demonstrates reading data from a 'Example' union type using Dart's built-in switch statement with pattern matching. It extracts specific properties based on the union case.

```dart
switch (example) {
  Person(:final name) => print('Person $name'),
  City(:final population) => print('City ($population)'),
}
```

--------------------------------

### Add Freezed and Dependencies to Dart Project

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Installs the necessary packages for using Freezed in a Dart project, including freezed_annotation, build_runner, and optionally json_annotation and json_serializable for JSON support. These packages enable code generation for data classes and serialization.

```console
dart pub add freezed_annotation
dart pub add dev:build_runner
dart pub add dev:freezed
# fromJson/toJson 생성도 사용하려면 아래를 추가하세요:
dart pub add json_annotation
dart pub add dev:json_serializable
```

--------------------------------

### JSON: Example of Runtime Type Selection for Freezed Constructors

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Illustrates JSON objects that correspond to the Dart Freezed class defined previously. The 'runtimeType' field in each JSON object dictates which constructor (MyResponseData, MyResponseSpecial, or MyResponseError) will be used.

```json
[
  {
    "runtimeType": "default",
    "a": "This JSON object will use constructor MyResponse()"
  },
  {
    "runtimeType": "special",
    "a": "This JSON object will use constructor MyResponse.special()",
    "b": 42
  },
  {
    "runtimeType": "error",
    "message": "This JSON object will use constructor MyResponse.error()"
  }
]
```

--------------------------------

### Dart Pattern Matching with If-Case

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Shows an alternative way to read data from a 'Example' union type using Dart's if-case statements with pattern matching. This provides conditional logic for accessing union members.

```dart
if (example case Person(:final name)) {
  print('Person $name');
} else if (example case City(:final population)) {
  print('City ($population)');
}
```

--------------------------------

### Add Freezed and Dependencies to Flutter Project

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Installs the necessary packages for using Freezed in a Flutter project, including freezed_annotation, build_runner, and optionally json_annotation and json_serializable for JSON support. These packages facilitate code generation for data classes and serialization.

```console
flutter pub add freezed_annotation
flutter pub add dev:build_runner
flutter pub add dev:freezed
# fromJson/toJson 생성도 사용하려면 아래를 추가하세요:
flutter pub add json_annotation
flutter pub add dev:json_serializable
```

--------------------------------

### Add Freezed Linting Dependencies (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Installs the custom_lint and freezed_lint development dependencies for your Dart project. These tools help enforce Freezed-specific linting rules and catch common errors during development.

```console
dart pub add dev:custom_lint
dart pub add dev:freezed_lint
```

--------------------------------

### Dart Freezed Class for JsonSerializable Integration

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

A basic Freezed sealed class 'Model' with two factories, 'first' and 'second'. This serves as the starting point for integrating with json_serializable.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

@freezed
sealed class Model with _$Model {
  factory Model.first(String a) = First;
  factory Model.second(int b, bool c) = Second;
}
```

--------------------------------

### Dart Union Type Definition

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Defines a sealed union type 'Example' with two cases: 'person' and 'city'. This allows for distinct data structures within a single type.

```dart
@freezed
sealed class Example with _$Example {
  const factory Example.person(String name, int age) = Person;
  const factory Example.city(String name, int population) = City;
}
```

--------------------------------

### Dart Freezed Configuration: Disabling copyWith and equal

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Example of customizing Freezed generation for a specific class by passing arguments to the @Freezed annotation. This snippet shows how to disable 'copyWith' and 'equal' methods.

```dart
@Freezed(
  copyWith: false,
  equal: false,
)
class Person with _$Person {
  factory Person(String name, int age) = _Person;
}

```

--------------------------------

### Disabling Freezed Code Generation Globally via build.yaml

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Explains how to apply Freezed code generation customizations across an entire project by configuring the `build.yaml` file. This example shows how to disable `copyWith` and `equal` generation for all Freezed models in the project.

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          copy_with: false
          equal: false
```

--------------------------------

### Dart: Custom JSON Converter for Freezed Union Types

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Provides an example of a custom Dart JSON converter implementing `JsonConverter`. This converter includes custom logic to determine which Freezed constructor to use based on JSON content when automatic detection is not possible.

```dart
class MyResponseConverter implements JsonConverter<MyResponse, Map<String, dynamic>> {
  const MyResponseConverter();

  @override
  MyResponse fromJson(Map<String, dynamic> json) {
    // type data was already set (e.g. because we serialized it ourselves)
    if (json['runtimeType'] != null) {
      return MyResponse.fromJson(json);
    }
    // 你需要找到一些条件去知道这是什么类型。例如：检查 JSON 中的某些字段
    if (isTypeData) {
      return MyResponseData.fromJson(json);
    } else if (isTypeSpecial) {
      return MyResponseSpecial.fromJson(json);
    } else if (isTypeError) {
      return MyResponseError.fromJson(json);
    } else {
      throw Exception('Could not determine the constructor for mapping from JSON');
    }
 }

  @override
  Map<String, dynamic> toJson(MyResponse data) => data.toJson();
}
```

--------------------------------

### Dart: Custom JSON Converter for Freezed Union

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Provides an example of a custom JSON converter class that implements the JsonConverter interface. This converter handles the logic for determining which Freezed constructor to use based on custom conditions within the JSON data.

```dart
import 'package:json_annotation/json_annotation.dart';

// Assuming MyResponse and its constructors are defined elsewhere
// import 'my_response.dart';

class MyResponseConverter implements JsonConverter<MyResponse, Map<String, dynamic>> {
  const MyResponseConverter();

  @override
  MyResponse fromJson(Map<String, dynamic> json) {
    // type data was already set (e.g. because we serialized it ourselves)
    if (json['runtimeType'] != null) {
      return MyResponse.fromJson(json);
    }
    // you need to find some condition to know which type it is. e.g. check the presence of some field in the json
    if (isTypeData) { // Replace with actual logic to check for MyResponseData
      return MyResponseData.fromJson(json);
    } else if (isTypeSpecial) { // Replace with actual logic to check for MyResponseSpecial
      return MyResponseSpecial.fromJson(json);
    } else if (isTypeError) { // Replace with actual logic to check for MyResponseError
      return MyResponseError.fromJson(json);
    } else {
      throw Exception('Could not determine the constructor for mapping from JSON');
    }
  }

  @override
  Map<String, dynamic> toJson(MyResponse data) => data.toJson();
}

// Placeholder for the actual logic to determine type
bool get isTypeData => false; // Implement actual check
bool get isTypeSpecial => false; // Implement actual check
bool get isTypeError => false; // Implement actual check

// Dummy classes for compilation, replace with actual Freezed classes
sealed class MyResponse {}
class MyResponseData extends MyResponse { factory MyResponseData.fromJson(Map<String, dynamic> json) => MyResponseData(); Map<String, dynamic> toJson() => {};}
class MyResponseSpecial extends MyResponse { factory MyResponseSpecial.fromJson(Map<String, dynamic> json) => MyResponseSpecial(); Map<String, dynamic> toJson() => {};}
class MyResponseError extends MyResponse { factory MyResponseError.fromJson(Map<String, dynamic> json) => MyResponseError(); Map<String, dynamic> toJson() => {};}

```

--------------------------------

### Add Methods to Freezed Models

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

This example shows how to add custom methods to a Freezed model by defining a private, parameterless constructor `Person._()`. This allows the generated code to subclass the model instead of implementing it, enabling the inclusion of custom methods like `method()`.

```dart
@freezed
abstract class Person with _$Person {
  const Person._();

  const factory Person(String name, {int? age}) = _Person;

  void method() {
    print('hello world');
  }
}
```

--------------------------------

### Disabling Freezed Code Generation for Specific Classes

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Shows how to customize the generated code for a single Freezed class by passing parameters to the `@Freezed()` annotation. This example demonstrates disabling the generation of `copyWith` and `==` methods for a `Person` class.

```dart
@Freezed(
  copyWith: false,
  equal: false,
)
class Person with _$Person {
  factory Person(String name, int age) = _Person;
}
```

--------------------------------

### Integrating @JsonSerializable with Freezed Classes

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Shows how to combine Freezed with `@JsonSerializable` for more complex JSON handling. This example uses `@JsonSerializable(explicitToJson: true)` on a Freezed constructor to control JSON serialization behavior, such as explicitly including nested objects.

```dart
@freezed
abstract class Example with _$Example {
  @JsonSerializable(explicitToJson: true)
  factory Example(@JsonKey(name: 'my_property') SomeOtherClass myProperty) = _Example;

  factory Example.fromJson(Map<String, dynamic> json) => _$ExampleFromJson(json);
}
```

--------------------------------

### Dart: Define Mutable Classes with @unfreezed Annotation

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Shows how to define mutable data classes using the `@unfreezed` annotation instead of `@freezed`. This allows properties to be modified after instantiation. The example demonstrates mutable `firstName` and `lastName` fields, while `age` remains immutable due to the `final` keyword. Note that mutable classes do not generate custom `==`/`hashCode` implementations and cannot be instantiated with `const`.

```dart
@unfreezed
abstract class Person with _$Person {
  factory Person({
    required String firstName,
    required String lastName,
    required final int age,
  }) = _Person;

  factory Person.fromJson(Map<String, Object?> json) => _$PersonFromJson(json);
}
```

```dart
void main() {
  var person = Person(firstName: 'John', lastName: 'Smith', age: 42);

  person.firstName = 'Mona';
  person.lastName = 'Lisa';
}
```

```dart
void main() {
  var john = Person(firstName: 'John', lastName: 'Smith', age: 42);
  var john2 = Person(firstName: 'John', lastName: 'Smith', age: 42);

  print(john == john2); // false
}
```

--------------------------------

### Use Dart pattern matching instead of Freezed extensions (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/migration_guide.md

Freezed v3 replaces its custom `.map`/`.when` extensions with Dart's built-in pattern matching syntax. This change improves performance and aligns with standard Dart practices.

```diff
final model = Model.first('42');

-final res = model.map(
-  first: (String a) => 'first $a',
-  second: (int b, bool c) => 'second $b $c',
-);
+final res = switch (model) {
+  First(:final a) => 'first $a',
+  Second(:final b, :final c) => 'second $b $c',
+};

```

--------------------------------

### Configure Project-Wide Generic Argument Factories using build.yaml

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Shows how to configure the `freezed` builder globally for a project to enable `generic_argument_factories` by modifying the `build.yaml` file.

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          generic_argument_factories: true
```

--------------------------------

### YAML: Global Freezed Configuration for Union Key and Case

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Demonstrates how to configure global settings for Freezed's union key and value case handling within the `build.yaml` file for a project. This approach applies the specified settings to all Freezed classes unless overridden by decorators.

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          union_key: type
          union_value_case: pascal
```

--------------------------------

### YAML: Configuring Freezed project-wide via build.yaml

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Shows how to configure Freezed code generation globally for an entire project by using a 'build.yaml' file. This allows setting options like 'format', 'copy_with', and 'equal' for all Freezed models.

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          format: true
          copy_with: false
          equal: false

```

--------------------------------

### Freezed Union Pattern Matching with when()

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Demonstrates the usage of the `when()` method for pattern matching with Freezed unions. It shows how to handle different states of a union by providing callbacks for each constructor. This method is recommended for simple value extraction.

```dart
@freezed
abstract class Union with _$Union {
  const factory Union(int value) = Data;
  const factory Union.loading() = Loading;
  const factory Union.error([String? message]) = ErrorDetails;
}

var union = Union(42);

print(
  union.when(
    (int value) => 'Data $value',
    loading: () => 'loading',
    error: (String? message) => 'Error: $message',
  ),
);
```

--------------------------------

### Run Freezed Code Generator

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Commands to execute the Freezed code generator. Use `dart run build_runner build` for general Dart projects and `flutter pub run build_runner build` for Flutter projects. Ensure `freezed_annotation` is imported and `part` directives are used.

```shell
dart run build_runner build
```

```shell
flutter pub run build_runner build
```

--------------------------------

### Dart: Adding Comments to Freezed Properties

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/vi_VN/README.md

Demonstrates how to add documentation comments to properties within a Freezed class. These comments appear as standard Dart documentation.

```dart
@freezed
class Person with _$Person {
  const factory Person({
    /// Tên người dùng
    ///
    /// Không được null
    String? name,
    int? age,
    Gender? gender,
  }) = _Person;
}
```

--------------------------------

### VSCode Freezed Extension: Generate Freezed Class Command

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Illustrates a command provided by the VSCode Freezed extension to quickly generate a basic Freezed class structure. This is a shortcut for boilerplate code creation.

```plaintext
Ctrl+Shift+P > Generate Freezed class

```

--------------------------------

### Basic Freezed File Structure

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Demonstrates the required imports and `part` directive for a file that uses Freezed. It includes importing `freezed_annotation` and defining the generated file name.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_file.freezed.dart';
```

--------------------------------

### Run Freezed Code Generator

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Executes the build_runner watch command to continuously generate code based on Freezed annotations. This command should be run from the project's root directory.

```console
dart run build_runner watch -d
```

--------------------------------

### Dart: Basic Freezed Class Definition

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/vi_VN/README.md

Defines a basic data class 'Person' using the Freezed package. It includes nullable 'name', 'age', and 'gender' properties.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'your_file.freezed.dart';

@freezed
class Person with _$Person {
  const factory Person({
    String? name,
    int? age,
    Gender? gender,
  }) = _Person;
}

enum Gender { male, female, other }
```

--------------------------------

### Freezed Deep Copy Syntax in Dart

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Demonstrates the concise syntax for deep copying nested Freezed models, reducing boilerplate code compared to traditional nested copyWith calls.

```dart
@freezed
abstract class Company with _$Company {
  factory Company({String? name, required Director director}) = _Company;
}

@freezed
abstract class Director with _$Director {
  factory Director({String? name, Assistant? assistant}) = _Director;
}

@freezed
abstract class Assistant with _$Assistant {
  factory Assistant({String? name, int? age}) = _Assistant;
}

Company company;

// Original nested copyWith
Company newCompany = company.copyWith(
  director: company.director.copyWith(
    assistant: company.director.assistant.copyWith(
      name: 'John Smith',
    ),
  ),
);

// Freezed deep copy syntax
Company newCompany = company.copyWith.director.assistant(name: 'John Smith');

// Updating director's name
Company newCompany = company.copyWith.director(name: 'John Doe');

// Combined updates
company = company.copyWith(name: 'Google', director: Director(...));
company = company.copyWith.director(name: 'Larry', assistant: Assistant(...));

// Handling null safety with ?.call
Company? newCompany = company.copyWith.director.assistant?.call(name: 'John');
```

--------------------------------

### Applying Decorators and Doc Comments in Freezed

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Illustrates how to add documentation comments and decorators (like @deprecated) to properties and constructors within Freezed models, which are then applied to the generated code.

```dart
@freezed
abstract class Person with _$Person {
  const factory Person({
    /// The user's name.
    ///
    /// Cannot be null
    String? name,
    int? age,
    @deprecated Gender? gender, // Deprecates the property, constructor parameter, and copyWith parameter
  }) = _Person;
}

// To deprecate the entire generated class:
@freezed
abstract class Person with _$Person {
  @deprecated // Deprecates the generated class _Person
  const factory Person({
    String? name,
    int? age,
    Gender? gender,
  }) = _Person;
}
```

--------------------------------

### Dart Freezed Class Generation with IntelliJ/Android Studio Live Template

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Shows how to use a Live Template in IntelliJ IDEA or Android Studio to quickly generate the boilerplate for a Freezed class.

```dart
// Type 'freezedClass' and press Tab
@freezed
class Demo with _$Demo {
}
```

--------------------------------

### Freezed File Structure: Imports and Part Directive

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Demonstrates the standard file structure required for a Dart file using Freezed. It includes importing the freezed_annotation package and declaring the generated part file using the 'part' keyword.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_file.freezed.dart';

```

--------------------------------

### Dart Sealed Class with 'when' for Different Constructors

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Illustrates using the 'when' method with a sealed class that has constructors with different argument lists. Each callback in 'when' must match the constructor's name and signature.

```dart
@freezed
sealed class Model with _$Model {
  factory Model.first(String a) = First;
  factory Model.second(int b, bool c) = Second;
}

var model = Model.first('42');

print(
  model.when(
    first: (String a) => 'first $a',
    second: (int b, bool c) => 'second $b $c'
  ),
);

```

--------------------------------

### Run Freezed Code Generator

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Executes the build_runner command to run code generators, including Freezed, in a Dart or Flutter project. This command should be run from the project's root directory.

```console
dart run build_runner build
```

--------------------------------

### Require 'abstract' keyword for factory constructors (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/migration_guide.md

Classes utilizing factory constructors with Freezed now require the 'abstract' keyword. This change ensures proper handling of abstract classes and their implementations.

```diff
@freezed
-class Person with _$Person {
+abstract class Person with _$Person {
  const factory Person({
    required String firstName,
    required String lastName,
    required int age,
  }) = _Person;

  factory Person.fromJson(Map<String, Object?> json)
      => _$PersonFromJson(json);
}
```

--------------------------------

### IntelliJ/Android Studio Freezed Live Template: freezedFromJson

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Demonstrates a live template for IntelliJ/Android Studio that generates a 'fromJson' factory method, typically used in conjunction with json_serializable. Typing 'freezedFromJson' and pressing Tab inserts the factory method.

```dart
factory Demo.fromJson(Map<String, dynamic> json) => _$DemoFromJson(json);

```

--------------------------------

### Create a Person Model with Freezed

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Defines a `Person` model using Freezed, making it immutable and serializable. It includes required fields (`firstName`, `lastName`, `age`), a `fromJson` factory for deserialization, and utilizes `part 'main.freezed.dart'` and `part 'main.g.dart'` for code generation.

```dart
// 이 파일은 "main.dart" 입니다.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

// 필수: `main.dart`를 Freezed에서 생성한 코드와 연결합니다.
part 'main.freezed.dart';
// 옵션(선택사항): Person 클래스는 직렬화 가능하므로 이 줄을 추가해야 합니다.
// 그러나 Person이 직렬화 가능하지 않은 경우 건너뛸 수 있습니다.
part 'main.g.dart';

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String firstName,
    required String lastName,
    required int age,
  }) = _Person;

  factory Person.fromJson(Map<String, Object?> json)
      => _$PersonFromJson(json);
}
```

--------------------------------

### Dart: Handling Generic Types with `fromString` Decorators

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/vi_VN/README.md

Demonstrates the use of `@With.fromString` and `@Implements.fromString` for applying mixins and interfaces to Freezed classes with generic type parameters. This circumvents Dart compilation issues with generic annotations.

```dart
abstract class GeographicArea {}
abstract class House {}
abstract class Shop {}
abstract class AdministrativeArea<T> {}

@freezed
sealed class Example<T> with _$Example<T> {
  const factory Example.person(String name, int age) = Person<T>;

  @With.fromString('AdministrativeArea<T>')
  const factory Example.street(String name) = Street<T>;

  @With<House>()
  @Implements<Shop>()
  @Implements.fromString('AdministrativeArea<T>')
  const factory Example.city(String name, int population) = City<T>;
}
```

--------------------------------

### Deserializing Generic Freezed Classes with genericArgumentFactories

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Demonstrates how to enable deserialization for generic Freezed classes by setting `genericArgumentFactories: true`. This requires modifying the `fromJson` method signature and the Freezed configuration. It also shows an alternative project-wide configuration using `build.yaml`.

```dart
@Freezed(genericArgumentFactories: true)
sealed class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse.data(T data) = ApiResponseData;
  const factory ApiResponse.error(String message) = ApiResponseError;

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) => _$ApiResponseFromJson(json, fromJsonT);
}
```

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          generic_argument_factories: true
```

--------------------------------

### Dart Sealed Class with 'when' Method

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Demonstrates defining a sealed class using Freezed and using the generated 'when' method for pattern matching on different union cases. The 'when' method requires all cases to be handled.

```dart
@freezed
sealed class Union with _$Union {
  const factory Union(int value) = Data;
  const factory Union.loading() = Loading;
  const factory Union.error([String? message]) = ErrorDetails;
}

var union = Union(42);

print(
  union.when(
    (int value) => 'Data $value',
    loading: () => 'loading',
    error: (String? message) => 'Error: $message',
  ),
);

```

--------------------------------

### Dart Freezed Union with Factory Constructors and 'when' Method

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Illustrates the 'when' method with a Freezed class that uses factory constructors. The 'when' method's callbacks correspond to the factory constructor names and their parameter types.

```dart
@freezed
sealed class Model with _$Model {
  factory Model.first(String a) = First;
  factory Model.second(int b, bool c) = Second;
}

var model = Model.first('42');

print(
  model.when(
    first: (String a) => 'first $a',
    second: (int b, bool c) => 'second $b $c'
  ),
);

// Expected output: first 42
```

--------------------------------

### Dart Freezed fromJson Method Generation with IntelliJ/Android Studio Live Template

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Demonstrates using a Live Template in IntelliJ IDEA or Android Studio to generate the 'fromJson' factory method for a Freezed class, typically used with 'json_serializable'.

```dart
// Type 'freezedFromJson' and press Tab
factory Demo.fromJson(Map<String, dynamic> json) => _$DemoFromJson(json);
```

--------------------------------

### Freezed Deep Copy Syntax for Nested Models

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Demonstrates the advanced "deep copy" syntax provided by Freezed for efficiently updating properties within nested Freezed models. This syntax simplifies the process compared to chaining multiple `copyWith` calls.

```dart
@freezed
abstract class Company with _$Company {
  const factory Company({String? name, required Director director}) = _Company;
}

@freezed
abstract class Director with _$Director {
  const factory Director({String? name, Assistant? assistant}) = _Director;
}

@freezed
abstract class Assistant with _$Assistant {
  const factory Assistant({String? name, int? age}) = _Assistant;
}

// Example usage:
// Company company;
// Company newCompany = company.copyWith.director.assistant(name: 'John Smith');
// Company newCompany = company.copyWith.director(name: 'Larry');
// Company newCompany = company.copyWith(name: 'Google', director: Director(...));

```

--------------------------------

### IntelliJ/Android Studio Freezed Live Template: freezedClass

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Shows a live template available in IntelliJ/Android Studio for generating a Freezed class. Typing 'freezedClass' and pressing Tab inserts the basic structure for a Freezed class.

```dart
@freezed
class Demo with _$Demo {
}

```

--------------------------------

### Dart: Extending classes with Freezed and private constructors

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Illustrates how to extend a non-Freezed class using Freezed by employing a private constructor (`._()`) to handle superclass initialization. This provides full control over inheritance, especially useful for union types.

```dart
class Subclass {
  const Subclass.name(this.value);

  final int value;
}

@freezed
abstract class MyFreezedClass extends Subclass with _$MyFreezedClass {
  // We can receive parameters in this constructor, which we can use with `super.field`
  const MyFreezedClass._(super.value) : super.name();

  const factory MyFreezedClass(int value, /* other fields */) = _MyFreezedClass;
}
```

--------------------------------

### Add Freezed Lint and Custom Lint Dev Dependencies

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed_lint/README.md

This command adds the necessary dev dependencies for freezed_lint and custom_lint to your Flutter project. These packages are required for enabling custom linting rules.

```console
flutter pub add dev:custom_lint
flutter pub add dev:freezed_lint
```

--------------------------------

### Dart: Customizing Freezed model with @Freezed annotation

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Demonstrates how to customize Freezed code generation for a specific model using the @Freezed() annotation with parameters like 'copyWith' and 'equal'.

```dart
@Freezed()
abstract class Person with _$Person {
  factory Person(String name, int age) = _Person;
}

@Freezed(
  copyWith: false,
  equal: false,
)
 abstract class Person with _$Person {...}

```

--------------------------------

### Dart: Freezed Class with Multiple Constructors for JSON

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Demonstrates a Dart class using the Freezed package with multiple constructors. Freezed automatically uses the 'runtimeType' field in JSON to select the appropriate constructor during deserialization.

```dart
@freezed
sealed class MyResponse with _$MyResponse {
  const factory MyResponse(String a) = MyResponseData;
  const factory MyResponse.special(String a, int b) = MyResponseSpecial;
  const factory MyResponse.error(String message) = MyResponseError;

  factory MyResponse.fromJson(Map<String, dynamic> json) => _$MyResponseFromJson(json);
}
```

--------------------------------

### Dart Freezed Class with Documented Property

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Demonstrates how to add documentation comments to a specific property ('name') within a Freezed class. These comments are preserved and can be used for generating API documentation.

```dart
@freezed
abstract class Person with _$Person {
  const factory Person({
    /// The name of the user.
    ///
    /// Must not be null
    String? name,
    int? age,
    Gender? gender,
  }) = _Person;
}
```

--------------------------------

### Dart Freezed Union with Interface Implementation

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Illustrates how to make a Freezed union case implement a Dart interface using the `@Implements` annotation. This allows conforming to existing abstract contracts.

```dart
abstract class GeographicArea {
  int get population;
  String get name;
}

@freezed
sealed class Example with _$Example {
  const factory Example.person(String name, int age) = Person;

  @Implements<GeographicArea>()
  const factory Example.city(String name, int population) = City;
}

void main() {
  final city = Example.city('London', 9000000);
  if (city is City) {
    GeographicArea geoArea = city;
    print('Geographic Area: ${geoArea.name}, Population: ${geoArea.population}');
  }
}
```

--------------------------------

### Dart Freezed Sealed Union with 'when' Method

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Demonstrates the 'when' method for pattern matching with destructuring on a sealed union defined using Freezed. The 'when' method's signature adapts to the union's constructors.

```dart
@freezed
sealed class Union with _$Union {
  const factory Union(int value) = Data;
  const factory Union.loading() = Loading;
  const factory Union.error([String? message]) = ErrorDetails;
}

var union = Union(42);

print(
  union.when(
    (int value) => 'Data $value',
    loading: () => 'loading',
    error: (String? message) => 'Error: $message',
  ),
);

// Expected output: Data 42
```

--------------------------------

### Dart: Customizing Freezed Union Key and Value Case

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Shows how to customize the JSON key used for determining the constructor type ('unionKey') and how the values for these keys are cased ('unionValueCase') using Freezed decorators in Dart.

```dart
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
sealed class MyResponse with _$MyResponse {
  const factory MyResponse(String a) = MyResponseData;

  @FreezedUnionValue('SpecialCase')
  const factory MyResponse.special(String a, int b) = MyResponseSpecial;

  const factory MyResponse.error(String message) = MyResponseError;

  // ...
}
```

--------------------------------

### Dart Freezed Union with Generic Mixins and Interfaces

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Demonstrates advanced usage of `@With.fromString` and `@Implements.fromString` for applying mixins and interfaces to generic Freezed union cases when direct annotation causes issues.

```dart
abstract class GeographicArea {}
abstract class House {}
abstract class Shop {}
abstract class AdministrativeArea<T> {}

@freezed
sealed class Example<T> with _$Example<T> {
  const factory Example.person(String name, int age) = Person<T>;

  @With.fromString('AdministrativeArea<T>')
  const factory Example.street(String name) = Street<T>;

  @With<House>()
  @Implements<Shop>()
  @Implements.fromString('AdministrativeArea<T>')
  const factory Example.city(String name, int population) = City<T>;
}

void main() {
  // Example usage would require defining the abstract classes and potentially 
  // implementing them if they had abstract members.
  print('Example setup complete.');
}
```

--------------------------------

### Require 'sealed' keyword for factory constructors (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/migration_guide.md

Classes defined with factory constructors for sealed classes in Freezed now necessitate the 'sealed' keyword. This enforces the sealed nature of the class, restricting extensions.

```diff
@freezed
-class Model with _$Model {
+sealed class Model with _$Model {
  factory Model.first(String a) = First;
  factory Model.second(int b, bool c) = Second;
}
```

--------------------------------

### Freezed with Classic Dart Class and JSON Serialization

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Demonstrates defining a model using a standard Dart class with Freezed for code generation, including support for JSON serialization via `@JsonSerializable`. This approach allows for advanced constructor logic but requires manual JSON annotation.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main.freezed.dart'; 
part 'main.g.dart';

@freezed
@JsonSerializable()
class Person with _$Person {
  const Person({
    required this.firstName,
    required this.lastName,
    required this.age,
  });

  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final int age;

  factory Person.fromJson(Map<String, Object?> json)
      => _$PersonFromJson(json);

  Map<String, Object?> toJson() => _$PersonToJson(this);
}
```

--------------------------------

### Freezed Class Destructuring with map()

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/ko_KR/README.md

Explains and demonstrates the `map()` method in Freezed, which is similar to `when()` but provides the full object instance to the callback, allowing for more complex operations like calling `copyWith` or accessing properties directly. This is useful for performing side effects or transformations.

```dart
@freezed
abstract class Model with _$Model {
  factory Model.first(String a) = First;
  factory Model.second(int b, bool c) = Second;
}

var model = Model.first('42');

print(
  model.map(
    first: (First value) => 'first ${value.a}',
    second: (Second value) => 'second ${value.b} ${value.c}'
  ),
);

var model2 = Model.second(42, false);
print(
  model2.map(
    first: (value) => value,
    second: (value) => value.copyWith(c: true),
  )
);
```

--------------------------------

### Customizing Union Key and Value Case (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/README.md

Shows how to customize the JSON key used for determining the constructor ('unionKey') and the casing of its values ('unionValueCase') using Freezed decorators. This allows for flexible JSON mapping.

```dart
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
sealed class MyResponse with _$MyResponse {
  const factory MyResponse(String a) = MyResponseData;

  @FreezedUnionValue('SpecialCase')
  const factory MyResponse.special(String a, int b) = MyResponseSpecial;

  const factory MyResponse.error(String message) = MyResponseError;

  factory MyResponse.fromJson(Map<String, dynamic> json) =>
      _$MyResponseFromJson(json);
}
```

--------------------------------

### Dart Union Pattern Matching with Switch

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Demonstrates reading properties from a Freezed union type using Dart's built-in switch statement with pattern matching. This is the recommended approach for handling union types.

```dart
@freezed
sealed class Example with _$Example {
  const factory Example.person(String name, int age) = Person;
  const factory Example.city(String name, int population) = City;
}

void main() {
  Example example = Example.person('Alice', 30);

  switch (example) {
    Person(:final name) => print('Person $name'),
    City(:final population) => print('City ($population)'),
  }
}
```

--------------------------------

### Dart: Implementing Interfaces with Freezed

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/vi_VN/README.md

Uses the `@Implements` decorator to make a Freezed union member (`City`) conform to an abstract interface (`GeographicArea`). This ensures the union member has the required members defined by the interface.

```dart
abstract class GeographicArea {
  int get population;
  String get name;
}

@freezed
sealed class Example with _$Example {
  const factory Example.person(String name, int age) = Person;

  @Implements<GeographicArea>()
  const factory Example.city(String name, int population) = City;
}
```

--------------------------------

### YAML Freezed Configuration: Disabling copyWith and equal project-wide

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Demonstrates how to disable Freezed generation options like 'copyWith' and 'equal' for an entire project using a build.yaml configuration file. This provides a global override for Freezed behavior.

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          # 禁用生成 copyWith / == （整个项目）
          copy_with: false
          equal: false

```

--------------------------------

### Dart: Marking Freezed Constructors as Deprecated

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/vi_VN/README.md

Illustrates how to deprecate the entire constructor of a Freezed class or its generated private class. This affects the constructor calls and property access.

```dart
@freezed
class Person with _$Person {
  @deprecated
  const factory Person({
    String? name,
    int? age,
    Gender? gender,
  }) = _Person;
}
```

--------------------------------

### Integrating Freezed with json_serializable (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Shows how to configure Freezed models to work with the `json_serializable` package for automatic JSON serialization and deserialization. This involves adding a `part 'model.g.dart';` directive and a `fromJson` factory constructor.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';
part 'model.g.dart';

@freezed
sealed class Model with _$Model {
  factory Model.first(String a) = First;
  factory Model.second(int b, bool c) = Second;

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);
}
```

--------------------------------

### json_serializable Dependency Configuration (YAML)

Source: https://github.com/rrousselgit/freezed/blob/master/resources/translations/zh_CN/README.md

Specifies the necessary addition of `json_serializable` to the `dev_dependencies` section of a `pubspec.yaml` file to enable JSON serialization for Freezed models.

```yaml
dev_dependencies:
  json_serializable:
```

--------------------------------

### Define Person Model with Freezed (Dart)

Source: https://github.com/rrousselgit/freezed/blob/master/packages/freezed/README.md

Demonstrates creating a serializable, immutable data model named 'Person' using Freezed's primary constructor syntax. It includes properties for firstName, lastName, and age, along with JSON serialization capabilities.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'main.freezed.dart';
// optional: Since our Person class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
part 'main.g.dart';

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String firstName,
    required String lastName,
    required int age,
  }) = _Person;

  factory Person.fromJson(Map<String, Object?> json) => _$PersonFromJson(json);
}
```