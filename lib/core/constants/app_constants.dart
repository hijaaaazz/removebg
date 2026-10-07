class AppConstants {
  static const String appName = 'RemoveIt';

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Polling intervals
  static const Duration pollInitialDelay = Duration(milliseconds: 800);
  static const Duration pollInterval = Duration(milliseconds: 1200);
  static const int maxPollAttempts = 25; // ~30 seconds

  // Image limits
  static const int maxImageDimension = 2048;
  static const int imageJpegQuality = 88;
  static const int maxFileSizeMb = 25;

  // Cache limits
  static const int maxCacheSizeMb = 250;
  static const int maxCachedThumbnails = 100;
}
