# RemoveIt App — Master Architectural Blueprint & Feature Implementation Instructor

> **Role of this Document:** This README serves as the **Master Instructor and Single Source of Truth** for the **RemoveIt** Flutter mobile application (iOS & Android). Whenever you (or an AI agent) are tasked with building, modifying, or scaling any feature in RemoveIt, **follow the instructions in this blueprint step-by-step**.
> Every step explicitly references its governing architectural specification and implementation guides located within this `docs/` suite.

---

## 📱 Product & Domain Overview

**RemoveIt** is a studio-grade consumer mobile application designed for instant AI background removal, portrait isolation, product photography enhancement, and creative background replacement.

### Core Ecosystem Architecture
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       RemoveIt Flutter Mobile Client                        │
│     (iOS & Android | Studio Dark Theme | BLoC Clean Architecture)          │
└──────────────┬──────────────────┬─────────────────────┬─────────────────────┘
               │                  │                     │
      REST API / JWT     Google AdMob (SSV)     RevenueCat / IAP
               │                  │                     │
               ▼                  ▼                     ▼
┌───────────────────────┐ ┌───────────────┐ ┌─────────────────────────────────┐
│ Django REST Backend   │ │ AdMob Servers │ │ Apple App Store / Google Play   │
│ - Auth (Google OAuth) │ └───────┬───────┘ └────────────────┬────────────────┘
│ - Quota Engine (Atomic│         │ Signed SSV               │ Webhook Sync
│ - Job Orchestration   │         │ Callback                 │
│ - BiRefNet AI Workers │◄────────┴──────────────────────────┴────────────────┘
└───────────────────────┘
```

---

## 🎯 The 10-Step Feature Implementation Workflow

Follow this sequence for **any** feature in the application (e.g., Image Upload, Canvas Studio, Ad Rewarded Unlock, History, Pro Paywall, Settings):

```
[1. Folder Structure] ──► [2. Domain Layer] ──► [3. Data Layer & Remote API]
                                                              │
[6. Studio UI & Canvas] ◄── [5. BLoC & Routing] ◄── [4. Dependency Injection]
         │
         ▼
[7. Design Tokens] ──► [8. Localization] ──► [9. Monetization/Security] ──► [10. Testing & Verification]
```

---

### Step 1: Establish Feature Directory Structure
Before writing any code, set up the standard feature-first directory layout under `lib/features/<feature_name>/`:

```
lib/features/<feature_name>/
├── domain/
│   ├── entities/              # Pure Dart domain entities (Equatable)
│   ├── repositories/          # Abstract repository contracts
│   └── usecases/              # CQRS single-purpose use case classes
├── data/
│   ├── models/                # DTOs with fromJson/toJson serializers
│   ├── datasources/           # Remote (Dio/ApiClient) & Local (Drift/Hive) data sources
│   └── repositories/          # Repository implementations
└── presentation/
    ├── bloc/ (or cubit/)      # State machine (Events, States, BLoC/Cubit)
    ├── screens/               # Route-level screens (hosted in StudioScaffold)
    └── widgets/               # Feature-private sub-components
```
🔗 **Mandatory Documents to Follow:**
- [**`01_ARCHITECTURE_AND_PATTERNS.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/01_ARCHITECTURE_AND_PATTERNS.md) — Clean Architecture layers, SOLID principles, and data isolation.
- [**`02_FOLDER_STRUCTURE_AND_CONVENTIONS.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/02_FOLDER_STRUCTURE_AND_CONVENTIONS.md) — Exact file naming rules, barrel export conventions, and private vs public widgets.

---

### Step 2: Implement the Domain Layer
The Domain layer is 100% pure Dart. It must never import Flutter UI packages (`package:flutter/*`), Dio, or local device storage.
1. **Entities**: Define immutable entity classes extending `Equatable` in `domain/entities/`.
2. **Repository Contract**: Define abstract interface in `domain/repositories/` (e.g. `abstract class JobRepository`).
3. **Use Cases**: Create single-purpose use cases in `domain/usecases/` implementing `call()` with explicit parameters and returning `Future<Either<Failure, T>>`:
   ```dart
   class UploadImageForRemovalUseCase {
     final JobRepository repository;
     UploadImageForRemovalUseCase(this.repository);
     Future<Either<Failure, JobEntity>> call(UploadImageParams params) => repository.uploadImage(params);
   }
   ```
🔗 **Mandatory Documents to Follow:**
- [**`01_ARCHITECTURE_AND_PATTERNS.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/01_ARCHITECTURE_AND_PATTERNS.md) — Entities, repository contracts, and functional error handling.

---

### Step 3: Implement the Data Layer & API Integration
1. **Models (DTOs)**: Implement `data/models/` extending Domain entities with `fromJson` and `toJson`.
2. **Remote Data Source**: Consume backend endpoints via the centralized `ApiClient` (`Dio`).
3. **Local Data Source**: Implement offline caching or SQLite persistence (Drift).
4. **Repository Implementation**: Implement domain repository contract, catch low-level `DioException` or `StorageException`, and map them to domain `Failure` subclasses.
🔗 **Mandatory Documents to Follow:**
- [**`06_NETWORKING_API_AND_OFFLINE_SYNC.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/06_NETWORKING_API_AND_OFFLINE_SYNC.md) — Dio interceptors, upload progress, polling, and error transformation.
- [**`09_LOCAL_STORAGE_HISTORY_AND_CACHE.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/09_LOCAL_STORAGE_HISTORY_AND_CACHE.md) — Offline caching, SQLite schema, and cache eviction.

---

### Step 4: Register Dependencies in the DI Container
Register all data sources, repositories, use cases, and BLoCs in `lib/injection_container.dart` (or via `@injectable`):
- Data sources and Repositories as `LazySingleton`.
- BLoCs and Cubits as `Factory` (unless app-global like `AuthBloc`, `QuotaBloc`, `ThemeCubit`).
🔗 **Mandatory Documents to Follow:**
- [**`13_DEPENDENCY_INJECTION_AND_FLAVORS.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/13_DEPENDENCY_INJECTION_AND_FLAVORS.md) — Service locator setup and environment flavors.

---

### Step 5: Implement BLoC State Machines & Navigation
1. Create Event and State classes extending `Equatable` in `presentation/bloc/`.
2. Keep UI purely reactive: UI emits Events -> BLoC executes UseCase -> BLoC emits State -> UI renders via `BlocBuilder` or handles side-effects via `BlocListener`.
3. Register screen routes in `lib/core/router/app_router.dart` (`GoRouter`) using typed route paths.
🔗 **Mandatory Documents to Follow:**
- [**`04_STATE_MANAGEMENT_AND_ROUTING.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/04_STATE_MANAGEMENT_AND_ROUTING.md) — BLoC state machines, GoRouter declarations, and route guards.

---

### Step 6: Construct UI with Common Studio Widgets
1. Scaffold screens using `StudioScaffold` to guarantee safe area handling, responsive layout, and dark theme backgrounds.
2. Assemble features using vetted design system widgets from `lib/core/widgets/` (`GlowButton`, `ComparisonSlider`, `ZoomableCanvas`, `QuotaBadge`, `AdBannerContainer`).
3. **Never write raw unstyled Flutter buttons, containers, or dialogs directly in screens.**
🔗 **Mandatory Documents to Follow:**
- [**`10_COMMON_WIDGET_CATALOG.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/10_COMMON_WIDGET_CATALOG.md) — The complete widget catalog.
- [**`07_IMAGE_PROCESSING_CANVAS_AND_STUDIO_ENGINE.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/07_IMAGE_PROCESSING_CANVAS_AND_STUDIO_ENGINE.md) — Interactive canvas, split-slider, and backdrop replacement.

---

### Step 7: Apply Theme Tokens & Context Extensions
1. Never hardcode colors, padding, or fonts.
2. Access colors via `context.colors` or `context.studioColors`.
3. Access typography via `context.textTheme`.
4. Trigger haptic feedback via `AppHaptics`.
🔗 **Mandatory Documents to Follow:**
- [**`03_CONSUMER_MOBILE_UI_UX_AND_DESIGN_SYSTEM.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/03_CONSUMER_MOBILE_UI_UX_AND_DESIGN_SYSTEM.md) — Studio Dark aesthetic, haptics, and thumb-zone ergonomics.
- [**`11_THEME_TOKENS_AND_CONTEXT_SYSTEM.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/11_THEME_TOKENS_AND_CONTEXT_SYSTEM.md) — Color tokens, ThemeExtensions, and BuildContext extensions.

---

### Step 8: Internationalize All User-Facing Strings
1. Add every visible string into `lib/l10n/app_en.arb`.
2. Add translations for supported languages (Spanish, Hindi, French, German, Japanese, Arabic RTL).
3. Reference strings in UI via `context.l10n.stringKey`.
🔗 **Mandatory Documents to Follow:**
- [**`12_LOCALIZATION_AND_INTERNATIONALIZATION.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/12_LOCALIZATION_AND_INTERNATIONALIZATION.md) — arb definitions, RTL support, and pluralization.

---

### Step 9: Integrate Monetization, Quota & Security
1. Verify feature access through `QuotaBloc` and `MonetizationBloc`.
2. For free tier bonus removals, trigger the AdMob Rewarded Video SSV handshake.
3. For Pro features (HD 4K download, bulk upload), trigger the RevenueCat paywall.
4. Keep JWT tokens secured in `FlutterSecureStorage`.
🔗 **Mandatory Documents to Follow:**
- [**`05_AUTH_GUEST_MODE_AND_SECURITY.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/05_AUTH_GUEST_MODE_AND_SECURITY.md) — Guest onboarding, JWT rotation, and secure storage.
- [**`08_MONETIZATION_ADMOB_SSV_AND_REVENUECAT.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/08_MONETIZATION_ADMOB_SSV_AND_REVENUECAT.md) — AdMob SSV handshake, RevenueCat IAP, and paywalls.

---

### Step 10: Testing, Verification & CI/CD Pipeline
1. Write unit tests for all BLoCs with `bloc_test`.
2. Mock dependencies with `mocktail`.
3. Run `flutter analyze` and ensure zero errors or warnings under strict analysis rules.
4. Validate builds via Fastlane and GitHub Actions CI.
🔗 **Mandatory Documents to Follow:**
- [**`14_TESTING_CI_CD_AND_STORE_DEPLOYMENT.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/14_TESTING_CI_CD_AND_STORE_DEPLOYMENT.md) — Testing patterns, Fastlane, and store release checklist.
- [**`15_RECOMMENDED_PACKAGES_AND_TOOLING.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/15_RECOMMENDED_PACKAGES_AND_TOOLING.md) — Curated dependencies and `analysis_options.yaml`.

---

## 📚 Complete Architectural Documentation Index

| Doc # | Title | Purpose |
| :--- | :--- | :--- |
| [**`01`**](file:///Users/hijazc/hijazc/removeit_app/docs/01_ARCHITECTURE_AND_PATTERNS.md) | **Architecture & Design Patterns** | Clean Architecture, Inversion of Control, BLoC State Machines |
| [**`02`**](file:///Users/hijazc/hijazc/removeit_app/docs/02_FOLDER_STRUCTURE_AND_CONVENTIONS.md) | **Folder Structure & Conventions** | Directory tree, naming conventions, barrel exports, code style |
| [**`03`**](file:///Users/hijazc/hijazc/removeit_app/docs/03_CONSUMER_MOBILE_UI_UX_AND_DESIGN_SYSTEM.md) | **UI/UX & Consumer Design System** | Creative Studio Dark theme, glassmorphism, haptics, ergonomics |
| [**`04`**](file:///Users/hijazc/hijazc/removeit_app/docs/04_STATE_MANAGEMENT_AND_ROUTING.md) | **State Management & Routing** | Flutter BLoC, GoRouter, deep links, guards, hydration |
| [**`05`**](file:///Users/hijazc/hijazc/removeit_app/docs/05_AUTH_GUEST_MODE_AND_SECURITY.md) | **Auth, Guest Mode & Security** | Frictionless guest onboarding, Google/Apple Sign-In, JWT refresh |
| [**`06`**](file:///Users/hijazc/hijazc/removeit_app/docs/06_NETWORKING_API_AND_OFFLINE_SYNC.md) | **Networking & API Integration** | Dio client, multipart upload progress, polling/SSE, presigned URLs |
| [**`07`**](file:///Users/hijazc/hijazc/removeit_app/docs/07_IMAGE_PROCESSING_CANVAS_AND_STUDIO_ENGINE.md) | **Image Processing & Studio Canvas** | Pre-upload compression, before/after split slider, pan/zoom, backdrops |
| [**`08`**](file:///Users/hijazc/hijazc/removeit_app/docs/08_MONETIZATION_ADMOB_SSV_AND_REVENUECAT.md) | **Monetization, AdMob SSV & In-App Purchases** | Dynamic ad mediation, AdMob SSV handshake, RevenueCat IAP, paywall |
| [**`09`**](file:///Users/hijazc/hijazc/removeit_app/docs/09_LOCAL_STORAGE_HISTORY_AND_CACHE.md) | **Local Storage, History & Cache** | Drift SQLite, thumbnail caching, presigned URL expiry, cleanup |
| [**`10`**](file:///Users/hijazc/hijazc/removeit_app/docs/10_COMMON_WIDGET_CATALOG.md) | **Common Widget Catalog** | Centralized reusable components (`StudioScaffold`, `ComparisonSlider`, etc.) |
| [**`11`**](file:///Users/hijazc/hijazc/removeit_app/docs/11_THEME_TOKENS_AND_CONTEXT_SYSTEM.md) | **Theme Tokens & Context System** | Color tokens, ThemeExtension, BuildContext extensions |
| [**`12`**](file:///Users/hijazc/hijazc/removeit_app/docs/12_LOCALIZATION_AND_INTERNATIONALIZATION.md) | **Localization & Internationalization** | Multi-language arb files, RTL support, currency formatting |
| [**`13`**](file:///Users/hijazc/hijazc/removeit_app/docs/13_DEPENDENCY_INJECTION_AND_FLAVORS.md) | **Dependency Injection & Flavors** | `get_it`, `injectable`, dev/staging/prod environments |
| [**`14`**](file:///Users/hijazc/hijazc/removeit_app/docs/14_TESTING_CI_CD_AND_STORE_DEPLOYMENT.md) | **Testing, CI/CD & Store Deployment** | BLoC testing, Golden tests, Fastlane, Google Play & App Store |
| [**`15`**](file:///Users/hijazc/hijazc/removeit_app/docs/15_RECOMMENDED_PACKAGES_AND_TOOLING.md) | **Recommended Packages & Tooling** | Vetted `pubspec.yaml`, analysis options, strict lint rules |
| [**`plan.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/plan.md) | **Master Delivery Roadmap & Milestones** | Phased execution plan, sprint milestones, MVP definition |
| [**`ROADMAP.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/ROADMAP.md) | **Phased Implementation Roadmap** | Detailed deliverables & acceptance criteria across all 9 phases |
| [**`ROADMAP_PROGRESS.md`**](file:///Users/hijazc/hijazc/removeit_app/docs/ROADMAP_PROGRESS.md) | **Implementation Status Tracker** | Live milestone progress, sub-task checklists, and prerequisites |

