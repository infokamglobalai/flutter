import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/api_service.dart';

class CoachingService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getStudentDashboard() async {
    try {
      final response = await _api.get(ApiConstants.studentCoachingDashboard);
      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': Map<String, dynamic>.from(response.data['data'] as Map),
        };
      }
      return {'success': false, 'message': response.data['message'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createRequest({
    required String subjectId,
    String? chapterId,
    required String requestMessage,
    String? preferredSchedule,
    String? contactNumber,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.studentCoachingRequests,
        data: {
          'subjectId': subjectId,
          'chapterId': chapterId,
          'requestMessage': requestMessage,
          'preferredSchedule': preferredSchedule,
          'contactNumber': contactNumber,
        },
      );

      return {
        'success': response.data['success'] == true,
        'message':
            response.data['message'] ??
            (response.data['success'] == true ? 'Success' : 'Error'),
        'data': response.data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> bookSession({
    required String slotId,
    String? requestId,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.studentCoachingBookSession,
        data: {
          'slotId': slotId,
          if (requestId != null && requestId.isNotEmpty) 'requestId': requestId,
        },
      );
      return {
        'success': response.data['success'] == true,
        'message':
            response.data['message'] ??
            (response.data['success'] == true ? 'Success' : 'Error'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> cancelStudentSession(String sessionId) async {
    try {
      final response = await _api.post(
        '${ApiConstants.studentCoachingCancelSession}/$sessionId/cancel',
        data: {},
      );
      return {
        'success': response.data['success'] == true,
        'message':
            response.data['message'] ??
            (response.data['success'] == true ? 'Cancelled' : 'Error'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
