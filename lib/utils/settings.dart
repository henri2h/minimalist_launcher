import 'dart:convert';

import 'package:mylauncher/home_page.dart';

import 'storage_manager.dart';

class Settings {
  bool getFavorite(String appId, bool value) {
    return _settings[appId] ?? true;
  }

  static Future<void> setFavorite(String appId, bool value) async {
    await loadGuarded();
    if (value) {
      _settings[appId] = value;
    } else {
      _settings.remove(appId);
    }
    await saveData();
  }

  static Future<void> toggleFavorite(String packageName) async {
    await setFavorite(packageName, !_settings.containsKey(packageName));
  }

  static Map<String, dynamic> _settings = {};

  static Future<void> loadAllValues() async {
    _settings = jsonDecode(await StorageManager.readData("settings") ?? "{}");
  }

  static Future<void> saveData() async {
    StorageManager.saveData("settings", jsonEncode(_settings));
  }

  static bool _loaded = false;

  static Future<void> loadGuarded() async {
    if (!_loaded) {
      await loadAllValues();
      _loaded = true;
    }
  }

  Settings();

  static Future<List<Favorite>> getFavorites() async {
    await loadGuarded();
    return _settings.keys.map((e) => Favorite(id: e)).toList();
  }
}
