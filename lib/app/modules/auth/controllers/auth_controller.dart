import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/services/fcm_service.dart';
import 'package:najahapp/app/data/models/user_model.dart';
import 'package:najahapp/app/data/repositories/auth_repository.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final userData = _storageService.getUserData();
    if (userData != null) {
      currentUser.value = UserModel.fromJson(userData);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // email parameter can be either email or userId (for parents)
      final result = await _authRepository.login(
        email: email, // This will be userId for parents, email for students
        password: password,
      );

      currentUser.value = result['user'];
      await _storageService.saveToken(result['token']);
      await _storageService.saveRefreshToken(result['refresh_token']);
      await _storageService.saveUserData(result['user'].toJson());

      // Send FCM token to backend after successful login
      try {
        final fcmService = Get.find<FCMService>();
        await fcmService.sendTokenAfterLogin();
      } catch (e) {
        print('Warning: Could not send FCM token: $e');
      }

      // Redirect based on user role
      final userRole = result['user'].role.toString().toLowerCase();
      if (userRole == 'parent') {
        Get.offAllNamed(Routes.PARENT_DASHBOARD);
      } else if (userRole == 'mentor') {
        Get.offAllNamed(Routes.MENTOR_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
      return true;
    } catch (e) {
      // Clean up error message by removing "Exception: " prefix
      String cleanError = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = cleanError;

      // Check if error is about email verification
      if (cleanError.contains('verify your email') ||
          cleanError.contains('verification')) {
        Get.toNamed(
          '/email-verification',
          arguments: {'email': email, 'message': cleanError},
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      currentUser.value = result['user'];
      await _storageService.saveToken(result['token']);
      await _storageService.saveRefreshToken(result['refresh_token']);
      await _storageService.saveUserData(result['user'].toJson());

      // Send FCM token to backend after successful registration
      try {
        final fcmService = Get.find<FCMService>();
        await fcmService.sendTokenAfterLogin();
      } catch (e) {
        print('Warning: Could not send FCM token: $e');
      }

      Get.offAllNamed(Routes.HOME);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String schoolName,
    required String board,
    required String grade,
    required String state,
    required String city,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.registerStudent(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        schoolName: schoolName,
        board: board,
        grade: grade,
        state: state,
        city: city,
      );

      // Navigate to OTP verification screen
      Get.toNamed(
        '/student-otp-verification',
        arguments: {
          'email': result['email'],
          'message': result['message'] ?? 'OTP has been sent to your email',
        },
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyStudentOtp({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.verifyStudentOtp(
        email: email,
        otp: otp,
      );

      // Save user data and token
      currentUser.value = result['user'];
      await _storageService.saveToken(result['token']);
      await _storageService.saveRefreshToken(result['token']);
      await _storageService.saveUserData(result['user'].toJson());

      // Send FCM token to backend after successful verification
      try {
        final fcmService = Get.find<FCMService>();
        await fcmService.sendTokenAfterLogin();
      } catch (e) {
        print('Warning: Could not send FCM token: $e');
      }

      // Navigate to dashboard
      Get.offAllNamed(Routes.DASHBOARD);

      Get.snackbar(
        'Success',
        result['message'] ?? 'Email verified successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      // Best-effort API call — don't block logout if backend is unreachable
      await _authRepository.logout().catchError((_) {});
    } finally {
      isLoading.value = false;
      // Always clear local session and navigate, regardless of API result
      await _storageService.clearAuth();
      currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final user = await _authRepository.getProfile();
      currentUser.value = user;
      await _storageService.saveUserData(user.toJson());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendPasswordResetOtp({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authRepository.sendPasswordResetOtp(email: email);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authRepository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendVerificationOtp({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authRepository.sendVerificationOtp(email: email);
      return true;
    } catch (e) {
      String cleanError = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = cleanError;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.verifyEmailOtp(
        email: email,
        otp: otp,
      );

      // After successful verification, save token and user data
      currentUser.value = result['user'];
      await _storageService.saveToken(result['token']);
      await _storageService.saveRefreshToken(result['refresh_token']);
      await _storageService.saveUserData(result['user'].toJson());

      // Redirect based on user role
      final userRole = result['user'].role.toString().toLowerCase();
      if (userRole == 'parent') {
        Get.offAllNamed(Routes.PARENT_DASHBOARD);
      } else if (userRole == 'mentor') {
        Get.offAllNamed(Routes.MENTOR_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
      return true;
    } catch (e) {
      String cleanError = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = cleanError;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool get isAuthenticated => currentUser.value != null;
}
