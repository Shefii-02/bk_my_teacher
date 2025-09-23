import 'package:hive/hive.dart';
import '../core/enums/launch_status.dart';

class LaunchStatusService {
  static const String _boxName = 'app_storage';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _userRoleKey = 'user_role'; // 'student', 'teacher'
  static const String _userIdKey = 'user_id';
  static const String _lastVersionKey = 'last_version';
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  /// Gets the current launch status of the app.
  static Future<LaunchStatus> getLaunchStatus() async {
    final box = await Hive.openBox(_boxName);
    // await box.put(_isFirstLaunchKey, true);
    final isFirstLaunch = box.get(_isFirstLaunchKey, defaultValue: true);

    if (isFirstLaunch == true) {
      // Set first launch to false from now on
      await box.put(_isFirstLaunchKey, false);
      return LaunchStatus.firstTime;
    }

    final userRole = box.get(_userRoleKey);
    // print('***********');
    // print('Lauch Service');
    // print(userRole);
    // print('***********');
    if (userRole == 'student' || userRole == 'teacher' || userRole == 'guest') {
      return LaunchStatus.logged;
    } else {
      return LaunchStatus.notLoggedIn;
    }
  }

  /// For setting user role after login
  static Future<void> setUserRole(String role) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_userRoleKey, role);
  }

  static Future<void> getUserRole() async {
    final box = await Hive.openBox(_boxName);
    final userRole = box.get(_userRoleKey);
    return userRole;
  }

  /// For setting user role after login
  static Future<void> setUserId(String userId) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_userIdKey, userId);
  }

  static Future<void> getUserId() async {
    final box = await Hive.openBox(_boxName);
    final userId = box.get(_userIdKey);
    return userId;
  }

  static Future<void> setNewUpdate(String newUpdate) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_lastVersionKey, newUpdate);
  }

  static Future<void> getNewUpdate() async {
    final box = await Hive.openBox(_boxName);
    final newUpdate = box.get(_lastVersionKey);
    return newUpdate;
  }

  static Future<void> saveAuthToken(String token) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_authTokenKey, token);
    // await box.put('auth_token', token);
  }

  static Future<void> saveUserData(Map<String, dynamic> data) async {
    final box = await Hive.openBox(_boxName);
    // Store as Map<String, dynamic>
    await box.put(_userDataKey, Map<String, dynamic>.from(data));
    // await box.put('user_data', data);
  }

  static Future<String?> getAuthToken() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_authTokenKey);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_userDataKey);

    if (stored is Map) {
      return Map<String, dynamic>.from(stored); // Convert safely
    }
    return null;
  }

  /// Optional: Use to reset app (e.g. during logout or testing)
  static Future<void> resetApp() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
