import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceHelper {

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future init() async {

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);
  }

  /// 🔔 Show Notification
  static Future show(String title, String body) async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id:  DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title:  title,
      body:  body,
     notificationDetails:  details,
    );
  }
}