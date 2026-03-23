class AppConstants {
  // App Info
  static const String appName = 'EduAiTutors';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyLanguage = 'app_language';
  static const String storageKeyTheme = 'app_theme';
  static const String storageKeyOnboarding = 'onboarding_completed';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Video Settings
  static const int videoBufferDuration = 3; // seconds
  static const double defaultPlaybackSpeed = 1.0;
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Cache Settings
  static const Duration cacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB

  // Quiz Settings
  static const int defaultQuizTimeLimit = 30; // minutes
  static const int passingPercentage = 60;

  // Subscription Types
  static const String subscriptionTypeMonthly = 'monthly';
  static const String subscriptionTypeQuarterly = 'quarterly';
  static const String subscriptionTypeYearly = 'yearly';

  // Content Types
  static const String contentTypeVideo = 'video';
  static const String contentTypeDocument = 'document';
  static const String contentTypePoll = 'poll';
  static const String contentTypeQuiz = 'quiz';

  // Date Formats
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, hh:mm a';

  // Regex Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String passwordPattern =
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'No internet connection. Please check your network.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnauthorized =
      'Session expired. Please login again.';
  static const String errorServerError =
      'Server error. Please try again later.';

  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successRegister = 'Registration successful!';
  static const String successUpdate = 'Updated successfully!';
  static const String successSubscription =
      'Subscription activated successfully!';
}
