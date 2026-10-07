# 14. Testing, CI/CD & Store Deployment Pipeline

To maintain studio reliability and ensure zero breaking regressions in production releases, **RemoveIt** implements an automated testing strategy and continuous deployment pipeline using **Fastlane** and **GitHub Actions**.

---

## 1. Automated Testing Strategy

```
                      / \
                     /   \
                    / E2E \       <-- Integration Tests (Patrol / Flutter Driver)
                   /-------\
                  / Golden  \     <-- Visual Snapshot Tests (Studio Canvas, Slider)
                 /-----------\
                /  BLoC Unit  \   <-- State Machine Tests (bloc_test + mocktail)
               /---------------\
              / Repository/Util \ <-- Pure Dart Unit Tests (Mappers, Isolate Preprocessor)
             /-------------------\
```

---

## 2. BLoC Unit Testing with `bloc_test` & `mocktail`

Every BLoC state transition is verified with unit tests without spinning up Flutter widgets:

```dart
// test/features/image_processing/presentation/bloc/job_processing_bloc_test.dart
import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/upload_image_usecase.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_bloc.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_event.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_state.dart';

class MockUploadImageUseCase extends Mock implements UploadImageUseCase {}

void main() {
  late MockUploadImageUseCase mockUploadUseCase;
  late JobProcessingBloc bloc;

  setUp(() {
    mockUploadUseCase = MockUploadImageUseCase();
    bloc = JobProcessingBloc(uploadImageUseCase: mockUploadUseCase);
  });

  tearDown(() => bloc.close());

  final tFile = File('test_assets/sample.jpg');
  final tJob = JobEntity(
    id: 'job-123',
    status: 'preview_ready',
    previewUrl: 'https://cdn.removebg.app/preview.png',
  );

  blocTest<JobProcessingBloc, JobProcessingState>(
    'emits [JobCompressingState, JobUploadingState, JobPreviewReadyState] on successful upload',
    build: () {
      when(() => mockUploadUseCase(any()))
          .thenAnswer((_) async => Right(tJob));
      return bloc;
    },
    act: (b) => b.add(PickImageEvent(tFile)),
    expect: () => [
      isA<JobCompressingState>(),
      isA<JobUploadingState>(),
      isA<JobPreviewReadyState>(),
    ],
  );

  blocTest<JobProcessingBloc, JobProcessingState>(
    'emits [JobErrorState] when upload exceeds quota',
    build: () {
      when(() => mockUploadUseCase(any()))
          .thenAnswer((_) async => const Left(QuotaExhaustedFailure()));
      return bloc;
    },
    act: (b) => b.add(PickImageEvent(tFile)),
    expect: () => [
      isA<JobCompressingState>(),
      isA<JobUploadingState>(),
      isA<JobErrorState>(),
    ],
  );
}
```

---

## 3. Continuous Integration: GitHub Actions

`.github/workflows/mobile_ci.yml` triggers on every Pull Request to `main`:

```yaml
name: RemoveIt Mobile CI

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.x'
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Verify Code Formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Run Static Analyzer
        run: flutter analyze --fatal-infos --fatal-warnings

      - name: Run Unit Tests with Coverage
        run: flutter test --coverage

      - name: Upload Test Coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## 4. Automated Deployment with Fastlane

### 4.1 Android Deployment (`android/fastlane/Fastfile`)
```ruby
default_platform(:android)

platform :android do
  desc "Build and deploy to Google Play Internal Track"
  lane :deploy_internal do
    gradle(task: "bundle", flavor: "prod", build_type: "Release")
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/prodRelease/app-prod-release.aab',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
end
```

### 4.2 iOS Deployment (`ios/fastlane/Fastfile`)
```ruby
default_platform(:ios)

platform :ios do
  desc "Build and deploy to Apple TestFlight"
  lane :beta do
    setup_ci if ENV['CI']
    match(type: 'appstore', readonly: true)
    build_app(
      scheme: "prod",
      export_method: "app-store"
    )
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end
end
```

---

## 5. Store Review & Compliance Checklist

- **Camera & Photos Permissions:** Clear user-facing descriptions in `Info.plist` (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`) and `AndroidManifest.xml`.
- **In-App Account Deletion:** Direct "Delete Account" button in `SettingsScreen` satisfying Apple App Store Guideline 5.1.1(v).
- **Privacy Policy & Terms:** Live URLs linked from paywalls and settings.
