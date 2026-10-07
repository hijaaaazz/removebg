import 'package:flutter/material.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        title: const Text('Cutout History'),
      ),
      body: const Center(
        child: Text('No previous cutouts yet.'),
      ),
    );
  }
}
