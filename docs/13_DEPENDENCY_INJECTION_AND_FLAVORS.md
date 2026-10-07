# 13. Dependency Injection & Multi-Environment Flavors

To guarantee testability, maintain separation of concerns, and enable clean switching between local development and production backends, **RemoveIt** uses `get_it` and `injectable` paired with compile-time build flavors.

---

## 1. Dependency Injection Architecture (`get_it` + `injectable`)

Dependencies are structured in a strict registration hierarchy inside `lib/injection_container.dart`:

```
[ 1. External Third-Party Drivers ]
  - Dio, FlutterSecureStorage, SharedPreferences, AppDatabase (Drift)
                    │
                    ▼
[ 2. Core Network & Services ]
  - ApiClient, AuthInterceptor, NetworkInfo, HapticService
                    │
                    ▼
[ 3. Feature Data Sources & Repositories ] (LazySingleton)
  - JobRemoteDataSource, JobRepositoryImpl, QuotaRepositoryImpl
                    │
                    ▼
[ 4. Domain Use Cases ] (Factory)
  - UploadImageUseCase, ClaimJobUseCase, GetUserQuotaUseCase
                    │
                    ▼
[ 5. Presentation BLoCs & Cubits ]
  - Global Singletons: AuthBloc, QuotaBloc, ThemeCubit
  - Screen Factories: JobProcessingBloc, StudioCanvasCubit, HistoryBloc
```

### DI Container Implementation
```dart
// lib/injection_container.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/core/network/auth_interceptor.dart';
import 'package:removeit_app/core/network/logging_interceptor.dart';
import 'package:removeit_app/core/network/retry_interceptor.dart';
import 'package:removeit_app/features/image_processing/data/datasources/job_remote_data_source.dart';
import 'package:removeit_app/features/image_processing/data/repositories/job_repository_impl.dart';
import 'package:removeit_app/features/image_processing/domain/repositories/job_repository.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/upload_image_usecase.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // 1. External Drivers
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  // 2. Core Network
  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(dio: sl(), secureStorage: sl()));
  sl.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());
  sl.registerLazySingleton<RetryInterceptor>(() => RetryInterceptor());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(
        authInterceptor: sl(),
        loggingInterceptor: sl(),
        retryInterceptor: sl(),
      ));

  // 3. Image Processing Feature
  sl.registerLazySingleton<JobRemoteDataSource>(() => JobRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<JobRepository>(() => JobRepositoryImpl(sl()));
  sl.registerFactory<UploadImageUseCase>(() => UploadImageUseCase(sl()));
  sl.registerFactory<JobProcessingBloc>(() => JobProcessingBloc(uploadImageUseCase: sl()));
}
```

---

## 2. Multi-Environment Flavors

RemoveIt supports three explicit build environments:

| Dimension | `dev` | `staging` | `prod` |
| :--- | :--- | :--- | :--- |
| **API Base URL** | `http://10.0.2.2:8000/api/v1` (Android) / `http://localhost:8000/api/v1` (iOS) | `https://staging-api.removebg.app/api/v1` | `https://api.removebg.app/api/v1` |
| **AdMob Unit IDs** | Google Official Test IDs (`ca-app-pub-3940256099942544/...`) | Test IDs | Live Production AdMob IDs |
| **RevenueCat Mode**| Sandbox / Test Store | Sandbox | Production StoreKit / Google Play Billing |
| **Logging** | Verbose cURL logs enabled | Debug warnings only | Completely disabled |

---

## 3. Flavor Bootstrap & Entry Points

```dart
// lib/core/config/env_config.dart
enum Flavor { dev, staging, prod }

class EnvConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;

  static late EnvConfig instance;

  EnvConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
  });

  static void initialize({
    required Flavor flavor,
    required String apiBaseUrl,
    required String appTitle,
    required bool enableLogging,
  }) {
    instance = EnvConfig._(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      appTitle: appTitle,
      enableLogging: enableLogging,
    );
  }
}
```

### Entry Points:
- `lib/main_dev.dart`: Bootstraps with `Flavor.dev` and local backend URL.
- `lib/main_staging.dart`: Bootstraps with `Flavor.staging` and staging URL.
- `lib/main_prod.dart`: Bootstraps with `Flavor.prod` and production URL.

```bash
# Run locally against development backend
flutter run -t lib/main_dev.dart --flavor dev

# Build release APK for production
flutter build appbundle -t lib/main_prod.dart --flavor prod
```
