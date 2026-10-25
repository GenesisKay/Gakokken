# Gakoken — Run (Windows / Android emulator)

Local-first Flutter app. Prefer **Android** (emulator or device) when verifying features.

## Tools for the Rust engine

Already installed on this machine (Windows):

- Rust via `rustup`, with Android targets: `rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android`
- Visual Studio 2022 Build Tools with the C++ workload (Rust needs the MSVC linker on Windows)
- Android NDK 27 (`%LOCALAPPDATA%\Android\Sdk\ndk`)
- `cargo install cargo-ndk flutter_rust_bridge_codegen`

In every PowerShell window before building:

```powershell
$env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

Build the test APK: `flutter build apk --debug` (output in `build/app/outputs/flutter-apk/`).

## Android emulator checklist

Do both of these before `flutter run`:

1. **Start the emulator from Android Studio**  
   Open Android Studio → Device Manager → start a virtual device.  
   Flutter does not always boot the AVD for you; leave the emulator running.

2. **Put `adb` on the PATH** (PowerShell, current session):

```powershell
$env:Path += ";$env:LOCALAPPDATA\Android\Sdk\platform-tools"
```

Without this, `flutter devices` / `flutter run` may not see the emulator even when it is open.

## Run the app

```powershell
flutter pub get
flutter devices
flutter run
```

If multiple devices are listed, pick the emulator:

```powershell
flutter run -d <device_id>
```

## Notes

- Re-run the `$env:Path += ...` line in every **new** PowerShell window (unless you add platform-tools to your user PATH permanently).
- SDK path above is the default Windows install under `%LOCALAPPDATA%\Android\Sdk`. Adjust if your SDK lives elsewhere.
- Real device: enable USB debugging; same PATH tip applies so `adb` works.
