# 06. Networking, API & Offline Sync Architecture

Consumer AI photography apps demand robust networking. Users upload multi-megabyte camera files across unpredictable cellular networks (4G, 5G, spotty Wi-Fi), and expect uninterrupted progress feedback.

---

## 1. Centralized Dio HTTP Client Architecture

All network traffic routes through a configured singleton `ApiClient` using **Dio**:

```
+-------------------------------------------------------------+
|               Feature Remote Data Source                    |
+------------------------------+------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|                     Dio ApiClient                           |
+------------------------------+------------------------------+
                               |
               +---------------+---------------+
               | Pipeline of Queued Interceptors|
               +---------------+---------------+
                               |
          [1] AuthInterceptor (Token injection & refresh)
          [2] LoggingInterceptor (Pretty cURL in debug mode)
          [3] RetryInterceptor (Exponential backoff on 5xx)
          [4] ErrorTransformer (Maps DioException -> AppFailures)
                               |
                               v
+-------------------------------------------------------------+
|               Django REST API (/api/v1/)                    |
+-------------------------------------------------------------+
```

### ApiClient Implementation
```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/network/auth_interceptor.dart';
import 'package:removeit_app/core/network/logging_interceptor.dart';
import 'package:removeit_app/core/network/retry_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient({
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required RetryInterceptor retryInterceptor,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 60), // generous for image uploads
            headers: {
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.addAll([
      authInterceptor,
      loggingInterceptor,
      retryInterceptor,
    ]);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, ProgressCallback? onSendProgress}) {
    return dio.post<T>(path, data: data, onSendProgress: onSendProgress);
  }
}
```

---

## 2. Multipart Image Upload with Progress Tracking

```dart
// lib/features/image_processing/data/datasources/job_remote_data_source.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/features/image_processing/data/models/job_model.dart';

abstract class JobRemoteDataSource {
  Future<JobModel> uploadImage(File file, {Function(int sent, int total)? onProgress});
  Future<JobModel> getJobStatus(String jobId);
  Future<JobModel> claimJob(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiClient apiClient;

  JobRemoteDataSourceImpl(this.apiClient);

  @override
  Future<JobModel> uploadImage(File file, {Function(int sent, int total)? onProgress}) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await apiClient.post(
      ApiEndpoints.jobs,
      data: formData,
      onSendProgress: onProgress,
    );

    return JobModel.fromJson(response.data['data']);
  }

  @override
  Future<JobModel> getJobStatus(String jobId) async {
    final response = await apiClient.get('${ApiEndpoints.jobs}$jobId/');
    return JobModel.fromJson(response.data['data']);
  }

  @override
  Future<JobModel> claimJob(String jobId) async {
    final response = await apiClient.post('${ApiEndpoints.jobs}$jobId/claim/');
    return JobModel.fromJson(response.data['data']);
  }
}
```

---

## 3. Asynchronous Job Polling Strategy

Inference with the BiRefNet model runs inside a Celery background worker, typically concluding in 1.2s to 3.5s.

The client executes exponential-damped polling:
1. First poll at **800ms**.
2. Subsequent polls every **1200ms**.
3. Max timeout threshold: **25 attempts (30 seconds)**.
4. If status transitions to `preview_ready`, polling halts immediately and navigates to the Studio Canvas.
5. If status transitions to `failed`, the backend automatically refunds quota and the client emits `JobErrorState`.

---

## 4. Error Code Transformation Catalog

The network layer intercepts API errors and maps backend error codes directly into localized UI strings:

| Backend Error Code | HTTP Status | User-Friendly UI Display Message |
| :--- | :--- | :--- |
| `QUOTA_EXHAUSTED` | 402 | You've used today's free removals! Watch a quick video to unlock a bonus or switch to Pro. |
| `MAX_AD_BONUSES_REACHED`| 400 | You've reached the maximum daily bonus uses! Upgrade to Pro for unlimited removals. |
| `INVALID_IMAGE` | 400 | This photo format is not supported. Please choose a JPG, PNG, or WebP photo. |
| `IMAGE_TOO_LARGE` | 413 | The selected photo is larger than 25MB. Please choose a smaller photo. |
| `INFERENCE_FAILED` | 500 | Unable to isolate subject cleanly. Your daily quota was not deducted. Please try another photo! |
| `MAINTENANCE_MODE` | 503 | We're upgrading our AI models! We will be back online in just a few minutes. |

---

## 5. Presigned URL Cache & Expiry Management

1. **Short-Lived URLs:** Output and preview URLs from Cloudflare R2 / AWS S3 expire after 15 minutes for asset security.
2. **Local Caching:** Images loaded into the canvas and history tiles use `cached_network_image` with a unique cache key based on `job_id`, preventing re-downloading if the presigned query parameters change.
3. **Auto-Refresh:** When an expired history thumbnail is requested, the client calls `GET /api/v1/jobs/{id}/` to fetch a refreshed presigned URL.
