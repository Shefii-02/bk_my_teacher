class Endpoints {
  // Base
  // static const base = "https://dashboard.bookmyteacher.co.in/api";
  static const base = "https://bookmyteacher.shefii.com/api";

  // Auth
  static const sendOtpSignIn = "/send-otp-signIn";
  static const verifyOtpSignIn = "/verify-otp-signIn";

  static const sendOtpSignUp = "/send-otp-signUp";
  static const verifyOtpSignUp = "/verify-otp-signUp";

  static const sendEmailOtp = "/send-email-otp";
  static const verifyEmailOtp = "/verify-email-otp";

  static const teacherSignup = "/teacher-signup";
  static const studentSignup = "/student-signup";

  static const userDetails = "/user-details";
  static const updateStudentDetails = "/student-details/update";
  static const updateTeacherDetails = "/teacher-details/update";
  static const teacherHome = "/teacher-home";
  static const studentHome = "/student-home";
  static const teacherProfile = "/teacher-profile";
  static const teacherMyCourses = "/teacher-mycourses";
  static const studentProfile = "/student-profile";
  static const notifications = "/notifications";
  static const logout = "/logout";


  // Registration
  static const teachersRegister = "/teachers/register";

  // Classes
  static const myClasses = "/classes";
  static const joinClass = "/classes/join";
  static const takeAttendance = "/classes/attendance";

  // Students
  static const studentRequests = "/students/requests";
  static const chatWithStudent = "/students/chat";

  // Profile
  static const uploadCertificates = "/profile/certificates";
  static const preferredSubjects = "/profile/subjects";
  static const ratingFeedback = "/profile/feedback";

  // Earnings
  static const earnings = "/earnings";
  static const withdraw = "/earnings/withdraw";


}