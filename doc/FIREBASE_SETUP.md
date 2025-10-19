# Firebase Multi-Flavor Setup Guide

This document explains the Firebase configuration for Tutor Zone's multi-flavor architecture.

## Architecture Overview

The app uses **Option 3: Two Projects** approach:
- **Dev & Staging** share the `tutor-zone-996b0` project
- **Production** uses the separate `tutor-zone-prod` project

This provides:
- ✅ Cost efficiency (dev/staging share resources)
- ✅ Production isolation (separate billing, quotas, data)
- ✅ Realistic staging environment (same project structure as dev)

## Firebase Projects

### Development/Staging Project
- **Project ID**: `tutor-zone-996b0`
- **Project Number**: `421970184365`
- **Used by**: Dev and Staging flavors
- **Storage Bucket**: `tutor-zone-996b0.firebasestorage.app`
- **Console**: https://console.firebase.google.com/project/tutor-zone-996b0

### Production Project
- **Project ID**: `tutor-zone-prod`
- **Project Number**: `212802016089`
- **Used by**: Production flavor
- **Storage Bucket**: `tutor-zone-prod.firebasestorage.app`
- **Console**: https://console.firebase.google.com/project/tutor-zone-prod

## Firebase Apps Configuration

### Android Apps

| Flavor | Package Name | App ID | Project |
|--------|-------------|---------|---------|
| Dev | `com.example.tutor_zone.dev` | `1:421970184365:android:4f50a1da76063fbacf1e24` | tutor-zone-996b0 |
| Staging | `com.example.tutor_zone.staging` | `1:421970184365:android:d53ffeaba84f55a1cf1e24` | tutor-zone-996b0 |
| Prod | `com.example.tutor_zone` | `1:212802016089:android:cc8d37399d48e8846f7248` | tutor-zone-prod |

### iOS Apps

| Flavor | Bundle ID | App ID | Project |
|--------|-----------|---------|---------|
| Dev | `com.example.tutorZone.dev` | `1:421970184365:ios:d5ec60356ddbe769cf1e24` | tutor-zone-996b0 |
| Staging | `com.example.tutorZone.staging` | `1:421970184365:ios:7f399d8c54aaf7e6cf1e24` | tutor-zone-996b0 |
| Prod | `com.example.tutorZone` | `1:212802016089:ios:a47a17f7d0b045206f7248` | tutor-zone-prod |

### Web Apps

| Flavor | App ID | Project |
|--------|---------|---------|
| Dev | `1:421970184365:web:d09346aab0dd8ceacf1e24` | tutor-zone-996b0 |
| Staging | `1:421970184365:web:aad357395e89191bcf1e24` | tutor-zone-996b0 |
| Prod | `1:212802016089:web:4c3a2e9b6d67a3236f7248` | tutor-zone-prod |

## File Structure

```
tutor_zone/
├── lib/
│   ├── config/
│   │   ├── firebase_options_dev.dart       # Dev Firebase config
│   │   ├── firebase_options_staging.dart   # Staging Firebase config
│   │   └── firebase_options_prod.dart      # Production Firebase config
│   ├── main_dev.dart                       # Dev entry point
│   ├── main_staging.dart                   # Staging entry point
│   ├── main_prod.dart                      # Production entry point
│   └── bootstrap.dart                      # Initializes Firebase based on flavor
│
├── android/
│   └── app/
│       ├── build.gradle.kts                # Contains product flavors config
│       └── src/
│           ├── dev/
│           │   └── google-services.json    # Dev Android config
│           ├── staging/
│           │   └── google-services.json    # Staging Android config
│           └── prod/
│               └── google-services.json    # Prod Android config
│
└── ios/
    ├── config/
    │   ├── dev/
    │   │   └── GoogleService-Info.plist    # Dev iOS config
    │   ├── staging/
    │   │   └── GoogleService-Info.plist    # Staging iOS config
    │   └── prod/
    │       └── GoogleService-Info.plist    # Prod iOS config
    └── scripts/
        └── copy-firebase-config.sh         # Build script to copy correct plist
```

## Running Different Flavors

### Development
```bash
# Default flavor (dev)
flutter run

# Explicit dev flavor
flutter run -t lib/main_dev.dart

# With specific device
flutter run -t lib/main_dev.dart -d <device_id>
```

### Staging
```bash
flutter run -t lib/main_staging.dart
```

### Production
```bash
flutter run -t lib/main_prod.dart
```

## Building for Release

### Android

```bash
# Dev
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build appbundle --flavor dev -t lib/main_dev.dart

# Staging
flutter build apk --flavor staging -t lib/main_staging.dart
flutter build appbundle --flavor staging -t lib/main_staging.dart

# Production
flutter build apk --flavor prod -t lib/main_prod.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

### iOS

For iOS, you'll need to:
1. Open Xcode
2. Create build configurations (Debug-dev, Release-dev, Debug-staging, etc.)
3. Create schemes for each flavor
4. Add a build phase to run `copy-firebase-config.sh`

```bash
# Dev
flutter build ios --flavor dev -t lib/main_dev.dart

# Staging
flutter build ios --flavor staging -t lib/main_staging.dart

# Production
flutter build ios --flavor prod -t lib/main_prod.dart
```

## iOS Xcode Configuration

### Step 1: Add Build Configurations
1. Open `ios/Runner.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select the **Info** tab
4. Under **Configurations**, duplicate existing configs:
   - Duplicate `Debug` → `Debug-dev`, `Debug-staging`, `Debug-prod`
   - Duplicate `Release` → `Release-dev`, `Release-staging`, `Release-prod`

### Step 2: Create Schemes
1. Go to **Product → Scheme → Manage Schemes**
2. Duplicate the `Runner` scheme three times
3. Rename them to: `Runner-dev`, `Runner-staging`, `Runner-prod`
4. For each scheme:
   - Edit Scheme → Build Configuration
   - Set Debug to corresponding Debug-* config
   - Set Release to corresponding Release-* config

### Step 3: Add Build Phase Script
1. Select the **Runner** target
2. Go to **Build Phases**
3. Click **+** → **New Run Script Phase**
4. Name it "Copy Firebase Config"
5. Add this script:
```bash
"${SRCROOT}/scripts/copy-firebase-config.sh"
```
6. Move it **before** "Copy Bundle Resources"

### Step 4: Update Bundle IDs
1. Select the **Runner** target
2. Go to **Build Settings**
3. Search for "Product Bundle Identifier"
4. For each configuration:
   - Debug-dev/Release-dev: `com.example.tutorZone.dev`
   - Debug-staging/Release-staging: `com.example.tutorZone.staging`
   - Debug-prod/Release-prod: `com.example.tutorZone`

## How It Works

### Android
1. Gradle's `productFlavors` configuration automatically selects the correct `google-services.json` from the flavor-specific `src` directory
2. Each flavor has its own application ID suffix (`.dev`, `.staging`, or none)
3. The build system picks the right config at build time

### iOS
1. The `copy-firebase-config.sh` script runs during the build phase
2. It detects the current build configuration (Debug-dev, Release-prod, etc.)
3. It copies the appropriate `GoogleService-Info.plist` from `ios/config/{flavor}/` to the app bundle
4. Different bundle IDs ensure apps can coexist on the same device

### Dart/Flutter
1. Each main entry point (`main_dev.dart`, etc.) sets the appropriate flavor
2. `bootstrap.dart` initializes Firebase with the flavor-specific options
3. The correct `firebase_options_{flavor}.dart` file is imported and used
4. Firebase SDK connects to the correct project automatically

## Verifying Setup

To verify Firebase is working correctly:

```dart
import 'package:firebase_core/firebase_core.dart';

void checkFirebaseSetup() {
  final app = Firebase.app();
  print('Firebase Project: ${app.options.projectId}');
  print('App ID: ${app.options.appId}');
  print('Storage Bucket: ${app.options.storageBucket}');
}
```

Expected output:
- **Dev**: `tutor-zone-996b0`
- **Staging**: `tutor-zone-996b0`
- **Prod**: `tutor-zone-prod`

## Troubleshooting

### Android: "No matching client found for package name"
- Ensure you're running the correct flavor: `flutter run --flavor dev`
- Check that `google-services.json` exists in the correct `src/{flavor}/` directory
- Verify package name in `build.gradle.kts` matches Firebase console

### iOS: "GoogleService-Info.plist not found"
- Ensure the build script `copy-firebase-config.sh` is executable: `chmod +x ios/scripts/copy-firebase-config.sh`
- Check that the build phase script runs before "Copy Bundle Resources"
- Verify the plist files exist in `ios/config/{flavor}/`

### Wrong Firebase project connected
- Check the flavor is set correctly in main entry point
- Verify `bootstrap.dart` is importing the correct firebase_options file
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

## Adding New Firebase Services

When adding new Firebase services (Auth, Firestore, Storage, etc.):

1. Enable the service in **both** Firebase projects (dev/staging and prod)
2. Add the required Flutter packages to `pubspec.yaml`
3. Initialize the service in `bootstrap.dart` after Firebase initialization
4. Use the same code across all flavors - the config handles the routing

Example:
```dart
// In bootstrap.dart
await _initializeFirebase(flavorConfig.flavor);

// Initialize Firebase Auth (works for all flavors)
// The SDK automatically uses the correct project based on Firebase.app()
```

## Security Notes

1. **API Keys in Code**: Firebase API keys in the code are safe - they identify your project, not authenticate users
2. **Security Rules**: Set up proper Firestore/Storage security rules in both projects
3. **Separate Data**: Dev/staging share a project but use different collections/paths if needed
4. **Production Isolation**: Production data is completely separate in its own project

## Next Steps

1. ✅ Firebase projects created (dev/staging + prod)
2. ✅ Firebase apps configured for all platforms
3. ✅ Configuration files generated and organized
4. ✅ Android product flavors configured
5. ✅ iOS build script created
6. ✅ Bootstrap integration complete
7. ⏳ Configure Xcode build configurations and schemes (iOS only)
8. ⏳ Set up Firebase Authentication in both projects
9. ⏳ Configure Firestore databases with security rules
10. ⏳ Set up Firebase Cloud Messaging for push notifications
11. ⏳ Configure Firebase Analytics (enabled for staging/prod)
12. ⏳ Set up Crashlytics for error tracking

---

**Last Updated**: 2025-01-19
**Version**: 1.0.0
