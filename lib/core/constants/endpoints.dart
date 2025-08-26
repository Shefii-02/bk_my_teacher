class Endpoints {
  // Base
  // static const base = "https://dashboard.bookmyteacher.co.in/api";
  static const base = "https://bookmyteacher.shefii.com/api";

  // Auth
  static const sendOtp = "/send-otp";
  static const verifyOtp = "/verify-otp";
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

  // Notifications
  static const notifications = "/notifications";
}
