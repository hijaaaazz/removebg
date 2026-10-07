import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';

class ProPaywallScreen extends StatelessWidget {
  const ProPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        title: const Text('Unlock Pro Studio'),
        actions: [
          TextButton(
            onPressed: () {
              // Restore purchases
            },
            child: const Text('Restore', style: TextStyle(color: AppColors.proGold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.workspace_premium_rounded, size: 64, color: AppColors.proGold),
            const SizedBox(height: 16),
            const Text(
              'Remove Limits. Keep Full 4K Quality.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Export native sensor resolutions, process batches up to 20 photos, and remove all ads.',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            GlowButton(
              label: 'Upgrade to Pro Unlimited',
              variant: GlowButtonVariant.proGold,
              onPressed: () {
                // Trigger RevenueCat purchase
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
