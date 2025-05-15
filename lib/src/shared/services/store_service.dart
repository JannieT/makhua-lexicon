import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum Keys { themeMode, email, password }

class StoreService {
  StoreService._(this._box);
  final Box _box;
  static StoreService? _instance;

  static Future<StoreService> instance() async {
    if (_instance != null) return _instance!;

    await Hive.initFlutter();
    Box box = await Hive.openBox('app');

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

  // ------------------------------------
  // User Credentials
  // ------------------------------------
  String? get email => _box.get(Keys.email.name);

  String? get password => _box.get(Keys.password.name);

  Future<void> saveCredentials({required String email, required String password}) async {
    await _box.put(Keys.email.name, email);
    await _box.put(Keys.password.name, password);
  }

  Future<void> clearCredentials() async {
    await _box.delete(Keys.email.name);
    await _box.delete(Keys.password.name);
  }

  bool get hasCredentials => email != null && password != null;

  // ------------------------------------
  // Test abilities
  // ------------------------------------

  @protected
  StoreService.init(this._box);

  @protected
  Box get box => _box;
}
