// import 'dart:io';
import 'dart:io' show Platform;
import 'package:BookMyTeacher/firebase_options.dart';
import 'package:BookMyTeacher/services/notification_service.dart';
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

import 'services/notification_service_helper.dart';

void main() async {
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  WidgetsFlutterBinding.ensureInitialized();
  // 🔔 Android Notification Settings
  // await AppNotificationService.initialize();
  // 🚫 Web must NEVER touch mobile notification code
  if (!kIsWeb) {
    await AppNotificationService.initialize();
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

  await Firebase.initializeApp();

  await NotificationServiceHelper.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



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

class MyApp extends StatefulWidget {
  // final CheckLaunchStatusUseCase useCase;
  // required this.useCase,
  const MyApp({ super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      if (message.notification != null) {

        NotificationServiceHelper.show(
          message.notification!.title ?? "",
          message.notification!.body ?? "",
        );

      }

    });

  }

  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        fontFamily: 'PetrovSans',
      ),
    );
  }
}
