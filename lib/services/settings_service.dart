import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static final Box _box = Hive.box('app_storage');

  static bool getBool(String key, {bool defaultValue = false}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  static Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }
}
