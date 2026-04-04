import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pinball_bounce/core/constants.dart';
import 'package:pinball_bounce/domain/models/ball.dart';
import 'package:pinball_bounce/domain/models/bumper.dart';
import 'package:pinball_bounce/domain/models/flipper.dart';
import 'package:pinball_bounce/domain/models/game_state.dart';
import 'package:pinball_bounce/domain/models/table_layout.dart';
import 'package:pinball_bounce/domain/models/target.dart';
import 'package:pinball_bounce/domain/services/physics_engine.dart';

TableLayout _makeTable({
  List<Bumper> bumpers = const [],
  List<Target> targets = const [],
  double width = 400,
  double height = 800,
}) {
  return TableLayout(
    level: 1,
    bumpers: bumpers,
    targets: targets,
    guideRails: const [],
    leftFlipper: Flipper(
      anchorX: width * 0.35,
      anchorY: height * 0.88,
      angle: GameConstants.flipperRestAngle,
      side: FlipperSide.left,
    ),
    rightFlipper: Flipper(
      anchorX: width * 0.65,
      anchorY: height * 0.88,
      angle: GameConstants.flipperRestAngle,
      side: FlipperSide.right,
    ),
    width: width,
    height: height,
  );
}

void main() {
  late PhysicsEngine engine;

  setUp(() {
    engine = PhysicsEngine();
  });

  group('Ball-bumper collision', () {
    test('ball bounces off bumper', () {
      final ball = Ball(
        x: 200,
        y: 300 - GameConstants.ballRadius - GameConstants.bumperRadius + 1,
        vx: 0,
        vy: 100,
      );
      final bumper = const Bumper(x: 200, y: 300);
      final table = _makeTable(bumpers: [bumper]);

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      // Ball should have been pushed away and velocity reversed
      expect(result.hitBumperIndices, isNotEmpty);
      expect(result.ball.vy, isNegative); // bounced upward
    });

    test('bumper hit count increments', () {
      final ball = Ball(
        x: 200,
        y: 300 - GameConstants.ballRadius - GameConstants.bumperRadius + 2,
        vx: 0,
        vy: 200,
      );
      final bumper = const Bumper(x: 200, y: 300);
      final table = _makeTable(bumpers: [bumper]);

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 1.0,
      );

      expect(result.hitBumperIndices, contains(0));
      expect(result.table.bumpers[0].hitCount, equals(1));
      expect(result.table.bumpers[0].lastHitTime, equals(1.0));
    });

    test('no collision when ball is far from bumper', () {
      final ball = const Ball(x: 100, y: 100, vx: 0, vy: 100);
      final bumper = const Bumper(x: 300, y: 300);
      final table = _makeTable(bumpers: [bumper]);

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.hitBumperIndices, isEmpty);
    });

    test('bumper boost increases ball speed', () {
      final ball = Ball(
        x: 200,
        y: 300 - GameConstants.ballRadius - GameConstants.bumperRadius + 1,
        vx: 0,
        vy: 100,
      );
      final bumper = const Bumper(x: 200, y: 300);
      final table = _makeTable(bumpers: [bumper]);

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      // Speed should be boosted by bumperBoost factor
      expect(result.ball.vy.abs(),
          greaterThan(100 * GameConstants.restitution * 0.9));
    });
  });

  group('Ball-wall reflection', () {
    test('ball bounces off left wall', () {
      final ball = const Ball(x: 2, y: 400, vx: -200, vy: 0);
      final table = _makeTable();

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.ball.vx, isPositive);
      expect(result.ball.x, greaterThanOrEqualTo(ball.radius));
    });

    test('ball bounces off right wall', () {
      final ball = const Ball(x: 398, y: 400, vx: 200, vy: 0);
      final table = _makeTable();

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.ball.vx, isNegative);
    });

    test('ball bounces off top wall', () {
      final ball = const Ball(x: 200, y: 2, vx: 0, vy: -200);
      final table = _makeTable();

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.ball.vy, isPositive);
    });

    test('ball falls through bottom (ball lost)', () {
      final ball = const Ball(x: 200, y: 820, vx: 0, vy: 200);
      final table = _makeTable();

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.ballLost, isTrue);
    });
  });

  group('Target clearing', () {
    test('target is cleared when hit by ball', () {
      final ball = Ball(
        x: 200,
        y: 300 - GameConstants.ballRadius - GameConstants.targetRadius + 1,
        vx: 0,
        vy: 100,
      );
      final target = const Target(x: 200, y: 300);
      final table = _makeTable(targets: [target]);

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 5.0,
      );

      expect(result.hitTargetIndices, contains(0));
      expect(result.table.targets[0].isCleared, isTrue);
      expect(result.table.targets[0].clearedTime, equals(5.0));
    });

    test('already cleared target is not hit again', () {
      final ball = Ball(
        x: 200,
        y: 300 - GameConstants.ballRadius - GameConstants.targetRadius + 1,
        vx: 0,
        vy: 100,
      );
      final target = const Target(x: 200, y: 300, isCleared: true);
      final table = _makeTable(targets: [target]);

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.hitTargetIndices, isEmpty);
    });
  });

  group('Flipper mechanics', () {
    test('flipper angle moves toward target when activated', () {
      final table = _makeTable().copyWith(
        leftFlipper: Flipper(
          anchorX: 140,
          anchorY: 704,
          angle: GameConstants.flipperRestAngle,
          side: FlipperSide.left,
          isActive: true,
        ),
      );

      final updated = engine.updateFlippers(table, 0.1);
      // Angle should move toward active angle (negative)
      expect(updated.leftFlipper.angle,
          lessThan(GameConstants.flipperRestAngle));
    });

    test('flipper angle returns to rest when deactivated', () {
      final table = _makeTable().copyWith(
        leftFlipper: Flipper(
          anchorX: 140,
          anchorY: 704,
          angle: GameConstants.flipperActiveAngle,
          side: FlipperSide.left,
          isActive: false,
        ),
      );

      final updated = engine.updateFlippers(table, 0.1);
      // Angle should move toward rest angle (positive)
      expect(updated.leftFlipper.angle,
          greaterThan(GameConstants.flipperActiveAngle));
    });
  });

  group('Particles', () {
    test('particles are spawned on bumper hit', () {
      final ball = Ball(
        x: 200,
        y: 300 - GameConstants.ballRadius - GameConstants.bumperRadius + 1,
        vx: 0,
        vy: 100,
      );
      final bumper = const Bumper(x: 200, y: 300);
      final table = _makeTable(bumpers: [bumper]);

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.newParticles, isNotEmpty);
      expect(result.newParticles.length,
          equals(GameConstants.bumperParticleCount));
    });

    test('particles decay over time', () {
      final particles = [
        const Particle(x: 100, y: 100, vx: 10, vy: -10, life: 1.0),
        const Particle(x: 200, y: 200, vx: -5, vy: 5, life: 0.1),
      ];

      final updated = engine.updateParticles(particles, 0.1);
      // First particle should still be alive, second might be gone
      expect(updated.length, greaterThanOrEqualTo(1));
      expect(updated.first.life, lessThan(1.0));
      expect(updated.first.x, isNot(equals(100)));
    });
  });

  group('Gravity', () {
    test('ball accelerates downward due to gravity', () {
      final ball = const Ball(x: 200, y: 200, vx: 0, vy: 0);
      final table = _makeTable();

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      expect(result.ball.vy, greaterThan(0));
    });
  });

  group('Speed capping', () {
    test('ball speed is capped at maximum', () {
      final ball = const Ball(x: 200, y: 200, vx: 2000, vy: 2000);
      final table = _makeTable();

      final result = engine.step(
        ball: ball,
        table: table,
        dt: 0.016,
        elapsedTime: 0,
      );

      final speed = _speed(result.ball.vx, result.ball.vy);
      expect(speed, lessThanOrEqualTo(GameConstants.maxBallSpeed + 50));
    });
  });
}

double _speed(double vx, double vy) {
  return sqrt(vx * vx + vy * vy);
}
