import 'package:flutter/material.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/core/router/app_router.dart';
import 'package:removeit_app/core/theme/app_theme.dart';

class RemoveItApp extends StatelessWidget {
  const RemoveItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: EnvConfig.instance.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
