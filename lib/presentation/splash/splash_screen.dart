import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:dio/dio.dart';
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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
    final api = ApiService(); // or ref.read in Riverpod
    final isAlive = await api.checkServer();

    if (isAlive) {
      return;
    } else {
      if (mounted) {
        context.go(AppRoutes.maintenance);
      }
    }
  }
  // Future<void> _checkServer() async {
  //   try {
  //     final response = await _dio.get(Endpoints.checkServer);
  //
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       if (data is Map && data['status'] == "development") {
  //         // 🚨 Maintenance mode
  //         if (mounted) {
  //           context.go(AppRoutes.maintenance);
  //         }
  //       } else {
  //         // ✅ Server OK → Go to Home/Login
  //         return;
  //       }
  //     } else {
  //       // 🚨 Bad response → Maintenance
  //       if (mounted) {
  //         context.go(AppRoutes.maintenance);
  //       }
  //     }
  //   } on DioException catch (_) {
  //     // 🚨 API call failed → Maintenance
  //     if (mounted) {
  //       context.go(AppRoutes.maintenance);
  //     }
  //   } catch (e) {
  //     // 🚨 Any other error
  //     if (mounted) {
  //       context.go(AppRoutes.maintenance);
  //     }
  //   }
  // }

  /// Check if stored user is valid
  // Future<void> _checkUser() async {
  //   try {
  //     final box = Hive.box('app_storage');
  //     final userId = box.get('user_id');
  //     final userRole = box.get('user_role');
  //
  //     if (userId == null) return;
  //
  //     final isValid = await UserCheckService().isUserValid(userId, userRole);
  //     if (!isValid) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("User not found. Resetting app...")),
  //       );
  //       await LaunchStatusService.resetApp();
  //     }
  //   } catch (e) {
  //     debugPrint("Error in _checkUser: $e");
  //   }
  // }
  Future<void> _checkUser() async {
    try {
      final box = Hive.box('app_storage');
      final userId = box.get('user_id');
      final userRole = box.get('user_role');

      if (userId == null) return;

      final isValid = await UserCheckService().isUserValid(userId.toString(), userRole);

      if (!isValid) {
        // ✅ Check if widget is still mounted before using context
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found. Resetting app...")),
        );

        await LaunchStatusService.resetApp();
      }
    } catch (e) {
      debugPrint("Error in _checkUser: $e");
    }
  }

  /// Main initialization and redirection
  // Future<void> _initAndRedirect() async {
  //   try {
  //     await _checkUser();
  //
  //     final box = await Hive.openBox('app_storage');
  //     final String? token = box.get('auth_token');
  //     final Map<String, dynamic>? storedUserData = box.get('user_data');
  //
  //     // Check for app update
  //     if (!kIsWeb) {
  //       final updateAvailable = await UpdateService.checkForUpdate(context);
  //       if (updateAvailable) return; // Stop navigation if update needed
  //     }
  //
  //     await Future.delayed(const Duration(seconds: 1));
  //
  //     final status = await LaunchStatusService.getLaunchStatus();
  //
  //     switch (status) {
  //       case LaunchStatus.firstTime:
  //         context.go('/onboarding');
  //         return;
  //
  //       case LaunchStatus.logged:
  //         Map<String, dynamic>? userData;
  //
  //         if (token != null && storedUserData != null) {
  //           // Optional: refresh from backend
  //           final fetched = await UserCheckService().fetchUserData(token);
  //           if (fetched != null) {
  //             userData = fetched;
  //             await box.put('user_data', userData);
  //             await box.put('auth_token', userData['token']);
  //           } else {
  //             userData = storedUserData;
  //           }
  //         } else {
  //           context.go('/auth');
  //           return;
  //         }
  //
  //         final accType = userData['acc_type'] ?? 'guest';
  //         final profileFill = userData['profile_fill'] ?? 0;
  //
  //         // Redirect based on account type and profile fill
  //         if (profileFill == 1) {
  //           if (accType == 'teacher') {
  //             context.go('/teacher-dashboard',
  //                 extra: {'teacherId': userData['id'].toString()});
  //             return;
  //           } else if (accType == 'student') {
  //             context.go('/student-dashboard',
  //                 extra: {'studentId': userData['id'].toString()});
  //             return;
  //           } else if (accType == 'guest') {
  //             context.go('/guest-dashboard',
  //                 extra: {'guestId': userData['id'].toString()});
  //             return;
  //           } else {
  //             context.go('/error');
  //             return;
  //           }
  //         } else {
  //           // Profile not filled → go to stepper page
  //           context.go('/signup-stepper');
  //           return;
  //         }
  //
  //       case LaunchStatus.notLoggedIn:
  //         context.go('/auth');
  //         return;
  //     }
  //   } catch (e) {
  //     debugPrint("Error in _initAndRedirect: $e");
  //     context.go('/auth'); // fallback to login
  //   }
  // }

  Future<void> _initAndRedirect() async {
    try {
      await _checkUser();
      final box = await Hive.openBox('app_storage');
      final String? token = await LaunchStatusService.getAuthToken();
      final String? userId = box.get('user_id');
      // final Map<String, dynamic>? storedUserData = await LaunchStatusService.getUserData();

      final storedUserData = await LaunchStatusService.getUserData();

      Map<String, dynamic>? userData;
      if (storedUserData != null && storedUserData['success'] == true) {
        userData = Map<String, dynamic>.from(storedUserData['data']);
      }

      print("****************************");
      print("auth Token : ");
      print(token);
      print("****************************");
      print("user Id : ");
      print(userId);
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
      final fetched = await UserCheckService().fetchUserData(token);
      if (!mounted) return;
      print("****************************");
      print("fetched : ");
      print(fetched);
      print("****************************");
      if (fetched != null) {
        userData = fetched['data'];
      } else {
        userData = storedUserData['data'];
      }

    } else if (userId != null) {
      final fetched = await UserCheckService().setUserToken(userId);
      if (!mounted) return;

      if (fetched != null) {
        userData = fetched as Map<String, dynamic>?;
        await box.put('user_data', userData);
        await box.put('auth_token', userData?['token']);
      } else {
        if (!mounted) return;
        context.go('/auth');
        return;
      }
    } else {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    //redirect to auth
    if(userData == null){
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    final accType = userData?['acc_type'] ?? 'guest';
    final profileFill = userData?['profile_fill'] ?? 0;

    if (!mounted) return;

    if (profileFill == 1) {
      switch (accType) {
        case 'teacher':
          context.go(
            '/teacher-dashboard',
            extra: {'teacherId': userData?['id'].toString()},
          );
          return;
        case 'student':
          context.go(
            '/student-dashboard',
            extra: {'studentId': userData?['id'].toString()},
          );
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
}
