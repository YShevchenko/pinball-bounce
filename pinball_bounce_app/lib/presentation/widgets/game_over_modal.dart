import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'neon_button.dart';
import 'neon_glow.dart';
import 'stats_row.dart';

/// Modal displayed when the player loses all lives.
class GameOverModal extends StatelessWidget {
  final int score;
  final int level;
  final VoidCallback onRetry;
  final VoidCallback onMainMenu;

  const GameOverModal({
    super.key,
    required this.score,
    required this.level,
    required this.onRetry,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(
              l10n.gameOver.toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 4,
                  ),
              glowColor: AppColors.secondaryGlow,
            ),
            const SizedBox(height: 24),
            StatsRow(
              stats: [
                StatItem(
                  label: l10n.score.toUpperCase(),
                  value: '$score',
                  color: AppColors.primary,
                ),
                StatItem(
                  label: l10n.level.toUpperCase(),
                  value: '$level',
                  color: AppColors.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 32),
            NeonButton(
              label: l10n.retry.toUpperCase(),
              onTap: onRetry,
              icon: Icons.refresh,
            ),
            const SizedBox(height: 12),
            NeonOutlinedButton(
              label: l10n.mainMenu.toUpperCase(),
              onTap: onMainMenu,
              leadingIcon: Icons.home_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
