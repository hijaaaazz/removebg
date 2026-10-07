# 15. Recommended Packages & Tooling Reference

Every dependency introduced into RemoveIt carries a maintenance, binary size, and security cost. The packages listed below have been vetted for:
1. **Active maintenance** and Flutter 3.38+ / Dart 3.10+ compatibility.
2. **First-class native Android & iOS platform support**.
3. **High performance with zero UI jank or memory leaks**.

---

## 1. Curated Production Dependencies Matrix

| Category | Package | Version | Purpose in RemoveIt |
| :--- | :--- | :--- | :--- |
| **State Management** | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) | `^8.1.6` | Event-driven state machines for AI processing & monetization |
| | [`equatable`](https://pub.dev/packages/equatable) | `^2.0.7` | Value equality for states, events, and entities |
| **Routing** | [`go_router`](https://pub.dev/packages/go_router) | `^14.8.1` | Declarative routing with stateful bottom navigation |
| **Networking** | [`dio`](https://pub.dev/packages/dio) | `^5.8.0+1` | Multipart progress uploads, queued token refresh interceptor |
| | [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) | `^6.1.3` | Monitor Wi-Fi / Cellular connection status |
| **Dependency Injection** | [`get_it`](https://pub.dev/packages/get_it) | `^8.0.3` | Service locator for Clean Architecture decoupling |
| | [`injectable`](https://pub.dev/packages/injectable) | `^2.5.0` | Compile-time dependency injection code generator |
| **Functional Programming** | [`fpdart`](https://pub.dev/packages/fpdart) | `^1.1.1` | Functional `Either<Failure, T>` return types |
| **Local Storage** | [`drift`](https://pub.dev/packages/drift) | `^2.24.2` | Type-safe SQLite relational database for job history |
| | [`sqlite3_flutter_libs`](https://pub.dev/packages/sqlite3_flutter_libs) | `^0.5.28` | Bundled native SQLite binaries for Android & iOS |
| | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) | `^9.2.4` | Encrypted JWT tokens and device UUID in Keychain/Keystore |
| | [`shared_preferences`](https://pub.dev/packages/shared_preferences) | `^2.5.2` | Theme settings and app flags |
| **Image & Media** | [`image_picker`](https://pub.dev/packages/image_picker) | `^1.1.2` | Native Camera and Photo Library image selector |
| | [`image`](https://pub.dev/packages/image) | `^4.5.3` | Pure Dart isolate image compression, EXIF auto-rotate |
| | [`gal`](https://pub.dev/packages/gal) | `^2.3.1` | Fast, modern photo roll saver with built-in permissions |
| | [`cached_network_image`](https://pub.dev/packages/cached_network_image) | `^3.4.1` | High-performance thumbnail disk and memory caching |
| **Monetization & Ads** | [`google_mobile_ads`](https://pub.dev/packages/google_mobile_ads) | `^5.3.1` | Official Google AdMob SDK (Banners & SSV Rewarded Video) |
| | [`purchases_flutter`](https://pub.dev/packages/purchases_flutter) | `^8.7.0` | RevenueCat In-App Purchases for Google Play & Apple App Store |
| **Hardware & Sharing** | [`share_plus`](https://pub.dev/packages/share_plus) | `^10.1.4` | Native OS share sheet for cutout images |
| | [`google_sign_in`](https://pub.dev/packages/google_sign_in) | `^6.2.2` | Native Google OAuth Sign-In |
| | [`sign_in_with_apple`](https://pub.dev/packages/sign_in_with_apple) | `^6.1.4` | Apple Sign-In integration (required for iOS App Store) |
| **Visuals & Typography** | [`google_fonts`](https://pub.dev/packages/google_fonts) | `^6.2.1` | Modern Studio typography (Outfit and Inter) |
| | [`intl`](https://pub.dev/packages/intl) | `^0.20.2` | Internationalization, currency and date formatting |

---

## 2. Recommended `pubspec.yaml` Specification

```yaml
name: removeit_app
description: "Studio-Grade AI Background Removal & Photo Isolation Mobile App"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.4

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7

  # Routing
  go_router: ^14.8.1

  # Networking & Connectivity
  dio: ^5.8.0+1
  connectivity_plus: ^6.1.3

  # Dependency Injection & Functional Errors
  get_it: ^8.0.3
  injectable: ^2.5.0
  fpdart: ^1.1.1

  # Local Persistence
  drift: ^2.24.2
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.2

  # Media, Camera & Canvas
  image_picker: ^1.1.2
  image: ^4.5.3
  gal: ^2.3.1
  cached_network_image: ^3.4.1
  share_plus: ^10.1.4

  # Monetization & Auth
  google_mobile_ads: ^5.3.1
  purchases_flutter: ^8.7.0
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.4

  # Visuals & Localization
  google_fonts: ^6.2.1
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

  # Testing & Mocking
  bloc_test: ^9.1.7
  mocktail: ^1.0.4

  # Code Generation
  build_runner: ^2.4.15
  drift_dev: ^2.24.2
  injectable_generator: ^2.6.2
  json_serializable: ^6.9.4
  json_annotation: ^4.9.0

flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## 3. Production Static Analysis Rules (`analysis_options.yaml`)

Enforces strict typing and forbids uncaught async errors:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    # Error Prevention
    - avoid_empty_else
    - avoid_relative_lib_imports
    - cancel_subscriptions
    - close_sinks
    - no_duplicate_case_values
    - unawaited_futures

    # Style & Performance
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_single_quotes
    - use_super_parameters
```
