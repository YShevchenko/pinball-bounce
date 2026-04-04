import 'package:equatable/equatable.dart';

import 'ball.dart';
import 'table_layout.dart';

/// Possible game phases.
enum GamePhase {
  /// Waiting to launch the ball.
  ready,

  /// Ball is in play.
  playing,

  /// Ball just fell below flippers — brief pause.
  ballLost,

  /// All targets cleared — level complete.
  levelComplete,

  /// No lives remaining — game over.
  gameOver,
}

/// A visual particle for effects.
class Particle extends Equatable {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double life; // 0.0 to 1.0 (1.0 = just spawned)
  final int colorIndex; // 0 = primary, 1 = secondary, 2 = tertiary

  const Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    this.colorIndex = 0,
  });

  Particle copyWith({
    double? x,
    double? y,
    double? vx,
    double? vy,
    double? life,
    int? colorIndex,
  }) {
    return Particle(
      x: x ?? this.x,
      y: y ?? this.y,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      life: life ?? this.life,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  List<Object?> get props => [x, y, vx, vy, life, colorIndex];
}

/// Complete game state for a single game session.
class GameState extends Equatable {
  final Ball ball;
  final TableLayout table;
  final int score;
  final int lives;
  final int level;
  final GamePhase phase;
  final double comboMultiplier;
  final double lastHitTime;
  final double elapsedTime;
  final List<Particle> particles;
  final int gamesPlayed;

  const GameState({
    required this.ball,
    required this.table,
    this.score = 0,
    this.lives = 3,
    this.level = 1,
    this.phase = GamePhase.ready,
    this.comboMultiplier = 1.0,
    this.lastHitTime = -10.0,
    this.elapsedTime = 0,
    this.particles = const [],
    this.gamesPlayed = 0,
  });

  GameState copyWith({
    Ball? ball,
    TableLayout? table,
    int? score,
    int? lives,
    int? level,
    GamePhase? phase,
    double? comboMultiplier,
    double? lastHitTime,
    double? elapsedTime,
    List<Particle>? particles,
    int? gamesPlayed,
  }) {
    return GameState(
      ball: ball ?? this.ball,
      table: table ?? this.table,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      level: level ?? this.level,
      phase: phase ?? this.phase,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      lastHitTime: lastHitTime ?? this.lastHitTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      particles: particles ?? this.particles,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }

  @override
  List<Object?> get props => [
        ball,
        table,
        score,
        lives,
        level,
        phase,
        comboMultiplier,
        lastHitTime,
        elapsedTime,
        particles,
        gamesPlayed,
      ];
}
