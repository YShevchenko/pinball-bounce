import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'neon_glow.dart';

/// Stats card matching the bento-style stat display.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 3,
                ),
          ),
          const SizedBox(height: 6),
          NeonText(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: valueColor ?? AppColors.primary,
                ),
            glowColor:
                (valueColor ?? AppColors.primary).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// Horizontal stats row with divider.
class StatsRow extends StatelessWidget {
  final List<StatItem> stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i > 0) ...[
            Container(
              width: 1,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ],
          Column(
            children: [
              Text(
                stats[i].label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 4),
              NeonText(
                stats[i].value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: stats[i].color ?? AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                glowColor: (stats[i].color ?? AppColors.primary)
                    .withValues(alpha: 0.4),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final Color? color;

  const StatItem({
    required this.label,
    required this.value,
    this.color,
  });
}
