enum Flavor { dev, staging, prod }

class EnvConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final String admobBannerId;
  final String admobRewardedId;
  final String admobInterstitialId;

  static late EnvConfig instance;

  EnvConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
    required this.admobBannerId,
    required this.admobRewardedId,
    required this.admobInterstitialId,
  });

  static void initialize({
    required Flavor flavor,
    required String apiBaseUrl,
    required String appTitle,
    required bool enableLogging,
    required String admobBannerId,
    required String admobRewardedId,
    required String admobInterstitialId,
  }) {
    instance = EnvConfig._(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      appTitle: appTitle,
      enableLogging: enableLogging,
      admobBannerId: admobBannerId,
      admobRewardedId: admobRewardedId,
      admobInterstitialId: admobInterstitialId,
    );
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;
}
