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
  static const String updateProfilePicture = '/auth/profile/picture';
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

  // Packages
  static const String packagesPublic = '/packages/public';
  static String packageById(String id) => '/packages/$id';

  // Content Endpoints
  static const String videos = '/content/videos';
  static const String documents = '/content/documents';
  static const String polls = '/content/polls';
  static const String pollResponse = '/content/polls/response';

  // Resources
  static String resourcesByChapter(String chapterId) => '/resources/chapter/$chapterId';

  // Exercises
  static String exercisesPublicByChapter(String chapterId) =>
      '/exercises/public/chapter/$chapterId';

  // Worksheets
  static const String worksheets = '/worksheets';
  static String worksheetById(String id) => '/worksheets/$id';

  // Assessment Endpoints
  static const String quizzes = '/assessments/quizzes';
  static const String submitQuiz = '/assessments/quizzes/submit';
  static const String quizResults = '/assessments/quizzes/results';
  static const String assignments = '/assessments/assignments';
  static const String submitAssignment = '/assessments/assignments/submit';

  // Public assessments flow
  static const String assessmentsPublic = '/assessments/public';
  static String assessmentAttemptById(String attemptId) =>
      '/assessments/attempts/$attemptId';

  // Progress Endpoints (student: GET /progress/me — full tree like web)
  static const String progressMe = '/progress/me';
  static const String progress = '/progress';
  static const String chapterProgress = '/progress/chapter';
  static const String updateProgress = '/progress/update';

  // Payment Endpoints (backend mounts at /api/payment — singular)
  static const String paymentVerify = '/payment/verify';
  static const String paymentConfig = '/payment/config';
  static const String paymentGenerateHash = '/payment/generate-hash';
  static const String paymentOttuInitiate = '/payment/ottu/initiate';
  static String paymentOttuCancel(String subscriptionId) =>
      '/payment/ottu/cancel/$subscriptionId';
  static String paymentOttuStatus(String sessionId) =>
      '/payment/ottu/status/$sessionId';
  /// List of payments for current user (see [DataService.fetchPaymentHistory]).
  static const String myPaymentsViaSubscriptions = '/subscriptions/payments/my';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/mark-read';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationById(String id) => '/notifications/$id';
  static String notificationMarkRead(String id) => '/notifications/$id/mark-read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // Mentor Endpoints
  static const String mentorProfile = '/mentors/me/profile';
  static const String mentorAnnouncements = '/mentors/me/announcements';
  static const String mentorDashboardStats = '/mentors/me/dashboard/stats';
  static const String mentorStudents = '/mentors/me/students';
  static const String mentorStudentsWithProgress = '/mentors/me/students/with-progress';
  static String mentorStudentProgress(String studentId) =>
      '/mentors/me/students/$studentId/progress';
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

  // Tickets (Support)
  static const String tickets = '/tickets';
  static String ticketById(String id) => '/tickets/$id';
  static String ticketResponses(String id) => '/tickets/$id/responses';
  static const String ticketStats = '/tickets/stats';

  // QnA
  static const String qnaThreads = '/qna/threads';
  static const String qnaGetThread = '/qna'; // uses query params: chapterId, packageId
  static const String qnaAskQuestion = '/qna/question';

  // AI
  static const String aiChat = '/ai/chat';
  static const String aiTranslate = '/ai/translate';
  static const String aiTts = '/ai/tts';

  // AI Chat History (persisted threads)
  // Mirrors eduai-frontend aiChatService + backend /api/ai-chat routes.
  static const String aiChatSave = '/ai-chat/save';
  static String aiChatHistory(String context) => '/ai-chat/history/$context';
  static const String aiChatClear = '/ai-chat/clear';
  static String aiChatAdminHistory(String studentId, String context) =>
      '/ai-chat/admin/history/$studentId/$context';

  // AI Counsellor
  static const String aiCounsellorData = '/ai-counsellor/data';
  static const String aiCounsellorReports = '/ai-counsellor/reports';
  static const String aiCounsellorChat = '/ai-counsellor/chat';

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

  // Mock tests (student: GET /mocktests/student, POST /mocktests/:id/submit)
  static const String mocktestsStudent = '/mocktests/student';

  // Coupons
  static const String couponsValidate = '/coupons/validate';

  // Guest resources
  static const String guestResourcesPublic = '/guest-resources/public';

  // Banners (mobile top slider)
  static const String bannersPublic = '/banners/public';

  // Self Assessment Endpoints
  static const String selfAssessments = '/self-assessments';
  static String selfAssessmentById(String id) => '/self-assessments/$id';
  static String selfAssessmentSubmit(String id) =>
      '/self-assessments/$id/submit';
}
