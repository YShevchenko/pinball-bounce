import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../domain/models/ball.dart';
import '../../domain/models/flipper.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/table_layout.dart';
import '../../domain/services/physics_engine.dart';
import '../../domain/services/table_generator.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import 'providers.dart';

class GameNotifier extends StateNotifier<GameState> {
  final PhysicsEngine _physicsEngine;
  final TableGenerator _tableGenerator;
  final AdServiceBase _adService;
  final AudioService _audioService;
  final Ref _ref;

  /// Accumulated bumper hits this game session (for stats).
  int _sessionBumperHits = 0;

  /// Accumulated targets cleared this game session (for stats).
  int _sessionTargetsCleared = 0;

  GameNotifier({
    required PhysicsEngine physicsEngine,
    required TableGenerator tableGenerator,
    required AdServiceBase adService,
    required AudioService audioService,
    required Ref ref,
  })  : _physicsEngine = physicsEngine,
        _tableGenerator = tableGenerator,
        _adService = adService,
        _audioService = audioService,
        _ref = ref,
        super(GameState(
          ball: const Ball(x: 0, y: 0),
          table: TableLayout(
            level: 1,
            bumpers: const [],
            targets: const [],
            guideRails: const [],
            leftFlipper: const Flipper(
              anchorX: 0,
              anchorY: 0,
              angle: GameConstants.flipperRestAngle,
              side: FlipperSide.left,
            ),
            rightFlipper: const Flipper(
              anchorX: 0,
              anchorY: 0,
              angle: GameConstants.flipperRestAngle,
              side: FlipperSide.right,
            ),
            width: 0,
            height: 0,
          ),
        ));

  /// Initialize a new game at level 1 with given screen dimensions.
  void startNewGame(double width, double height) {
    _sessionBumperHits = 0;
    _sessionTargetsCleared = 0;

    final table = _tableGenerator.generate(
      level: 1,
      width: width,
      height: height,
    );

    state = GameState(
      ball: Ball(
        x: width / 2,
        y: height * 0.82,
      ),
      table: table,
      score: 0,
      lives: GameConstants.startLives,
      level: 1,
      phase: GamePhase.ready,
      gamesPlayed: state.gamesPlayed,
    );
  }

  /// Launch the ball upward.
  void launchBall() {
    if (state.phase != GamePhase.ready) return;

    _audioService.playLaunch();

    // Small random horizontal offset for variety
    final rng = Random();
    final hOffset = (rng.nextDouble() - 0.5) * 40;

    state = state.copyWith(
      ball: state.ball.copyWith(
        vx: hOffset,
        vy: -GameConstants.launchSpeed,
      ),
      phase: GamePhase.playing,
    );
  }

  /// Activate or deactivate left flipper.
  void setLeftFlipper(bool active) {
    final table = state.table;
    state = state.copyWith(
      table: table.copyWith(
        leftFlipper: table.leftFlipper.copyWith(isActive: active),
      ),
    );
  }

  /// Activate or deactivate right flipper.
  void setRightFlipper(bool active) {
    final table = state.table;
    state = state.copyWith(
      table: table.copyWith(
        rightFlipper: table.rightFlipper.copyWith(isActive: active),
      ),
    );
  }

  /// Update game physics for one frame.
  void update(double dt) {
    if (state.phase != GamePhase.playing) return;

    final newElapsed = state.elapsedTime + dt;

    // Update flipper angles
    TableLayout updatedTable = _physicsEngine.updateFlippers(state.table, dt);

    // Run physics step
    final result = _physicsEngine.step(
      ball: state.ball,
      table: updatedTable,
      dt: dt,
      elapsedTime: newElapsed,
    );

    // Update particles
    final updatedParticles = _physicsEngine.updateParticles(
      [...state.particles, ...result.newParticles],
      dt,
    );

    // Calculate score from hits
    int scoreAdd = 0;
    double combo = state.comboMultiplier;
    double lastHit = state.lastHitTime;

    // Bumper hits
    if (result.hitBumperIndices.isNotEmpty) {
      _audioService.playBumperHit();
      _triggerHaptic();
      _sessionBumperHits += result.hitBumperIndices.length;

      for (final _ in result.hitBumperIndices) {
        // Update combo
        if (newElapsed - lastHit < GameConstants.comboTimeWindow) {
          combo = (combo + GameConstants.comboMultiplierStep)
              .clamp(1.0, GameConstants.maxComboMultiplier);
        } else {
          combo = 1.0;
        }
        lastHit = newElapsed;
        scoreAdd += (GameConstants.bumperHitScore * combo).round();
      }
    }

    // Target hits
    if (result.hitTargetIndices.isNotEmpty) {
      _audioService.playTargetClear();
      _triggerHaptic();
      _sessionTargetsCleared += result.hitTargetIndices.length;

      for (final _ in result.hitTargetIndices) {
        if (newElapsed - lastHit < GameConstants.comboTimeWindow) {
          combo = (combo + GameConstants.comboMultiplierStep)
              .clamp(1.0, GameConstants.maxComboMultiplier);
        } else {
          combo = 1.0;
        }
        lastHit = newElapsed;
        scoreAdd += (GameConstants.targetClearScore * combo).round();
      }
    }

    final newScore = state.score + scoreAdd;

    // Check level complete
    if (result.table.allTargetsCleared) {
      _audioService.playLevelComplete();
      _triggerHaptic();

      state = state.copyWith(
        ball: result.ball,
        table: result.table,
        score: newScore,
        phase: GamePhase.levelComplete,
        comboMultiplier: combo,
        lastHitTime: lastHit,
        elapsedTime: newElapsed,
        particles: updatedParticles,
      );
      return;
    }

    // Check ball lost
    if (result.ballLost) {
      _audioService.playBallLost();
      _triggerHaptic();

      final newLives = state.lives - 1;
      if (newLives <= 0) {
        _audioService.playGameOver();

        // Record stats
        _ref.read(progressProvider.notifier).completeGame(
              level: state.level,
              score: newScore,
              bumperHits: _sessionBumperHits,
              targetsCleared: _sessionTargetsCleared,
            );

        _adService.showInterstitialIfReady(state.gamesPlayed + 1);

        state = state.copyWith(
          ball: result.ball,
          table: result.table,
          score: newScore,
          lives: 0,
          phase: GamePhase.gameOver,
          comboMultiplier: combo,
          lastHitTime: lastHit,
          elapsedTime: newElapsed,
          particles: updatedParticles,
          gamesPlayed: state.gamesPlayed + 1,
        );
      } else {
        state = state.copyWith(
          ball: result.ball,
          table: result.table,
          score: newScore,
          lives: newLives,
          phase: GamePhase.ballLost,
          comboMultiplier: 1.0,
          lastHitTime: lastHit,
          elapsedTime: newElapsed,
          particles: updatedParticles,
        );
      }
      return;
    }

    state = state.copyWith(
      ball: result.ball,
      table: result.table,
      score: newScore,
      comboMultiplier: combo,
      lastHitTime: lastHit,
      elapsedTime: newElapsed,
      particles: updatedParticles,
    );
  }

  /// Reset ball to launch position after losing a life.
  void resetBall() {
    if (state.phase != GamePhase.ballLost) return;

    final table = state.table;
    state = state.copyWith(
      ball: Ball(
        x: table.width / 2,
        y: table.height * 0.82,
      ),
      phase: GamePhase.ready,
    );
  }

  /// Advance to the next level.
  void nextLevel() {
    if (state.phase != GamePhase.levelComplete) return;

    final newLevel = state.level + 1;
    final table = _tableGenerator.generate(
      level: newLevel,
      width: state.table.width,
      height: state.table.height,
    );

    state = state.copyWith(
      ball: Ball(
        x: table.width / 2,
        y: table.height * 0.82,
      ),
      table: table,
      level: newLevel,
      phase: GamePhase.ready,
      comboMultiplier: 1.0,
    );
  }

  /// Restart the current game from scratch.
  void restartGame() {
    startNewGame(state.table.width, state.table.height);
  }

  void _triggerHaptic() {
    final settings = _ref.read(settingsProvider);
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }
}
