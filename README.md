# Split Happens

A Flutter app that splits restaurant bills: photograph a receipt, extract the
line items with on-device OCR (Google ML Kit), parse them into structured data
with an LLM (via OpenRouter), assign items to people, and see who owes what —
with tax and tip prorated automatically.

## Tech stack

- **Flutter** (Material 3) + **Riverpod** for state
- **google_mlkit_text_recognition** — on-device, offline OCR
- **OpenRouter** REST API for LLM parsing
- **drift** (SQLite) for saved bills
- **camera** / **image_picker** for capture, **pdf** / **printing** / **share_plus** for export
- **flutter_secure_storage** for the API key

---

## Prerequisites

- **Flutter SDK 3.44+** (Dart 3.12+). Check with `flutter --version`.
- An **OpenRouter API key** — sign up at <https://openrouter.ai> and create a key
  (entered in the app's Settings screen, not in code).
- For **Android**: Android Studio + an Android SDK (the app targets **minSdk 24**,
  Android 7.0+, required by ML Kit and secure storage).
- For **iOS**: a Mac with **Xcode** and CocoaPods (`sudo gem install cocoapods`).

Verify your setup at any time with:

```bash
flutter doctor
```

---

## First-time setup (all platforms)

```bash
# 1. Install Dart/Flutter dependencies
flutter pub get

# 2. Generate code (Freezed models, json_serializable, Drift, Riverpod)
dart run build_runner build --delete-conflicting-outputs
```

> Re-run the `build_runner` command whenever you change a `@freezed` model, a
> Riverpod provider annotation, or the Drift schema. During active development
> you can use `dart run build_runner watch --delete-conflicting-outputs` to
> regenerate automatically.

After launching the app, open **Settings** and paste your OpenRouter API key
before scanning a receipt.

---

## Run on Android (command line)

1. Connect a device with **USB debugging** enabled, or start an emulator
   (`flutter emulators --launch <emulator_id>`).
2. Confirm it's detected:

   ```bash
   flutter devices
   ```

3. Run in debug mode:

   ```bash
   flutter run
   ```

   If multiple devices are connected, target one explicitly:

   ```bash
   flutter run -d <device_id>
   ```

Build installable artifacts:

```bash
flutter build apk --release          # APK for sideloading
flutter build appbundle --release    # AAB for the Play Store
```

The APK is written to `build/app/outputs/flutter-apk/`.

---

## Run on Android (Android Studio)

1. **Open the project**: *File → Open* and select the repository root
   (`split_happens/`). Let Gradle sync finish.
2. Install the **Flutter** and **Dart** plugins if prompted
   (*Settings → Plugins*), then restart.
3. Set the Flutter SDK path if asked: *Settings → Languages & Frameworks →
   Flutter*.
4. Run the codegen step once from the built-in terminal:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Pick a device/emulator in the device dropdown (top toolbar). To create an
   emulator: *Tools → Device Manager → Create Device*.
6. Select **main.dart** as the run configuration and press **Run** (▶) or
   **Debug** (🐞).

> Camera capture does not work on a bare emulator without a configured virtual
> camera — use a physical device for scanning, or the in-app **gallery picker**
> on the emulator.

---

## Run on iOS (Mac only)

1. Install pods on first run:

   ```bash
   cd ios && pod install && cd ..
   ```

2. Run on a connected device or the simulator:

   ```bash
   flutter run                 # auto-selects a running simulator/device
   flutter run -d <device_id>  # or target a specific one
   ```

3. To run from **Xcode** (needed for signing on a physical device):

   ```bash
   open ios/Runner.xcworkspace
   ```

   In Xcode, select **Runner → Signing & Capabilities**, choose your Apple
   developer **Team**, then press **Run**.

Build a release archive:

```bash
flutter build ipa --release
```

> The camera is unavailable on the iOS Simulator — use a physical device to
> scan, or the **gallery picker** in the simulator. Permission prompts for the
> camera and photo library are already declared in `ios/Runner/Info.plist`.

---

## Permissions

These are pre-configured in the repository:

- **Android** (`android/app/src/main/AndroidManifest.xml`): `CAMERA` permission
  and the ML Kit OCR model dependency.
- **iOS** (`ios/Runner/Info.plist`): `NSCameraUsageDescription` and
  `NSPhotoLibraryUsageDescription`.

---

## Tests & static analysis

```bash
flutter test       # unit tests (SplitCalculator math)
flutter analyze    # static analysis — should report no issues
```
