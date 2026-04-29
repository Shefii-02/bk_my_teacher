import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceHelper {

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const String channelId =
      'high_importance_channel';

  static const String channelName =
      'High Importance Notifications';


  static Future<void> init() async {

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings,
    );

    // Android 8+ notification channel
    const AndroidNotificationChannel channel =
    AndroidNotificationChannel(
      channelId,
      channelName,
      description:
      'Used for important notifications',
      importance: Importance.max,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      channel,
    );
  }


  static Future<void> show(
      String title,
      String body,
      ) async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      channelId,
      channelName,

      channelDescription:
      'Used for important notifications',

      importance: Importance.max,
      priority: Priority.high,

      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails();

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id :DateTime.now()
          .millisecondsSinceEpoch ~/
          1000,
      title:  title,
      body:  body,
      notificationDetails: details,
    );
  }
}