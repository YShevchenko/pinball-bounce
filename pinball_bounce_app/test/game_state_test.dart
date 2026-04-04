import 'package:flutter_test/flutter_test.dart';
import 'package:pinball_bounce/core/constants.dart';
import 'package:pinball_bounce/domain/models/ball.dart';
import 'package:pinball_bounce/domain/models/bumper.dart';
import 'package:pinball_bounce/domain/models/flipper.dart';
import 'package:pinball_bounce/domain/models/game_state.dart';
import 'package:pinball_bounce/domain/models/table_layout.dart';
import 'package:pinball_bounce/domain/models/target.dart';

TableLayout _makeTable({
  List<Target> targets = const [],
  double width = 400,
  double height = 800,
}) {
  return TableLayout(
    level: 1,
    bumpers: const [],
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
  group('GameState', () {
    test('initial state is correct', () {
      final state = GameState(
        ball: const Ball(x: 200, y: 600),
        table: _makeTable(),
      );
      expect(state.score, equals(0));
      expect(state.lives, equals(3));
      expect(state.level, equals(1));
      expect(state.phase, equals(GamePhase.ready));
      expect(state.comboMultiplier, equals(1.0));
    });

    test('copyWith preserves unchanged fields', () {
      final state = GameState(
        ball: const Ball(x: 200, y: 600),
        table: _makeTable(),
        score: 500,
        lives: 2,
        level: 3,
      );
      final updated = state.copyWith(score: 600);
      expect(updated.score, equals(600));
      expect(updated.lives, equals(2));
      expect(updated.level, equals(3));
    });

    test('phase transitions', () {
      final state = GameState(
        ball: const Ball(x: 200, y: 600),
        table: _makeTable(),
        phase: GamePhase.ready,
      );

      final playing = state.copyWith(phase: GamePhase.playing);
      expect(playing.phase, equals(GamePhase.playing));

      final ballLost = playing.copyWith(phase: GamePhase.ballLost);
      expect(ballLost.phase, equals(GamePhase.ballLost));

      final gameOver = ballLost.copyWith(phase: GamePhase.gameOver);
      expect(gameOver.phase, equals(GamePhase.gameOver));
    });
  });

  group('TableLayout', () {
    test('remainingTargets counts uncleared targets', () {
      final table = _makeTable(targets: [
        const Target(x: 100, y: 200, isCleared: true),
        const Target(x: 200, y: 200, isCleared: false),
        const Target(x: 300, y: 200, isCleared: false),
      ]);
      expect(table.remainingTargets, equals(2));
    });

    test('allTargetsCleared is true when all cleared', () {
      final table = _makeTable(targets: [
        const Target(x: 100, y: 200, isCleared: true),
        const Target(x: 200, y: 200, isCleared: true),
      ]);
      expect(table.allTargetsCleared, isTrue);
    });

    test('allTargetsCleared is false when some remain', () {
      final table = _makeTable(targets: [
        const Target(x: 100, y: 200, isCleared: true),
        const Target(x: 200, y: 200, isCleared: false),
      ]);
      expect(table.allTargetsCleared, isFalse);
    });
  });

  group('Particle', () {
    test('copyWith works correctly', () {
      const p = Particle(x: 10, y: 20, vx: 1, vy: -1, life: 1.0);
      final updated = p.copyWith(life: 0.5, x: 15);
      expect(updated.x, equals(15));
      expect(updated.life, equals(0.5));
      expect(updated.y, equals(20));
    });
  });

  group('Bumper', () {
    test('isRecentlyHit returns true within window', () {
      const bumper = Bumper(x: 100, y: 200, lastHitTime: 5.0);
      expect(bumper.isRecentlyHit(5.1), isTrue);
      expect(bumper.isRecentlyHit(5.5), isFalse);
    });
  });

  group('Ball', () {
    test('trail is preserved through copyWith', () {
      final ball = const Ball(x: 100, y: 200).copyWith(
        trail: [const Offset(90, 190), const Offset(80, 180)],
      );
      expect(ball.trail.length, equals(2));
    });
  });
}
