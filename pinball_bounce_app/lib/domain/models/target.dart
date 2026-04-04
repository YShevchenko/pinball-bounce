import 'package:equatable/equatable.dart';

import '../../core/constants.dart';

/// A target that lights up when hit. Clear all to complete the level.
class Target extends Equatable {
  final double x;
  final double y;
  final double radius;

  /// Whether this target has been cleared (hit by the ball).
  final bool isCleared;

  /// Time when cleared for visual effect.
  final double clearedTime;

  const Target({
    required this.x,
    required this.y,
    this.radius = GameConstants.targetRadius,
    this.isCleared = false,
    this.clearedTime = -10.0,
  });

  Target copyWith({
    double? x,
    double? y,
    double? radius,
    bool? isCleared,
    double? clearedTime,
  }) {
    return Target(
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
      isCleared: isCleared ?? this.isCleared,
      clearedTime: clearedTime ?? this.clearedTime,
    );
  }

  @override
  List<Object?> get props => [x, y, radius, isCleared, clearedTime];
}
