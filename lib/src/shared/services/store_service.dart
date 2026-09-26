import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum Keys {
  themeMode,
  language,

  // No longer written: sign-in credentials used to be persisted in plain text
  email,
  password,
}

class StoreService {
  StoreService._(this._box);
  final Box _box;
  static StoreService? _instance;

  static Future<StoreService> instance() async {
    if (_instance != null) return _instance!;

    await Hive.initFlutter();
    Box box = await Hive.openBox('app');
    await box.deleteAll([Keys.email.name, Keys.password.name]);

    _instance = StoreService._(box);
    return _instance!;
  }

  // ------------------------------------
  // Settings
  // ------------------------------------
  String get themeMode => _box.get(Keys.themeMode.name, defaultValue: 'light');

  Future<void> putThemeMode(String mode) async {
    await _box.put(Keys.themeMode.name, mode);
  }

  String get language => _box.get(Keys.language.name, defaultValue: 'en');

  Future<void> putLanguage(String language) async {
    await _box.put(Keys.language.name, language);
  }

  // ------------------------------------
  // Test abilities
  // ------------------------------------

  @protected
  StoreService.init(this._box);

  @protected
  Box get box => _box;
}
