# Penguin Balance

Deterministic Flutter puzzle game where players place weighted penguin pieces on fixed board slots to keep torque balanced.

## Features

- Integer-only torque math (`Σ weight × distance`)
- Solo level mode with predefined levels
- Toy-like board with 3x3 slots per side (9 left + 9 right)
- Deterministic AI mode (no randomness)
- State-driven board tilt + wobble animation
- Pseudo-3D board and piece styling
- `go_router` navigation with Home / Solo / VS AI / Settings
- Dedicated settings screen with continue flow
- Play win confetti feedback
- Local persistence for settings + progress (wins/losses/levels played)

## Structure

```text
lib/
 ├── core/
 │    ├── balance_logic.dart
 │    ├── ai_engine.dart
 │    ├── game_state.dart
 │    ├── app_storage.dart
 │    └── app_config.dart
 │
 ├── models/
 │    ├── piece.dart
 │    ├── slot.dart
 │    ├── level.dart
 │
 ├── ui/
 │    ├── board_widget.dart
 │    ├── piece_widget.dart
 │    ├── game_screen.dart
 │    ├── home_screen.dart
 │    └── settings_screen.dart
 │
 └── main.dart
```

## Local setup (development environment)

### 1) Install required tools
- Flutter SDK (stable channel)
- Dart SDK (comes with Flutter)
- Android Studio (for Android SDK + emulator)
- Xcode (macOS only, for iOS builds)

Check installation:

```bash
flutter --version
flutter doctor
```

Resolve all issues reported by `flutter doctor` before continuing.

### 2) Clone and bootstrap

```bash
git clone <your-repo-url>
cd balance-pengines
flutter pub get
```

### 3) Run the app

```bash
flutter run
```

You can target specific devices:

```bash
flutter devices
flutter run -d <device_id>
```

## Testing and quality checks

Run unit tests:

```bash
flutter test
```

Recommended static checks:

```bash
flutter analyze
```

Optional formatting:

```bash
dart format lib test
```

## Production build and publishing

> This repository currently contains Dart source only. To publish to stores, ensure standard Flutter platform folders (`android/`, `ios/`) are present in your app project.

### Android (Google Play)

#### 1) Build release artifact
Use either App Bundle (recommended) or APK:

```bash
flutter build appbundle --release
# or
flutter build apk --release
```

Output (AAB):
- `build/app/outputs/bundle/release/app-release.aab`

#### 2) App signing (required)
- Create/upload keystore
- Configure signing in `android/key.properties` and `android/app/build.gradle`

#### 3) Publish to Play Console
- Create application listing
- Upload `app-release.aab`
- Fill store listing, data safety, privacy policy, content rating
- Roll out to internal test, closed/open testing, then production

### iOS (App Store)

#### 1) Build iOS release

```bash
flutter build ios --release
```

#### 2) Archive in Xcode
- Open `ios/Runner.xcworkspace` in Xcode
- Select **Any iOS Device (arm64)**
- Product → Archive
- Validate and upload using Organizer

#### 3) Publish in App Store Connect
- Create app record
- Add screenshots, metadata, privacy details
- Select uploaded build
- Submit for review

## Versioning before release

Update `version` in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- `1.0.0` = user-visible version
- `+1` = build number (must increase each upload)

## Permissions

This app currently uses local key-value storage (`shared_preferences`) only and does not request dangerous runtime permissions.

Permission policy is documented in `lib/core/app_config.dart` (`requiredRuntimePermissions` is empty).
