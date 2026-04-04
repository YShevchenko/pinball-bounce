import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/game_state.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/game_over_modal.dart';
import '../widgets/level_complete_modal.dart';
import '../widgets/neon_glow.dart';
import '../widgets/score_hud.dart';
import '../widgets/table_painter.dart';

/// The main game screen with pinball table, flippers, and HUD.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_initialized) return;

    final dt = (_lastTick == Duration.zero)
        ? 0.016
        : (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    // Clamp dt to avoid huge jumps when app resumes
    final clampedDt = dt.clamp(0.0, 0.05);

    ref.read(gameProvider.notifier).update(clampedDt);
  }

  void _initGame(Size size) {
    if (_initialized) return;
    _initialized = true;

    // Use a post-frame callback to ensure the widget is fully laid out
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startNewGame(size.width, size.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            _initGame(size);

            return Stack(
              children: [
                // Game table
                GestureDetector(
                  onTapDown: (details) => _handleTapDown(details, size),
                  onTapUp: (details) => _handleTapUp(details, size),
                  onTapCancel: _handleTapCancel,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: TablePainter(gameState: gameState),
                      size: size,
                    ),
                  ),
                ),
                // HUD
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ScoreHud(gameState: gameState),
                ),
                // Targets remaining indicator
                if (gameState.phase == GamePhase.playing)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: TargetsIndicator(
                        remaining: gameState.table.remainingTargets,
                        total: gameState.table.targets.length,
                      ),
                    ),
                  ),
                // Ready state — tap to launch
                if (gameState.phase == GamePhase.ready)
                  _buildReadyOverlay(context),
                // Ball lost — tap to continue
                if (gameState.phase == GamePhase.ballLost)
                  _buildBallLostOverlay(context),
                // Level complete
                if (gameState.phase == GamePhase.levelComplete)
                  LevelCompleteModal(
                    score: gameState.score,
                    level: gameState.level,
                    onNextLevel: () {
                      ref.read(gameProvider.notifier).nextLevel();
                    },
                    onMainMenu: () => Navigator.pop(context),
                  ),
                // Game over
                if (gameState.phase == GamePhase.gameOver)
                  GameOverModal(
                    score: gameState.score,
                    level: gameState.level,
                    onRetry: () {
                      ref.read(gameProvider.notifier).restartGame();
                    },
                    onMainMenu: () => Navigator.pop(context),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReadyOverlay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          ref.read(gameProvider.notifier).launchBall();
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 100),
                NeonText(
                  l10n.tapToLaunch.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                  glowColor: AppColors.primaryGlow,
                ),
                const SizedBox(height: 16),
                Icon(
                  Icons.touch_app,
                  color: AppColors.primary.withValues(alpha: 0.6),
                  size: 36,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBallLostOverlay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          ref.read(gameProvider.notifier).resetBall();
        },
        child: Container(
          color: AppColors.background.withValues(alpha: 0.5),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeonText(
                  l10n.ballLost.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 3,
                      ),
                  glowColor: AppColors.secondaryGlow,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.tapToContinue.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 3,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    final gameState = ref.read(gameProvider);
    if (gameState.phase != GamePhase.playing) return;

    final x = details.localPosition.dx;
    if (x < size.width / 2) {
      ref.read(gameProvider.notifier).setLeftFlipper(true);
    } else {
      ref.read(gameProvider.notifier).setRightFlipper(true);
    }
  }

  void _handleTapUp(TapUpDetails details, Size size) {
    final gameState = ref.read(gameProvider);
    if (gameState.phase != GamePhase.playing) return;

    final x = details.localPosition.dx;
    if (x < size.width / 2) {
      ref.read(gameProvider.notifier).setLeftFlipper(false);
    } else {
      ref.read(gameProvider.notifier).setRightFlipper(false);
    }
  }

  void _handleTapCancel() {
    ref.read(gameProvider.notifier).setLeftFlipper(false);
    ref.read(gameProvider.notifier).setRightFlipper(false);
  }
}
