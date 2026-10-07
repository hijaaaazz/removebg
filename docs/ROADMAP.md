# RemoveIt Mobile App: Master Phased Roadmap

## 1. Phased Delivery Strategy

To build an exceptional, studio-grade consumer mobile application without technical debt, regressions, or UI jank, development proceeds through an incremental 9-phase roadmap:

```
[Phase 0: Foundations & Project Skeleton]
                   │
                   ▼
[Phase 1: Guest Mode & Google/Apple Auth]
                   │
                   ▼
[Phase 2: Media Picker & Multipart Upload]
                   │
                   ▼
[Phase 3: Interactive Studio Canvas & Slider]
                   │
                   ▼
[Phase 4: Quota Sync & AdMob SSV Rewarded Ads]
                   │
                   ▼
[Phase 5: RevenueCat In-App Purchases & Paywall]
                   │
                   ▼
[Phase 6: Drift SQLite History & Cloud Sync]
                   │
                   ▼
[Phase 7: Settings, Localization & Dynamic Flags]
                   │
                   ▼
[Phase 8: Hardening, CI/CD & Store Deployment]
```

---

## 2. Milestone Specifications & Deliverables

### Phase 0: Foundations, Core Tooling & Architecture Skeleton
- **Goal:** Establish the project foundation, dependency graph, linting rules, and core design tokens.
- **Deliverables:**
  - Update `pubspec.yaml` with production dependencies (`flutter_bloc`, `dio`, `get_it`, `drift`, `go_router`, `cached_network_image`, `google_fonts`, `fpdart`, `gal`).
  - Configure strict `analysis_options.yaml` (strict casts, strict inference, zero unawaited futures).
  - Setup multi-flavor entry points: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart` with `EnvConfig`.
  - Establish `lib/core` foundation:
    - Design tokens: `AppColors` (Obsidian Dark `#090C10`, Cosmic Violet `#7C3AED`, Neon Cyan `#06B6D4`).
    - Typography: Google Fonts (`Outfit` and `Inter`).
    - Custom `StudioThemeExtension` for studio tokens.
    - `BuildContext` extensions (`context.studioTheme`, `context.colors`, `context.textTheme`).
    - `HapticService` providing tactile feedback ticks.
  - Setup `get_it` dependency injection container in `lib/injection_container.dart`.
  - Configure declarative `GoRouter` with `StatefulShellRoute` for bottom navigation tabs.
- **Done When:** The app compiles and boots cleanly across Android & iOS simulators in dark studio theme with zero lint warnings.

---

### Phase 1: Guest-First Onboarding, Auth & Secure Storage
- **Goal:** Provide frictionless anonymous guest onboarding while enabling seamless cloud account linking.
- **Deliverables:**
  - Anonymous hardware-derived device UUID generation stored in `FlutterSecureStorage`.
  - Integration of `google_sign_in` (Android/iOS) and `sign_in_with_apple` (iOS).
  - `POST /api/v1/auth/google/` backend token exchange endpoint integration.
  - Dual-token JWT lifecycle management:
    - Short-lived Access Token (60 min) + Long-lived Refresh Token (14 days).
    - `AuthInterceptor` (`QueuedInterceptor`) executing automatic, silent token refresh on HTTP 401.
  - `AuthBloc` managing `AuthInitial`, `AuthGuest`, `AuthAuthenticated`, and `AuthError` states.
  - Account linking flow: Claiming guest jobs and quota into the authenticated user profile.
- **Done When:** First-time users enter the app immediately as guests; signing in with Google links their session, stores tokens in Keychain/Keystore, and survives app restarts.

---

### Phase 2: Media Picker, Preprocessing Isolate & Multipart Upload
- **Goal:** Allow users to capture or select photos, compress them off the main thread, and upload them with real-time progress.
- **Deliverables:**
  - Camera and Photo Gallery picker service via `image_picker`.
  - Offloaded background isolate preprocessor (`ImagePreprocessor` via `compute`):
    - EXIF orientation auto-rotation (`img.bakeOrientation`).
    - GPS and sensitive metadata stripping.
    - Smart downscaling to max 2048px edge to conserve bandwidth and prevent memory bloat.
  - Multipart upload service via Dio `FormData` with live `onSendProgress` callback.
  - Asynchronous job polling state machine (`JobProcessingBloc`):
    - Polls `GET /api/v1/jobs/{id}/` every 1200ms.
    - Handles status transitions: `queued` -> `running` -> `preview_ready`.
    - Handles failure states with automatic quota refund notifications.
  - Home upload hero UI with glowing drop zone and animated ambient scanline during AI processing.
- **Done When:** User picks a 12MB camera photo, it downscales in <200ms without frame drops, uploads with a smooth progress bar, polls the backend, and transitions to the preview state in under 3 seconds.

---

### Phase 3: Interactive Studio Canvas & Backdrop Replacer Engine
- **Goal:** Deliver a 120Hz interactive editing canvas with before/after comparison and instant background replacement.
- **Deliverables:**
  - Interactive Before/After Split Comparison Slider (`ComparisonSlider`):
    - Silky smooth touch drag with zero-lag clipping.
    - Center-crossing haptic feedback ticks via `HapticService.selection()`.
    - Double-tap gesture to snap divider back to center (0.5) with spring physics.
  - Zoom & Pan canvas engine (`InteractiveViewer`) with boundary constraints (1.0x to 5.0x zoom).
  - Dynamic Backdrop Replacer Bar (`BackdropSelectorBar`):
    - **Mode 1:** Transparent Alpha Checkerboard (`#1A202C` & `#2D3748`).
    - **Mode 2:** Studio Solid Colors (Pure White, Studio Black, Off-White, Pastel Blue, Mint).
    - **Mode 3:** Studio Lighting Gradients (Spotlight Violet, Soft Sunset).
    - **Mode 4:** Custom Photo Backdrop (picks replacement image from Camera Roll).
    - **Mode 5:** DSLR Bokeh Blur (applies Gaussian blur to original background while keeping cutout sharp).
  - High-Resolution Export Pipeline:
    - Compositing subject + backdrop via `ui.PictureRecorder` and `Canvas`.
    - Saving to native Photos / Camera Roll via `gal` with permissions handled.
    - Native OS Share Sheet integration via `share_plus`.
- **Done When:** User wipes the slider to inspect edge details, switches backdrops seamlessly, and exports a crystal-clear PNG to their gallery.

---

### Phase 4: Atomic Daily Quota & AdMob SSV Monetization
- **Goal:** Synchronize daily usage limits and implement cryptographic Server-Side Verification for ad bonus rewards.
- **Deliverables:**
  - `QuotaBloc` syncing with `GET /api/v1/quota/`.
  - Top header `QuotaPillBadge` displaying remaining daily uses (`"1 Left"`, `"0 Left"`).
  - Dynamic ad mediation config fetch from `GET /api/v1/ads/config/`.
  - Google AdMob SDK integration (`google_mobile_ads`):
    - Adaptive Sticky Banner (`AdBannerContainer`) anchored at screen bottom.
    - Interstitial ads with strict frequency capping (max 1 ad per 3 completed jobs).
    - Rewarded Video with Server-Side Verification (SSV):
      - Request session nonce: `POST /api/v1/ads/rewarded/start/`.
      - Attach `ServerSideVerificationOptions(customData: nonce)` to `RewardedAd`.
      - User watches ad -> AdMob calls Django backend with signed ECDSA query.
      - Backend credits `+1` bonus removal; client receives `onUserEarnedReward` and refreshes quota.
- **Done When:** When a free user exhausts their daily quota, watching an ad triggers the backend SSV verification and instantly unlocks a bonus removal without restarting the app.

---

### Phase 5: RevenueCat In-App Purchases & Pro Paywall
- **Goal:** Maximize subscription conversion with a premium paywall and cross-platform IAP integration.
- **Deliverables:**
  - RevenueCat SDK initialization (`purchases_flutter`) for Google Play Billing and Apple StoreKit.
  - `MonetizationBloc` managing `pro_access` entitlement status.
  - Studio `ProPaywallScreen`:
    - Subscription tiers: Annual (Best Value / 3-day trial), Monthly, and Lifetime.
    - Pro feature breakdown: 4K Native sensor resolution, unlimited/high quota, batch uploads, ad-free.
    - Store compliance: Prominent pricing terms, **"Restore Purchases"** button, and legal links.
  - Pro capability gates:
    - Claiming 100% native uncompressed resolution (bypassing the 1080p free clamp).
    - Hiding all banner and interstitial ads for Pro subscribers.
- **Done When:** Test subscription in Sandbox unlocks 4K exports and removes ads; restoring purchases recovers active subscriptions on new devices.

---

### Phase 6: Drift SQLite Local History & Disk Housekeeping
- **Goal:** Provide an offline-first cutout gallery with cloud synchronization and automatic cache management.
- **Deliverables:**
  - Drift SQLite schema (`JobHistoryTable`) and DAOs.
  - Reactive history grid displaying past cutouts with `cached_network_image`.
  - Background delta synchronization with `GET /api/v1/history/`.
  - Deletion flows: Single item delete, multi-select bulk delete, and clear all.
  - Presigned URL expiry handler: Automatically requests a fresh presigned URL when an asset link expires.
  - Disk cache management:
    - Auto-deletion of temporary downscaled images.
    - LRU thumbnail cache capped at 250MB.
    - Settings option: "Clear Temporary Cache" with calculated MB display.
- **Done When:** Cutouts remain accessible and re-editable while offline; deleting an item updates local SQLite and dispatches backend deletion.

---

### Phase 7: Settings, Localization (i18n / RTL) & Dynamic System Flags
- **Goal:** Polish the app for global multi-language distribution and runtime remote configuration.
- **Deliverables:**
  - Flutter `l10n` setup with `.arb` templates:
    - English (`app_en.arb`), Spanish (`app_es.arb`), Hindi (`app_hi.arb`), French, German, Japanese, Portuguese.
    - Arabic (`app_ar.arb`) with full Right-to-Left (RTL) layout mirroring.
  - System flags integration (`GET /api/v1/flags/`):
    - `maintenance_mode`: Displays full-screen maintenance overlay.
    - `min_app_version`: Prompts mandatory app store update if client is outdated.
  - Settings screen:
    - Theme toggle (Obsidian Dark / Clean Light).
    - Language switcher.
    - Terms of Service & Privacy Policy webview links.
    - In-app Account Deletion flow satisfying Apple App Store Guideline 5.1.1(v).
- **Done When:** Switching system language to Arabic completely mirrors the layout and translates all strings; backend maintenance flag puts the app into maintenance mode gracefully.

---

### Phase 8: Hardening, Automated Testing & Store Deployment
- **Goal:** Ensure production stability, verify test coverage, and automate release distribution.
- **Deliverables:**
  - Unit tests with `bloc_test` and `mocktail` (target 85%+ coverage on BLoCs and repositories).
  - Visual Golden snapshot tests for `HomeScreen`, `StudioCanvasScreen`, and `ComparisonSlider`.
  - GitHub Actions CI workflow (`.github/workflows/mobile_ci.yml`):
    - `dart format` check.
    - `flutter analyze` with fatal linter warnings.
    - `flutter test --coverage`.
  - Fastlane automation setup:
    - Android: Building `.aab` and deploying to Google Play Internal Track.
    - iOS: Building `.ipa` via Fastlane Match and deploying to Apple TestFlight.
- **Done When:** Pull requests trigger green CI checks, and release tags automatically build and upload signed binaries to Google Play Console and TestFlight.
