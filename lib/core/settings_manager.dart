import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ArcadeThemeMode { neon, paper }

class SettingsManager {
  static SettingsManager? _instance;
  static SettingsManager get instance => _instance ??= SettingsManager._();

  SettingsManager._();

  SharedPreferences? _prefs;

  final ValueNotifier<bool> soundEnabledNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<ArcadeThemeMode> themeModeNotifier =
      ValueNotifier<ArcadeThemeMode>(ArcadeThemeMode.neon);
  final ValueNotifier<bool> showTouchControlsNotifier =
      ValueNotifier<bool>(true);

  bool get soundEnabled => soundEnabledNotifier.value;
  ArcadeThemeMode get themeMode => themeModeNotifier.value;
  bool get showTouchControls => showTouchControlsNotifier.value;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    soundEnabledNotifier.value = _prefs?.getBool('sound_enabled') ?? true;
    final themeIndex = _prefs?.getInt('theme_mode') ?? 0;
    themeModeNotifier.value = ArcadeThemeMode.values[
        themeIndex.clamp(0, ArcadeThemeMode.values.length - 1)];
    showTouchControlsNotifier.value =
        _prefs?.getBool('show_touch_controls') ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    soundEnabledNotifier.value = enabled;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool('sound_enabled', enabled);
  }

  Future<void> toggleSound() async {
    await setSoundEnabled(!soundEnabled);
  }

  Future<void> setThemeMode(ArcadeThemeMode mode) async {
    themeModeNotifier.value = mode;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setInt('theme_mode', mode.index);
  }

  Future<void> setShowTouchControls(bool show) async {
    showTouchControlsNotifier.value = show;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool('show_touch_controls', show);
  }
}
