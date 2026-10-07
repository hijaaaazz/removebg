import 'package:flutter/material.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';

class StudioCanvasScreen extends StatelessWidget {
  final String jobId;

  const StudioCanvasScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        title: const Text('Studio Canvas'),
      ),
      body: Center(
        child: Text('Canvas Studio for Job: $jobId'),
      ),
    );
  }
}
