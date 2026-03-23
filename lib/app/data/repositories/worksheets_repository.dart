import 'package:get/get.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/data/models/worksheet_model.dart';

class WorksheetsRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Fetch worksheets with optional filters and pagination
  Future<WorksheetResponse> getWorksheets({
    int page = 1,
    int limit = 20,
    String? gradeId,
    String? subjectId,
    String? chapterId,
    String? boardId,
    int? academicYear,
  }) async {
    try {
      final queryParameters = {
        'page': page,
        'limit': limit,
        if (gradeId != null) 'grade': gradeId,
        if (subjectId != null) 'subject': subjectId,
        if (chapterId != null) 'chapter': chapterId,
        if (boardId != null) 'board': boardId,
        if (academicYear != null) 'academicYear': academicYear,
      };

      final response = await _apiClient.get(
        '/worksheets',
        queryParameters: queryParameters,
      );

      if (response.data['success'] == true) {
        return WorksheetResponse.fromJson(response.data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch worksheets',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single worksheet by ID
  Future<WorksheetModel> getWorksheetById(String id) async {
    try {
      final response = await _apiClient.get('/worksheets/$id');

      if (response.data['success'] == true) {
        return WorksheetModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch worksheet',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get the full URL for downloading a worksheet
  String getDownloadUrl(String filePath) {
    // Static files are served from the server root, not under /api
    // Remove /api from baseUrl to get server base URL
    final serverBaseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    // Ensure filePath starts with /
    final path = filePath.startsWith('/') ? filePath : '/$filePath';

    return '$serverBaseUrl$path';
  }
}
