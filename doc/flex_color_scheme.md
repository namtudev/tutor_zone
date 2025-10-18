### Running the Default FlexColorScheme Example Application (Bash)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/examples.mdx

This snippet provides the bash commands to navigate into the `example/` directory of the FlexColorScheme repository and run the default Flutter application. This allows users to launch the 'Hot Reload Playground' on a device or simulator to experiment with different theming options. It requires the FlexColorScheme repository to be cloned and the Flutter SDK to be installed.

```bash
cd example/
flutter run
```

--------------------------------

### Adding FlexColorScheme Package to Flutter Project

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/installing.mdx

This command adds the `flex_color_scheme` package as a dependency to your Flutter project's `pubspec.yaml` file, making it available for use. Either `dart pub add` or `flutter pub add` can be used.

```Shell
dart pub add flex_color_scheme
```

--------------------------------

### Importing FlexColorScheme Package in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/installing.mdx

This import statement makes all classes and functions from the `flex_color_scheme` package available for use in your Dart file, allowing you to access its theming capabilities.

```Dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
```

--------------------------------

### Creating Flutter Skeleton Project (Bash)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial2.mdx

This Bash command is used to generate a new Flutter project with the 'skeleton' template. This template provides a basic application architecture, including components like `ThemeService` and `ThemeController`, which are utilized in the examples for managing theme settings.

```bash
> flutter create -t skeleton my_flutter_app
```

--------------------------------

### Changing FlexColorScheme Scheme in Dart Example

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/examples.mdx

This Dart snippet demonstrates how to switch to a pre-defined color scheme, specifically `FlexScheme.blueWhale`, within the FlexColorScheme API. It highlights that instead of assigning `FlexSchemeColor` to `colors`, one should assign a `FlexScheme` enum value to the `scheme` property. This modification can be hot reloaded in the 'Hot Reload Playground' to see immediate visual effects on the application's theme.

```dart
// To use a pre-defined color scheme, don't assign any FlexSchemeColor to
// `colors`, instead pick a FlexScheme and assign it to the `scheme` property.
// Try eg the new "Blue Whale" color scheme.
const FlexScheme _scheme = FlexScheme.blueWhale;
```

--------------------------------

### Initializing ThemeServiceHive and ThemeController in Flutter

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial4.mdx

This snippet demonstrates the initialization process for `ThemeServiceHive` and `ThemeController` in a Flutter application. It shows how to create a `ThemeServiceHive` instance with a specified box name for persistent storage, initialize the service, create a `ThemeController` linked to this service, load saved theme settings, and finally run the application, passing the controller for theme management. This setup ensures theme settings are loaded before the UI is rendered, preventing a theme change flicker.

```Dart
// The ThemeServiceHive constructor requires a box name, the others do not.
// The box name is just a file name for the file that stores the settings.
final ThemeService themeService = ThemeServiceHive('flex_color_scheme_v5_box_4');
// Initialize the theme service.
await themeService.init();
// Create a ThemeController that uses the ThemeService.
final ThemeController themeController = ThemeController(themeService);
// Load preferred theme settings, while the app is loading, before MaterialApp
// is created, this prevents a theme change when the app is first displayed.
await themeController.loadAll();
// Run the app and pass in the ThemeController. The app listens to the
// ThemeController for changes.
runApp(DemoApp(themeController: themeController));
```

--------------------------------

### Creating Themes with FlexColorScheme.toTheme in Flutter (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet illustrates the use of `FlexColorScheme.light()` and `FlexColorScheme.dark()` factory constructors, followed by the `.toTheme` method, to configure and apply light and dark themes in a Flutter `MaterialApp`. This is the original, more verbose approach compared to `FlexThemeData`.

```Dart
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Guide',
      theme: FlexColorScheme.light(scheme: FlexScheme.mandyRed).toTheme,
      darkTheme: FlexColorScheme.dark(scheme: FlexScheme.mandyRed).toTheme,
      themeMode: ThemeMode.system,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );

```

--------------------------------

### Defining M3 Baseline Light ColorScheme in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This snippet defines `flexSchemeLight`, a `ColorScheme` instance for a light theme. It's designed to be similar to the Material 3 Guide Baseline, but with less colorful `onColors`. This scheme is used as input for `FlexColorScheme` studies, particularly because its primary color, when used as a seed, generates the same `ColorScheme` as the M3 guide's specified version. It's a standard `ColorScheme` instance, despite its name.

```dart
const ColorScheme flexSchemeLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff6750a4),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffeaddff),
  onPrimaryContainer: Color(0xff000000),
  secondary: Color(0xff625b71),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xffe8def8),
  onSecondaryContainer: Color(0xff000000),
  tertiary: Color(0xff7d5260),
  onTertiary: Color(0xffffffff),
  tertiaryContainer: Color(0xffffd8e4),
  onTertiaryContainer: Color(0xff000000),
  error: Color(0xffba1a1a),
  onError: Color(0xffffffff),
  errorContainer: Color(0xffffdad6),
  onErrorContainer: Color(0xff000000),
  background: Color(0xffffffff),
  onBackground: Color(0xff000000),
  surface: Color(0xffffffff),
  onSurface: Color(0xff000000),
  surfaceVariant: Color(0xffeeeeee),
  onSurfaceVariant: Color(0xff000000),
  outline: Color(0xff737373),
  outlineVariant: Color(0xffbfbfbf),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff121212),
  onInverseSurface: Color(0xffffffff),
  inversePrimary: Color(0xfff0e9ff),
  surfaceTint: Color(0xff6750a4),
);
```

--------------------------------

### Initializing ThemeServiceHive and ThemeController in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial5.mdx

This `main` function initializes Flutter widgets, creates a `ThemeServiceHive` instance for theme persistence, and then a `ThemeController` to manage theme settings. It loads the preferred theme settings before the app starts to prevent a theme change on initial display, and finally runs the `PlaygroundApp` with the configured controller. It uses Hive for persistent storage.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The ThemeServiceHive constructor requires a box name, the others do not.
  // The box name is just a file name for the file that stores the settings.
  final ThemeService themeService = ThemeServiceHive('flex_color_scheme_v5_box_5');
  // Initialize the theme service.
  await themeService.init();
  // Create a ThemeController that uses the ThemeService.
  final ThemeController themeController = ThemeController(themeService);
  // Load preferred theme settings, while the app is loading, before MaterialApp
  // is created, this prevents a theme change when the app is first displayed.
  await themeController.loadAll();
  // Run the app and pass in the ThemeController. The app listens to the
  // ThemeController for changes. The same ThemeController as used in example 4
  // controls all the myriad of Theme settings and the ThemeService also
  // persists the settings with the injected ThemeServiceHive.
runApp(PlaygroundApp(controller: themeController));
}
```

--------------------------------

### Simplified FlexKeyColors Configuration for Seeded Scheme in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial4.mdx

This snippet provides a simplified example of `FlexKeyColors` configuration where `useSecondary` and `useTertiary` are set to `true` to use these colors as key colors, and `keepPrimary` is set to `true` to preserve the primary color as a brand color. This is a common setup for a seeded `ColorScheme`.

```Dart
  keyColors: FlexKeyColors(
    useSecondary: true,
    useTertiary: true,
    keepPrimary: true,
  ),
```

--------------------------------

### Defining FlexTones.vivid for Light and Dark Brightness (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This Dart code defines the `FlexTones.vivid` static method, which provides a predefined set of tone adjustments for `FlexColorScheme` based on the `Brightness` (light or dark). It configures specific `primaryTone`, `onPrimaryTone`, `primaryContainerTone`, `onErrorContainerTone`, and `primaryMinChroma` values to achieve a 'vivid' color appearance, demonstrating how custom tone setups can be created.

```Dart
static FlexTones vivid(Brightness brightness) =>
    brightness == Brightness.light
        ? const FlexTones.light(
            primaryTone: 30,
            primaryChroma: null,
            secondaryChroma: null,
            tertiaryChroma: null,
            primaryMinChroma: 50,
          )
        : const FlexTones.dark(
            onPrimaryTone: 10,
            primaryContainerTone: 20,
            onErrorContainerTone: 90,
            primaryChroma: null,
            secondaryChroma: null,
            tertiaryChroma: null,
            primaryMinChroma: 50,
          );
```

--------------------------------

### Defining M3 Baseline Dark ColorScheme in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This snippet defines `flexSchemeDark`, a `ColorScheme` instance for a dark theme. Similar to its light counterpart, it mirrors the Material 3 Guide Baseline but with less colorful `onColors`. It serves as an input for `FlexColorScheme` studies, allowing for consistent color generation when seeded with its primary color, matching the M3 guide's specified dark `ColorScheme`. It's a standard `ColorScheme` instance.

```dart
const ColorScheme flexSchemeDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffd0bcff),
  onPrimary: Color(0xff000000),
  primaryContainer: Color(0xff4f378b),
  onPrimaryContainer: Color(0xffffffff),
  secondary: Color(0xffccc2dc),
  onSecondary: Color(0xff000000),
  secondaryContainer: Color(0xff4a4458),
  onSecondaryContainer: Color(0xffffffff),
  tertiary: Color(0xffefb8c8),
  onTertiary: Color(0xff000000),
  tertiaryContainer: Color(0xff633b48),
  onTertiaryContainer: Color(0xffffffff),
  error: Color(0xffffb4ab),
  onError: Color(0xff000000),
  errorContainer: Color(0xff93000a),
  onErrorContainer: Color(0xffffffff),
  background: Color(0xff121212),
  onBackground: Color(0xffffffff),
  surface: Color(0xff121212),
  onSurface: Color(0xffffffff),
  surfaceVariant: Color(0xff323232),
  onSurfaceVariant: Color(0xffffffff),
  outline: Color(0xff8c8c8c),
  outlineVariant: Color(0xff404040),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xffffffff),
  onInverseSurface: Color(0xff000000),
  inversePrimary: Color(0xff635b70),
  surfaceTint: Color(0xffd0bcff),
);
```

--------------------------------

### Applying FlexColorScheme to MaterialApp in Flutter

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/installing.mdx

This Dart code demonstrates how to integrate FlexColorScheme into a Flutter `MaterialApp`. It configures the light and dark themes using `FlexThemeData.light` and `FlexThemeData.dark` with the `FlexScheme.mandyRed` predefined scheme, and sets `themeMode` to `ThemeMode.system` for automatic theme switching based on device settings.

```Dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // The Mandy red, light theme.
      theme: FlexThemeData.light(scheme: FlexScheme.mandyRed),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
      // Use dark or light theme based on system setting.
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

--------------------------------

### Creating Themes with FlexThemeData in Flutter (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet demonstrates how to use the `FlexThemeData.light()` and `FlexThemeData.dark()` static extension methods to generate `ThemeData` objects for light and dark modes within a Flutter `MaterialApp`. It simplifies theme creation by directly returning `ThemeData`.

```Dart
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Guide',
      theme: FlexThemeData.light(scheme: FlexScheme.mandyRed),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
      themeMode: ThemeMode.system,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );

```

--------------------------------

### Defining a Custom Theme Extension for Brand Colors in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet defines a `BrandTheme` class that extends `ThemeExtension`, allowing for custom brand colors to be added to a theme. It includes the required `copyWith` and `lerp` methods for theme extension functionality and defines constant instances for light and dark modes.

```Dart
/// A theme Extension example with a single custom brand color property.
class BrandTheme extends ThemeExtension<BrandTheme> {
  const BrandTheme({
    this.brandColor,
  });
  final Color? brandColor;

  // You must override the copyWith method.
  @override
  BrandTheme copyWith({
    Color? brandColor,
  }) =>
      BrandTheme(
        brandColor: brandColor ?? this.brandColor,
      );

  // You must override the lerp method.
  @override
  BrandTheme lerp(ThemeExtension<BrandTheme>? other, double t) {
    if (other is! BrandTheme) {
      return this;
    }
    return BrandTheme(
      brandColor: Color.lerp(brandColor, other.brandColor, t),
    );
  }
}

// Custom const theme with our brand color in light mode.
const BrandTheme lightBrandTheme = BrandTheme(
  brandColor: Color.fromARGB(255, 8, 79, 71),
);

// Custom const theme with our brand color in dark mode.
const BrandTheme darkBrandTheme = BrandTheme(
  brandColor: Color.fromARGB(255, 167, 227, 218),
);
```

--------------------------------

### Configuring ThemeData with custom flexSwatch (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This example illustrates theme definition using `ThemeData` with a custom `flexSwatch` as the `primarySwatch`. It configures both light and dark themes to use a user-defined color swatch for primary colors.

```Dart
// 2 flex) TD primarySwatch
//    ThemeData(brightness: ..., primarySwatch: flexSwatch)
title: '3) TD primarySwatch',
theme: ThemeData(
  brightness: Brightness.light,
  primarySwatch: flexSwatch,
),
darkTheme: ThemeData(
  brightness: Brightness.dark,
  primarySwatch: flexSwatch,
),
```

--------------------------------

### Configuring FlexThemeData with Key Colors - Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet demonstrates how to configure FlexThemeData.light using key colors and other properties like 'scheme', 'usedColors', 'surfaceMode', and 'blendLevel'. It shows how to apply a specific color scheme ('FlexScheme.flutterDash') and adjust surface blending for a light theme.

```Dart
theme: FlexThemeData.light(
  scheme: FlexScheme.flutterDash,
  usedColors: 4,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 20,
)
```

--------------------------------

### Migrating surfaceStyle to surfaceMode and blendLevel in FlexColorScheme (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/migrating.mdx

This code snippet demonstrates how to replace the deprecated `surfaceStyle` property with `surfaceMode` and `blendLevel` when configuring a light theme using `FlexThemeData.light`. It shows an example of setting the `surfaceMode` to `FlexSurfaceMode.highScaffoldLowSurface` and `blendLevel` to `20` to achieve similar surface blending effects. This is a direct migration example for a breaking change in FlexColorScheme v5.0.

```Dart
theme: FlexThemeData.light(
  scheme: FlexScheme.flutterDash,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 20,
),
```

--------------------------------

### Generating FlexThemeData from keyColors (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This example shows how FlexThemeData can generate its internal ColorScheme using 'keyColors', mimicking the behavior of ColorScheme.fromSeed. By passing 'const FlexKeyColors()', FlexColorScheme uses its default algorithm to derive a color scheme from the primary color of the provided 'flexSchemeLight' and 'flexSchemeDark' inputs.

```Dart
title: '11) FlexThemeData.light(keyColors)',
theme: FlexThemeData.light(
  colorScheme: flexSchemeLight,
  keyColors: const FlexKeyColors(),
),
darkTheme: FlexThemeData.dark(
  colorScheme: flexSchemeDark,
  keyColors: const FlexKeyColors(),
),
```

--------------------------------

### Applying a Custom Theme Extension to FlexThemeData.light in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet demonstrates how to apply a custom `ThemeExtension` (specifically `lightBrandTheme`) to the `theme` property of a `MaterialApp` using `FlexThemeData.light`. This integrates the custom brand color into the application's light theme.

```Dart
class _DemoAppState extends State<DemoApp> {
  ThemeMode themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlexThemeData.light(
        ...
        // Add all our custom theme extensions, in this case we only have one.
        extensions: <ThemeExtension<dynamic>>{
          lightBrandTheme,
        },
      ),
   ...
   );
```

--------------------------------

### Configuring FlexThemeData with Key Colors and Tones (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This Dart snippet demonstrates how to configure `FlexThemeData` for both light and dark themes. It sets properties like `surfaceMode`, `blendLevel`, `appBarStyle`, `appBarOpacity`, `tabBarStyle`, and crucially, `keyColors` to enable secondary and tertiary colors, and `tones` using the predefined `FlexTones.vivid` for a specific color vibrancy.

```Dart
appBarStyle: FlexAppBarStyle.background,
  appBarOpacity: 0.95,
  tabBarStyle: FlexTabBarStyle.forBackground,
  swapColors: true,
  keyColors: const FlexKeyColors(
    useSecondary: true,
    useTertiary: true,
  ),
  tones: FlexTones.vivid(Brightness.light),
),
darkTheme: FlexThemeData.dark(
  scheme: FlexScheme.flutterDash,
  usedColors: 4,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 15,
  appBarStyle: FlexAppBarStyle.background,
  appBarOpacity: 0.90,
  tabBarStyle: FlexTabBarStyle.forBackground,
  keyColors: const FlexKeyColors(
    useSecondary: true,
    useTertiary: true,
  ),
  tones: FlexTones.vivid(Brightness.dark),
),
```

--------------------------------

### Creating Custom ThemeData with FlexColorScheme and Component Themes (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet demonstrates how to create a custom `ThemeData` using `FlexColorScheme` and integrate a custom `ToggleButtonsThemeData` component theme. It shows how to extract the `ColorScheme` from the `FlexColorScheme` instance using `toScheme` to ensure theme-matching colors are used within custom component themes. The `toggleButtonsTheme` function defines the styling for `ToggleButtons` based on the provided `ColorScheme`.

```Dart
// A function to make custom ThemeData using FlexColorScheme
// and a custom ToggleButtonsThemeData component theme.
ThemeData myLightTheme({
}) {
  // We need to use the ColorScheme defined by the ThemeData that
  // FlexColorScheme will create based on our configuration in our
  // custom component theme. We first create the `FlexColorScheme` object:
  final FlexColorScheme flexScheme = FlexColorScheme.light(
    scheme: FlexScheme.flutterDash,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 10,
    appBarStyle: FlexAppBarStyle.background,
    appBarOpacity: 0.95,
    tabBarStyle: FlexTabBarStyle.forBackground,
  );
  // Then get the `ColorScheme` defined by our FlexColorScheme configuration,
  // using its `toScheme` method.
  final ColorScheme colorScheme = flexScheme.toScheme;
  // We can the return the `ThemeData` from our `FlexColorScheme`, with
  // our custom component theme added to it, where its customizations uses
  // color that the `ColorScheme` in the return `ThemeData` also gets.
  return flexScheme.toTheme.copyWith(
    // Add our custom toggle buttons component theme.
    toggleButtonsTheme: toggleButtonsTheme(colorScheme),
  );
}

// ToggleButtons theme.
ToggleButtonsThemeData toggleButtonsTheme(ColorScheme colorScheme) =>
    ToggleButtonsThemeData(
      selectedColor: colorScheme.onPrimary,
      color: colorScheme.primary.withOpacity(0.85),
      fillColor: colorScheme.primary.withOpacity(0.85),
      hoverColor: colorScheme.primary.withOpacity(0.2),
      focusColor: colorScheme.primary.withOpacity(0.3),
      borderWidth: 1.5,
      borderColor: colorScheme.primary,
      selectedBorderColor: colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
    );
```

--------------------------------

### Customizing ThemeData for Light and Dark Themes in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This Dart code demonstrates how to manually configure `ThemeData` for both light and dark modes. It uses `flexSchemeLight` and `flexSchemeDark` as base color schemes and customizes various properties like `primaryColor`, `scaffoldBackgroundColor`, `cardColor`, and `dialogBackgroundColor`. It also includes examples of computing `primaryColorLight` and `primaryColorDark` and integrating custom `textTheme` and `appBarTheme`.

```Dart
title: 'Custom ThemeData',
theme: ThemeData(
  colorScheme: flexSchemeLight,
  brightness: flexSchemeLight.brightness,
  primaryColor: flexSchemeLight.primary,
  // These we have to compute based based on our colorScheme primary color,
  // if we want to give them color scheme matching values. Here is an example that
  // happens to be what FlexColorScheme does, but feel free to use what you prefer:
  primaryColorLight: Color.alphaBlend(
      Colors.white.withAlpha(0x66), flexSchemeLight.primary),
  primaryColorDark: Color.alphaBlend(
      Colors.black.withAlpha(0x66), flexSchemeLight.primary),
  secondaryHeaderColor: Color.alphaBlend(
      Colors.white.withAlpha(0xCC), flexSchemeLight.primary),
  // These are deprecated in Flutter, we can skip defining them:
  //   primaryColorBrightness: ThemeData.estimateBrightnessForColor(colorScheme.primary),
  //   accentColor: colorScheme.secondary,
  //   accentColorBrightness: ThemeData.estimateBrightnessForColor(colorScheme.secondary),

  // As long as `toggleableActiveColor` exists in ThemeData, consider adding this one:
  toggleableActiveColor: flexSchemeLight.secondary,
  scaffoldBackgroundColor: flexSchemeLight.background,
  canvasColor: flexSchemeLight.background,
  backgroundColor: flexSchemeLight.background,
  cardColor: flexSchemeLight.surface,
  bottomAppBarColor: flexSchemeLight.surface,

  // For dialog prefer surface if your scheme background color is different from
  // its surface, this ensures elevation color in dark mode on dialogs, when
  // applyElevationOverlayColor is true in dark mode.
  dialogBackgroundColor: flexSchemeLight.surface,
  // In light mode the indicator is assumed to be used in a TabBar used
  // on an AppBar that is primary colored by default, so onPrimary is right
  // default. If you adjust your AppBar theme to something needing other
  // contrast color, or use TabBar on a light surface you need to adjust
  // this e.g. to onBackground.
  indicatorColor: flexSchemeLight.onPrimary,
  dividerColor: flexSchemeLight.onSurface.withOpacity(0.12),
  errorColor: flexSchemeLight.error,
  // Keep false in light mode.
  applyElevationOverlayColor: false,
  // Add your app's text theme here, or skip if default is OK.
  textTheme: myTextTheme,
  // Add all your custom component themes, as many as needed...
  appBarTheme: myAppBarTheme,
  tabBarTheme: myTabBarTheme,
),
// We repeat the above for our dark theme mode with our dark color schemes,
// with a few modifications mentioned below.
darkTheme: ThemeData(
  colorScheme: flexSchemeDark,
  brightness: flexSchemeDark.brightness,
  // Prefer primary for the `ThemeData.primaryColor` in dark mode too.
  primaryColor: flexSchemeDark.primary,
  // Same computation as above, just tuned a bit differently, adjust as needed.
  primaryColorLight: Color.alphaBlend(
      Colors.white.withAlpha(0x59), flexSchemeDark.primary),
  primaryColorDark: Color.alphaBlend(
      Colors.black.withAlpha(0x72), flexSchemeDark.primary),
  secondaryHeaderColor: Color.alphaBlend(
      Colors.black.withAlpha(0x99), flexSchemeDark.primary),
  // Don't forget this one in dark mode too.
  toggleableActiveColor: flexSchemeDark.secondary,
  scaffoldBackgroundColor: flexSchemeDark.background,
  canvasColor: flexSchemeDark.background,
  backgroundColor: flexSchemeDark.background,
  cardColor: flexSchemeDark.surface,
  bottomAppBarColor: flexSchemeDark.surface,
  // Use surface instead of background this ensures elevation color on dialogs,
  // when applyElevationOverlayColor is true.
  dialogBackgroundColor: flexSchemeDark.surface,
  // The AppBar will be dark, almost black, so this is correct for indicator
  // contrast on it, typically used by a TabBar in the AppBar.
  indicatorColor: flexSchemeDark.onBackground,
  dividerColor: flexSchemeDark.onSurface.withOpacity(0.12),
  errorColor: flexSchemeDark.error,
  // Set to true in dark mode.
  applyElevationOverlayColor: true,
  // Add your app's text theme here, or skip if default is OK.
  textTheme: myTextTheme,
  // Add all your custom component themes, as many as needed...
  appBarTheme: myAppBarTheme,
```

--------------------------------

### Applying Theme Data in Flutter MaterialApp

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_guide.mdx

This snippet demonstrates how to configure the `MaterialApp` widget to use custom `ThemeData` objects for different theme modes. It shows the use of `themeMode` to control the active theme, and `theme` and `darkTheme` properties to assign specific `ThemeData` objects for light and dark modes, respectively. This setup allows for a consistent visual appearance across the application based on user or system preferences.

```Dart
MaterialApp(
  themeMode: ThemeMode.system, // or ThemeMode.light or ThemeMode.dark,
  theme: ThemeData(...), // Your light ThemeData object.
  darkTheme: ThemeData(...), // Your dark ThemeData object.
  home: ...
```

--------------------------------

### Configuring Light and Dark Themes with FlexThemeData in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet demonstrates how to configure both light and dark themes using FlexThemeData from the flex_color_scheme package. It sets various properties such as scheme, usedColors, surfaceMode, blendLevel, appBarStyle, appBarOpacity, tabBarStyle, swapColors, and useMaterial3ErrorColors to customize the visual appearance of a Flutter application. The 'theme' property defines the light theme, while 'darkTheme' defines the dark theme, each with specific color and style adjustments.

```Dart
theme: FlexThemeData.light(
  scheme: FlexScheme.flutterDash,
  usedColors: 4,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 20,
  appBarStyle: FlexAppBarStyle.background,
  appBarOpacity: 0.95,
  tabBarStyle: FlexTabBarStyle.forBackground,
  swapColors: true,
  useMaterial3ErrorColors: true,
),
darkTheme: FlexThemeData.dark(
  scheme: FlexScheme.flutterDash,
  usedColors: 4,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 15,
  appBarStyle: FlexAppBarStyle.background,
  appBarOpacity: 0.90,
  tabBarStyle: FlexTabBarStyle.forBackground,
  useMaterial3ErrorColors: true,
),
```

--------------------------------

### Configuring FlexColorScheme with SubThemesData for Global Styling in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/api_guide.mdx

This snippet demonstrates how to configure FlexThemeData for both light and dark themes using FlexColorScheme in Flutter. It specifically highlights the use of FlexSubThemesData to apply a global defaultRadius of 12.0 dp to all components supporting border radius. It also shows how to control color blending (blendOnLevel, blendOnColors) and text theme usage (useTextTheme). The light theme uses blendLevel: 20 and blendOnColors: false for specific onColors, while the dark theme uses blendLevel: 15 and blendOnLevel: 30 with blendOnColors defaulting to true.

```Dart
theme: FlexThemeData.light(
  scheme: FlexScheme.flutterDash,
  usedColors: 4,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 20,
  appBarStyle: FlexAppBarStyle.background,
  appBarOpacity: 0.95,
  tabBarStyle: FlexTabBarStyle.forBackground,
  swapColors: true,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    blendOnColors: false,
    useTextTheme: false,
    defaultRadius: 12.0,
  ),
  keyColors: const FlexKeyColors(
    useSecondary: true,
    useTertiary: true,
  ),
  tones: FlexTones.vivid(Brightness.light),
),
darkTheme: FlexThemeData.dark(
  scheme: FlexScheme.flutterDash,
  usedColors: 4,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 15,
  appBarStyle: FlexAppBarStyle.background,
  appBarOpacity: 0.90,
  tabBarStyle: FlexTabBarStyle.forBackground,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 30,
    useTextTheme: false,
    defaultRadius: 12.0,
  ),
  keyColors: const FlexKeyColors(
    useSecondary: true,
    useTertiary: true,
  ),
  tones: FlexTones.vivid(Brightness.dark),
),
```

--------------------------------

### Initializing Theme Service and Controller in Flutter (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial3.mdx

This snippet initializes the Flutter application's theme management. It ensures Flutter bindings are ready, instantiates `ThemeServicePrefs` for local persistence via SharedPreferences, and then creates a `ThemeController` to manage and load theme settings. Finally, it runs the `DemoApp`, passing the initialized controller for theme state management.

```Dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Here we use the Shared Preferences theme service.
  final ThemeService themeService = ThemeServicePrefs();
  // Initialize the theme service.
  await themeService.init();
  // Create a ThemeController that uses the ThemeService.
  final ThemeController themeController = ThemeController(themeService);
  // Load preferred theme settings, while the app is loading, before MaterialApp
  // is created, this prevents a theme change when the app is first displayed.
  await themeController.loadAll();
  // Run the app and pass in the ThemeController. The app listens to the
  // ThemeController for changes.
  runApp(DemoApp(themeController: themeController));
}
```

--------------------------------

### Initializing Theme Service and Controller (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial2.mdx

This `main` function initializes the Flutter binding, creates a memory-only `ThemeServiceMem` instance, and then uses it to instantiate a `ThemeController`. It loads the preferred theme settings before the `MaterialApp` is built to prevent a theme change on initial display, and finally runs the application, passing the `ThemeController` for theme management.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The used memory only theme service.
  final ThemeService themeService = ThemeServiceMem();
  // Initialize the theme service.
  await themeService.init();
  // Create a ThemeController that uses the ThemeService.
  final ThemeController themeController = ThemeController(themeService);
  // Load preferred theme settings, while the app is loading, before MaterialApp
  // is created, this prevents a theme change when the app is first displayed.
  await themeController.loadAll();
  // Run the app and pass in the ThemeController. The app listens to the
  // ThemeController for changes.
  runApp(DemoApp(themeController: themeController));
}
```

--------------------------------

### Generating ThemeData from FlexColorScheme (Light)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial5.mdx

This snippet defines the `flexThemeLight` function, which serves as the entry point for generating the light `ThemeData` for the `MaterialApp`. It calls `flexColorSchemeLight` to obtain a `FlexColorScheme` object and then converts it to `ThemeData` using the `.toTheme` method. It depends on `ThemeController` and `flexColorSchemeLight`.

```Dart
ThemeData flexThemeLight(ThemeController controller) =>
    flexColorSchemeLight(controller).toTheme;
```

--------------------------------

### Using ThemeData.from with ColorScheme.fromSwatch (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This snippet illustrates a more advanced theme configuration using the `ThemeData.from` factory constructor, which takes a `ColorScheme` generated by `ColorScheme.fromSwatch`. It demonstrates how to create light and dark themes based on a swatch, either `Colors.blue` or `flexSwatch`.

```Dart
// 4) TD.from scheme.fromSwatch
//    ThemeData.from(colorScheme: ColorScheme.fromSwatch(...))
//
title: '4) TD.from fromSwatch',
theme: ThemeData.from(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue, // or flexSwatch
    brightness: Brightness.light,
  ),
),
darkTheme: ThemeData.from(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue, // or flexSwatch
    brightness: Brightness.dark,
  ),
),
```

--------------------------------

### Applying FlexColorScheme Comfortable Platform Visual Density (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial3.mdx

This snippet applies `FlexColorScheme.comfortablePlatformDensity` as the `visualDensity` for the `ThemeData`. This static helper provides a platform-adaptive visual density that is 'comfortable' on desktops (larger touch targets than 'compact') while maintaining appropriate density for other devices, offering a balanced user experience.

```Dart
  // Use FlexColorScheme static helper comfortablePlatformDensity.
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
```

--------------------------------

### Initializing Flutter App with FlexColorScheme Themes - Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial1.mdx

This Dart code initializes a Flutter application (`DemoApp`) using `FlexColorScheme` to manage light and dark themes. It demonstrates how to configure `MaterialApp` with `FlexThemeData.light` and `FlexThemeData.dark` using a predefined `FlexScheme` (mandyRed), and how to switch between theme modes (system, light, dark) and Material 2/3 versions. The `HomePage` is passed theme mode and Material 3 state for dynamic updates.

```Dart
void main() => runApp(const DemoApp());

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  // Used to select if we use the dark or light theme, start with system mode.
  ThemeMode themeMode = ThemeMode.system;
  // Opt in/out on Material-3
  bool useMaterial3 = true;

  @override
  Widget build(BuildContext context) {
    // Select the predefined FlexScheme color scheme to use. Modify the
    // used FlexScheme enum value below to try other pre-made color schemes.
    const FlexScheme usedScheme = FlexScheme.mandyRed;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Basic Theme Usage',
      // Use a predefined FlexThemeData.light() theme for the light theme.
      theme: FlexThemeData.light(
        scheme: usedScheme,
        // Use very subtly themed app bar elevation in light mode.
        appBarElevation: 0.5,
        useMaterial3: useMaterial3,
        // We use the nicer Material-3 Typography in both M2 and M3 mode.
        typography: Typography.material2021(platform: defaultTargetPlatform),
      ),
      // Same definition for the dark theme, but using FlexThemeData.dark().
      darkTheme: FlexThemeData.dark(
        scheme: usedScheme,
        // Use a bit more themed elevated app bar in dark mode.
        appBarElevation: 2,
        useMaterial3: useMaterial3,
        // We use the nicer Material-3 Typography in both M2 and M3 mode.
        typography: Typography.material2021(platform: defaultTargetPlatform),
      ),
      // Use the above dark or light theme based on active themeMode.
      themeMode: themeMode,
      home: HomePage(
        // We pass it the current theme mode.
        themeMode: themeMode,
        // On the home page we can toggle theme mode between light and dark.
        onThemeModeChanged: (ThemeMode mode) {
          setState(() {
            themeMode = mode;
          });
        },
        useMaterial3: useMaterial3,
        // On the home page we can toggle theme Material 2/3 mode.
        onUseMaterial3Changed: (bool material3) {
          setState(() {
            useMaterial3 = material3;
          });
        },
        flexSchemeData: FlexColor.schemes[usedScheme]!,
      ),
    );
  }
}
```

--------------------------------

### Initializing ThemeData.from with ColorScheme.fromSeed in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This snippet demonstrates creating `ThemeData` using the `ThemeData.from` factory constructor, which takes an existing `ColorScheme` as input. The `ColorScheme` itself is generated using `ColorScheme.fromSeed` with a specified `seedColor` and `brightness` for both light and dark themes. This approach combines `ThemeData.from`'s ability to derive a theme from a color scheme with the seeded color generation.

```Dart
// 9) TD.from scheme.fromSeed
//    ThemeData(colorScheme: ColorScheme.fromSeed(...))
//
title: '9) TD.from fromSeed',
theme: ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff6750a4),
    brightness: Brightness.light,
  ),
),
darkTheme: ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff6750a4),
    brightness: Brightness.dark,
  ),
),
```

--------------------------------

### Configuring MaterialApp with FlexColorScheme in Dart

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial4.mdx

This Dart snippet defines a `DemoApp` StatelessWidget that dynamically configures the `MaterialApp`'s light and dark themes using `FlexThemeData` and a `ThemeController`. It showcases detailed theme customization including `useMaterial3`, `colors` from custom schemes, `FlexSurfaceMode.highScaffoldLowSurfaces`, `blendLevel`, `appBarElevation`, `FlexSubThemesData` for component theming, and `FlexKeyColors` for Material 3 seed generation, ensuring the app rebuilds on theme changes.

```Dart
class DemoApp extends StatelessWidget {
  const DemoApp({Key? key, required this.themeController}) : super(key: key);
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    // Whenever the theme controller notifies the listenable in the
    // ListenableBuilder, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: themeController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          title: 'All Themes',
          // Define the light theme for the app, using current scheme index.
          theme: FlexThemeData.light(
            useMaterial3: themeController.useMaterial3,
            // We use our list of color schemes, and a theme controller managed
            // index to change the index of used color scheme from the list.
            colors: AppColor.customSchemes[themeController.schemeIndex].light,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
            // Our content is not all wrapped in cards in this demo, so
            // we keep the blend level fairly low for good contrast.
            blendLevel: 2,
            appBarElevation: 0.5,
            // Opt-in/out on using component sub-themes.
            subThemesData: themeController.useSubThemes
                ? FlexSubThemesData(
                    // ThemeController managed radius to use as widget radius.
                    defaultRadius: themeController.defaultRadius,
                  )
                : null,
            // Control how seed generation is done by using `FlexKeyColors`
            keyColors: FlexKeyColors(
              useKeyColors: themeController.useKeyColors,
              useSecondary: themeController.useSecondary,
              useTertiary: themeController.useTertiary,
              keepPrimary: themeController.keepPrimary,
              keepSecondary: themeController.keepSecondary,
              keepTertiary: themeController.keepTertiary,
            ),
            visualDensity: AppData.visualDensity,
            fontFamily: AppData.font,
            // We use the nicer Material-3 Typography in both M2 and M3 mode.
            typography: Typography.material2021(platform: defaultTargetPlatform),
          ),
          // We make an equivalent definition for the dark theme.
          darkTheme: FlexThemeData.dark(
            useMaterial3: themeController.useMaterial3,
            colors: AppColor.customSchemes[themeController.schemeIndex].dark,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
            // We go with a slightly stronger blend in dark mode.
            blendLevel: 7,
            appBarElevation: 0.5,
            keyColors: FlexKeyColors(
              useKeyColors: themeController.useKeyColors,
              useSecondary: themeController.useSecondary,
              useTertiary: themeController.useTertiary,
              keepPrimary: themeController.keepDarkPrimary,
              keepSecondary: themeController.keepDarkSecondary,
              keepTertiary: themeController.keepDarkTertiary,
            ),
            subThemesData: themeController.useSubThemes
                ? FlexSubThemesData(
                    defaultRadius: themeController.defaultRadius,
                  )
                : null,
            visualDensity: AppData.visualDensity,
            fontFamily: AppData.font,
            typography: Typography.material2021(platform: defaultTargetPlatform),
          ),
          // Use the dark or light theme based on controller setting.
          themeMode: themeController.themeMode,
          // Here we only pass the theme controller to the HomePage, where
          // we can can change its values with UI controls.
          home: HomePage(controller: themeController),
        );
      },
    );
  }
}
```

--------------------------------

### Configuring MaterialApp with ThemeController in Flutter

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/tutorial5.mdx

This `StatelessWidget` `PlaygroundApp` builds the root `MaterialApp` of the application. It uses a `ThemeController` to manage theme settings, dynamically switching between `FlexColorScheme` generated themes (`flexThemeLight`, `flexThemeDark`) and standard `ThemeData` (`themeDataLight`, `themeDataDark`) based on `controller.useFlexColorScheme`. The `ListenableBuilder` ensures the `MaterialApp` rebuilds whenever the controller notifies changes, applying new theme configurations.

```Dart
class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key, required this.controller});
  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    // Whenever the theme controller notifies the listenable in the
    // ListenableBuilder, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Themes Playground',
          // The Theme controller controls if we use FlexColorScheme made
          // ThemeData or standard SDK ThemeData. It also
          // controls all the configuration parameters used to define the
          // FlexColorScheme object that produces the ThemeData object.
          theme: controller.useFlexColorScheme
              ? flexThemeLight(controller)
              : themeDataLight(controller),
          darkTheme: controller.useFlexColorScheme
              ? flexThemeDark(controller)
              : themeDataDark(controller),
          // Use the dark/light theme based on controller setting.
          themeMode: controller.themeMode,
          home: GestureDetector(
            // This allows us to un-focus a widget, typically a TextField
            // with focus by tapping somewhere outside it. It is no longer
            // needed on desktop builds, it is done automatically there for
            // TextField, but not on tablet and phone app. In this app we
            // want it on them too and to unfocus other widgets with focus
            // on desktop too.
            onTap: () => FocusScope.of(context).unfocus(),
            // Pass the controller to the HomePage where we use it to change
            // the theme settings that will cause themes above to change and
            // rebuild the entire look of the app based on modified theme.
            //
            // There are more than 270 properties in the controller that can
            // be used to control the two light and dark mode themes.
            // Every time one of them is modified, the themed app is rebuilt
            // with the new ThemeData applied.
            // The code that one need to use the same theme is also updated
            // interactively for each change when the code gen panel is
            // in view.
            child: HomePage(controller: controller),
          ),
        );
      },
    );
  }
}
```

--------------------------------

### Creating FlexThemeData with existing ColorScheme (Dart)

Source: https://github.com/rydmike/flex_color_scheme_docs/blob/master/docs/theming_roads.mdx

This snippet demonstrates how to initialize FlexThemeData directly using pre-defined 'flexSchemeLight' and 'flexSchemeDark' ColorScheme objects. This approach allows for precise control over the theme's color palette and facilitates direct comparison with standard ThemeData creation methods.

```Dart
title: '10) FlexThemeData.light(colorScheme)',
theme: FlexThemeData.light(colorScheme: flexSchemeLight),
darkTheme: FlexThemeData.dark(colorScheme: flexSchemeDark),
```