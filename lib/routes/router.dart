import 'package:BookMyTeacher/presentation/auth/view/sign_up_guest.dart';
import 'package:BookMyTeacher/presentation/guest/guest_dashboard.dart';
import 'package:BookMyTeacher/presentation/students/my_class_list.dart';
import 'package:BookMyTeacher/presentation/widgets/personal_info_view.dart';
import 'package:BookMyTeacher/services/upload_sample.dart';
import 'package:go_router/go_router.dart';

import '../model/webinar.dart';
import '../presentation/audio_room/audio_room_page.dart';
import '../presentation/auth/view/auth_screen.dart';
import '../presentation/auth/view/sign_up_otp_screen.dart';
import '../presentation/auth/view/sign_up_student.dart';
import '../presentation/auth/view/sign_up_teacher.dart';
import '../presentation/auth/view/sign_up_verification_screen.dart';
import '../presentation/auth/view/signup_stepper.dart';
import '../presentation/auth/view/verification_screen.dart';
import '../presentation/errror/error_screen.dart';
import '../presentation/errror/maintenance_screen.dart';
import '../presentation/errror/no_network_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/one_on_one/one_on_one_call_page.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/students/class_detail_screen.dart';
import '../presentation/students/courses_screen.dart';
import '../presentation/students/student_dashboard.dart';
import '../presentation/widgets/pdf_view_page.dart';
import '../presentation/widgets/teaching_details_info.dart';
import '../presentation/widgets/top_banner_detail_page.dart';
import '../presentation/teachers/account/cv_upload.dart';
import '../presentation/teachers/account/personal_info.dart';
import '../presentation/teachers/account/teaching_details.dart';
import '../presentation/teachers/account/upload_demo.dart';
import '../presentation/teachers/google_login_screen.dart';
import '../presentation/teachers/teacher_dashboard.dart';
import '../presentation/video_conference/conference_page.dart';
import '../presentation/webinars/audience_live_page.dart';
import '../presentation/webinars/audience_page.dart';
import '../presentation/webinars/webinar_detail_page.dart';
import '../presentation/webinars/webinar_stream_page.dart';
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
      path: AppRoutes.signupGuest,
      builder: (context, state) => const SignUpGuest(),
    ),
    GoRoute(
      path: '/personal-info',
      builder: (context, state) {
        return PersonalInfo(); // ✅ correct syntax
      },
    ),
    GoRoute(
      path: '/personal/view',
      builder: (context, state) {
        final teacherData = state.extra as Map<String, dynamic>?;
        return PersonalInfoView(); // ✅ correct syntax
      },
    ),

    GoRoute(
      path: AppRoutes.teachingDetails,
      builder: (context, state) => const TeachingDetails(),
    ),
    GoRoute(
      path: '/teaching/view',
      builder: (context, state) => const TeachingDetailsInfo(),
    ),

    GoRoute(
      path: AppRoutes.cvUpload,
      builder: (context, state) => const CvUpload(),
    ),
    GoRoute(
      path: '/pdf-view',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final url = args?['url'] ?? '';
        return PdfViewPage(url: url);
      },
    ),
    GoRoute(
      path: AppRoutes.uploadDemo,
      builder: (context, state) => const UploadDemo(),
    ),
    GoRoute(
      path: '/top-banner/:id',
      builder: (context, state) {
        final bannerId = state.pathParameters['id']!;
        return TopBannerDetailPage(bannerId: bannerId);
      },
    ),
    GoRoute(
      path: AppRoutes.teacherDashboard,
      builder: (context, state) {
        return TeacherDashboard();
      },
    ),
    GoRoute(
      path: AppRoutes.studentDashboard,
      builder: (context, state) {
        return StudentDashboard();
      },
    ),
    GoRoute(
      path: AppRoutes.guestDashboard,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final guestId = extra['guestId'] as String;
        return GuestDashboard(guestId: guestId);
      },
    ),
    GoRoute(
      path: '/upload-sample',
      builder: (context, state) {
        return UploadSample();
      },
    ),
    GoRoute(
      path: '/sign-google',
      builder: (context, state) {
        return GoogleLoginScreen();
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
    GoRoute(
      path: '/audience',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return AudienceLivePage(
          appID: data['appID'] as int,
          appSign: data['appSign'] as String,
          userID: data['userID'] as String,
          userName: data['userName'] as String,
          liveID: data['liveID'] as String,
          isHost: data['isHost'] as bool,
          title: data['title'] as String,
          hostName: data['hostName'] as String,
        );
      },
    ),
    GoRoute(
      path: '/course-store',
      builder: (context, state) {
        return CoursesScreen();
      },
    ),

    GoRoute(
      path: '/class-detail',
      builder: (context, state) {
        final classId = state.extra as String; // ✅ String ID
        return ClassDetailScreen(classId: classId);
      },
    ),


    // GoRoute(
    //   path: '/audience',
    //   builder: (context, state) {
    //     // Cast the extra data to a Map<String, dynamic>
    //     final data = state.extra as Map<String, dynamic>;
    //
    //     return AudienceLivePage(
    //       // Access the data directly, no need for parsing
    //       appID: data['appID'] as int,
    //       appSign: data['appSign'] as String,
    //       userID: data['userID'] as String,
    //       userName: data['userName'] as String,
    //       liveID: data['liveID'] as String,
    //       isHost: data['isHost'] as bool,
    //     );
    //   },
    // ),

    GoRoute(
      path: '/live',
      builder: (context, state) {
        // Cast the extra data to a Map<String, dynamic>
        final data = state.extra as Map<String, dynamic>;

        return AudiencePage(
          // Access the data directly, no need for parsing
          appID: data['appID'] as int,
          appSign: data['appSign'] as String,
          userID: data['userID'] as String,
          userName: data['userName'] as String,
          liveID: data['liveID'] as String,
          isHost: data['isHost'] as bool,
        );
      },
    ),

    GoRoute(
      path: '/oneonone',
      builder: (context, state) {
        // Cast the extra data to a Map<String, dynamic>
        final data = state.extra as Map<String, dynamic>;

        return OneOnOneCallPage(
          // Access the data directly, no need for parsing
          appID: data['appID'] as int,
          appSign: data['appSign'] as String,
          userID: data['userID'] as String,
          userName: data['userName'] as String,
          callID: data['callID'] as String,
          isHost: data['isHost'] as bool,
        );
      },
    ),

    GoRoute(
      path: '/conference',
      builder: (context, state) {
        // Cast the extra data to a Map<String, dynamic>
        final data = state.extra as Map<String, dynamic>;

        return ConferencePage(
          // Access the data directly, no need for parsing
          appID: data['appID'] as int,
          appSign: data['appSign'] as String,
          userID: data['userID'] as String,
          userName: data['userName'] as String,
          conferenceID: data['conferenceID'] as String,
          isHost: data['isHost'] as bool,
        );
      },
    ),

    GoRoute(
      path: '/audioroom',
      builder: (context, state) {
        // Cast the extra data to a Map<String, dynamic>
        final data = state.extra as Map<String, dynamic>;

        return AudioRoomPage(
          // Access the data directly, no need for parsing
          appID: data['appID'] as int,
          appSign: data['appSign'] as String,
          userID: data['userID'] as String,
          userName: data['userName'] as String,
          roomID: data['roomID'] as String,
          isHost: data['isHost'] as bool,
        );
      },
    ),


    GoRoute(
      path: AppRoutes.myClassList,
      builder: (context, state) {
        return MyClassList();
      },
    ),
    GoRoute(
      path: '/webinars/:id',
      builder: (context, state) {
        final webinar = state.extra as Webinar;
        return WebinarDetailPage(webinar: webinar);
      },
    ),

    GoRoute(
      path: '/webinars/:id/stream',
      builder: (context, state) {
        final liveData = state.extra as Map<String, dynamic>;
        return WebinarStreamPage(streamData: liveData,);
      },
    ),

    // GoRoute(
    //   path: '/live',
    //   builder: (context, state) => AudiencePage(
    //     params: state.uri.queryParameters,
    //   ),
    // ),
    // GoRoute(
    //   path: '/oneonone',
    //   builder: (context, state) => OneOnOneCallPage(
    //     params: state.uri.queryParameters,
    //   ),
    // ),
    // GoRoute(
    //   path: '/conference',
    //   builder: (context, state) => ConferencePage(
    //     params: state.uri.queryParameters,
    //   ),
    // ),
    // GoRoute(
    //   path: '/audioroom',
    //   builder: (context, state) => AudioRoomPage(
    //     params: state.uri.queryParameters,
    //   ),
    // ),
    GoRoute(path: '/home', builder: (context, state) => const ErrorScreen()),
    GoRoute(path: '/error', builder: (context, state) => const ErrorScreen()),
    GoRoute(
      path: AppRoutes.maintenance,
      builder: (context, state) => const MaintenanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.noNetwork,
      builder: (context, state) => const NoNetworkScreen(),
    ),

  ],
);
