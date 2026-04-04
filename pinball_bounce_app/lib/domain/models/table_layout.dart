import 'package:equatable/equatable.dart';

import 'bumper.dart';
import 'flipper.dart';
import 'target.dart';

/// A guide rail segment (angled wall).
class GuideRail extends Equatable {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const GuideRail({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  @override
  List<Object?> get props => [x1, y1, x2, y2];
}

/// Complete table layout for a single level.
class TableLayout extends Equatable {
  final int level;
  final List<Bumper> bumpers;
  final List<Target> targets;
  final List<GuideRail> guideRails;
  final Flipper leftFlipper;
  final Flipper rightFlipper;

  /// Table dimensions in logical pixels.
  final double width;
  final double height;

  const TableLayout({
    required this.level,
    required this.bumpers,
    required this.targets,
    required this.guideRails,
    required this.leftFlipper,
    required this.rightFlipper,
    required this.width,
    required this.height,
  });

  TableLayout copyWith({
    int? level,
    List<Bumper>? bumpers,
    List<Target>? targets,
    List<GuideRail>? guideRails,
    Flipper? leftFlipper,
    Flipper? rightFlipper,
    double? width,
    double? height,
  }) {
    return TableLayout(
      level: level ?? this.level,
      bumpers: bumpers ?? this.bumpers,
      targets: targets ?? this.targets,
      guideRails: guideRails ?? this.guideRails,
      leftFlipper: leftFlipper ?? this.leftFlipper,
      rightFlipper: rightFlipper ?? this.rightFlipper,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Count of targets not yet cleared.
  int get remainingTargets =>
      targets.where((t) => !t.isCleared).length;

  /// Whether all targets are cleared.
  bool get allTargetsCleared => remainingTargets == 0;

  @override
  List<Object?> get props => [
        level,
        bumpers,
        targets,
        guideRails,
        leftFlipper,
        rightFlipper,
        width,
        height,
      ];
}
