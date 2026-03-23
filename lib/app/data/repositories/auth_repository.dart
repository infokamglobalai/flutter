import 'package:get/get.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/data/models/user_model.dart';
import 'package:najahapp/app/data/models/student_profile_model.dart';

class AuthRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Determine if it's a userId (Parent) or email (Student)
      // Parent IDs typically start with 'PAR' and don't contain '@'
      final isParentId = !email.contains('@');
      final loginData = isParentId
          ? {'userId': email, 'password': password}
          : {'email': email, 'password': password};

      final response = await _apiClient.post(
        ApiConstants.login,
        data: loginData,
      );

      // Check if email verification is required
      if (response.data['requiresVerification'] == true) {
        throw Exception(response.data['message'] ?? 'Please verify your email');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Login failed');
      }

      return {
        'user': UserModel.fromJson(response.data['data']),
        'token': response.data['token'],
        'refresh_token':
            response.data['token'], // Using same token as refresh for now
      };
    } catch (e) {
      // If it's a string error from ApiClient, throw it as Exception
      // Otherwise rethrow the original exception
      if (e is String) {
        throw Exception(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      return {
        'user': UserModel.fromJson(response.data['user']),
        'token': response.data['token'],
        'refresh_token': response.data['refresh_token'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerStudent({
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
      final response = await _apiClient.post(
        ApiConstants.registerStudent,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'schoolName': schoolName,
          'board': board,
          'grade': grade,
          'state': state,
          'city': city,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }

      return {
        'userId': response.data['data']['userId'],
        'email': response.data['data']['email'],
        'message': response.data['message'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyStudentOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyStudentOtp,
        data: {'email': email, 'otp': otp},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'OTP verification failed');
      }

      return {
        'user': UserModel.fromJson(response.data['data']),
        'token': response.data['token'],
        'message': response.data['message'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to fetch profile');
      }
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? firstName,
    String? lastName,
    String? avatar,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateProfile,
        data: {
          'name': name,
          'phone': phone,
          'firstName': firstName,
          'lastName': lastName,
          'avatar': avatar
        },
      );
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendPasswordResetOtp,
        data: {'email': email},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentProfileModel> getStudentProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.studentProfile);

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch student profile',
        );
      }

      return StudentProfileModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getParentCredentials() async {
    try {
      final response = await _apiClient.get(ApiConstants.parentCredentials);

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch parent credentials',
        );
      }

      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getParentProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.parentProfile);

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch parent profile',
        );
      }

      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendParentCredentials() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resendParentCredentials,
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to resend parent credentials',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendVerificationOtp({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendVerificationOtp,
        data: {'email': email},
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to send verification OTP',
        );
      }

      return {
        'success': true,
        'message': response.data['message'] ?? 'OTP sent to your email',
      };
    } catch (e) {
      if (e is String) {
        throw Exception(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyStudentOtp,
        data: {'email': email, 'otp': otp},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to verify OTP');
      }

      // After successful verification, we get a token
      return {
        'success': true,
        'message': response.data['message'] ?? 'Email verified successfully',
        'user': UserModel.fromJson(response.data['data']),
        'token': response.data['token'],
        'refresh_token': response.data['token'],
      };
    } catch (e) {
      if (e is String) {
        throw Exception(e);
      }
      rethrow;
    }
  }
}
