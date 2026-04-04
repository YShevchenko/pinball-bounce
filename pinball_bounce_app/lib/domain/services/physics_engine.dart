import 'dart:math';
import 'dart:ui';

import '../../core/constants.dart';
import '../models/ball.dart';
import '../models/bumper.dart';
import '../models/flipper.dart';
import '../models/game_state.dart';
import '../models/table_layout.dart';
import '../models/target.dart';

/// Result of a physics step.
class PhysicsResult {
  final Ball ball;
  final TableLayout table;
  final List<int> hitBumperIndices;
  final List<int> hitTargetIndices;
  final bool ballLost;
  final List<Particle> newParticles;

  const PhysicsResult({
    required this.ball,
    required this.table,
    this.hitBumperIndices = const [],
    this.hitTargetIndices = const [],
    this.ballLost = false,
    this.newParticles = const [],
  });
}

/// Simple 2D physics for the pinball game.
class PhysicsEngine {
  final Random _random = Random();

  /// Update ball position and check collisions for one frame.
  PhysicsResult step({
    required Ball ball,
    required TableLayout table,
    required double dt,
    required double elapsedTime,
  }) {
    // Apply gravity
    double newVx = ball.vx;
    double newVy = ball.vy + GameConstants.gravity * dt;

    // Update position
    double newX = ball.x + newVx * dt;
    double newY = ball.y + newVy * dt;

    // Cap speed
    final speed = sqrt(newVx * newVx + newVy * newVy);
    if (speed > GameConstants.maxBallSpeed) {
      final scale = GameConstants.maxBallSpeed / speed;
      newVx *= scale;
      newVy *= scale;
    }

    // Update trail
    final trail = [
      Offset(ball.x, ball.y),
      ...ball.trail,
    ];
    final clampedTrail = trail.length > GameConstants.ballTrailLength
        ? trail.sublist(0, GameConstants.ballTrailLength)
        : trail;

    Ball updatedBall = ball.copyWith(
      x: newX,
      y: newY,
      vx: newVx,
      vy: newVy,
      trail: clampedTrail,
    );

    final hitBumpers = <int>[];
    final hitTargets = <int>[];
    final newParticles = <Particle>[];
    List<Bumper> updatedBumpers = List.from(table.bumpers);
    List<Target> updatedTargets = List.from(table.targets);

    // Wall collisions
    updatedBall = _handleWallCollisions(updatedBall, table.width, table.height);

    // Bumper collisions
    for (int i = 0; i < updatedBumpers.length; i++) {
      final bumper = updatedBumpers[i];
      // For moving bumpers, calculate current position
      final bx = bumper.isMoving
          ? bumper.x + sin(elapsedTime * bumper.moveSpeed) * bumper.moveRange
          : bumper.x;

      final result = _checkCircleCollision(
        updatedBall.x,
        updatedBall.y,
        updatedBall.radius,
        updatedBall.vx,
        updatedBall.vy,
        bx,
        bumper.y,
        bumper.radius,
      );
      if (result != null) {
        updatedBall = updatedBall.copyWith(
          x: result.x,
          y: result.y,
          vx: result.vx * GameConstants.bumperBoost,
          vy: result.vy * GameConstants.bumperBoost,
        );
        updatedBumpers[i] = bumper.copyWith(
          hitCount: bumper.hitCount + 1,
          lastHitTime: elapsedTime,
        );
        hitBumpers.add(i);

        // Spawn particles at collision point
        newParticles.addAll(_spawnParticles(
          bx,
          bumper.y,
          GameConstants.bumperParticleCount,
          1, // secondary color
        ));
      }
    }

    // Target collisions
    for (int i = 0; i < updatedTargets.length; i++) {
      final target = updatedTargets[i];
      if (target.isCleared) continue;

      final result = _checkCircleCollision(
        updatedBall.x,
        updatedBall.y,
        updatedBall.radius,
        updatedBall.vx,
        updatedBall.vy,
        target.x,
        target.y,
        target.radius,
      );
      if (result != null) {
        updatedBall = updatedBall.copyWith(
          x: result.x,
          y: result.y,
          vx: result.vx,
          vy: result.vy,
        );
        updatedTargets[i] = target.copyWith(
          isCleared: true,
          clearedTime: elapsedTime,
        );
        hitTargets.add(i);

        // Spawn particles at target
        newParticles.addAll(_spawnParticles(
          target.x,
          target.y,
          GameConstants.targetParticleCount,
          2, // tertiary color
        ));
      }
    }

    // Flipper collisions
    final leftResult = _checkFlipperCollision(
      updatedBall,
      table.leftFlipper,
    );
    if (leftResult != null) {
      updatedBall = leftResult;
    }

    final rightResult = _checkFlipperCollision(
      updatedBall,
      table.rightFlipper,
    );
    if (rightResult != null) {
      updatedBall = rightResult;
    }

    // Guide rail collisions
    for (final rail in table.guideRails) {
      final railResult = _checkLineCollision(
        updatedBall, rail.x1, rail.y1, rail.x2, rail.y2);
      if (railResult != null) {
        updatedBall = railResult;
      }
    }

    // Check if ball fell below flippers
    final floorY = table.height + ball.radius * 2;
    final ballLost = updatedBall.y > floorY;

    final updatedTable = table.copyWith(
      bumpers: updatedBumpers,
      targets: updatedTargets,
    );

    return PhysicsResult(
      ball: updatedBall,
      table: updatedTable,
      hitBumperIndices: hitBumpers,
      hitTargetIndices: hitTargets,
      ballLost: ballLost,
      newParticles: newParticles,
    );
  }

  /// Update flipper angles based on activation state.
  TableLayout updateFlippers(TableLayout table, double dt) {
    final leftAngle = _moveAngleTowards(
      table.leftFlipper.angle,
      table.leftFlipper.targetAngle,
      GameConstants.flipperAngularSpeed * dt,
    );
    final rightAngle = _moveAngleTowards(
      table.rightFlipper.angle,
      table.rightFlipper.targetAngle,
      GameConstants.flipperAngularSpeed * dt,
    );
    return table.copyWith(
      leftFlipper: table.leftFlipper.copyWith(angle: leftAngle),
      rightFlipper: table.rightFlipper.copyWith(angle: rightAngle),
    );
  }

  /// Update particle positions and lifetimes.
  List<Particle> updateParticles(List<Particle> particles, double dt) {
    final updated = <Particle>[];
    for (final p in particles) {
      final newLife = p.life - dt * 2.0; // particles last ~0.5s
      if (newLife > 0) {
        updated.add(p.copyWith(
          x: p.x + p.vx * dt,
          y: p.y + p.vy * dt,
          vy: p.vy + GameConstants.gravity * 0.3 * dt,
          life: newLife,
        ));
      }
    }
    return updated;
  }

  // --- Private helpers ---

  Ball _handleWallCollisions(Ball ball, double tableWidth, double tableHeight) {
    double x = ball.x;
    double y = ball.y;
    double vx = ball.vx;
    double vy = ball.vy;

    // Left wall
    if (x - ball.radius < 0) {
      x = ball.radius;
      vx = -vx * GameConstants.restitution;
    }
    // Right wall
    if (x + ball.radius > tableWidth) {
      x = tableWidth - ball.radius;
      vx = -vx * GameConstants.restitution;
    }
    // Top wall
    if (y - ball.radius < 0) {
      y = ball.radius;
      vy = -vy * GameConstants.restitution;
    }
    // No bottom wall — ball can fall through

    return ball.copyWith(x: x, y: y, vx: vx, vy: vy);
  }

  /// Circle-circle collision detection and response.
  /// Returns new ball state if collision occurred, null otherwise.
  _CollisionResult? _checkCircleCollision(
    double bx,
    double by,
    double bRadius,
    double bvx,
    double bvy,
    double cx,
    double cy,
    double cRadius,
  ) {
    final dx = bx - cx;
    final dy = by - cy;
    final dist = sqrt(dx * dx + dy * dy);
    final minDist = bRadius + cRadius;

    if (dist >= minDist || dist == 0) return null;

    // Normalize collision normal
    final nx = dx / dist;
    final ny = dy / dist;

    // Separate ball from bumper
    final overlap = minDist - dist;
    final newX = bx + nx * overlap;
    final newY = by + ny * overlap;

    // Reflect velocity
    final dot = bvx * nx + bvy * ny;
    final newVx = bvx - 2 * dot * nx;
    final newVy = bvy - 2 * dot * ny;

    return _CollisionResult(
      x: newX,
      y: newY,
      vx: newVx * GameConstants.restitution,
      vy: newVy * GameConstants.restitution,
    );
  }

  /// Check ball collision with a flipper (treated as a line segment).
  Ball? _checkFlipperCollision(Ball ball, Flipper flipper) {
    final dir = flipper.side == FlipperSide.left ? 1.0 : -1.0;
    final ax = flipper.anchorX;
    final ay = flipper.anchorY;
    final tipX = ax + dir * flipper.length * cos(flipper.angle);
    final tipY = ay - flipper.length * sin(flipper.angle);

    final result = _checkLineCollision(ball, ax, ay, tipX, tipY);
    if (result != null) {
      // If flipper is activating, add extra upward force
      if (flipper.isActive) {
        final boost = GameConstants.flipperHitForce;
        final angleBoost = flipper.side == FlipperSide.left ? 0.3 : -0.3;
        return result.copyWith(
          vx: result.vx + boost * angleBoost,
          vy: -boost.abs(),
        );
      }
      return result;
    }
    return null;
  }

  /// Check ball collision with a line segment.
  Ball? _checkLineCollision(
    Ball ball,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return null;

    // Line direction and normal
    final ldx = dx / len;
    final ldy = dy / len;
    final nx = -ldy;
    final ny = ldx;

    // Vector from line start to ball center
    final bx = ball.x - x1;
    final by = ball.y - y1;

    // Project ball onto line
    final projection = bx * ldx + by * ldy;
    final distance = bx * nx + by * ny;

    // Check if ball is close enough and within segment bounds
    final halfWidth = GameConstants.flipperWidth / 2 + ball.radius;
    if (distance.abs() > halfWidth) return null;
    if (projection < -ball.radius || projection > len + ball.radius) {
      return null;
    }

    // Ball is colliding with the line
    final sign = distance >= 0 ? 1.0 : -1.0;
    final pushOut = halfWidth - distance.abs();

    final newX = ball.x + nx * sign * pushOut;
    final newY = ball.y + ny * sign * pushOut;

    // Reflect velocity off the line normal
    final dot = ball.vx * nx * sign + ball.vy * ny * sign;
    if (dot >= 0) return null; // Moving away

    final newVx = (ball.vx - 2 * dot * nx * sign) * GameConstants.restitution;
    final newVy = (ball.vy - 2 * dot * ny * sign) * GameConstants.restitution;

    return ball.copyWith(x: newX, y: newY, vx: newVx, vy: newVy);
  }

  double _moveAngleTowards(double current, double target, double maxDelta) {
    final diff = target - current;
    if (diff.abs() <= maxDelta) return target;
    return current + maxDelta * diff.sign;
  }

  List<Particle> _spawnParticles(
    double x,
    double y,
    int count,
    int colorIndex,
  ) {
    final particles = <Particle>[];
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50.0 + _random.nextDouble() * 150.0;
      particles.add(Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: 0.8 + _random.nextDouble() * 0.2,
        colorIndex: colorIndex,
      ));
    }
    return particles;
  }
}

class _CollisionResult {
  final double x;
  final double y;
  final double vx;
  final double vy;

  const _CollisionResult({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });
}
