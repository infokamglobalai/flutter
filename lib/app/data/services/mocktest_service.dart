import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/api_service.dart';

/// Student mocktests — matches eduai-frontend `mocktestService` + backend routes.
class MocktestService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Map<String, dynamic>>> getStudentMocktests({
    required String boardId,
    required String gradeId,
    required String packageId,
  }) async {
    final resp = await _api.get(
      '/mocktests/student',
      queryParameters: {
        'boardId': boardId,
        'gradeId': gradeId,
        'packageId': packageId,
      },
    );
    if (resp.data['success'] == true) {
      final list = resp.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    throw Exception(resp.data['message'] ?? 'Failed to load mock tests');
  }

  /// Student must pass [packageId] (subscription id) as query — backend enforces access.
  Future<Map<String, dynamic>> getMocktestById(
    String mocktestId,
    String packageId,
  ) async {
    try {
      final resp = await _api.get(
        '/mocktests/$mocktestId',
        queryParameters: {'packageId': packageId},
      );
      if (resp.data['success'] == true) {
        return Map<String, dynamic>.from(resp.data['data'] as Map);
      }
      final msg = resp.data['message']?.toString() ?? 'Failed to load mock test';
      throw Exception(msg);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message']?.toString() ?? 'Failed to load mock test';
        final aid = data['attemptId'];
        if (aid != null) {
          throw MocktestAlreadyCompletedException(msg, aid.toString());
        }
        throw Exception(msg);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitAttempt({
    required String mocktestId,
    required String packageId,
    required List<Map<String, dynamic>> answers,
    required int durationInSeconds,
  }) async {
    final resp = await _api.post(
      '/mocktests/$mocktestId/submit',
      data: {
        'packageId': packageId,
        'answers': answers,
        'durationInSeconds': durationInSeconds,
      },
    );
    if (resp.data['success'] == true) {
      return Map<String, dynamic>.from(resp.data['data'] as Map);
    }
    throw Exception(resp.data['message'] ?? 'Submit failed');
  }

  Future<Map<String, dynamic>> getAttemptResults(String attemptId) async {
    final resp = await _api.get('/mocktests/attempts/$attemptId');
    if (resp.data['success'] == true) {
      return Map<String, dynamic>.from(resp.data['data'] as Map);
    }
    throw Exception(resp.data['message'] ?? 'Failed to load results');
  }
}

class MocktestAlreadyCompletedException implements Exception {
  MocktestAlreadyCompletedException(this.message, this.attemptId);
  final String message;
  final String attemptId;

  @override
  String toString() => message;
}
