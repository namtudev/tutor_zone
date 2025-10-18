### Basic GoRouter Configuration

Source: https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic

Demonstrates the fundamental setup of GoRouter with a simple route for the home screen. This configuration is essential for initializing navigation in a Flutter app.

```dart
import 'package:go_router/go_router.dart';

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
  ],
);

```

--------------------------------

### go_router API Documentation Topics

Source: https://pub.dev/documentation/go_router/latest/index

Lists the various topics covered in the go_router API documentation, providing links to detailed guides on getting started, configuration, navigation, redirection, web support, deep linking, transitions, type-safe routes, named routes, and error handling.

```APIDOC
See the API documentation for details on the following topics:
  * [Getting started](https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html)
  * [Upgrade an existing app](https://pub.dev/documentation/go_router/latest/topics/Upgrading-topic.html)
  * [Configuration](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
  * [Navigation](https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html)
  * [Redirection](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
  * [Web](https://pub.dev/documentation/go_router/latest/topics/Web-topic.html)
  * [Deep linking](https://pub.dev/documentation/go_router/latest/topics/Deep%20linking-topic.html)
  * [Transition animations](https://pub.dev/documentation/go_router/latest/topics/Transition%20animations-topic.html)
  * [Type-safe routes](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html)
  * [Named routes](https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic.html)
  * [Error handling](https://pub.dev/documentation/go_router/latest/topics/Error%20handling-topic.html)
```

--------------------------------

### GoRouteData buildPage Method Implementation Example

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRouteData/buildPage

Provides a default implementation example for the buildPage method. This example shows how to return a NoOpPage, which is a placeholder that allows the framework to use a default Page implementation.

```dart
Page<void> buildPage(BuildContext context, GoRouterState state) =>
    const NoOpPage();
```

--------------------------------

### go_router Topics

Source: https://pub.dev/documentation/go_router/latest/index

Key topics covered in the go_router documentation, including getting started, upgrading, configuration, navigation, redirection, web support, deep linking, transition animations, type-safe routes, named routes, and error handling.

```dart
// Topics covered:
// - Get started
// - Upgrading
// - Configuration
// - Navigation
// - Redirection
// - Web
// - Deep linking
// - Transition animations
// - Type-safe routes
// - Named routes
// - Error handling
```

--------------------------------

### go_router Migration Guides

Source: https://pub.dev/documentation/go_router/latest/index

Provides links to migration guides for various versions of the go_router package, detailing breaking changes and how to upgrade existing Flutter applications.

```APIDOC
## Migration Guides
  * [Migrating to 16.0.0](https://flutter.dev/go/go-router-v16-breaking-changes).
  * [Migrating to 15.0.0](https://flutter.dev/go/go-router-v15-breaking-changes).
  * [Migrating to 14.0.0](https://flutter.dev/go/go-router-v14-breaking-changes).
  * [Migrating to 13.0.0](https://flutter.dev/go/go-router-v13-breaking-changes).
  * [Migrating to 12.0.0](https://flutter.dev/go/go-router-v12-breaking-changes).
  * [Migrating to 11.0.0](https://flutter.dev/go/go-router-v11-breaking-changes).
  * [Migrating to 10.0.0](https://flutter.dev/go/go-router-v10-breaking-changes).
  * [Migrating to 9.0.0](https://flutter.dev/go/go-router-v9-breaking-changes).
  * [Migrating to 8.0.0](https://flutter.dev/go/go-router-v8-breaking-changes).
  * [Migrating to 7.0.0](https://flutter.dev/go/go-router-v7-breaking-changes).
  * [Migrating to 6.0.0](https://flutter.dev/go/go-router-v6-breaking-changes)
  * [Migrating to 5.1.2](https://flutter.dev/go/go-router-v5-1-2-breaking-changes)
  * [Migrating to 5.0](https://flutter.dev/go/go-router-v5-breaking-changes)
  * [Migrating to 4.0](https://flutter.dev/go/go-router-v4-breaking-changes)
  * [Migrating to 3.0](https://flutter.dev/go/go-router-v3-breaking-changes)
  * [Migrating to 2.5](https://flutter.dev/go/go-router-v2-5-breaking-changes)
  * [Migrating to 2.0](https://flutter.dev/go/go-router-v2-breaking-changes)
```

--------------------------------

### Configure GoRouter in Flutter App

Source: https://pub.dev/documentation/go_router/latest/topics/Get started-topic

Demonstrates how to define routes and create a GoRouter configuration object for a Flutter application. This is the primary step for integrating go_router.

```dart
import 'package:go_router/go_router.dart';

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
  ],
);

```

--------------------------------

### NavigatorBuilder Typedef Implementation Example

Source: https://pub.dev/documentation/go_router/latest/go_router/NavigatorBuilder

Provides a concrete implementation example of the NavigatorBuilder typedef, showing how to define a function that matches the required signature for building a navigator.

```dart
typedef NavigatorBuilder = Widget Function(
    GlobalKey<NavigatorState> navigatorKey,
    ShellRouteMatch match,
    RouteMatchList matchList,
    List<NavigatorObserver>? observers,
    String? restorationScopeId);
```

--------------------------------

### go_router redirect method implementation example

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRouteData/redirect

A basic implementation example of the redirect method, returning null to indicate no redirection is needed.

```dart
FutureOr<String?> redirect(BuildContext context, GoRouterState state) => null;
```

--------------------------------

### Basic GoRouter Configuration

Source: https://pub.dev/documentation/go_router/latest/topics/Configuration-topic

Demonstrates the fundamental setup of a GoRouter with a list of GoRoute objects, defining paths and their corresponding builders.

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Page1Screen(),
    ),
    GoRoute(
      path: '/page2',
      builder: (context, state) => const Page2Screen(),
    ),
  ],
);
```

--------------------------------

### Configure GoRouter with Routes

Source: https://pub.dev/documentation/go_router/latest/topics/Configuration-topic

Demonstrates the basic setup of a GoRouter instance by providing a list of GoRoute objects, each defining a path and its corresponding builder function.

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Page1Screen(),
    ),
    GoRoute(
      path: '/page2',
      builder: (context, state) => const Page2Screen(),
    ),
  ],
);
```

--------------------------------

### initState Implementation Example

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulNavigationShellState/initState

This code snippet shows the specific implementation of the initState method within the StatefulNavigationShellState class for the go_router package.

```dart
@override
void initState() {
  super.initState();
  _updateCurrentBranchStateFromWidget();
}
```

--------------------------------

### Configure GoRouter in Flutter App

Source: https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic

Demonstrates how to define routes and create a GoRouter configuration object for a Flutter application. This is the primary step for integrating go_router.

```dart
import 'package:go_router/go_router.dart';

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
  ],
);

```

--------------------------------

### Example Path Pattern

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteMatchList/fullPath

Illustrates a typical full path pattern used by the go_router package to match URIs, including parameters.

```string
'/family/:fid/person/:pid'
```

--------------------------------

### Integrating GoRouter with MaterialApp.router

Source: https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic

Shows how to integrate the GoRouter configuration with the MaterialApp.router widget. This is the standard way to enable routing in a Flutter application using go_router.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

```

--------------------------------

### ShellRoute Builder Example

Source: https://pub.dev/documentation/go_router/latest/go_router/ShellRoute-class

Illustrates a basic implementation of the ShellRoute builder, showing how to wrap child routes within a Scaffold with an AppBar and body.

```dart
ShellRoute(
  builder: (BuildContext context, GoRouterState state, Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Shell')
      ),
      body: Center(
        child: child,
      ),
    );
  },
  routes: [
    GoRoute(
      path: 'a'
      builder: (BuildContext context, GoRouterState state) {
        return Text('Child Route "/a"');
      }
    ),
  ],
),
```

--------------------------------

### go_router createRoute Implementation Example

Source: https://pub.dev/documentation/go_router/latest/go_router/CustomTransitionPage/createRoute

An example implementation of the createRoute method, typically used within a Page class to return a specific Route type, such as a CustomTransitionPageRoute.

```Dart
@override
Route<T> createRoute(BuildContext context) =>
    _CustomTransitionPageRoute<T>(this);
```

--------------------------------

### Integrate GoRouter Configuration with MaterialApp

Source: https://pub.dev/documentation/go_router/latest/topics/Get started-topic

Shows how to use the GoRouter configuration object with the routerConfig parameter of MaterialApp.router or CupertinoApp.router to enable routing in your Flutter app.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

```

--------------------------------

### GoRoute Path Example

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRoute/path

Demonstrates how to define a route using the 'path' property in the GoRoute constructor. It shows a basic route for the home page.

```dart
GoRoute(
  path: '/',
  pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage<void>(
    key: state.pageKey,
    child: HomePage(families: Families.data),
  ),
)
```

--------------------------------

### GoRouter Class Documentation

Source: https://pub.dev/documentation/go_router/latest/topics/Web-topic

Provides detailed information about the GoRouter class, its methods, and how to configure it for routing in Flutter applications. This includes setup, navigation, and handling of various routing scenarios.

```APIDOC
GoRouter:
  A route configuration for the app.

  Topics:
    - Get started
    - Upgrading
    - Configuration
    - Navigation
    - Redirection
    - Web
    - Deep linking
    - Named routes
    - Error handling

  Methods:
    - `GoRouter.of(context)`: Access the nearest GoRouter instance.
    - `GoRouter.of(context).go(location)`: Navigate to a new location.
    - `GoRouter.of(context).push(location)`: Push a new route onto the stack.
    - `GoRouter.of(context).pop()`: Pop the current route off the stack.

  Configuration:
    - `routes`: A list of `GoRoute` objects defining the app's routes.
    - `errorBuilder`: A builder for handling errors.
    - `redirect`: A function for handling route redirections.

  Web Specifics:
    - Supports hash fragment or URL path for navigation.
    - Refer to Flutter's URL strategy documentation for web configuration.
```

--------------------------------

### Integrate GoRouter Configuration with MaterialApp

Source: https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic

Shows how to use the GoRouter configuration object with the routerConfig parameter of MaterialApp.router or CupertinoApp.router to enable routing in your Flutter app.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

```

--------------------------------

### Upgrade App Using Navigator to go_router

Source: https://pub.dev/documentation/go_router/latest/topics/Upgrading-topic

Demonstrates how to configure go_router for an app initially using the Navigator, starting with the home screen.

```dart
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
```

--------------------------------

### GoRouter Redirect Function Example

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteBase/redirect

Demonstrates how to use the redirect property in GoRoute to specify a redirection logic. This example shows a simple redirect from the root path to a specific family ID.

```dart
final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      redirect: (_, __) => '/family/${Families.data[0].id}',
    ),
    GoRoute(
      path: '/family/:fid',
      pageBuilder: (BuildContext context, GoRouterState state) => ...,
    ),
  ],
);
```

--------------------------------

### go_router pageBuilder Method Implementation

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRouteData/pageBuilder

This snippet shows the implementation of the pageBuilder method for go_router. It takes BuildContext, GoRouterState, and StatefulNavigationShell as parameters and returns a Page<void>. The example uses NoOpPage as a placeholder.

```dart
Page<void> pageBuilder(
  BuildContext context,
  GoRouterState state,
  StatefulNavigationShell navigationShell,
) => const NoOpPage();
```

--------------------------------

### StatefulShellBranch API Documentation

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulShellBranch/preload

API documentation for the StatefulShellBranch class in the go_router package. Includes constructors, properties like initialLocation, navigatorKey, and routes, as well as methods and operators.

```APIDOC
StatefulShellBranch:
  Constructors:
    StatefulShellBranch()
  Properties:
    defaultRoute: String? - The default route for this branch.
    hashCode: int - The hash code for this object.
    initialLocation: String - The initial location for this branch.
    navigatorKey: GlobalKey<NavigatorState>? - The navigator key for this branch.
    observers: List<NavigatorObserver>? - Observers for the navigator.
    preload: bool - Whether this route branch should be eagerly loaded.
    restorationScopeId: String? - The restoration scope ID for this branch.
    routes: List<RouteBase> - The routes for this branch.
  Methods:
    noSuchMethod(Invocation invocation) - NoSuchMethod.
    toString() → String - A string representation of this object.
  Operators:
    operator ==(Object other) → bool - The equality operator.
```

--------------------------------

### DiagnosticsProperty Example Usage

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRoute/debugFillProperties

Examples demonstrating the use of `DiagnosticsProperty` with specific parameters like `showSeparator` and `showName` to control the output format of diagnostic information.

```dart
DiagnosticsProperty<Object>('child(3, 4)', null, ifNull: 'is null', showSeparator: false).toString()
DiagnosticsProperty<IconData>('icon', icon, ifNull: '<empty>', showName: false).toString()
```

--------------------------------

### DiagnosticsProperty Usage Examples

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteMatchBase/debugFillProperties

Illustrates the practical application of DiagnosticsProperty subclasses and their parameters like `showSeparator`, `showName`, `ifNull`, `ifEmpty`, `unit`, and `tooltip` for enhanced debugging output.

```dart
DiagnosticsProperty<Object>('child(3, 4)', null, ifNull: 'is null', showSeparator: false).toString()
// Shows using `showSeparator` to get output `child(3, 4) is null` which is more polished than `child(3, 4): is null`.

DiagnosticsProperty<IconData>('icon', icon, ifNull: '<empty>', showName: false).toString()
// Shows using `showName` to omit the property name as in this context the property name does not add useful information.
```

--------------------------------

### GoRouterHelper Methods Overview

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRouterHelper/push

Overview of methods available in the GoRouterHelper extension on BuildContext for navigation within the go_router package.

```APIDOC
GoRouterHelper Methods:

- canPop: Checks if the current route can be popped.
- go: Navigates to a new location, replacing the current history.
- goNamed: Navigates to a named route.
- namedLocation: Generates a location string for a named route.
- pop: Pops the current route off the page stack.
- push: Pushes a new location onto the page stack.
- pushNamed: Pushes a new named route onto the page stack.
- pushReplacement: Replaces the top-most page with a new one.
- pushReplacementNamed: Replaces the top-most named route with a new one.
- replace: Replaces the top-most page, reusing the page key.
- replaceNamed: Replaces the top-most named route, reusing the page key.
```

--------------------------------

### Look up Location for a Named Route using namedLocation

Source: https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic

Shows how to get the URL path for a named route using `namedLocation`. This is useful when you need the URL string before navigating, for example, to share a link or for programmatic navigation.

```dart
TextButton(
  onPressed: () {
    final String location = context.namedLocation('song', pathParameters: {'songId': 123});
    context.go(location);
  },
  child: const Text('Go to song 2'),
)
```

--------------------------------

### Example debugFillProperties Implementation in Dart

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteMatchList/debugFillProperties

Demonstrates best practices for implementing the debugFillProperties method using various DiagnosticsProperty subclasses and parameters. This example showcases how to add different types of properties (String, Double, Int, Percent, Flag) with custom display options like hiding names, setting default values, specifying units, and conditional display.

```dart
class ExampleObject extends ExampleSuperclass {

  // ...various members and properties...

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    // Always add properties from the base class first.
    super.debugFillProperties(properties);

    // Omit the property name 'message' when displaying this String property
    // as it would just add visual noise.
    properties.add(StringProperty('message', message, showName: false));

    properties.add(DoubleProperty('stepWidth', stepWidth));

    // A scale of 1.0 does nothing so should be hidden.
    properties.add(DoubleProperty('scale', scale, defaultValue: 1.0));

    // If the hitTestExtent matches the paintExtent, it is just set to its
    // default value so is not relevant.
    properties.add(DoubleProperty('hitTestExtent', hitTestExtent, defaultValue: paintExtent));

    // maxWidth of double.infinity indicates the width is unconstrained and
    // so maxWidth has no impact.
    properties.add(DoubleProperty('maxWidth', maxWidth, defaultValue: double.infinity));

    // Progress is a value between 0 and 1 or null. Showing it as a
    // percentage makes the meaning clear enough that the name can be
    // hidden.
    properties.add(PercentProperty(
      'progress',
      progress,
      showName: false,
      ifNull: '<indeterminate>',
    ));

    // Most text fields have maxLines set to 1.
    properties.add(IntProperty('maxLines', maxLines, defaultValue: 1));

    // Specify the unit as otherwise it would be unclear that time is in
    // milliseconds.
    properties.add(IntProperty('duration', duration.inMilliseconds, unit: 'ms'));

    // Tooltip is used instead of unit for this case as a unit should be a
    // terse description appropriate to display directly after a number
    // without a space.
    properties.add(DoubleProperty(
      'device pixel ratio',
      devicePixelRatio,
      tooltip: 'physical pixels per logical pixel',
    ));

    // Displaying the depth value would be distracting. Instead only display
    // if the depth value is missing.
    properties.add(ObjectFlagProperty<int>('depth', depth, ifNull: 'no depth'));

    // bool flag that is only shown when the value is true.
    properties.add(FlagProperty('using primary controller', value: primary));

    properties.add(FlagProperty(
      'isCurrent',
      value: isCurrent,
      ifTrue: 'active',
      ifFalse: 'inactive',
    ));
  }
}
```

--------------------------------

### ImperativeRouteMatch Constructor

Source: https://pub.dev/documentation/go_router/latest/go_router/ImperativeRouteMatch/ImperativeRouteMatch

Defines the constructor for the ImperativeRouteMatch class, specifying required parameters like pageKey, matches, and completer. It also shows the implementation details, including superclass initialization.

```APIDOC
ImperativeRouteMatch.new constructor

ImperativeRouteMatch({
  required ValueKey<String> pageKey,
  required RouteMatchList matches,
  required Completer<Object?> completer,
})

Constructor for ImperativeRouteMatch.

Implementation:
ImperativeRouteMatch(
    {required super.pageKey, required this.matches, required this.completer})
    : super(
        route: _getsLastRouteFromMatches(matches),
        matchedLocation: _getsMatchedLocationFromMatches(matches),
      );
```

--------------------------------

### Flutter debugFillProperties Example with DiagnosticsProperty Variants

Source: https://pub.dev/documentation/go_router/latest/go_router/InheritedGoRouter/debugFillProperties

Demonstrates best practices for implementing debugFillProperties in Flutter, showcasing the use of various DiagnosticsProperty subclasses and parameters. This example includes StringProperty, DoubleProperty, PercentProperty, IntProperty, ObjectFlagProperty, and FlagProperty with different configurations for displaying debugging information.

```dart
class ExampleObject extends ExampleSuperclass {

  // ...various members and properties...

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    // Always add properties from the base class first.
    super.debugFillProperties(properties);

    // Omit the property name 'message' when displaying this String property
    // as it would just add visual noise.
    properties.add(StringProperty('message', message, showName: false));

    properties.add(DoubleProperty('stepWidth', stepWidth));

    // A scale of 1.0 does nothing so should be hidden.
    properties.add(DoubleProperty('scale', scale, defaultValue: 1.0));

    // If the hitTestExtent matches the paintExtent, it is just set to its
    // default value so is not relevant.
    properties.add(DoubleProperty('hitTestExtent', hitTestExtent, defaultValue: paintExtent));

    // maxWidth of double.infinity indicates the width is unconstrained and
    // so maxWidth has no impact.
    properties.add(DoubleProperty('maxWidth', maxWidth, defaultValue: double.infinity));

    // Progress is a value between 0 and 1 or null. Showing it as a
    // percentage makes the meaning clear enough that the name can be
    // hidden.
    properties.add(PercentProperty(
      'progress',
      progress,
      showName: false,
      ifNull: '<indeterminate>',
    ));

    // Most text fields have maxLines set to 1.
    properties.add(IntProperty('maxLines', maxLines, defaultValue: 1));

    // Specify the unit as otherwise it would be unclear that time is in
    // milliseconds.
    properties.add(IntProperty('duration', duration.inMilliseconds, unit: 'ms'));

    // Tooltip is used instead of unit for this case as a unit should be a
    // terse description appropriate to display directly after a number
    // without a space.
    properties.add(DoubleProperty(
      'device pixel ratio',
      devicePixelRatio,
      tooltip: 'physical pixels per logical pixel',
    ));

    // Displaying the depth value would be distracting. Instead only display
    // if the depth value is missing.
    properties.add(ObjectFlagProperty<int>('depth', depth, ifNull: 'no depth'));

    // bool flag that is only shown when the value is true.
    properties.add(FlagProperty('using primary controller', value: primary));

    properties.add(FlagProperty(
      'isCurrent',
      value: isCurrent,
      ifTrue: 'active',
      ifFalse: 'inactive',
    ));

  }
}
```

--------------------------------

### RouteMatch.new constructor API

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteMatch/RouteMatch

API documentation for the RouteMatch constructor, outlining its required parameters: route (GoRoute), matchedLocation (String), and pageKey (ValueKey<String>).

```APIDOC
RouteMatch.new const constructor

# RouteMatch constructor

const
RouteMatch({
  required GoRoute route,
  required String matchedLocation,
  required ValueKey<String> pageKey,
})

Constructor for RouteMatch.
```

--------------------------------

### StatefulShellRoute Branch Navigation

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class

Example of how to switch to a different branch within a StatefulShellRoute using the goBranch method of StatefulNavigationShell.

```dart
void _onItemTapped(int index) {
  navigationShell.goBranch(index: index);
}

```

--------------------------------

### go_router pageKey Property Example

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRouterState/pageKey

Demonstrates the usage of the pageKey property in go_router, which serves as a unique string key for a sub-route. It shows how to assign a ValueKey with a string path.

```dart
final ValueKey<String> pageKey;
// Example usage:
// ValueKey('/family/:fid')
```

--------------------------------

### ShellRouteMatch Class API Documentation

Source: https://pub.dev/documentation/go_router/latest/go_router/ShellRouteMatch/pageKey

API documentation for the ShellRouteMatch class in the go_router package. Lists constructors, properties (including pageKey, matchedLocation, navigatorKey, etc.), methods (like buildState), and operators.

```APIDOC
ShellRouteMatch:
  Constructors:
    ShellRouteMatch()
  Properties:
    pageKey: ValueKey<String> - The page key.
    matchedLocation: String - The location that was matched.
    navigatorKey: GlobalKey<NavigatorState>? - The navigator key.
    matches: List<RouteMatch> - The list of route matches.
  Methods:
    buildState(BuildContext context, GoRouterState state) -> ShellRouteState
      Builds the state for the shell route.
    debugFillProperties(DiagnosticPropertiesBuilder properties)
      Adds this object to the diagnostic tree.
  Operators:
    operator ==(Object other) -> bool
      The equality operator.
```

--------------------------------

### GoRouterHelper Navigation Methods

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRouterHelper/pushReplacement

Provides an overview of various navigation methods available through the GoRouterHelper extension on BuildContext, including pushReplacement, go, push, and replace.

```APIDOC
GoRouterHelper:
  canPop() -> bool
    Checks if the current route can be popped.

  go(String location, {Object? extra})
    Navigates to the given location.

  goNamed(String name, {String? params, String? queryParams, Object? extra})
    Navigates to the given named route.

  namedLocation(String name, {String? params, String? queryParams})
    Returns the URL for a named route.

  pop({Object? result})
    Pops the current route off the page stack.

  push(String location, {Object? extra})
    Pushes the given location onto the page stack.

  pushNamed(String name, {String? params, String? queryParams, Object? extra})
    Pushes the given named route onto the page stack.

  pushReplacement(String location, {Object? extra})
    Replaces the top-most page of the page stack with the given location.

  pushReplacementNamed(String name, {String? params, String? queryParams, Object? extra})
    Replaces the top-most page of the page stack with the given named route.

  replace(String location, {Object? extra})
    Replaces the top-most page of the page stack, treating it as the same page.

  replaceNamed(String name, {String? params, String? queryParams, Object? extra})
    Replaces the top-most page of the page stack with the given named route, treating it as the same page.
```

--------------------------------

### GoRoute Constructor Implementation

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRoute/GoRoute

Shows the Dart implementation of the GoRoute constructor, including assertions for parameter validation and internal setup for path parsing.

```dart
GoRoute({
  required this.path,
  this.name,
  this.builder,
  this.pageBuilder,
  super.parentNavigatorKey,
  super.redirect,
  this.onExit,
  this.caseSensitive = true,
  super.routes = const <RouteBase>[],
})  : assert(path.isNotEmpty, 'GoRoute path cannot be empty'),
      assert(name == null || name.isNotEmpty, 'GoRoute name cannot be empty'),
      assert(pageBuilder != null || builder != null || redirect != null, 'builder, pageBuilder, or redirect must be provided'),
      assert(onExit == null || pageBuilder != null || builder != null, 'if onExit is provided, one of pageBuilder or builder must be provided'),
      super._() {
  // cache the path regexp and parameters
  _pathRE = patternToRegExp(path, pathParameters, caseSensitive: caseSensitive);
}
```

--------------------------------

### DiagnosticsProperty Usage Examples

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteBase/debugFillProperties

Demonstrates the usage of `DiagnosticsProperty` with parameters like `showSeparator` and `showName` to control the output format for debugging.

```Dart
DiagnosticsProperty<Object>('child(3, 4)', null, ifNull: 'is null', showSeparator: false).toString()

DiagnosticsProperty<IconData>('icon', icon, ifNull: '<empty>', showName: false).toString()
```

--------------------------------

### Upgrade from Navigator to GoRouter

Source: https://pub.dev/documentation/go_router/latest/topics/Upgrading-topic

Demonstrates how to integrate go_router into an app currently using the Navigator API. It shows the initial setup with a single GoRoute for the home screen and explains that existing Navigator calls remain functional during the gradual migration.

```Dart
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

```

--------------------------------

### Example Usage of StatefulNavigationShell

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulNavigationShell-class

Demonstrates how to use the StatefulNavigationShell widget within a StatefulShellRoute's builder to create a custom shell container for branch Navigators.

```dart
builder: (BuildContext context, GoRouterState state,
    StatefulNavigationShell navigationShell) {
  return StatefulNavigationShell(
    shellRouteState: state,
    containerBuilder: (_, __, List<Widget> children) => MyCustomShell(shellState: state, children: children),
  );
}
```

--------------------------------

### RouteConfiguration Property

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteBuilder/configuration

Defines the route configuration for the application using the go_router package. This property is part of the overall routing setup.

```dart
final RouteConfiguration configuration;
```

--------------------------------

### GoRouterState.of Usage Example

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRouterState/of

Demonstrates how to use `GoRouterState.of(context)` within a `StatelessWidget` to access path parameters.

```dart
GoRoute(
  path: '/:id'
  builder: (_, __) => MyWidget(),
);

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('${GoRouterState.of(context).pathParameters['id']}');
  }
}
```

--------------------------------

### DiagnosticsProperty Usage Examples

Source: https://pub.dev/documentation/go_router/latest/go_router/ShellRoute/debugFillProperties

Illustrates the usage of DiagnosticsProperty with parameters like showSeparator and showName to control the output format for debugging information.

```dart
DiagnosticsProperty<Object>('child(3, 4)', null, ifNull: 'is null', showSeparator: false).toString()

DiagnosticsProperty<IconData>('icon', icon, ifNull: '<empty>', showName: false).toString()
```

--------------------------------

### GoRouterDelegate API Documentation

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRouterDelegate/GoRouterDelegate

API reference for the GoRouterDelegate class, detailing its constructors, properties, and methods for route management in go_router.

```APIDOC
GoRouterDelegate:
  A RouterDelegate for GoRouter.

  Constructors:
    GoRouterDelegate({Key? key, GlobalKey<NavigatorState>? navigatorKey, bool routerNeglect = false, Object? restorationId})
      - Creates a GoRouterDelegate.
      - Parameters:
        - key: Optional key for the delegate.
        - navigatorKey: A GlobalKey for the Navigator.
        - routerNeglect: Whether to neglect the router when navigating.
        - restorationId: Optional restoration ID for state restoration.

  Properties:
    navigatorKey: GlobalKey<NavigatorState>?
      - The key for the Navigator.
    routerNeglect: bool
      - Whether the router neglects navigation.
    currentConfiguration: RouteConfiguration?
      - The current route configuration.
    state: RouterState?
      - The current router state.
    hasListeners: bool
      - Whether there are any listeners registered.

  Methods:
    build(BuildContext context) -> Widget
      - Builds the UI for the current route.
      - Returns a Widget representing the current route's UI.
    canPop() -> bool
      - Returns true if the current route can be popped.
    addListener(VoidCallback listener)
      - Adds a listener to the delegate.
    removeListener(VoidCallback listener)
      - Removes a listener from the delegate.
    notifyListeners()
      - Notifies all registered listeners.
    pop() -> void
      - Pops the current route.
    popRoute() -> void
      - Pops the current route, handling route information.
    setInitialRoutePath(configuration: RouteConfiguration)
      - Sets the initial route path.
    setNewRoutePath(configuration: RouteConfiguration)
      - Sets a new route path.
    setRestoredRoutePath(configuration: RouteConfiguration)
      - Sets a restored route path.

  Inherited from ChangeNotifier:
    addListener, removeListener, dispose, notifyListeners

  Inherited from RouterDelegate:
    build, currentConfiguration, navigatorKey, routerNeglect, setNewRoutePath, setRestoredRoutePath, setInitialRoutePath, canPop, popRoute, matchingLocation

  Inherited from Object:
    hashCode, runtimeType, noSuchMethod, toString, operator ==

```

--------------------------------

### GoRouter Redirect Example

Source: https://pub.dev/documentation/go_router/latest/topics/Redirection-topic

Demonstrates how to implement a redirect callback for GoRouter to conditionally change the application's location based on authentication state.

```dart
redirect: (BuildContext context, GoRouterState state) {
  if (!AuthState.of(context).isSignedIn) {
    return '/signin';
  } else {
    return null;
  }
}
```

--------------------------------

### RouteMatch Class Properties and Methods

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteMatch/route

Provides an overview of the properties and methods available in the RouteMatch class from the go_router package. This includes constructors, properties like matchedLocation and pageKey, and methods for building state and debugging.

```APIDOC
RouteMatch:
  Constructors:
    new RouteMatch()
      - Creates a new RouteMatch instance.
  Properties:
    hashCode: int
      - The hash code for this object.
    matchedLocation: String
      - The matched location string.
    pageKey: ValueKey<String>
      - The page key for the route.
    route: GoRoute
      - The matched GoRoute object.
    runtimeType: Type
      - A representation of the runtime type of the object.
  Methods:
    buildState(BuildContext context)
      - Builds the state for the route.
    debugFillProperties(DiagnosticPropertiesBuilder properties)
      - Adds this object to the diagnostic tree.
    noSuchMethod(Invocation invocation)
      - NoSuchMethod
    toDiagnosticsNode(Object parentAttachment)
      - Returns a debug representation of the object that is used by the devic
    toString(): String
      - A string representation of this object.
    toStringShort(): String
      - A short, representative description of this object, often just the class name.
  Operators:
    operator ==(Object other)
      - Equality operator.
```

--------------------------------

### GoRouter Redirect Example

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteBase/redirect

Demonstrates how to use the redirect property in a GoRoute to redirect from the root path to a specific family member's route.

```dart
final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      redirect: (_, __) => '/family/${Families.data[0].id}',
    ),
    GoRoute(
      path: '/family/:fid',
      pageBuilder: (BuildContext context, GoRouterState state) => ...,
    ),
  ],
);
```

--------------------------------

### RouteBuilder Constructor API

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteBuilder/RouteBuilder

Details the parameters required for initializing the RouteBuilder, including configuration, navigation builders, error handling, restoration scope, observers, and pop page callbacks.

```APIDOC
RouteBuilder Constructor:
  __init__(
    required configuration: RouteConfiguration,
    required builderWithNav: GoRouterBuilderWithNav,
    required errorPageBuilder: GoRouterPageBuilder?,
    required errorBuilder: GoRouterWidgetBuilder?,
    required restorationScopeId: String?,
    required observers: List<NavigatorObserver>,
    required onPopPageWithRouteMatch: PopPageWithRouteMatchCallback,
    requestFocus: bool = true
  )
    - Constructor for the RouteBuilder class.
    - Parameters:
      - configuration: The route configuration object.
      - builderWithNav: The builder function for navigation with context.
      - errorPageBuilder: An optional builder for custom error pages.
      - errorBuilder: An optional builder for custom error widgets.
      - restorationScopeId: An optional string for state restoration scope.
      - observers: A list of NavigatorObserver instances.
      - onPopPageWithRouteMatch: A callback function invoked when a page is popped.
      - requestFocus: A boolean indicating whether to request focus (defaults to true).
```

--------------------------------

### RouteConfiguration Constructor Implementation

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration/RouteConfiguration

Provides the Dart implementation for the RouteConfiguration constructor, including initialization logic and listener setup for routing table changes.

```Dart
RouteConfiguration(
  this._routingConfig,
  {
    required this.navigatorKey,
    this.extraCodec,
  }
) {
  _onRoutingTableChanged();
  _routingConfig.addListener(_onRoutingTableChanged);
}
```

--------------------------------

### GoRoute Constructor API Reference

Source: https://pub.dev/documentation/go_router/latest/go_router/GoRoute/GoRoute

Detailed API documentation for the GoRoute constructor, including parameter descriptions, types, constraints, and usage notes.

```APIDOC
GoRoute:
  __init__({required String path, String? name, GoRouterWidgetBuilder? builder, GoRouterPageBuilder? pageBuilder, GlobalKey<NavigatorState>? parentNavigatorKey, GoRouterRedirect? redirect, ExitCallback? onExit, bool caseSensitive = true, List<RouteBase> routes = const <RouteBase>[]})
    - Constructs a GoRoute.
    - Parameters:
      - path: The route path (required, cannot be empty).
      - name: An optional name for the route (cannot be empty if provided).
      - builder: A widget builder for the route.
      - pageBuilder: A page builder for the route.
      - parentNavigatorKey: An optional key for the parent navigator.
      - redirect: An optional redirect function.
      - onExit: An optional callback when exiting the route.
      - caseSensitive: Whether the path matching is case-sensitive (defaults to true).
      - routes: A list of child routes.
    - Constraints:
      - `path` and `name` cannot be empty strings.
      - One of either `builder` or `pageBuilder` must be provided.
      - If `onExit` is provided, one of `pageBuilder` or `builder` must also be provided.
```

--------------------------------

### RouteMatchBase Class API Documentation

Source: https://pub.dev/documentation/go_router/latest/go_router/RouteMatchBase/pageKey

API documentation for the RouteMatchBase class in the go_router package. This includes constructors, properties like 'matchedLocation' and 'pageKey', and methods such as 'buildState'.

```APIDOC
RouteMatchBase class:
  Constructors:
    new RouteMatchBase()
  Properties:
    matchedLocation: The matched location string.
    pageKey: The key of the page.
    route: The route object.
    hashCode: The hash code of the object.
    runtimeType: A representation of the runtime type of the object.
  Methods:
    buildState(BuildContext context): Builds the state for the route.
    debugFillProperties(DiagnosticPropertiesBuilder properties): Adds this object to the diagnostic tree.
    noSuchMethod(Invocation invocation): Invoked when a non-existent method or property is accessed.
    toDiagnosticsNode(Object parent, {String name}): Returns a debug representation of the object.
    toString(): A string representation of the object.
    toStringShort(): A short, representative string of the object.
  Operators:
    operator ==(Object other): The equality operator.
  Static methods:
    match(String location, RouteBase route, {required Map<String, String> pathParameters, required Map<String, String> queryParameters}): Matches a location against a route.
```

--------------------------------

### StatefulNavigationShellState API Documentation

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulNavigationShellState/StatefulNavigationShellState

API documentation for the StatefulNavigationShellState class in the go_router package. Includes constructors, properties, methods, and operators.

```APIDOC
StatefulNavigationShellState:
  __init__()
    Initializes the state for navigation within a shell.

  Properties:
    bucket: The RestorationBucket for this object.
    context: The BuildContext of this widget.
    currentIndex: The index of the currently active branch.
    hashCode: The hash code for this object.
    mounted: Whether this object is currently in a mutable state.
    restorationId: The restoration ID for this object.
    restorePending: Whether the object has pending restoration.
    route: The current route.
    runtimeType: A string representation of the runtime type of the object.
    widget: The widget that this State is associated with.

  Methods:
    activate(): Called when this object is inserted into the widget tree.
    build(): Describes the part of the user interface represented by this widget.
    deactivate(): Called when this object is removed from the widget tree.
    debugFillProperties(DiagnosticPropertiesBuilder properties):
      Add additional properties associated with the node.
    didChangeDependencies(): Called when a dependency of this State object changes.
    didToggleBucket(RestorationBucket? oldBucket):
      Called when the RestorationBucket for this object changes.
    didUpdateRestorationId(): Called when the restorationId for this object changes.
    didUpdateWidget(StatefulWidget oldWidget):
      Called when the parent is rebuilding the widget with the given oldWidget.
    dispose(): Called when this object is removed from the widget tree.
    goBranch(int index, {Object? extra}): Navigates to a specific branch.
    initState(): Called when this object is inserted into the widget tree.
    noSuchMethod(Invocation invocation):
      Invoked when a non-existent method or property is accessed.
    reassemble(): Called by the framework when an Element is rebuilt.
    registerForRestoration(StatefulWidget owner, {String? restorationId}):
      Registers this object for restoration.
    restoreState(RestorationBucket? oldBucket, RestorationBucket? newBucket):
      Restores the state of this object.
    setState(VoidCallback fn):
      Notifies the framework that the internal state of this object has changed.
    toDiagnosticsNode(String name, DiagnosticsTreeStyle? style):
      Returns a DiagnosticableNode representing this node.
    toString(DiagnosticLevel minLevel):
      A string representation of this object.
    toStringShort():
      A short, representative description of this object, often a class name.
    unregisterFromRestoration(StatefulWidget owner):
      Unregisters this object from restoration.

  Operators:
    operator ==(Object other):
      The equality operator.

```

--------------------------------

### ShellRouteContext Class Properties and Methods

Source: https://pub.dev/documentation/go_router/latest/go_router/ShellRouteContext/navigatorBuilder

Documentation for the ShellRouteContext class in go_router, outlining its properties like match, navigatorBuilder, navigatorKey, route, routeMatchList, and routerState, as well as methods like noSuchMethod and toString.

```APIDOC
ShellRouteContext:
  Constructors:
    - new(match: RouteMatch, navigatorKey: GlobalKey<NavigatorState>, route: RouteBase, routeMatchList: RouteMatchList, routerState: GoRouterState)

  Properties:
    - match: RouteMatch
      The current route match.
    - navigatorBuilder: NavigatorBuilder
      Function used to build the Navigator for the current route.
    - navigatorKey: GlobalKey<NavigatorState>
      The key for the navigator.
    - route: RouteBase
      The current route.
    - routeMatchList: RouteMatchList
      The list of route matches.
    - routerState: GoRouterState
      The current router state.

  Methods:
    - noSuchMethod(Invocation invocation): dynamic
      Invoked when a non-existent method or property is accessed.
    - toString(): String
      A string representation of the object.

  Operators:
    - operator ==(Object other): bool
      The equality operator.
```

--------------------------------

### Flutter createState Method Example

Source: https://pub.dev/documentation/go_router/latest/go_router/StatefulNavigationShell/createState

Demonstrates the standard implementation of the createState method in a Flutter StatefulWidget. This method is crucial for creating the mutable state associated with a widget.

```dart
@override
State<SomeWidget> createState() => _SomeWidgetState();
```