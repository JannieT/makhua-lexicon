import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../shared/services/analytics_service.dart';
import '../shared/services/service_locator.dart';
import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings,
/// update user settings, or listen to user settings changes.
class SettingsManager {
  SettingsManager(this._settingsService) {
    loadSettings();
  }

  final SettingsService _settingsService;

  final _themeModeSignal = Signal<ThemeMode>(ThemeMode.system);
  ThemeMode get themeMode => _themeModeSignal.value;

  final _languageSignal = Signal<String>('en');
  String get language => _languageSignal.value;

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeModeSignal.value) return;

    _themeModeSignal.value = newThemeMode;

    await _settingsService.updateThemeMode(newThemeMode);
    await get<AnalyticsService>().logSetting('themeMode', newThemeMode.name);
  }

  Future<void> updateLanguage(String newLanguage) async {
    if (newLanguage == _languageSignal.value) return;

    _languageSignal.value = newLanguage;

    await _settingsService.updateLanguage(newLanguage);
    await get<AnalyticsService>().logSetting('language', newLanguage);
  }

  Future<void> loadSettings() async {
    _themeModeSignal.value = await _settingsService.themeMode();
    _languageSignal.value = await _settingsService.language();
  }
}
