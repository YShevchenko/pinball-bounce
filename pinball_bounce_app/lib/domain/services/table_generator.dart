import 'dart:math';

import '../../core/constants.dart';
import '../models/bumper.dart';
import '../models/flipper.dart';
import '../models/table_layout.dart';
import '../models/target.dart';

/// Generates procedural table layouts for each level.
class TableGenerator {
  /// Generate a table layout for the given level and screen dimensions.
  TableLayout generate({
    required int level,
    required double width,
    required double height,
  }) {
    final seed = level * 31 + 7; // Deterministic seed per level
    final rng = Random(seed);

    // Difficulty scaling
    final numBumpers = _clampInt(
      GameConstants.minBumpers + (level ~/ 2),
      GameConstants.minBumpers,
      GameConstants.maxBumpers,
    );
    final numTargets = _clampInt(
      GameConstants.minTargets + (level ~/ 3),
      GameConstants.minTargets,
      GameConstants.maxTargets,
    );
    final hasMovingBumpers = level >= 5;

    // Flipper positions
    final flipperY = height * 0.88;
    final centerX = width / 2;
    final flipperSpacing = width * 0.15;

    final leftFlipper = Flipper(
      anchorX: centerX - flipperSpacing,
      anchorY: flipperY,
      angle: GameConstants.flipperRestAngle,
      side: FlipperSide.left,
    );
    final rightFlipper = Flipper(
      anchorX: centerX + flipperSpacing,
      anchorY: flipperY,
      angle: GameConstants.flipperRestAngle,
      side: FlipperSide.right,
    );

    // Place bumpers in the upper 60% of the table
    final bumpers = _placeBumpers(
      rng: rng,
      count: numBumpers,
      width: width,
      height: height,
      hasMoving: hasMovingBumpers,
      level: level,
    );

    // Place targets avoiding overlap with bumpers
    final targets = _placeTargets(
      rng: rng,
      count: numTargets,
      width: width,
      height: height,
      bumpers: bumpers,
    );

    // Generate guide rails for higher levels
    final guideRails = _generateGuideRails(
      rng: rng,
      level: level,
      width: width,
      height: height,
    );

    return TableLayout(
      level: level,
      bumpers: bumpers,
      targets: targets,
      guideRails: guideRails,
      leftFlipper: leftFlipper,
      rightFlipper: rightFlipper,
      width: width,
      height: height,
    );
  }

  List<Bumper> _placeBumpers({
    required Random rng,
    required int count,
    required double width,
    required double height,
    required bool hasMoving,
    required int level,
  }) {
    final bumpers = <Bumper>[];
    final margin = GameConstants.bumperRadius * 2;
    final minX = margin;
    final maxX = width - margin;
    final minY = height * 0.12;
    final maxY = height * 0.55;

    int attempts = 0;
    while (bumpers.length < count && attempts < 200) {
      attempts++;
      final x = minX + rng.nextDouble() * (maxX - minX);
      final y = minY + rng.nextDouble() * (maxY - minY);

      // Check no overlap with existing bumpers
      bool overlaps = false;
      for (final b in bumpers) {
        final dx = x - b.x;
        final dy = y - b.y;
        final minDist = GameConstants.bumperRadius * 3;
        if (dx * dx + dy * dy < minDist * minDist) {
          overlaps = true;
          break;
        }
      }
      if (overlaps) continue;

      final isMoving = hasMoving && rng.nextDouble() < 0.3;
      bumpers.add(Bumper(
        x: x,
        y: y,
        isMoving: isMoving,
        moveSpeed: isMoving ? 1.0 + rng.nextDouble() * (level * 0.2) : 0,
        moveRange: isMoving ? 20.0 + rng.nextDouble() * 30.0 : 0,
        movePhase: rng.nextDouble() * 3.14159 * 2,
      ));
    }
    return bumpers;
  }

  List<Target> _placeTargets({
    required Random rng,
    required int count,
    required double width,
    required double height,
    required List<Bumper> bumpers,
  }) {
    final targets = <Target>[];
    final margin = GameConstants.targetRadius * 2;
    final minX = margin;
    final maxX = width - margin;
    final minY = height * 0.15;
    final maxY = height * 0.65;

    int attempts = 0;
    while (targets.length < count && attempts < 200) {
      attempts++;
      final x = minX + rng.nextDouble() * (maxX - minX);
      final y = minY + rng.nextDouble() * (maxY - minY);

      // Check no overlap with bumpers
      bool overlaps = false;
      for (final b in bumpers) {
        final dx = x - b.x;
        final dy = y - b.y;
        final minDist = GameConstants.bumperRadius + GameConstants.targetRadius + 10;
        if (dx * dx + dy * dy < minDist * minDist) {
          overlaps = true;
          break;
        }
      }
      if (overlaps) continue;

      // Check no overlap with other targets
      for (final t in targets) {
        final dx = x - t.x;
        final dy = y - t.y;
        final minDist = GameConstants.targetRadius * 3;
        if (dx * dx + dy * dy < minDist * minDist) {
          overlaps = true;
          break;
        }
      }
      if (overlaps) continue;

      targets.add(Target(x: x, y: y));
    }
    return targets;
  }

  List<GuideRail> _generateGuideRails({
    required Random rng,
    required int level,
    required double width,
    required double height,
  }) {
    final rails = <GuideRail>[];

    // Always add angled walls near the bottom to funnel ball toward flippers
    final wallLen = width * 0.15;
    final wallY = height * 0.78;

    // Left funnel wall
    rails.add(GuideRail(
      x1: 0,
      y1: wallY - wallLen * 0.3,
      x2: width * 0.18,
      y2: wallY + wallLen * 0.3,
    ));

    // Right funnel wall
    rails.add(GuideRail(
      x1: width,
      y1: wallY - wallLen * 0.3,
      x2: width * 0.82,
      y2: wallY + wallLen * 0.3,
    ));

    // Higher levels get additional obstacles
    if (level >= 3) {
      // Center divider near top
      final dividerY = height * 0.08;
      rails.add(GuideRail(
        x1: width * 0.4,
        y1: dividerY,
        x2: width * 0.6,
        y2: dividerY + height * 0.06,
      ));
    }

    if (level >= 7) {
      // Side ramps
      final rampY = height * 0.35;
      rails.add(GuideRail(
        x1: 0,
        y1: rampY,
        x2: width * 0.12,
        y2: rampY - height * 0.08,
      ));
      rails.add(GuideRail(
        x1: width,
        y1: rampY,
        x2: width * 0.88,
        y2: rampY - height * 0.08,
      ));
    }

    return rails;
  }

  int _clampInt(int value, int minVal, int maxVal) {
    if (value < minVal) return minVal;
    if (value > maxVal) return maxVal;
    return value;
  }
}
