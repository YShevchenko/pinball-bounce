import '../../core/constants.dart';

/// Manages difficulty scaling based on level progression.
class DifficultyService {
  /// Ball speed multiplier for the given level.
  double ballSpeedMultiplier(int level) {
    // Gradually increase from 1.0 to 1.5 over 20 levels
    return 1.0 + (level - 1) * 0.025;
  }

  /// Gravity multiplier for the given level.
  double gravityMultiplier(int level) {
    // Slight gravity increase at higher levels
    return 1.0 + (level - 1) * 0.01;
  }

  /// Number of bumpers for the given level.
  int bumperCount(int level) {
    return _clamp(
      GameConstants.minBumpers + (level ~/ 2),
      GameConstants.minBumpers,
      GameConstants.maxBumpers,
    );
  }

  /// Number of targets for the given level.
  int targetCount(int level) {
    return _clamp(
      GameConstants.minTargets + (level ~/ 3),
      GameConstants.minTargets,
      GameConstants.maxTargets,
    );
  }

  /// Whether moving bumpers are enabled for the given level.
  bool hasMovingBumpers(int level) => level >= 5;

  /// Bumper movement speed scale for the given level.
  double bumperMoveSpeed(int level) {
    if (level < 5) return 0;
    return 1.0 + (level - 5) * 0.15;
  }

  int _clamp(int value, int minVal, int maxVal) {
    if (value < minVal) return minVal;
    if (value > maxVal) return maxVal;
    return value;
  }
}
