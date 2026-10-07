# Roadmap Progress & Implementation Status Tracker

**Current Milestone:** Phase 0 (Foundations & Architectural Blueprints Established)  
**Last Updated:** 2026-10-07  
**Overall App Health:** Architecture, Design System & 17 Technical Blueprints 100% Documented; Starter Flutter Project Ready for Implementation  

---

## 1. Executive Summary & Status Dashboard

| Phase | Milestone Name | Status | Completion % | Verified Deliverables |
|---|---|---|:---:|---|
| **Phase 0** | Foundations, Core Tooling & DI Skeleton | **IN PROGRESS** | **50%** | Full 17-document architecture suite completed, design tokens planned; starter Flutter project created; awaiting dependency installation & core wiring. |
| **Phase 1** | Guest-First Mode & Auth (Google/Apple) | **QUEUED** | **0%** | Architecture documented in `05_AUTH_GUEST_MODE_AND_SECURITY.md`; backend endpoints ready at `/api/v1/auth/google/`. |
| **Phase 2** | Media Picker, Preprocessor & Multipart Upload | **QUEUED** | **0%** | Architecture documented in `06_NETWORKING_API_AND_OFFLINE_SYNC.md`; backend tested via test pipeline runner. |
| **Phase 3** | Studio Canvas, Split Slider & Backdrop Engine | **QUEUED** | **0%** | Architecture documented in `03_CONSUMER_MOBILE_UI_UX_AND_DESIGN_SYSTEM.md` and `07_IMAGE_PROCESSING_CANVAS_AND_STUDIO_ENGINE.md`. |
| **Phase 4** | Atomic Daily Quota & AdMob SSV Monetization | **QUEUED** | **0%** | Architecture documented in `08_MONETIZATION_ADMOB_SSV_AND_REVENUECAT.md`; backend SSV callback verified. |
| **Phase 5** | RevenueCat In-App Purchases & Pro Paywall | **QUEUED** | **0%** | Architecture documented in `08_MONETIZATION_ADMOB_SSV_AND_REVENUECAT.md`; backend RevenueCat webhook handler verified. |
| **Phase 6** | Drift SQLite Local History & Disk Housekeeping | **QUEUED** | **0%** | Architecture documented in `09_LOCAL_STORAGE_HISTORY_AND_CACHE.md`. |
| **Phase 7** | Settings, Localization (i18n/RTL) & Flags | **QUEUED** | **0%** | Architecture documented in `12_LOCALIZATION_AND_INTERNATIONALIZATION.md`. |
| **Phase 8** | Hardening, CI/CD Pipeline & Store Deployment | **QUEUED** | **0%** | Architecture documented in `14_TESTING_CI_CD_AND_STORE_DEPLOYMENT.md`. |

---

## 2. Detailed Phase-by-Phase Checklist

### Phase 0: Foundations & Project Skeleton (50% Complete)
- [x] Create comprehensive 17-document architectural specifications in `removeit_app/docs/`.
- [x] Define Clean Architecture layers, Inversion of Control, and BLoC state machine guidelines.
- [x] Design Studio Obsidian Dark palette (`#090C10`, `#7C3AED`, `#06B6D4`) and theme tokens.
- [x] Document 10-step feature implementation workflow in `README.md`.
- [x] Document complete phased delivery roadmap in `ROADMAP.md`.
- [ ] Update root `pubspec.yaml` with vetted dependencies (`flutter_bloc`, `dio`, `get_it`, `drift`, `go_router`, etc.).
- [ ] Configure strict `analysis_options.yaml` (strict casts, strict inference, zero unawaited futures).
- [ ] Setup multi-flavor entry points: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart` with `EnvConfig`.
- [ ] Create `lib/core/theme/` (`app_colors.dart`, `studio_theme_extension.dart`, `app_theme.dart`).
- [ ] Create `lib/core/network/` (`api_client.dart`, `auth_interceptor.dart`, `retry_interceptor.dart`).
- [ ] Configure `lib/injection_container.dart` with `get_it`.
- [ ] Configure `lib/core/router/app_router.dart` with `GoRouter` and bottom navigation shell.

---

### Phase 1: Guest Mode & Authentication (0% Complete)
- [ ] Generate anonymous hardware-derived device UUID stored in `FlutterSecureStorage`.
- [ ] Integrate `google_sign_in` plugin for Android and iOS.
- [ ] Integrate `sign_in_with_apple` plugin for iOS.
- [ ] Implement `AuthRemoteDataSource` calling `POST /api/v1/auth/google/`.
- [ ] Implement `AuthInterceptor` with `QueuedInterceptor` for silent JWT token refresh.
- [ ] Implement `AuthBloc` (handling Guest, Authenticated, and Profile states).
- [ ] Create account linking dialog to claim guest quota into authenticated user account.

---

### Phase 2: Media Picker, Preprocessor & Multipart Upload (0% Complete)
- [ ] Implement `ImagePickerService` for Camera and Photo Gallery selection.
- [ ] Implement `ImagePreprocessor` background isolate (`compute`) for auto-orient, EXIF strip, and downscaling.
- [ ] Implement `JobRemoteDataSource` with Dio multipart upload and `onSendProgress`.
- [ ] Implement `JobProcessingBloc` handling `queued`, `running`, `preview_ready`, and error states.
- [ ] Create `HomeScreen` upload hero UI with glowing dropzone and animated pulse scanline.
- [ ] Verify error code handling (`QUOTA_EXHAUSTED`, `IMAGE_TOO_LARGE`, `INFERENCE_FAILED`).

---

### Phase 3: Interactive Studio Canvas & Backdrop Replacer (0% Complete)
- [ ] Implement `ComparisonSlider` with interactive touch drag and divider thumb.
- [ ] Wire up `HapticService.selection()` on slider center crossing.
- [ ] Implement double-tap to reset slider with spring animation curve (`Curves.easeOutBack`).
- [ ] Implement `ZoomableCanvas` wrapping `InteractiveViewer` (1.0x to 5.0x zoom).
- [ ] Implement `BackdropSelectorBar` supporting:
  - Transparent checkerboard (`#1A202C` / `#2D3748`).
  - Solid studio colors (White, Black, Off-White, Pastel Blue, Mint).
  - Studio gradients (Spotlight Violet, Soft Sunset).
  - Custom replacement background photo picker.
  - DSLR bokeh background blur.
- [ ] Implement `GallerySaverService` compositing canvas layers and saving via `gal`.
- [ ] Implement native OS share sheet via `share_plus`.

---

### Phase 4: Atomic Daily Quota & AdMob SSV Monetization (0% Complete)
- [ ] Implement `QuotaRemoteDataSource` calling `GET /api/v1/quota/`.
- [ ] Implement `QuotaBloc` managing daily limits and resets timer.
- [ ] Create `QuotaPillBadge` in top header bar.
- [ ] Implement `AdMobDataSource` loading dynamic placement IDs from `GET /api/v1/ads/config/`.
- [ ] Implement `AdBannerContainer` rendering adaptive bottom banners.
- [ ] Implement AdMob Rewarded Video SSV handshake:
  - Request nonce from `POST /api/v1/ads/rewarded/start/`.
  - Pass nonce in `ServerSideVerificationOptions`.
  - Listen for reward callback and update `QuotaBloc`.
- [ ] Implement interstitial ad frequency capper (max 1 per 3 jobs).

---

### Phase 5: RevenueCat In-App Purchases & Pro Paywall (0% Complete)
- [ ] Initialize RevenueCat SDK (`purchases_flutter`) on app startup.
- [ ] Implement `MonetizationBloc` tracking `pro_access` entitlement.
- [ ] Build `ProPaywallScreen` with Annual, Monthly, and Lifetime subscription packages.
- [ ] Implement "Restore Purchases" button and terms disclosure for App Store compliance.
- [ ] Gate Pro perks: 4K native uncompressed export, bulk uploads, ad-free UI.

---

### Phase 6: Drift SQLite Local History & Disk Housekeeping (0% Complete)
- [ ] Define Drift SQLite table `JobHistoryTable` with DAOs.
- [ ] Build reactive History grid screen with `cached_network_image`.
- [ ] Implement background delta sync with `GET /api/v1/history/`.
- [ ] Implement single-item delete, bulk select delete, and clear all.
- [ ] Implement presigned URL auto-refresh on token expiration.
- [ ] Add disk cache housekeeping and "Clear Temporary Cache" button in Settings.

---

### Phase 7: Settings, Localization & Dynamic System Flags (0% Complete)
- [ ] Setup `l10n.yaml` and `.arb` files (English, Spanish, Hindi, French, German, Japanese, Portuguese).
- [ ] Add Arabic (`app_ar.arb`) with full RTL layout mirroring.
- [ ] Implement `FlagsRemoteDataSource` polling `GET /api/v1/flags/`.
- [ ] Build maintenance mode full-screen overlay for `maintenance_mode = true`.
- [ ] Build mandatory upgrade dialog for `min_app_version`.
- [ ] Implement Account Deletion flow satisfying Apple App Store Guideline 5.1.1(v).

---

### Phase 8: Hardening, CI/CD & Store Deployment (0% Complete)
- [ ] Write unit tests for `JobProcessingBloc`, `QuotaBloc`, and `AuthBloc` with `bloc_test`.
- [ ] Write Golden UI snapshot tests for Canvas and Slider.
- [ ] Setup GitHub Actions CI (`.github/workflows/mobile_ci.yml`).
- [ ] Setup Fastlane for Android (Google Play Internal Track) and iOS (Apple TestFlight).
- [ ] Verify store compliance: Permissions descriptions in `Info.plist` and `AndroidManifest.xml`.

---

## 3. Platform Prerequisites & Credentials Checklist

| Item | Status | Notes |
| :--- | :---: | :--- |
| **Backend API (Django)** | **READY** | Running locally on `http://127.0.0.1:8000/api/v1/` with Celery & BiRefNet model. |
| **Google Cloud Console OAuth** | Needed for Phase 1 | Requires Web Client ID and Android SHA-1 fingerprint. |
| **Google AdMob App IDs** | Needed for Phase 4 | Use official Google test IDs during Phase 0–7; live IDs for Phase 8. |
| **RevenueCat Account & Products** | Needed for Phase 5 | Configure `pro_access` entitlement and Google Play / StoreKit SKUs. |
| **Apple Developer Account** | Needed for Phase 8 | For Sign in with Apple, StoreKit IAP, and TestFlight deployment. |
| **Google Play Developer Console**| Needed for Phase 8 | For Google Play Billing and App Bundle internal testing. |

---

## 4. Immediate Next Actions (Phase 0 Completion)

1. **Update `pubspec.yaml`:** Add all production packages from [`15_RECOMMENDED_PACKAGES_AND_TOOLING.md`](file:///Users/hijazc/hijazc/removeit_app/docs/15_RECOMMENDED_PACKAGES_AND_TOOLING.md).
2. **Configure `analysis_options.yaml`:** Apply strict linter rules.
3. **Bootstrap Core Architecture:** Create `lib/core/` theme, network client, DI container, and router.
