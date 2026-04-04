import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/neon_button.dart';
import '../widgets/scanline_overlay.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(progressProvider);
    final iap = ref.read(iapServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AtmosphericBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.neonCyan),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        l10n.store.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.neonCyan,
                                  letterSpacing: 4,
                                ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 16),
                      // Remove Ads
                      _ShopItem(
                        title: l10n.removeAds,
                        description: l10n.removeAdsDescription,
                        price: '\$2.99',
                        icon: Icons.block,
                        iconColor: AppColors.primary,
                        isPurchased: progress.adsRemoved,
                        onPurchase: () {
                          iap.purchase(GameConstants.removeAdsProductId);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Extra Lives
                      _ShopItem(
                        title: l10n.extraLives,
                        description: l10n.extraLivesDescription,
                        price: '\$0.99',
                        icon: Icons.favorite,
                        iconColor: AppColors.secondary,
                        isPurchased:
                            iap.isPurchased(GameConstants.extraLivesProductId),
                        onPurchase: () {
                          iap.purchase(GameConstants.extraLivesProductId);
                        },
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            iap.restorePurchases();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.restore),
                                backgroundColor:
                                    AppColors.surfaceContainerHigh,
                              ),
                            );
                          },
                          child: Text(
                            l10n.restore.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 3,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final IconData icon;
  final Color iconColor;
  final bool isPurchased;
  final VoidCallback onPurchase;

  const _ShopItem({
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.iconColor,
    required this.isPurchased,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPurchased
              ? AppColors.primaryDim.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isPurchased)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryDim.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.purchased.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryDim,
                      letterSpacing: 3,
                    ),
              ),
            )
          else
            NeonButton(
              label: price,
              onTap: onPurchase,
            ),
        ],
      ),
    );
  }
}
