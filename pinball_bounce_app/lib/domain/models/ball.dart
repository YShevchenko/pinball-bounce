import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../core/constants.dart';

/// The pinball ball state.
class Ball extends Equatable {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double radius;

  /// Trail positions for visual effect (most recent first).
  final List<Offset> trail;

  const Ball({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.radius = GameConstants.ballRadius,
    this.trail = const [],
  });

  Ball copyWith({
    double? x,
    double? y,
    double? vx,
    double? vy,
    double? radius,
    List<Offset>? trail,
  }) {
    return Ball(
      x: x ?? this.x,
      y: y ?? this.y,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      radius: radius ?? this.radius,
      trail: trail ?? this.trail,
    );
  }

  /// Speed magnitude.
  double get speed {
    final dx = vx;
    final dy = vy;
    return (dx * dx + dy * dy).isNaN ? 0.0 : _sqrt(dx * dx + dy * dy);
  }

  static double _sqrt(double v) {
    if (v <= 0) return 0;
    // Newton's method for sqrt
    double x = v;
    double y = (x + 1) / 2;
    while (y < x) {
      x = y;
      y = (x + v / x) / 2;
    }
    return x;
  }

  @override
  List<Object?> get props => [x, y, vx, vy, radius];
}
