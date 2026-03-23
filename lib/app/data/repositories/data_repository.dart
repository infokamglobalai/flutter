import 'package:get/get.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';

class BoardModel {
  final String id;
  final String name;

  BoardModel({required this.id, required this.name});

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class GradeModel {
  final String id;
  final String name;

  GradeModel({required this.id, required this.name});

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class DataRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<BoardModel>> getBoards({int page = 1, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.boards,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to fetch boards');
      }

      return (response.data['data'] as List)
          .map((board) => BoardModel.fromJson(board))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GradeModel>> getGrades({int page = 1, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.grades,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to fetch grades');
      }

      return (response.data['data'] as List)
          .map((grade) => GradeModel.fromJson(grade))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
