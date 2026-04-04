import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/neon_glow.dart';
import '../widgets/scanline_overlay.dart';
import '../widgets/stats_row.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

/// Title screen with PLAY button, stats.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(progressProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(progressProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const AtmosphericBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, l10n),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHighScore(context, l10n, stats.highScore),
                      const SizedBox(height: 48),
                      _buildPlayButton(context, l10n),
                      const SizedBox(height: 40),
                      _buildStatsGrid(context, l10n, stats),
                    ],
                  ),
                ),
                _buildBottomNav(context, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.sports_esports,
                  color: AppColors.neonCyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              NeonText(
                'NEON PULSE',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                glowColor: AppColors.neonCyan.withValues(alpha: 0.4),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.neonCyan),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHighScore(
      BuildContext context, AppLocalizations l10n, int highScore) {
    return Column(
      children: [
        Text(
          l10n.highScore.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 3,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events,
                color: AppColors.tertiary, size: 28),
            const SizedBox(width: 8),
            NeonText(
              '$highScore',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
              glowColor: AppColors.tertiary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _goToGame,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryContainer],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  blurRadius: 40,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLowest,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeonText(
                    l10n.play.toUpperCase(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 36,
                          letterSpacing: 6,
                        ),
                  ),
                  const Icon(
                    Icons.play_arrow,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AppLocalizations l10n, stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: l10n.gamesPlayed.toUpperCase(),
              value: '${stats.gamesPlayed}',
              valueColor: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              label: l10n.totalScore.toUpperCase(),
              value: _formatScore(stats.totalScore),
              valueColor: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.shopping_bag_outlined,
            label: l10n.shop.toUpperCase(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopScreen()),
            ),
          ),
          _NavItem(
            icon: Icons.sports_esports,
            label: l10n.play.toUpperCase(),
            isActive: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: l10n.settings.toUpperCase(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _goToGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  String _formatScore(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.neonCyan : AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                    blurRadius: 15,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
