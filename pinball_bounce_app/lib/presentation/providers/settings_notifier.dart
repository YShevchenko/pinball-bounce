import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable settings state.
class SettingsState extends Equatable {
  final bool soundEnabled;
  final bool hapticEnabled;
  final String locale;

  const SettingsState({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.locale = 'en',
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    String? locale,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [soundEnabled, hapticEnabled, locale];
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _soundKey = 'settings_sound';
  static const _hapticKey = 'settings_haptic';
  static const _localeKey = 'settings_locale';

  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(SettingsState(
          soundEnabled: _prefs.getBool(_soundKey) ?? true,
          hapticEnabled: _prefs.getBool(_hapticKey) ?? true,
          locale: _prefs.getString(_localeKey) ?? 'en',
        ));

  void toggleSound() {
    final updated = state.copyWith(soundEnabled: !state.soundEnabled);
    state = updated;
    _prefs.setBool(_soundKey, updated.soundEnabled);
  }

  void toggleHaptic() {
    final updated = state.copyWith(hapticEnabled: !state.hapticEnabled);
    state = updated;
    _prefs.setBool(_hapticKey, updated.hapticEnabled);
  }

  void setLocale(String locale) {
    final updated = state.copyWith(locale: locale);
    state = updated;
    _prefs.setString(_localeKey, updated.locale);
  }
}
