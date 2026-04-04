import 'package:equatable/equatable.dart';

class PlayerStats extends Equatable {
  /// Highest level reached.
  final int highestLevel;

  /// Total games played.
  final int gamesPlayed;

  /// High score (single game).
  final int highScore;

  /// Total score across all games.
  final int totalScore;

  /// Total bumper hits across all games.
  final int totalBumperHits;

  /// Total targets cleared across all games.
  final int totalTargetsCleared;

  /// Whether ads have been removed via IAP.
  final bool adsRemoved;

  const PlayerStats({
    this.highestLevel = 0,
    this.gamesPlayed = 0,
    this.highScore = 0,
    this.totalScore = 0,
    this.totalBumperHits = 0,
    this.totalTargetsCleared = 0,
    this.adsRemoved = false,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      highestLevel: json['highestLevel'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      highScore: json['highScore'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      totalBumperHits: json['totalBumperHits'] as int? ?? 0,
      totalTargetsCleared: json['totalTargetsCleared'] as int? ?? 0,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'highestLevel': highestLevel,
        'gamesPlayed': gamesPlayed,
        'highScore': highScore,
        'totalScore': totalScore,
        'totalBumperHits': totalBumperHits,
        'totalTargetsCleared': totalTargetsCleared,
        'adsRemoved': adsRemoved,
      };

  /// Record a completed game and return updated stats.
  PlayerStats withGameComplete({
    required int level,
    required int score,
    required int bumperHits,
    required int targetsCleared,
  }) {
    return PlayerStats(
      highestLevel: level > highestLevel ? level : highestLevel,
      gamesPlayed: gamesPlayed + 1,
      highScore: score > highScore ? score : highScore,
      totalScore: totalScore + score,
      totalBumperHits: totalBumperHits + bumperHits,
      totalTargetsCleared: totalTargetsCleared + targetsCleared,
      adsRemoved: adsRemoved,
    );
  }

  PlayerStats copyWith({
    int? highestLevel,
    int? gamesPlayed,
    int? highScore,
    int? totalScore,
    int? totalBumperHits,
    int? totalTargetsCleared,
    bool? adsRemoved,
  }) {
    return PlayerStats(
      highestLevel: highestLevel ?? this.highestLevel,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      highScore: highScore ?? this.highScore,
      totalScore: totalScore ?? this.totalScore,
      totalBumperHits: totalBumperHits ?? this.totalBumperHits,
      totalTargetsCleared: totalTargetsCleared ?? this.totalTargetsCleared,
      adsRemoved: adsRemoved ?? this.adsRemoved,
    );
  }

  @override
  List<Object?> get props => [
        highestLevel,
        gamesPlayed,
        highScore,
        totalScore,
        totalBumperHits,
        totalTargetsCleared,
        adsRemoved,
      ];
}
