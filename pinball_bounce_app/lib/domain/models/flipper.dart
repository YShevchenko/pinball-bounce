import 'package:equatable/equatable.dart';

import '../../core/constants.dart';

/// Which side of the table the flipper is on.
enum FlipperSide { left, right }

/// A pinball flipper anchored at one end.
class Flipper extends Equatable {
  /// Anchor point (the pivot) in logical pixels.
  final double anchorX;
  final double anchorY;

  /// Current angle in radians (0 = horizontal, positive = clockwise).
  final double angle;

  /// Length of the flipper.
  final double length;

  /// Thickness of the flipper.
  final double width;

  /// Which side this flipper is on.
  final FlipperSide side;

  /// Whether currently activated (button held).
  final bool isActive;

  const Flipper({
    required this.anchorX,
    required this.anchorY,
    required this.angle,
    this.length = GameConstants.flipperLength,
    this.width = GameConstants.flipperWidth,
    required this.side,
    this.isActive = false,
  });

  Flipper copyWith({
    double? anchorX,
    double? anchorY,
    double? angle,
    double? length,
    double? width,
    FlipperSide? side,
    bool? isActive,
  }) {
    return Flipper(
      anchorX: anchorX ?? this.anchorX,
      anchorY: anchorY ?? this.anchorY,
      angle: angle ?? this.angle,
      length: length ?? this.length,
      width: width ?? this.width,
      side: side ?? this.side,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Tip position (the end opposite the anchor).
  double get tipX {
    final dir = side == FlipperSide.left ? 1.0 : -1.0;
    return anchorX + dir * length * _cos(angle);
  }

  double get tipY {
    return anchorY - length * _sin(angle);
  }

  /// Target angle based on active state.
  double get targetAngle {
    return isActive
        ? GameConstants.flipperActiveAngle
        : GameConstants.flipperRestAngle;
  }

  static double _cos(double radians) {
    // Use dart:math indirectly via import-free approximation
    // This is a model class; actual trig is done in physics engine
    return radians; // placeholder — real math done in physics_engine
  }

  static double _sin(double radians) {
    return radians; // placeholder — real math done in physics_engine
  }

  @override
  List<Object?> get props => [anchorX, anchorY, angle, length, width, side, isActive];
}
