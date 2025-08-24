import 'package:go_router/go_router.dart';

import '../presentation/auth/view/auth_screen.dart dart.dart';
import '../presentation/auth/view/sign_up_teacher.dart';
import '../presentation/auth/view/verification_screen.dart';
import '../presentation/errror/error_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/students/student_dashboard.dart';
import '../presentation/teachers/teacher_dashboard.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const SplashScreen(), // Placeholder while checking
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/verification-screen',
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: '/signup-teacher',
      builder: (context, state) => const SignUpTeacher(),
    ),
    GoRoute(
      path: '/signup-student',
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentDashboard(),
    ),
    GoRoute(
      path: '/teacher',
      builder: (context, state) => const TeacherDashboard(),
    ),

    GoRoute(path: '/error', builder: (context, state) => const ErrorScreen()),
  ],
);
