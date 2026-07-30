import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/live_class_model.dart';

import 'package:get/get.dart';

class LiveClassService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Fetch all live classes for student / user
  Future<List<LiveClassModel>> fetchLiveClasses() async {
    try {
      final response = await _apiService.get(ApiConstants.liveClasses);
      if (response.data['success'] == true && response.data['data'] != null) {
        final List list = response.data['data'];
        return list.map((json) => LiveClassModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Fetch live classes error: ${e.message}');
      return [];
    } catch (e) {
      print('Fetch live classes unexpected error: $e');
      return [];
    }
  }

  /// Get live class details by ID
  Future<LiveClassModel?> getLiveClassById(String id) async {
    try {
      final response = await _apiService.get(ApiConstants.liveClassById(id));
      if (response.data['success'] == true && response.data['data'] != null) {
        return LiveClassModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Get live class by id error: $e');
      return null;
    }
  }

  /// Get JWT token to join live class room
  Future<String?> getLiveClassToken(String id) async {
    try {
      final response = await _apiService.post(ApiConstants.liveClassToken(id));
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data']['token'];
      }
      return null;
    } catch (e) {
      print('Get live class token error: $e');
      return null;
    }
  }

  /// Create / Schedule a new live class (Mentor / Admin)
  Future<Map<String, dynamic>> createLiveClass({
    required String title,
    String? description,
    String? subjectId,
    String? gradeId,
    required DateTime scheduledAt,
    int durationMinutes = 60,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.liveClasses,
        data: {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (subjectId != null && subjectId.isNotEmpty) 'subject': subjectId,
          if (gradeId != null && gradeId.isNotEmpty) 'grade': gradeId,
          'scheduledAt': scheduledAt.toIso8601String(),
          'durationMinutes': durationMinutes,
        },
      );
      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Live class created successfully!',
          'data': LiveClassModel.fromJson(response.data['data']),
        };
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create live class',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error occurred: $e'};
    }
  }
}
