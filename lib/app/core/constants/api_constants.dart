class ApiConstants {
  // Base URL - Update with your actual API endpoint
  // For Android Emulator: http://10.0.2.2:5000/api
  // For iOS Simulator: http://localhost:5000/api
  // For Physical Device: http://YOUR_LOCAL_IP:5000/api (e.g., http://192.168.1.4:5000/api)
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String baseUrl = 'https://lms.eduaitutors.com/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerStudent = '/auth/register-student';
  static const String verifyStudentOtp = '/auth/verify-student-otp';
  static const String sendVerificationOtp = '/auth/send-verification-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String sendPasswordResetOtp = '/auth/forgot-password/send-otp';
  static const String resetPassword = '/auth/forgot-password/reset';
  static const String verifyOtp = '/auth/verify-otp';
  static const String me = '/auth/me';

  // User Endpoints
  static const String profile = '/auth/me';
  static const String studentProfile = '/auth/me/student-profile';
  static const String parentCredentials = '/auth/me/parent-credentials';
  static const String parentProfile = '/auth/me/parent';
  static const String resendParentCredentials =
      '/auth/resend-parent-credentials';
  static const String sendReferral = '/referral';
  static const String updateProfile = '/auth/profile/update';
  static const String changePassword = '/user/change-password';

  // Subscription Endpoints
  static const String subscriptions = '/subscriptions';
  static const String activeSubscription = '/subscriptions/active';
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscribe = '/subscriptions/subscribe';
  static const String cancelSubscription = '/subscriptions/cancel';

  // Content Hierarchy Endpoints
  static const String boards = '/boards';
  static const String grades = '/grades';
  static const String subjects = '/subjects';
  static const String chapters = '/chapters';

  // Content Endpoints
  static const String videos = '/content/videos';
  static const String documents = '/content/documents';
  static const String polls = '/content/polls';
  static const String pollResponse = '/content/polls/response';

  // Assessment Endpoints
  static const String quizzes = '/assessments/quizzes';
  static const String submitQuiz = '/assessments/quizzes/submit';
  static const String quizResults = '/assessments/quizzes/results';
  static const String assignments = '/assessments/assignments';
  static const String submitAssignment = '/assessments/assignments/submit';

  // Progress Endpoints
  static const String progress = '/progress';
  static const String chapterProgress = '/progress/chapter';
  static const String updateProgress = '/progress/update';

  // Payment Endpoints
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static const String paymentHistory = '/payments/history';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/mark-read';

  // Mentor Endpoints
  static const String mentorProfile = '/mentors/me/profile';
  static const String mentorAnnouncements = '/mentors/me/announcements';
  static const String mentorExerciseProgressReport =
      '/mentors/me/reports/exercise-progress';
  static const String mentorExerciseProgressReportExport =
      '/mentors/me/reports/exercise-progress/export';
  static const String mentorMessages = '/mentors/me/messages';
  static const String mentorBroadcastMessage = '/mentors/me/messages/broadcast';

  // Question Bank Endpoints (accessible by Admin + Mentor)
  static const String questions = '/questions';

  // Assessments (accessible by Admin + Mentor)
  static const String assessments = '/assessments';

  // Rating Endpoints
  /// Student: POST /ratings/content/:contentId  | GET /ratings/content/:contentId/mine
  static const String ratingsContent = '/ratings/content';

  /// Mentor: GET /ratings/mentor/overview
  static const String mentorRatingsOverview = '/ratings/mentor/overview';

  /// Mentor: GET /ratings/mentor/stats?top=10
  static const String mentorRatingsStats = '/ratings/mentor/stats';

  /// Mentor: GET /ratings/mentor/feedbacks
  static const String mentorRatingsFeedbacks = '/ratings/mentor/feedbacks';

  /// Mentor: POST /ratings/:ratingId/reply
  static const String ratingsReply = '/ratings';

  // Parent Endpoints
  static const String parentStudents = '/auth/me/students';
  static const String parentMe = '/auth/me';
  static const String parentResources = '/parent-resources/public';

  // Coaching Endpoints
  static const String mentorCoachingRequests = '/coaching/mentor/requests';
  static const String mentorCoachingCalendar = '/coaching/mentor/calendar';
  static const String mentorCoachingSlots = '/coaching/mentor/slots';
  static const String studentCoachingDashboard = '/coaching/student/dashboard';
  static const String studentCoachingRequests = '/coaching/student/requests';
  static const String studentCoachingBookSession =
      '/coaching/student/sessions/book';
  static const String studentCoachingCancelSession =
      '/coaching/student/sessions';

  // Analytics Endpoints
  static const String trackEvent = '/analytics/track';

  // Self Assessment Endpoints
  static const String selfAssessments = '/self-assessments';
  static String selfAssessmentById(String id) => '/self-assessments/$id';
  static String selfAssessmentSubmit(String id) =>
      '/self-assessments/$id/submit';
}
