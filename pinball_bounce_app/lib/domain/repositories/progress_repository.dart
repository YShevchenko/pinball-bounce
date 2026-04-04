import '../models/player_stats.dart';

/// Abstract repository for persisting player progress.
abstract class ProgressRepository {
  Future<PlayerStats> load();
  Future<void> save(PlayerStats stats);
  Future<void> clear();
}
