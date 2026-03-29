# Kigo Flutter — Technical Decisions

This document explains the architectural and technical choices made during this assessment, the trade-offs considered, and what would change in a production context.

---

## Architecture: Feature-First + Repository Pattern

### Decision
The project is organised by feature (`auth/`, `home/`) rather than by layer (`screens/`, `stores/`, `models/`). Each feature owns its screens, state stores, models, and repository.

### Why
- **Scalability:** Adding a new feature means adding a new folder, not scattering files across multiple top-level directories
- **Team-friendly:** Multiple developers can work on different features with minimal merge conflicts
- **Clear ownership:** All code related to authentication lives in `features/auth/`, which means, easy to find, easy to delete or refactor in isolation

### Trade-offs
- For very small apps, layer-first can feel simpler initially. Feature-first pays off once you have 4+ features
- Requires discipline to keep shared utilities in `core/` or `shared/` rather than leaking them into feature folders

---

## State Management: MobX

### Decision
MobX with `flutter_mobx` and code generation via `mobx_codegen`.

### Why
- **Reactive and minimal:** Observables, actions, and computed values map naturally to UI state (e.g. `canSubmit` computed from `phoneNumber` + `privacyAccepted`)
- **Separation of concerns:** Stores hold all business logic; widgets are purely declarative via `Observer`
- **Predictable:** All state mutations must be wrapped in `@action`, making data flow easy to trace and debug
- **Good DX:** `build_runner` code generation removes the boilerplate of implementing `Store` by hand

### Alternatives considered
- **Riverpod:** Excellent package, but adds more concepts (providers, ref, notifiers) that have a steeper initial learning curve. Better fit for projects already using it
- **BLoC:** Very explicit and testable, but high boilerplate for an assessment project. Better for teams that need strict event-driven discipline
- **setState/ValueNotifier:** Fine for local state, but doesn't scale across screens or handle async state cleanly

### What would change for production
- Add unit tests for every `Store` — stores are pure Dart classes with no Flutter dependency, making them trivially testable
- Consider splitting large stores into smaller, more focused ones as features grow
- Evaluate whether some stores should be scoped to a route rather than globally registered via get_it

---

## Navigation: go_router

### Decision
`go_router` with a `ShellRoute` wrapping the 5-tab bottom navigation.

### Why
- **Declarative:** Route definitions are a single source of truth, not scattered across `Navigator.push` calls
- **Deep-link ready:** go_router handles deep links and URL-based navigation out of the box. Essential for a mobility/parking app that may need to open directly to a QR scan or a specific parking session
- **ShellRoute:** Enables persistent bottom nav across tab changes without rebuilding the shell widget on every navigation
- **Type-safe extras:** Passing the phone number from Login → OTP via `extra` keeps screens decoupled while still sharing state

### What would change for production
- Add proper typed route classes (go_router's `TypedGoRoute`) for fully type-safe navigation parameters
- Implement route guards for authenticated routes and redirect to `/login` if no valid session exists
- Add transition animations per the design spec

---

## Dependency Injection: get_it

### Decision
`get_it` as a service locator, with all registrations centralised in `core/di/injection.dart`.

### Why
- **Simple and pragmatic:** No code generation required, and easy to understand
- **Swappable implementations:** Registering against abstract interfaces (e.g. `AuthRepository`) means any concrete implementation can be swapped in one line — this is the key enabler of the mock data layer
- **Lazy singletons:** Stores and repositories are only instantiated when first accessed, keeping startup time low

### Trade-offs
- get_it is a service locator, not true dependency injection. Dependencies are pulled rather than pushed. This can make unit testing slightly harder than constructor injection
- No compile-time safety: incorrect registrations fail at runtime, not build time. `injectable` (code-gen wrapper around get_it) solves this but adds complexity

### What would change for production
- Consider `injectable` for compile-time verified DI
- Add environment-based registration (e.g. `registerIf(env == 'dev', () => FakeAuthRepository())`) to automatically use fakes in development and real implementations in production

---

## Mock Data Layer: Repository Pattern

### Decision
Abstract repository interfaces with fake implementations. All stores depend on the abstract interface; concrete implementations are injected via get_it.

### Why
- **Testability:** Any screen or store can be tested with a fake repository that returns predictable data
- **Backend-independent development:** The entire UI can be built and demoed without a real API
- **Minimal migration cost:** When the real backend is ready, only the concrete repository implementation changes — stores, screens, and tests are untouched

### Structure
```
AuthRepository (abstract)
  └── FakeAuthRepository   ← used now
  └── RealAuthRepository   ← drop in when backend is ready

HomeRepository (abstract)
  └── FakeHomeRepository   ← used now
  └── RealHomeRepository   ← drop in when backend is ready
```

---

## Camera / QR: mobile_scanner

### Decision
`mobile_scanner ^6.0.0` for the live camera viewfinder and QR code scanning.

### Why
- Best-maintained QR scanning package for Flutter
- Supports iOS and Android with a consistent API
- Handles camera permissions, lifecycle management, and torch control
- Active development and responsive to Flutter SDK updates

### Known limitation
- The camera preview does not render on the iOS Simulator — this is a simulator hardware limitation, not a code issue. All QR scanning functionality should work on a physical device. But more testing with a physical device would be needed to make sure.

---

## What Would Change for Production

| Area | Current (Assessment) | Production |
|------|---------------------|------------|
| Auth | Any code is accepted | Real OTP implementation (e.g. Twilio, Firebase Auth) |
| Data | Fake repositories | Real REST/GraphQL clients with error handling, caching, retry |
| Security | None | Secure token storage (`flutter_secure_storage`), certificate pinning |
| Error handling | Basic UI states | Centralised error handling, crash reporting (Sentry / Firebase Crashlytics) |
| Analytics | None | Event tracking (Amplitude, Firebase Analytics) |
| Testing | None | Unit tests for all stores, widget tests for key flows, integration tests |
| CI/CD | None | GitHub Actions: lint → test → build → distribute (Firebase App Distribution) |
| Localisation | Hardcoded Spanish strings | `flutter_localizations` + ARB files |
| Accessibility | Not addressed | Semantic labels, minimum touch targets, contrast ratios |
| Performance | Not optimised | Image caching, lazy loading, `const` widgets throughout |

---

## Folder Structure Rationale

```
lib/
├── core/         # App-wide infrastructure: theme, router, DI
├── features/     # One folder per product feature
└── shared/       # Reusable widgets not owned by any feature
```

`core/` is for things that configure and wire the app. `features/` is where product work lives. `shared/` is for UI components that multiple features use (buttons, text fields, cards). This separation prevents the common anti-pattern of a single bloated `widgets/` folder that becomes a dumping ground.
