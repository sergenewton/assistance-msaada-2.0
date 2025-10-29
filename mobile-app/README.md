# assistance_msaada_2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local runs (emulators) 🚀

Backend local URL: http://localhost:8000 (started from repo root with `./quick-start-local.sh`).

API base URL rules by target:
- Android emulator: use `http://10.0.2.2:8000`
- iOS simulator: use `http://localhost:8000`
- Chrome (web): use `http://localhost:8000`

### Quick scripts

Make scripts executable once:

```bash
chmod +x scripts/run-android.sh scripts/run-ios.sh
```

Run on Android emulator (auto-starts first AVD if needed):

```bash
scripts/run-android.sh
# override API if needed
API_BASE_URL=http://10.0.2.2:8001 scripts/run-android.sh
scripts/run-android.sh --api http://10.0.2.2:8000
```

Run on iOS simulator:

```bash
scripts/run-ios.sh
# override API if needed
API_BASE_URL=http://localhost:8001 scripts/run-ios.sh
scripts/run-ios.sh --api http://localhost:8000
```

### Manual commands

```bash
flutter pub get
flutter devices
# Android emulator target
flutter run -d <ANDROID_DEVICE_ID> --dart-define API_BASE_URL=http://10.0.2.2:8000
# iOS simulator target
flutter run -d <IOS_SIMULATOR_ID> --dart-define API_BASE_URL=http://localhost:8000
```

### Notes

- Android emulator resolves host machine via `10.0.2.2`.
- If using HTTP in dev, ensure AndroidManifest has `android:usesCleartextTraffic="true"`; for iOS add temporary ATS exceptions in Info.plist when needed.
- For web testing, ensure CORS allows `http://localhost:3000` (Vite) to call `http://localhost:8000`.
