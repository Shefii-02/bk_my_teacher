import 'package:hive/hive.dart';
import '../core/enums/launch_status.dart';

class LaunchStatusService {
  static const String _boxName = 'app_storage';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _userRoleKey = 'user_role'; // 'student', 'teacher'

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
    if (userRole == 'student' || userRole == 'teacher') {
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

  /// Optional: Use to reset app (e.g. during logout or testing)
  static Future<void> resetApp() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }

}
