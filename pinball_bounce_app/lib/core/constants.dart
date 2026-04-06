/// Game tuning constants. Change here, not scattered through code.
abstract final class GameConstants {
  /// Gravity acceleration in pixels per second squared.
  static const double gravity = 500.0;

  /// Ball radius in logical pixels.
  static const double ballRadius = 8.0;

  /// Bumper radius in logical pixels.
  static const double bumperRadius = 25.0;

  /// Target radius in logical pixels.
  static const double targetRadius = 15.0;

  /// Flipper length in logical pixels.
  static const double flipperLength = 70.0;

  /// Flipper width (thickness) in logical pixels.
  static const double flipperWidth = 12.0;

  /// Coefficient of restitution for wall/flipper bounces.
  static const double restitution = 0.7;

  /// Extra energy multiplier when hitting a bumper.
  static const double bumperBoost = 1.6;

  /// Starting number of lives per game.
  static const int startLives = 3;

  /// Physics update timestep (seconds).
  static const double physicsTimestep = 1.0 / 60.0;

  /// Flipper rest angle in radians (~30 degrees down from horizontal).
  static const double flipperRestAngle = 0.52; // ~30 degrees

  /// Flipper activated angle in radians (~30 degrees up from horizontal).
  static const double flipperActiveAngle = -0.52;

  /// Flipper angular speed in radians per second.
  static const double flipperAngularSpeed = 15.0;

  /// Force applied to ball when hit by a moving flipper.
  static const double flipperHitForce = 1200.0;

  /// Score for hitting a bumper.
  static const int bumperHitScore = 10;

  /// Score for clearing a target.
  static const int targetClearScore = 50;

  /// Combo multiplier increase per consecutive hit.
  static const double comboMultiplierStep = 0.5;

  /// Max combo multiplier.
  static const double maxComboMultiplier = 5.0;

  /// Time window for combo in seconds.
  static const double comboTimeWindow = 2.0;

  /// Ball launch speed (pixels per second, upward).
  static const double launchSpeed = 500.0;

  /// Minimum bumpers per level.
  static const int minBumpers = 3;

  /// Maximum bumpers per level.
  static const int maxBumpers = 8;

  /// Minimum targets per level.
  static const int minTargets = 3;

  /// Maximum targets per level.
  static const int maxTargets = 6;

  /// Show interstitial ad every N games.
  static const int adFrequencyGames = 3;

  /// IAP product IDs.
  static const String removeAdsProductId = 'pinball_bounce_remove_ads';
  static const String extraLivesProductId = 'pinball_bounce_extra_lives';

  /// Available locales.
  static const Map<String, String> supportedLocales = {
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Espanol',
    'uk': 'Ukrainska',
  };

  /// Maximum ball speed (cap to prevent tunneling).
  static const double maxBallSpeed = 1200.0;

  /// Ball trail length (number of positions to remember).
  static const int ballTrailLength = 10;

  /// Particle count per bumper hit.
  static const int bumperParticleCount = 8;

  /// Particle count per target clear.
  static const int targetParticleCount = 12;

  /// Guide rail thickness.
  static const double guideRailThickness = 3.0;
}
