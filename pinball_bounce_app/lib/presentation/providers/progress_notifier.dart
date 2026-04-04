import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/player_stats.dart';
import '../../domain/repositories/progress_repository.dart';

class ProgressNotifier extends StateNotifier<PlayerStats> {
  final ProgressRepository _repo;

  ProgressNotifier(this._repo) : super(const PlayerStats());

  /// Load saved stats from persistent storage.
  Future<void> load() async {
    state = await _repo.load();
  }

  /// Record a completed game and persist.
  Future<void> completeGame({
    required int level,
    required int score,
    required int bumperHits,
    required int targetsCleared,
  }) async {
    state = state.withGameComplete(
      level: level,
      score: score,
      bumperHits: bumperHits,
      targetsCleared: targetsCleared,
    );
    await _repo.save(state);
  }

  /// Mark ads as removed (or re-enabled) and persist.
  Future<void> setAdsRemoved(bool removed) async {
    state = state.copyWith(adsRemoved: removed);
    await _repo.save(state);
  }

  /// Reset all progress and clear storage.
  Future<void> reset() async {
    state = const PlayerStats();
    await _repo.clear();
  }
}
