# Kigo — Flutter Technical Assessment

A Flutter mobile app built from Figma designs. Kigo is a parking and mobility app.

---

## Screens to implement

| Screen Name | Description |
|--------|--------|
| Splash | Orange background, Kigo + Parkimovil logos |
| Login | Phone input, privacy policy toggle |
| OTP | 5-digit OTP input, auto-advance |
| QR Home | Live camera, balance card, feature buttons |

---

## Features

- **Phone authentication flow** — Phone number input → OTP verification → QR Home
- **Live QR scanner** — Real camera viewfinder via `mobile_scanner`, flash toggle
- **Balance card** — Active parking card with balance display
- **Country selector** — Change country dropdown
- **Feature shortcuts** — Parkingmeter and Status quick-access buttons
- **5-tab bottom navigation** — Map, Control, QR, Services, Profile
- **Full UI state handling** — Loading, success, empty, error, and retry states throughout
- **Mocked data layer** — Fake repositories swappable with a real backend via dependency injection

---

## Tech Stack

| Concern | Choice | Reason |
|---------|--------|--------|
| State management | MobX | Reactive, minimal boilerplate, scales well |
| Navigation | go_router | Declarative, deep-link ready, shell routes for bottom nav |
| Dependency injection | get_it | Simple service locator, easy to swap implementations |
| Architecture | Feature-first + Repository pattern | Scales by feature, clear separation of concerns |
| Camera / QR | mobile_scanner | Best-maintained Flutter QR package, supports iOS & Android |

---

## Project Structure

```
lib/
├── core/
│   ├── theme/          # AppColors, AppTextStyles, AppTheme
│   ├── router/         # go_router config, ShellRoute, all routes
│   └── di/             # get_it registrations (injection.dart)
├── features/
│   ├── auth/
│   │   ├── screens/    # splash_screen, login_screen, otp_screen
│   │   ├── stores/     # AuthStore (MobX), OtpStore (MobX)
│   │   └── repositories/ # AuthRepository (abstract) + FakeAuthRepository
│   └── home/
│       ├── screens/    # qr_screen, stub_screen
│       ├── models/     # CardInfo
│       ├── stores/     # HomeStore (MobX)
│       └── repositories/ # HomeRepository (abstract) + FakeHomeRepository
└── shared/
    └── widgets/        # Shared reusable components
```

---

## Getting Started

### Prerequisites

- Flutter 3.29.x stable ([install via flutter.dev](https://flutter.dev/docs/get-started/install))
- Xcode 15+ with Command Line Tools (for iOS builds)
- CocoaPods (`sudo gem install cocoapods`)
- An iOS simulator or Android emulator

### Clone & Run

```bash
# 1. Clone the repository
git clone https://github.com/NuryReyes/flutter-kigo-flow.git
cd flutter-kigo-flow

# 2. Install dependencies
flutter pub get

# 3. Generate MobX code (required before first run)
dart run build_runner build --delete-conflicting-outputs

# 4. Install iOS pods
cd ios && pod install && cd ..

# 5. Run on simulator
flutter run
```

> **Note on camera:** The live QR camera viewfinder requires a physical device. On the iOS simulator, the camera area will appear blank — this is expected behaviour from `mobile_scanner`. All other features work normally on the simulator.

---

## Running Tests

**Note:** Tests not included due to time constraints

```bash
flutter test
```

---

## Building a Release APK (Android)

```bash
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

> **Android setup required:** Ensure you have Android Studio and an Android SDK installed, or set `ANDROID_HOME` to your SDK path.

---

## Mocked Data Layer

All data is served by fake repository implementations registered in `core/di/injection.dart`. To swap in a real backend:

1. Create a new implementation of the relevant abstract repository (e.g. `RealAuthRepository implements AuthRepository`)
2. In `injection.dart`, replace the `FakeAuthRepository` registration with your new class
3. No other code changes required — stores and screens are decoupled from the data source

```dart
// injection.dart — swap this line:
getIt.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
// with:
getIt.registerLazySingleton<AuthRepository>(() => RealAuthRepository());
```

---

## Navigation Flow

```
/splash  →  /login  →  /otp  →  /home/qr
                                    ├── /home/mapa
                                    ├── /home/control
                                    ├── /home/servicios
                                    └── /home/perfil
```

State is passed between screens via `go_router`'s `extra` parameter (e.g. phone number from login → OTP screen).

---

## Known Limitations

- Camera preview was not tested, only the iOS simulator was used.
- Stub screens (Mapa, Control, Servicios, Perfil) are placeholders, each of these screens should be handled as a separate feature.
- OTP verification accepts any code and navigates user to the next screen. A real OTP implementation might be more complex than what was provided, depending on the service used and if part of the requirement was to auto-complete the code from received SMS.
- Many buttons in the QR Screen (and registration screens) are not functional as it was out of the scope of the project. For example, the lantern and country dropdown was not implemented as it was considered out of scope.

---

## Assessment Context

This project was built as Part 1 of a Flutter technical assessment. It demonstrates:

- Feature-first architecture with clean separation of concerns
- Reactive state management with MobX observables, actions, and computed values
- Repository pattern enabling a fully swappable data layer
- Declarative navigation with go_router shell routes
- Handling of all major UI states: loading, success, empty, error, and retry
- Pixel-close implementation of provided Figma designs, due to time constraints some screens need some UI detail work

---

## Author

Nuria Reyes