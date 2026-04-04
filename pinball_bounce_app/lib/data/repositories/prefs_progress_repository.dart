import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/player_stats.dart';
import '../../domain/repositories/progress_repository.dart';

class PrefsProgressRepository implements ProgressRepository {
  static const _key = 'pinball_bounce_player_stats';
  final SharedPreferences _prefs;

  PrefsProgressRepository(this._prefs);

  @override
  Future<PlayerStats> load() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return const PlayerStats();
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return PlayerStats.fromJson(json);
  }

  @override
  Future<void> save(PlayerStats stats) async {
    await _prefs.setString(_key, jsonEncode(stats.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
