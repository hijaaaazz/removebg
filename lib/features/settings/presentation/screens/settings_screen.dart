import 'package:flutter/material.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Settings & Preferences'),
      ),
    );
  }
}
