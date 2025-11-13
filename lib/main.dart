import 'dart:io';

import 'package:BookMyTeacher/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


import './routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ import
import 'data/datasources/local_data_source.dart';
import 'data/repositories/app_repository_impl.dart';
import 'domain/usecases/check_launch_status_usecase.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Import this
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    // Setting web contents debugging for InAppWebView (used by the YouTube player)
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

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

class MyApp extends StatelessWidget {
  // final CheckLaunchStatusUseCase useCase;
  // required this.useCase,
  const MyApp({ super.key});

  @override
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
