import 'package:flutter_test/flutter_test.dart';
import 'package:pinball_bounce/domain/models/player_stats.dart';

void main() {
  group('PlayerStats', () {
    test('default values', () {
      const stats = PlayerStats();
      expect(stats.highestLevel, equals(0));
      expect(stats.gamesPlayed, equals(0));
      expect(stats.highScore, equals(0));
      expect(stats.totalScore, equals(0));
      expect(stats.totalBumperHits, equals(0));
      expect(stats.totalTargetsCleared, equals(0));
      expect(stats.adsRemoved, isFalse);
    });

    test('withGameComplete updates correctly', () {
      const stats = PlayerStats();
      final updated = stats.withGameComplete(
        level: 3,
        score: 500,
        bumperHits: 10,
        targetsCleared: 4,
      );
      expect(updated.highestLevel, equals(3));
      expect(updated.gamesPlayed, equals(1));
      expect(updated.highScore, equals(500));
      expect(updated.totalScore, equals(500));
      expect(updated.totalBumperHits, equals(10));
      expect(updated.totalTargetsCleared, equals(4));
    });

    test('withGameComplete preserves high score', () {
      final stats = const PlayerStats().withGameComplete(
        level: 5,
        score: 1000,
        bumperHits: 20,
        targetsCleared: 8,
      );
      final updated = stats.withGameComplete(
        level: 3,
        score: 500,
        bumperHits: 5,
        targetsCleared: 3,
      );
      expect(updated.highScore, equals(1000));
      expect(updated.highestLevel, equals(5));
      expect(updated.gamesPlayed, equals(2));
      expect(updated.totalScore, equals(1500));
    });

    test('withGameComplete updates high score when beaten', () {
      final stats = const PlayerStats().withGameComplete(
        level: 3,
        score: 500,
        bumperHits: 10,
        targetsCleared: 4,
      );
      final updated = stats.withGameComplete(
        level: 7,
        score: 2000,
        bumperHits: 30,
        targetsCleared: 12,
      );
      expect(updated.highScore, equals(2000));
      expect(updated.highestLevel, equals(7));
    });

    test('JSON serialization round-trip', () {
      const stats = PlayerStats(
        highestLevel: 5,
        gamesPlayed: 10,
        highScore: 1500,
        totalScore: 5000,
        totalBumperHits: 100,
        totalTargetsCleared: 40,
        adsRemoved: true,
      );
      final json = stats.toJson();
      final restored = PlayerStats.fromJson(json);
      expect(restored, equals(stats));
    });

    test('JSON deserialization handles missing fields', () {
      final stats = PlayerStats.fromJson({});
      expect(stats.highestLevel, equals(0));
      expect(stats.gamesPlayed, equals(0));
      expect(stats.highScore, equals(0));
      expect(stats.adsRemoved, isFalse);
    });

    test('copyWith works correctly', () {
      const stats = PlayerStats(highScore: 100);
      final updated = stats.copyWith(adsRemoved: true);
      expect(updated.highScore, equals(100));
      expect(updated.adsRemoved, isTrue);
    });

    test('equatable comparison works', () {
      const a = PlayerStats(highScore: 100, gamesPlayed: 5);
      const b = PlayerStats(highScore: 100, gamesPlayed: 5);
      const c = PlayerStats(highScore: 200, gamesPlayed: 5);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
