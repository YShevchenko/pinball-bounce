import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/flipper.dart';
import '../../domain/models/game_state.dart';

/// Renders the entire pinball table.
class TablePainter extends CustomPainter {
  final GameState gameState;

  TablePainter({required this.gameState});

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawGuideRails(canvas);
    _drawBumpers(canvas);
    _drawTargets(canvas);
    _drawFlippers(canvas);
    _drawParticles(canvas);
    _drawBallTrail(canvas);
    _drawBall(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Table border
    final borderPaint = Paint()
      ..color = AppColors.wallColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  void _drawGuideRails(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.wallColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.guideRailThickness
      ..strokeCap = StrokeCap.round;

    for (final rail in gameState.table.guideRails) {
      canvas.drawLine(
        Offset(rail.x1, rail.y1),
        Offset(rail.x2, rail.y2),
        paint,
      );
    }
  }

  void _drawBumpers(Canvas canvas) {
    for (final bumper in gameState.table.bumpers) {
      // Calculate actual position for moving bumpers
      final bx = bumper.isMoving
          ? bumper.x +
              sin(gameState.elapsedTime * bumper.moveSpeed) * bumper.moveRange
          : bumper.x;

      final isHit = bumper.isRecentlyHit(gameState.elapsedTime);
      final hitProgress = isHit
          ? 1.0 -
              ((gameState.elapsedTime - bumper.lastHitTime) / 0.3)
                  .clamp(0.0, 1.0)
          : 0.0;

      // Outer glow
      if (isHit) {
        final glowPaint = Paint()
          ..color = AppColors.bumperColor.withValues(alpha: 0.3 * hitProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawCircle(
          Offset(bx, bumper.y),
          bumper.radius + 10 * hitProgress,
          glowPaint,
        );
      }

      // Bumper body
      final bodyPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = isHit
            ? Color.lerp(
                AppColors.secondaryContainer, AppColors.bumperColor, hitProgress)!
            : AppColors.secondaryContainer;
      canvas.drawCircle(Offset(bx, bumper.y), bumper.radius, bodyPaint);

      // Bumper outline
      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = AppColors.bumperColor;
      canvas.drawCircle(Offset(bx, bumper.y), bumper.radius, outlinePaint);

      // Inner highlight
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.bumperColor.withValues(alpha: 0.3);
      canvas.drawCircle(
          Offset(bx - bumper.radius * 0.2, bumper.y - bumper.radius * 0.2),
          bumper.radius * 0.3,
          highlightPaint);
    }
  }

  void _drawTargets(Canvas canvas) {
    for (final target in gameState.table.targets) {
      if (target.isCleared) {
        // Cleared target — bright green with glow
        final clearProgress =
            ((gameState.elapsedTime - target.clearedTime) / 0.5)
                .clamp(0.0, 1.0);
        final alpha = 1.0 - clearProgress * 0.5;

        // Glow
        final glowPaint = Paint()
          ..color = AppColors.targetClearedColor.withValues(alpha: 0.4 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(
            Offset(target.x, target.y), target.radius + 8, glowPaint);

        // Body
        final bodyPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.targetClearedColor.withValues(alpha: alpha);
        canvas.drawCircle(Offset(target.x, target.y), target.radius, bodyPaint);

        // Check mark
        final checkPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = AppColors.background.withValues(alpha: alpha)
          ..strokeCap = StrokeCap.round;
        final cx = target.x;
        final cy = target.y;
        final r = target.radius * 0.4;
        canvas.drawLine(
          Offset(cx - r, cy),
          Offset(cx - r * 0.2, cy + r),
          checkPaint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.2, cy + r),
          Offset(cx + r, cy - r * 0.7),
          checkPaint,
        );
      } else {
        // Uncleared target — green outline, dimmer
        final outlinePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = AppColors.targetColor;
        canvas.drawCircle(
            Offset(target.x, target.y), target.radius, outlinePaint);

        // Inner fill
        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.targetColor.withValues(alpha: 0.15);
        canvas.drawCircle(
            Offset(target.x, target.y), target.radius, fillPaint);

        // Diamond shape inside
        final innerPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.targetColor.withValues(alpha: 0.5);
        final r = target.radius * 0.35;
        final path = Path()
          ..moveTo(target.x, target.y - r)
          ..lineTo(target.x + r, target.y)
          ..lineTo(target.x, target.y + r)
          ..lineTo(target.x - r, target.y)
          ..close();
        canvas.drawPath(path, innerPaint);
      }
    }
  }

  void _drawFlippers(Canvas canvas) {
    _drawFlipper(canvas, gameState.table.leftFlipper);
    _drawFlipper(canvas, gameState.table.rightFlipper);
  }

  void _drawFlipper(Canvas canvas, Flipper flipper) {
    final dir = flipper.side == FlipperSide.left ? 1.0 : -1.0;
    final tipX =
        flipper.anchorX + dir * flipper.length * cos(flipper.angle);
    final tipY = flipper.anchorY - flipper.length * sin(flipper.angle);

    // Draw flipper as a tapered line
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = flipper.width
      ..color = AppColors.flipperColor
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(flipper.anchorX, flipper.anchorY),
      Offset(tipX, tipY),
      paint,
    );

    // Pivot point
    final pivotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primary;
    canvas.drawCircle(
        Offset(flipper.anchorX, flipper.anchorY), 5.0, pivotPaint);
  }

  void _drawBallTrail(Canvas canvas) {
    final trail = gameState.ball.trail;
    if (trail.isEmpty) return;

    for (int i = 0; i < trail.length; i++) {
      final alpha = (1.0 - i / trail.length) * 0.4;
      final radius = gameState.ball.radius * (1.0 - i / trail.length) * 0.8;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.ballColor.withValues(alpha: alpha);
      canvas.drawCircle(trail[i], radius, paint);
    }
  }

  void _drawBall(Canvas canvas) {
    final ball = gameState.ball;

    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.ballColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(ball.x, ball.y), ball.radius + 4, glowPaint);

    // Ball body
    final bodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.ballColor;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, bodyPaint);

    // Highlight
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(
      Offset(ball.x - ball.radius * 0.25, ball.y - ball.radius * 0.25),
      ball.radius * 0.35,
      highlightPaint,
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final particle in gameState.particles) {
      final color = _particleColor(particle.colorIndex);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: particle.life * 0.8);
      final radius = 2.0 + particle.life * 3.0;
      canvas.drawCircle(Offset(particle.x, particle.y), radius, paint);
    }
  }

  Color _particleColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.secondary;
      case 2:
        return AppColors.tertiary;
      default:
        return AppColors.primary;
    }
  }

  @override
  bool shouldRepaint(covariant TablePainter oldDelegate) => true;
}
