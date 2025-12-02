import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/image_paths.dart';
import '../../core/enums/launch_status.dart';
import '../../routes/app_router.dart';
import '../../services/api_service.dart';
import '../../services/launch_status_service.dart';
import '../../services/update_service.dart';
import '../../services/user_check_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServer();
      // LaunchStatusService.resetApp();
      _initAndRedirect();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkServer() async {
    final api = ApiService();
    final isAlive = await api.checkServer();

    if (isAlive) {
      await _checkUser();
      return;
    } else {
      // 🔹 First check internet connection
      final hasConnection = await _hasInternetConnection();

      if (!hasConnection) {
        if (mounted) {
          context.go(AppRoutes.noNetwork);
        }
      } else {
        if (mounted) {
          context.go(AppRoutes.maintenance);
        }
      }
    }
  }

  Future<void> _checkUser() async {
    try {
      final box = Hive.box('app_storage');
      final userId = box.get('user_id');
      final userRole = box.get('user_role');
      // final referralCode = box.get('referral_code');

      if (userId == null) return;

      final isValid = await UserCheckService().isUserValid(
        userId.toString(),
        userRole,
      );

      if (!isValid) {
        // ✅ Check if widget is still mounted before using context
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found. Resetting app...")),
        );
      }
    } catch (e) {
      debugPrint("Error in _checkUser: $e");
    }
  }

  Future<void> _initAndRedirect() async {

    final box = await Hive.openBox('app_storage');
    final String? token = await LaunchStatusService.getAuthToken();
    if(token == null){
      context.go('/auth');
      return ;
    }
    await ref.read(userProvider.notifier).loadUser();
    final userState = ref.read(userProvider);
    final user2 = userState.value;
    final data = user2?.toJson();
    try {
      print("****");
      print(data);
      print("****");
      // Read current state
      final String? userId = box.get('user_id');

      if (data != null) {
        LaunchStatusService.saveUserData(data);
      }

      // final Map<String, dynamic>? storedUserData = await LaunchStatusService.getUserData();

      final storedUserData = await LaunchStatusService.getUserData();

      Map<String, dynamic>? userData;

      if (storedUserData != null && storedUserData['success'] == true) {
        userData = Map<String, dynamic>.from(storedUserData['data']);
      }

      print("****************************");
      print("auth Token :");
      print(token);
      print("****************************");
      print("storedUserData : ");
      print(storedUserData);
      print("****************************");

      // Check for app update
      if (!kIsWeb) {
        if (!mounted) return;
        final updateAvailable = await UpdateService.checkForUpdate(context);

        if (updateAvailable) return; // Stop navigation if update needed
      }

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return; // ✅ Check widget still in tree

      final status = await LaunchStatusService.getLaunchStatus();
      print(status);
      switch (status) {
        case LaunchStatus.firstTime:
          if (!mounted) return;
          context.go('/onboarding');
          return;

        case LaunchStatus.logged:
          if (!mounted) return;
          await _handleLoginFlow(token, userId, storedUserData, box);
          return;

        // call function
        case LaunchStatus.notLoggedIn:
          if (!mounted) return;
          await _handleLoginFlow(token, userId, storedUserData, box);
          return;

        // call function
        // if (!mounted) return;
        // context.go('/auth');
        // return;
      }
    } catch (e) {
      debugPrint("Error in _initAndRedirect: $e");
      if (!mounted) return;
      context.go('/auth'); // fallback
    }
  }

  /// 🔹 Handles login/session based redirection
  Future<void> _handleLoginFlow(
    String? token,
    String? userId,
    Map<String, dynamic>? storedUserData,
    Box box,
  ) async {
    Map<String, dynamic>? userData;

    if (token != null && storedUserData != null) {
      // final fetched = await UserCheckService().fetchUserData(token);
      // if (!mounted) return;
      // print("****************************");
      // print("fetched : ");
      // print(fetched);
      // print("****************************");
      // if (fetched != null) {
        userData = storedUserData;
      // } else {
      //   userData = storedUserData['data'];
      // }
    }
    // else if (userId != null) {
    //   final fetched = await UserCheckService().setUserToken(userId);
    //   if (!mounted) return;
    //
    //   if (fetched != null) {
    //     userData = fetched as Map<String, dynamic>?;
    //     await box.put('user_data', userData);
    //     await box.put('auth_token', userData?['token']);
    //   } else {
    //     if (!mounted) return;
    //     context.go('/auth');
    //     return;
    //   }
    // }
    else {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    //redirect to auth
    if (userData == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    final accType = userData['acc_type'] ?? 'guest';
    final profileFill = userData['profile_fill'] ?? 0;

    if (!mounted) return;

    if (profileFill == 1) {
      switch (accType) {
        case 'teacher':
          context.go('/teacher-dashboard');
          return;
        case 'student':
          context.go('/student-dashboard');
          return;
        case 'guest':
          context.go(
            '/guest-dashboard',
            extra: {'guestId': userData?['id'].toString()},
          );
          return;
        default:
          context.go('/error');
          return;
      }
    } else {
      context.go('/signup-stepper');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            isDark ? ImagePaths.appLogoWhite : ImagePaths.appLogoBlack,
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Future<bool> _hasInternetConnection() async {
    try {
      // Simple test: ping Google DNS
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}
