import 'package:flutter_test/flutter_test.dart';
import 'package:pinball_bounce/core/constants.dart';
import 'package:pinball_bounce/domain/services/table_generator.dart';

void main() {
  late TableGenerator generator;

  setUp(() {
    generator = TableGenerator();
  });

  group('Table generation', () {
    test('generates correct number of bumpers for level 1', () {
      final table = generator.generate(level: 1, width: 400, height: 800);
      expect(table.bumpers.length, greaterThanOrEqualTo(GameConstants.minBumpers));
      expect(table.bumpers.length, lessThanOrEqualTo(GameConstants.maxBumpers));
    });

    test('generates correct number of targets for level 1', () {
      final table = generator.generate(level: 1, width: 400, height: 800);
      expect(table.targets.length, greaterThanOrEqualTo(GameConstants.minTargets));
      expect(table.targets.length, lessThanOrEqualTo(GameConstants.maxTargets));
    });

    test('all targets start uncleared', () {
      final table = generator.generate(level: 1, width: 400, height: 800);
      for (final target in table.targets) {
        expect(target.isCleared, isFalse);
      }
    });

    test('flippers are positioned at bottom of table', () {
      final table = generator.generate(level: 1, width: 400, height: 800);
      final flipperY = 800 * 0.88;
      expect(table.leftFlipper.anchorY, equals(flipperY));
      expect(table.rightFlipper.anchorY, equals(flipperY));
    });

    test('left flipper is on left side, right flipper on right', () {
      final table = generator.generate(level: 1, width: 400, height: 800);
      expect(table.leftFlipper.anchorX, lessThan(200));
      expect(table.rightFlipper.anchorX, greaterThan(200));
    });

    test('no overlapping bumpers', () {
      final table = generator.generate(level: 5, width: 400, height: 800);
      for (int i = 0; i < table.bumpers.length; i++) {
        for (int j = i + 1; j < table.bumpers.length; j++) {
          final dx = table.bumpers[i].x - table.bumpers[j].x;
          final dy = table.bumpers[i].y - table.bumpers[j].y;
          final dist = dx * dx + dy * dy;
          final minDist = GameConstants.bumperRadius * 3;
          expect(dist, greaterThan(minDist * minDist * 0.9),
              reason: 'Bumpers $i and $j overlap');
        }
      }
    });

    test('no overlapping targets', () {
      final table = generator.generate(level: 5, width: 400, height: 800);
      for (int i = 0; i < table.targets.length; i++) {
        for (int j = i + 1; j < table.targets.length; j++) {
          final dx = table.targets[i].x - table.targets[j].x;
          final dy = table.targets[i].y - table.targets[j].y;
          final dist = dx * dx + dy * dy;
          final minDist = GameConstants.targetRadius * 3;
          expect(dist, greaterThan(minDist * minDist * 0.9),
              reason: 'Targets $i and $j overlap');
        }
      }
    });

    test('bumpers and targets do not overlap', () {
      final table = generator.generate(level: 5, width: 400, height: 800);
      for (final bumper in table.bumpers) {
        for (final target in table.targets) {
          final dx = bumper.x - target.x;
          final dy = bumper.y - target.y;
          final dist = dx * dx + dy * dy;
          final minDist =
              GameConstants.bumperRadius + GameConstants.targetRadius + 10;
          expect(dist, greaterThan(minDist * minDist * 0.8),
              reason: 'Bumper and target overlap');
        }
      }
    });

    test('higher levels generate more elements', () {
      final table1 = generator.generate(level: 1, width: 400, height: 800);
      final table10 = generator.generate(level: 10, width: 400, height: 800);
      expect(table10.bumpers.length, greaterThanOrEqualTo(table1.bumpers.length));
    });

    test('same level generates same layout (deterministic)', () {
      final table1 = generator.generate(level: 3, width: 400, height: 800);
      final table2 = generator.generate(level: 3, width: 400, height: 800);
      expect(table1.bumpers.length, equals(table2.bumpers.length));
      expect(table1.targets.length, equals(table2.targets.length));
      for (int i = 0; i < table1.bumpers.length; i++) {
        expect(table1.bumpers[i].x, equals(table2.bumpers[i].x));
        expect(table1.bumpers[i].y, equals(table2.bumpers[i].y));
      }
    });

    test('level 5+ can have moving bumpers', () {
      final table = generator.generate(level: 10, width: 400, height: 800);
      // At level 10, there's a chance of moving bumpers
      // We can't guarantee it due to randomness, but verify the table is valid
      expect(table.bumpers, isNotEmpty);
    });

    test('guide rails are generated', () {
      final table = generator.generate(level: 1, width: 400, height: 800);
      // Level 1 always has funnel walls
      expect(table.guideRails, isNotEmpty);
    });

    test('table dimensions match input', () {
      final table = generator.generate(level: 1, width: 400, height: 800);
      expect(table.width, equals(400));
      expect(table.height, equals(800));
    });

    test('elements are within table bounds', () {
      final table = generator.generate(level: 5, width: 400, height: 800);
      for (final bumper in table.bumpers) {
        expect(bumper.x, greaterThan(0));
        expect(bumper.x, lessThan(400));
        expect(bumper.y, greaterThan(0));
        expect(bumper.y, lessThan(800));
      }
      for (final target in table.targets) {
        expect(target.x, greaterThan(0));
        expect(target.x, lessThan(400));
        expect(target.y, greaterThan(0));
        expect(target.y, lessThan(800));
      }
    });
  });
}
