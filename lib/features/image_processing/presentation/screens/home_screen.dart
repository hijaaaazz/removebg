import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/utils/context_extensions.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/core/widgets/monetization/quota_pill_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        title: const Text('RemoveIt Studio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: QuotaPillBadge(
              remaining: 1,
              isPro: false,
              onTap: () => context.push(RouteNames.paywall),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Glowing Dropzone Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryViolet.withOpacity(0.08),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryViolet.withOpacity(0.15),
                      border: Border.all(color: AppColors.primaryViolet.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: AppColors.primaryVioletLight,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Remove Background Instantly',
                    style: context.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select any portrait or product photo to isolate subjects with studio precision.',
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action Buttons
            GlowButton(
              label: 'Select Photo from Gallery',
              icon: Icons.photo_library_rounded,
              onPressed: () {
                // Media picker will be wired in Phase 2
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // Camera will be wired in Phase 2
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.textSecondaryDark),
                  SizedBox(width: 8),
                  Text('Take Photo with Camera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
