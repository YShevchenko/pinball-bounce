import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/game_state.dart';
import '../../l10n/app_localizations.dart';
import 'neon_glow.dart';

/// Score and lives display overlay at the top of the game screen.
class ScoreHud extends StatelessWidget {
  final GameState gameState;

  const ScoreHud({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.score.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 3,
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              NeonText(
                '${gameState.score}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.w800,
                    ),
                glowColor: AppColors.primaryGlow,
              ),
            ],
          ),
          // Combo multiplier (only show if > 1)
          if (gameState.comboMultiplier > 1.0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.4),
                ),
              ),
              child: NeonText(
                '${l10n.combo} x${gameState.comboMultiplier.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                glowColor: AppColors.tertiaryGlow,
              ),
            ),
          // Level + Lives
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l10n.level.toUpperCase()} ${gameState.level}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 3,
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final isFilled = i < gameState.lives;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      isFilled ? Icons.favorite : Icons.favorite_border,
                      color: isFilled
                          ? AppColors.secondary
                          : AppColors.outlineVariant,
                      size: 20,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Remaining targets indicator.
class TargetsIndicator extends StatelessWidget {
  final int remaining;
  final int total;

  const TargetsIndicator({
    super.key,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.targetColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$remaining / $total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
