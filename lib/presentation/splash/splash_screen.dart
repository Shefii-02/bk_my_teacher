import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/image_paths.dart';
import '../../core/enums/launch_status.dart';
import '../../services/launch_status_service.dart';

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
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    _initAndRedirect();
  }

  Future<void> _initAndRedirect() async {
    // await LaunchStatusService.resetApp();

    await Future.delayed(const Duration(seconds: 6)); // simulate loading
    final status = await LaunchStatusService.getLaunchStatus();

    // print("********************");
    // print(status);
    // print("********************");
    switch (status) {
      case LaunchStatus.firstTime:
        context.go('/onboarding');
      case LaunchStatus.logged:
      case LaunchStatus.notLoggedIn:
        context.go('/auth');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

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
