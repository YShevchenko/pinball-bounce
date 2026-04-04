import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'neon_button.dart';
import 'neon_glow.dart';
import 'stats_row.dart';

/// Modal displayed when the player clears all targets.
class LevelCompleteModal extends StatelessWidget {
  final int score;
  final int level;
  final VoidCallback onNextLevel;
  final VoidCallback onMainMenu;

  const LevelCompleteModal({
    super.key,
    required this.score,
    required this.level,
    required this.onNextLevel,
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
            color: AppColors.tertiary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiary.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(
              l10n.levelComplete.toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.tertiary,
                    letterSpacing: 3,
                    fontSize: 26,
                  ),
              glowColor: AppColors.tertiaryGlow,
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
              label: l10n.nextLevel.toUpperCase(),
              onTap: onNextLevel,
              icon: Icons.arrow_forward,
              color: AppColors.tertiaryContainer,
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
