import 'package:equatable/equatable.dart';

import '../../core/constants.dart';

/// A circular bumper that bounces the ball away.
class Bumper extends Equatable {
  final double x;
  final double y;
  final double radius;

  /// Number of times hit this level.
  final int hitCount;

  /// Time of last hit for visual pulse effect (in seconds since level start).
  final double lastHitTime;

  /// Whether this bumper moves (higher difficulty levels).
  final bool isMoving;

  /// Movement speed if moving.
  final double moveSpeed;

  /// Movement range (oscillates left-right within this range).
  final double moveRange;

  /// Current movement phase.
  final double movePhase;

  const Bumper({
    required this.x,
    required this.y,
    this.radius = GameConstants.bumperRadius,
    this.hitCount = 0,
    this.lastHitTime = -10.0,
    this.isMoving = false,
    this.moveSpeed = 0,
    this.moveRange = 0,
    this.movePhase = 0,
  });

  Bumper copyWith({
    double? x,
    double? y,
    double? radius,
    int? hitCount,
    double? lastHitTime,
    bool? isMoving,
    double? moveSpeed,
    double? moveRange,
    double? movePhase,
  }) {
    return Bumper(
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
      hitCount: hitCount ?? this.hitCount,
      lastHitTime: lastHitTime ?? this.lastHitTime,
      isMoving: isMoving ?? this.isMoving,
      moveSpeed: moveSpeed ?? this.moveSpeed,
      moveRange: moveRange ?? this.moveRange,
      movePhase: movePhase ?? this.movePhase,
    );
  }

  /// Whether the bumper was recently hit (for glow effect).
  bool isRecentlyHit(double currentTime) {
    return (currentTime - lastHitTime) < 0.3;
  }

  @override
  List<Object?> get props => [
        x,
        y,
        radius,
        hitCount,
        lastHitTime,
        isMoving,
        moveSpeed,
        moveRange,
        movePhase,
      ];
}
