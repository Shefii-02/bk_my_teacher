import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

class AppNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // ------------------------------
  // INITIALIZE (Call in main.dart)
  // ------------------------------
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS (REQUIRED)
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined settings
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // const InitializationSettings initializationSettings =
    // InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;

        if (payload != null && payload.isNotEmpty) {
          // If payload is a file path → open file
          if (payload.endsWith(".pdf")) {
            OpenFilex.open(payload);
          }
        }
      },
    );



    // 👇 iOS permission request (THIS IS THE RIGHT PLACE)
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ------------------------------
  // COMMON NOTIFICATION METHOD
  // ------------------------------
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload, // optional → open a file or pass any data
  }) async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      channelDescription: 'App alerts and updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
      title,
      body,
      details,
      payload: payload,
    );
  }
}
