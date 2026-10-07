import 'package:dio/dio.dart';
import 'package:removeit_app/core/error/failures.dart';

class ErrorHandler {
  static Failure handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data['error'] != null) {
          final errorObj = data['error'];
          final code = errorObj['code'] as String?;
          final message = errorObj['message'] as String? ?? 'An unexpected error occurred.';

          switch (code) {
            case 'QUOTA_EXHAUSTED':
              return const QuotaExhaustedFailure();
            case 'MAX_AD_BONUSES_REACHED':
              return const MaxAdBonusesReachedFailure();
            case 'INVALID_IMAGE':
              return const InvalidImageFailure();
            case 'IMAGE_TOO_LARGE':
              return const ImageTooLargeFailure();
            case 'INFERENCE_FAILED':
              return const InferenceFailure();
            case 'MAINTENANCE_MODE':
              return const MaintenanceModeFailure();
            default:
              return ServerFailure(message: message, code: code);
          }
        }
        return ServerFailure(
          message: 'Server error: ${error.response?.statusCode}',
          code: 'SERVER_${error.response?.statusCode}',
        );

      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Request was cancelled.');

      default:
        return const NetworkFailure();
    }
  }
}
