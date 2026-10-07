import 'package:flutter/material.dart';
import 'package:removeit_app/app.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.initialize(
    flavor: Flavor.prod,
    apiBaseUrl: 'https://api.removebg.app/api/v1',
    appTitle: 'RemoveIt',
    enableLogging: false,
    admobBannerId: 'ca-app-pub-placeholder-prod/banner',
    admobRewardedId: 'ca-app-pub-placeholder-prod/rewarded',
    admobInterstitialId: 'ca-app-pub-placeholder-prod/interstitial',
  );

  await initInjection();

  runApp(const RemoveItApp());
}
