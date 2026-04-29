// import 'dart:io';
import 'dart:io' show Platform;
import 'package:BookMyTeacher/firebase_options.dart';
// import 'package:BookMyTeacher/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import './routes/router.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ import
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Import this
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/theme_provider.dart';
import 'services/notification_service_helper.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  NotificationServiceHelper.show(
    message.notification?.title ?? message.data['title'] ?? '',
    message.notification?.body ?? message.data['body'] ?? '',
  );
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Register BEFORE Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await Firebase.initializeApp();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  //
  // final FlutterLocalNotificationsPlugin _notifications =
  // FlutterLocalNotificationsPlugin();

  // const AndroidNotificationChannel channel =
  // AndroidNotificationChannel(
  //   'high_importance_channel',
  //   'High Importance Notifications',
  //   description: 'Used for important notifications.',
  //   importance: Importance.max,
  // );


// Create Android notification channel
//   final FlutterLocalNotificationsPlugin notifications =
//   FlutterLocalNotificationsPlugin();

  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // await notifications
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  await NotificationServiceHelper.init();

  // 🔔 Android Notification Settings
  // await AppNotificationService.initialize();
  // 🚫 Web must NEVER touch mobile notification code
  if (!kIsWeb) {
    // await AppNotificationService.initialize();
  }

  // InAppWebView debugging → Android only
  if (!kIsWeb && Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  // if (Platform.isAndroid) {
  //   // Setting web contents debugging for InAppWebView (used by the YouTube player)
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  // }

  // if (kIsWeb) {
  //   // Web-specific logic
  // } else if (Platform.isAndroid) {
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  //
  //   // Android logic
  // } else if (Platform.isIOS) {
  //   // iOS logic
  // }




  await Hive.initFlutter();

  // Open required Hive boxes
  final settingsBox = await Hive.openBox('settings');
  // final appDataBox = await Hive.openBox('app_data');
  final appStorage = await Hive.openBox('app_storage');

  // Check onboarding status
  bool hasSeen = settingsBox.get('hasSeenOnboarding', defaultValue: false);

  // Setup secure storage
  // final storage = FlutterSecureStorage();

  // Setup local data source and repository
  // final localDataSource = LocalDataSource(storage, appDataBox);
  // final appRepo = AppRepositoryImpl(localDataSource);
  // final useCase = CheckLaunchStatusUseCase(appRepo);


  runApp(
    ProviderScope(
      // ✅ wrap with ProviderScope
      // child: MyApp(useCase: useCase),
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  // final CheckLaunchStatusUseCase useCase;
  // required this.useCase,
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() =>
      _MyAppState();
}

class _MyAppState
    extends ConsumerState<MyApp> {

  @override

  @override
  void initState() {
    super.initState();



    // Foreground notifications
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {

        if (message.notification != null) {

          NotificationServiceHelper.show(
            message.notification!.title ?? '',
            message.notification!.body ?? '',
          );

        } else if (message.data.isNotEmpty) {

          NotificationServiceHelper.show(
            message.data['title'] ?? '',
            message.data['body'] ?? '',
          );

        }

      },
    );

  }

  // Widget build(BuildContext context) {
  //
  //   return MaterialApp.router(
  //     debugShowCheckedModeBanner: false,
  //     routerConfig: appRouter,
  //     theme: ThemeData(
  //       fontFamily: 'PetrovSans',
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {

    final themeMode =
    ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,

      themeMode: themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'PetrovSans',
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'PetrovSans',
      ),

    );
  }
}
