import 'package:BookMyTeacher/services/upload_sample.dart';
import 'package:go_router/go_router.dart';

import '../presentation/auth/view/auth_screen.dart';
import '../presentation/auth/view/sign_up_otp_screen.dart';
import '../presentation/auth/view/sign_up_student.dart';
import '../presentation/auth/view/sign_up_teacher.dart';
import '../presentation/auth/view/sign_up_verification_screen.dart';
import '../presentation/auth/view/signup_stepper.dart';
import '../presentation/auth/view/verification_screen.dart';
import '../presentation/errror/error_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/students/student_dashboard.dart';
import '../presentation/teachers/teacher_dashboard.dart';
import 'app_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUpStepper,
      builder: (context, state) => const SignUpStepper(),
    ),
    GoRoute(
      path: AppRoutes.signupTeacher,
      builder: (context, state) => const SignUpTeacher(),
    ),
    GoRoute(
      path: AppRoutes.signupStudent,
      builder: (context, state) => const SignUpStudent(),
    ),
    GoRoute(
      path: '/teacher-dashboard',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final teacherId = extra['teacherId'] as String;
        return TeacherDashboard(teacherId: teacherId);
      },
    ),
    GoRoute(
      path: '/student-dashboard',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final studentId = extra['studentId'] as String;
        return StudentDashboard(studentId: studentId);
      },
    ),
    GoRoute(
      path: '/upload-sample',
      builder: (context, state) {
        return UploadSample();
      },
    ),

    GoRoute(
      path: AppRoutes.verificationScreen,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        final mobile = extras['phoneNumber'] as String? ?? '';
        // final mobile = state.extra as String? ?? '';
        return VerificationScreen(phoneNumber: mobile);
      },
    ),
    GoRoute(
      path: AppRoutes.signupOtpScreen,
      builder: (context, state) => const SignUpOtpScreen(),
    ),
    GoRoute(
      path: AppRoutes.verificationScreenSignup,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        final mobile = extras['phoneNumber'] as String? ?? '';
        // final mobile = state.extra as String? ?? '';
        return SignUpVerificationScreen(phoneNumber: mobile);
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => const ErrorScreen()),
    GoRoute(path: '/error', builder: (context, state) => const ErrorScreen()),
  ],
);
