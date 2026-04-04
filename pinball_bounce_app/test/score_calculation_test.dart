import 'package:flutter_test/flutter_test.dart';
import 'package:pinball_bounce/core/constants.dart';

void main() {
  group('Score calculation', () {
    test('bumper hit score', () {
      const score = GameConstants.bumperHitScore;
      expect(score, equals(10));
    });

    test('target clear score', () {
      const score = GameConstants.targetClearScore;
      expect(score, equals(50));
    });

    test('combo multiplier increases score', () {
      const baseScore = GameConstants.bumperHitScore;
      const combo = 2.5;
      final scored = (baseScore * combo).round();
      expect(scored, equals(25));
    });

    test('combo multiplier is capped', () {
      double combo = 1.0;
      for (int i = 0; i < 20; i++) {
        combo = (combo + GameConstants.comboMultiplierStep)
            .clamp(1.0, GameConstants.maxComboMultiplier);
      }
      expect(combo, equals(GameConstants.maxComboMultiplier));
    });

    test('combo resets after timeout', () {
      // Combo window is 2 seconds
      const window = GameConstants.comboTimeWindow;
      expect(window, equals(2.0));

      // If last hit was more than 2 seconds ago, combo resets to 1.0
      const lastHitTime = 5.0;
      const currentTime = 8.0;
      final withinWindow = (currentTime - lastHitTime) < window;
      expect(withinWindow, isFalse);
    });

    test('combo builds within window', () {
      const lastHitTime = 5.0;
      const currentTime = 6.5;
      final withinWindow =
          (currentTime - lastHitTime) < GameConstants.comboTimeWindow;
      expect(withinWindow, isTrue);
    });
  });

  group('Game constants sanity checks', () {
    test('start lives is 3', () {
      expect(GameConstants.startLives, equals(3));
    });

    test('ball radius is positive', () {
      expect(GameConstants.ballRadius, greaterThan(0));
    });

    test('bumper radius is larger than ball radius', () {
      expect(GameConstants.bumperRadius, greaterThan(GameConstants.ballRadius));
    });

    test('flipper length is reasonable', () {
      expect(GameConstants.flipperLength, greaterThan(30));
      expect(GameConstants.flipperLength, lessThan(200));
    });

    test('restitution is between 0 and 1', () {
      expect(GameConstants.restitution, greaterThan(0));
      expect(GameConstants.restitution, lessThan(1));
    });

    test('bumper boost is greater than 1', () {
      expect(GameConstants.bumperBoost, greaterThan(1.0));
    });

    test('max ball speed is reasonable', () {
      expect(GameConstants.maxBallSpeed, greaterThan(GameConstants.launchSpeed));
    });
  });
}
