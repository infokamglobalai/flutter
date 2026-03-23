import 'package:get/get.dart';
import 'package:najahapp/app/data/models/user_model.dart';
import 'package:najahapp/app/data/models/subscription_model.dart';
import 'package:najahapp/app/data/models/student_profile_model.dart';
import 'package:najahapp/app/data/models/package_model.dart';
import 'package:najahapp/app/data/repositories/subscription_repository.dart';
import 'package:najahapp/app/data/repositories/auth_repository.dart';
import 'package:najahapp/app/data/services/package_service.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/data/services/notification_service.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';
import 'package:najahapp/app/core/services/fcm_service.dart';

class DashboardController extends GetxController {
  final SubscriptionRepository _subscriptionRepository =
      Get.find<SubscriptionRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final PackageService _packageService = PackageService();
  final DataService _dataService = DataService();
  final NotificationService _notificationService = NotificationService();

  FCMService get _fcmService => Get.find<FCMService>();

  // Make AuthController optional for guest mode
  AuthController? get _authController {
    try {
      return Get.find<AuthController>();
    } catch (e) {
      return null;
    }
  }

  // Reactive state
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final Rx<StudentProfileModel?> studentProfile = Rx<StudentProfileModel?>(
    null,
  );
  final Rx<Map<String, dynamic>?> parentCredentials = Rx<Map<String, dynamic>?>(
    null,
  );
  final Rx<Map<String, dynamic>?> parentProfile = Rx<Map<String, dynamic>?>(
    null,
  );
  final Rx<SubscriptionModel?> activeSubscription = Rx<SubscriptionModel?>(
    null,
  );
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingParentInfo = false.obs;
  final RxBool showParentPassword = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isGuestMode = false.obs;
  final RxBool isUpdatingProfile = false.obs;

  // Student Progress
  final Rx<Map<String, dynamic>?> studentProgressData =
      Rx<Map<String, dynamic>?>(null);
  final RxBool isLoadingProgress = false.obs;

  // Section expansion states
  final RxMap<String, bool> sectionExpanded = <String, bool>{
    'personal': true,
    'academic': true,
    'contact': true,
    'myProgress': true,
    'parent': true,
    'learningProgress': true,
  }.obs;

  // Self-assessment expansion states
  final RxMap<String, bool> expandedAssessments = <String, bool>{}.obs;

  void toggleSection(String key) {
    sectionExpanded[key] = !(sectionExpanded[key] ?? true);
  }

  // Packages
  final RxList<PackageModel> publicPackages = <PackageModel>[].obs;
  final RxBool isLoadingPackages = false.obs;
  final RxString packagesError = ''.obs;

  // User Subscriptions
  final RxList<SubscriptionModel> userSubscriptions = <SubscriptionModel>[].obs;
  final RxBool isLoadingSubscriptions = false.obs;
  final RxString subscriptionsError = ''.obs;

  // Dashboard stats
  final RxInt completedChapters = 0.obs;
  final RxInt totalChapters = 0.obs;
  final RxDouble progressPercentage = 0.0.obs;
  final RxInt quizzesTaken = 0.obs;
  final RxInt averageScore = 0.obs;

  // Notifications
  final RxInt notificationCount = 0.obs;
  final RxBool notificationPermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadPublicPackages();
    loadUserSubscriptions();
    loadNotificationCount();
    checkNotificationPermission();
  }

  Future<void> loadUserSubscriptions() async {
    // Skip silently when the user is not yet authenticated to avoid a noisy
    // 401 / "No token provided" error on the dashboard.
    final authController = _authController;
    if (authController == null || !authController.isAuthenticated) {
      return;
    }

    try {
      isLoadingSubscriptions.value = true;
      subscriptionsError.value = '';

      final subscriptions = await _dataService.fetchUserSubscriptions();
      userSubscriptions.value = subscriptions;
    } catch (e) {
      subscriptionsError.value = e.toString().replaceAll('Exception: ', '');
      print('Error loading subscriptions: ${subscriptionsError.value}');
    } finally {
      isLoadingSubscriptions.value = false;
    }
  }

  Future<void> loadPublicPackages() async {
    try {
      isLoadingPackages.value = true;
      packagesError.value = '';

      final packages = await _packageService.getPublicPackages();
      publicPackages.value = packages.where((p) => p.isActive).toList();
    } catch (e) {
      packagesError.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Failed to load packages: ${packagesError.value}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingPackages.value = false;
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if guest mode
      if (_authController == null ||
          _authController!.currentUser.value == null) {
        isGuestMode.value = true;
        user.value = null;
        // Set default guest stats
        completedChapters.value = 0;
        totalChapters.value = 10;
        progressPercentage.value = 0.0;
        quizzesTaken.value = 0;
        averageScore.value = 0;
      } else {
        isGuestMode.value = false;
        // Load user profile
        user.value = _authController!.currentUser.value;

        // Load student profile if user is a student
        if (user.value?.role.toLowerCase() == 'student') {
          try {
            final profile = await _authRepository.getStudentProfile();
            studentProfile.value = profile;
          } catch (e) {
            // Failed to load student profile, continue without it
            studentProfile.value = null;
          }
        }

        // Load active subscription
        final subscription = await _subscriptionRepository
            .getActiveSubscription();
        activeSubscription.value = subscription;

        // Load dashboard statistics
        await _loadStatistics();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await loadDashboardData();
      await loadNotificationCount();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadNotificationCount() async {
    try {
      notificationCount.value = await _notificationService.getUnreadCount();
    } catch (e) {
      // Silently fail for notification count
      notificationCount.value = 0;
    }
  }

  /// Check notification permission status
  Future<void> checkNotificationPermission() async {
    try {
      final granted = await _fcmService.checkNotificationPermission();
      notificationPermissionGranted.value = granted;

      if (!granted) {
        print('⚠️  Notification permission not granted');
      }
    } catch (e) {
      print('❌ Error checking notification permission: $e');
      notificationPermissionGranted.value = false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final granted = await _fcmService.requestNotificationPermission();
      notificationPermissionGranted.value = granted;
      return granted;
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      notificationPermissionGranted.value = false;
      return false;
    }
  }

  Future<void> _loadStatistics() async {
    // TODO: Implement actual API call to get statistics
    // Mock data for now
    completedChapters.value = 12;
    totalChapters.value = 50;
    progressPercentage.value =
        (completedChapters.value / totalChapters.value) * 100;
    quizzesTaken.value = 8;
    averageScore.value = 75;
  }

  // Navigation methods
  void navigateToSubscription() {
    Get.toNamed('/subscription-plans');
  }

  void navigateToBoards() {
    Get.toNamed('/boards');
  }

  void navigateToProgress() {
    Get.toNamed('/progress');
  }

  void navigateToProfile() {
    Get.toNamed('/profile');
  }

  // Getters
  bool get hasActiveSubscription =>
      activeSubscription.value != null && activeSubscription.value!.isActive;

  String get subscriptionStatus {
    if (activeSubscription.value == null) return 'No Active Subscription';
    if (activeSubscription.value!.isActive) return 'Active';
    return 'Expired';
  }

  int get daysRemaining {
    if (activeSubscription.value == null ||
        activeSubscription.value!.endDate == null)
      return 0;
    final days = activeSubscription.value!.endDate!
        .difference(DateTime.now())
        .inDays;
    return days > 0 ? days : 0;
  }

  // Parent-related methods
  Future<void> loadParentInformation() async {
    try {
      isLoadingParentInfo.value = true;

      // Load parent credentials and profile
      final credentials = await _authRepository.getParentCredentials();
      parentCredentials.value = credentials;

      final profile = await _authRepository.getParentProfile();
      parentProfile.value = profile;
    } catch (e) {
      // Parent info might not be available for all students
      parentCredentials.value = null;
      parentProfile.value = null;
    } finally {
      isLoadingParentInfo.value = false;
    }
  }

  Future<void> resendParentCredentials() async {
    try {
      isLoadingParentInfo.value = true;
      await _authRepository.resendParentCredentials();

      Get.snackbar(
        'Success',
        'Parent credentials sent successfully to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingParentInfo.value = false;
    }
  }

  // Student Progress Methods
  Future<void> loadStudentProgress() async {
    try {
      isLoadingProgress.value = true;

      final response = await _dataService.fetchStudentProgress();
      studentProgressData.value = response;
    } catch (e) {
      // Progress data might not be available
      studentProgressData.value = null;
      print('Error loading student progress: $e');
    } finally {
      isLoadingProgress.value = false;
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      isUpdatingProfile.value = true;
      final updatedUser = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      user.value = updatedUser;
      
      if (_authController != null) {
        _authController!.currentUser.value = updatedUser;
      }

      Get.back(); // close bottom sheet
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isUpdatingProfile.value = false;
    }
  }
}
