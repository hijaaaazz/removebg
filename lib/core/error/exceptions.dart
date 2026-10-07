class ServerException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  ServerException({required this.message, this.code, this.statusCode});

  @override
  String toString() => 'ServerException: $message ($code, $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network connection failed']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache operation failed']);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Session expired']);
}
