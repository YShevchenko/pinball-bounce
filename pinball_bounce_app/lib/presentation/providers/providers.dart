import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/prefs_progress_repository.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/player_stats.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/physics_engine.dart';
import '../../domain/services/table_generator.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/iap_service.dart';
import 'game_notifier.dart';
import 'progress_notifier.dart';
import 'settings_notifier.dart';

// -- Foundation --

/// Must be overridden in main() via ProviderScope(overrides: [...]).
final sharedPrefsProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError(
    'sharedPrefsProvider must be overridden with an actual SharedPreferences '
    'instance before the app starts.',
  );
});

// -- Domain services --

final physicsEngineProvider = Provider<PhysicsEngine>((_) {
  return PhysicsEngine();
});

final tableGeneratorProvider = Provider<TableGenerator>((_) {
  return TableGenerator();
});

// -- Repositories --

final progressRepoProvider = Provider<ProgressRepository>((ref) {
  return PrefsProgressRepository(ref.watch(sharedPrefsProvider));
});

// -- Services --

final adServiceProvider = Provider<AdServiceBase>((_) {
  return AdService();
});

final iapServiceProvider = Provider<IAPServiceBase>((_) {
  return IAPService();
});

final audioServiceProvider = Provider<AudioService>((_) {
  return AudioService();
});

// -- State notifiers --

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    physicsEngine: ref.watch(physicsEngineProvider),
    tableGenerator: ref.watch(tableGeneratorProvider),
    adService: ref.watch(adServiceProvider),
    audioService: ref.watch(audioServiceProvider),
    ref: ref,
  );
});

final progressProvider =
    StateNotifierProvider<ProgressNotifier, PlayerStats>((ref) {
  return ProgressNotifier(ref.watch(progressRepoProvider));
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(sharedPrefsProvider));
});
