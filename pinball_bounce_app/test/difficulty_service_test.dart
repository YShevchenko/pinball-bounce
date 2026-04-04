import 'package:flutter_test/flutter_test.dart';
import 'package:pinball_bounce/core/constants.dart';
import 'package:pinball_bounce/domain/services/difficulty_service.dart';

void main() {
  late DifficultyService service;

  setUp(() {
    service = DifficultyService();
  });

  group('DifficultyService', () {
    test('ball speed increases with level', () {
      final speed1 = service.ballSpeedMultiplier(1);
      final speed10 = service.ballSpeedMultiplier(10);
      expect(speed10, greaterThan(speed1));
    });

    test('level 1 has default multiplier', () {
      expect(service.ballSpeedMultiplier(1), equals(1.0));
    });

    test('gravity increases with level', () {
      final gravity1 = service.gravityMultiplier(1);
      final gravity10 = service.gravityMultiplier(10);
      expect(gravity10, greaterThan(gravity1));
    });

    test('bumper count is within bounds', () {
      for (int level = 1; level <= 20; level++) {
        final count = service.bumperCount(level);
        expect(count, greaterThanOrEqualTo(GameConstants.minBumpers));
        expect(count, lessThanOrEqualTo(GameConstants.maxBumpers));
      }
    });

    test('target count is within bounds', () {
      for (int level = 1; level <= 20; level++) {
        final count = service.targetCount(level);
        expect(count, greaterThanOrEqualTo(GameConstants.minTargets));
        expect(count, lessThanOrEqualTo(GameConstants.maxTargets));
      }
    });

    test('no moving bumpers before level 5', () {
      expect(service.hasMovingBumpers(1), isFalse);
      expect(service.hasMovingBumpers(4), isFalse);
      expect(service.hasMovingBumpers(5), isTrue);
      expect(service.hasMovingBumpers(10), isTrue);
    });

    test('bumper move speed is zero before level 5', () {
      expect(service.bumperMoveSpeed(1), equals(0));
      expect(service.bumperMoveSpeed(4), equals(0));
      expect(service.bumperMoveSpeed(5), greaterThan(0));
    });
  });
}
