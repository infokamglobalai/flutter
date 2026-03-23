import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        // Check if email verification is required
        if (response.data['requiresVerification'] == true) {
          return {
            'success': false,
            'requiresVerification': true,
            'message': response.data['message'],
            'email': response.data['email'],
          };
        }

        // Save token and user data
        final token = response.data['token'];
        final userData = response.data['data'];

        await _storage.write('auth_token', token);
        await _storage.write('user_data', userData);

        return {
          'success': true,
          'message': response.data['message'],
          'user': UserModel.fromJson(userData),
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Register Student
  Future<Map<String, dynamic>> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String board,
    required String grade,
    required String state,
    required String city,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register-student',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'board': board,
          'grade': grade,
          'state': state,
          'city': city,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'userId': response.data['data']['userId'],
          'email': response.data['data']['email'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Registration failed',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Get Current User
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');

      if (response.data['success'] == true) {
        final userData = response.data['data'];
        await _storage.write('user_data', userData);

        return {'success': true, 'user': UserModel.fromJson(userData)};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch user data',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.remove('auth_token');
    await _storage.remove('user_data');
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _storage.read('auth_token') != null;
  }

  // Get stored token
  String? getToken() {
    return _storage.read('auth_token');
  }

  // Get stored user data
  UserModel? getStoredUser() {
    final userData = _storage.read('user_data');
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  // Save FCM Token
  Future<Map<String, dynamic>> saveFCMToken({
    required String fcmToken,
    String? platform,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/fcm-token',
        data: {'fcmToken': fcmToken, 'platform': platform ?? 'android'},
      );

      if (response.data['success'] == true) {
        return {'success': true, 'message': response.data['message']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to save FCM token',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Remove FCM Token
  Future<Map<String, dynamic>> removeFCMToken({
    required String fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/fcm-token/remove',
        data: {'fcmToken': fcmToken},
      );

      if (response.data['success'] == true) {
        return {'success': true, 'message': response.data['message']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to remove FCM token',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }
}
