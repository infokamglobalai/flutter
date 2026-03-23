import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../core/services/api_service.dart';
import '../models/doubt_model.dart';

class DoubtService {
  final ApiService _apiService = ApiService();

  /// Create a new doubt (ticket)
  Future<Map<String, dynamic>> createDoubt({
    required String subject,
    required String description,
    String? subjectId,
    String? chapterId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post(
        '/tickets',
        data: {
          'category': 'subjectRelated',
          'subject': subject,
          'description': description,
          'metadata': {
            ...?metadata,
            'subjectId': subjectId,
            'chapterId': chapterId,
          },
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Doubt submitted successfully',
          'doubt': Doubt.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to submit doubt',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  /// Get all doubts with filters
  Future<Map<String, dynamic>> getDoubts({
    int page = 1,
    int limit = 50,
    String? status,
    String? category,
    String? priority,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get(
        '/tickets',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true || response.data['data'] != null) {
        final doubts = (response.data['data'] as List)
            .map((json) => Doubt.fromJson(json))
            .toList();

        return {
          'success': true,
          'doubts': doubts,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch doubts',
          'doubts': <Doubt>[],
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
        'doubts': <Doubt>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'doubts': <Doubt>[],
      };
    }
  }

  /// Get a single doubt by ID with all responses
  Future<Map<String, dynamic>> getDoubtById(String doubtId) async {
    try {
      final response = await _apiService.get('/tickets/$doubtId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'doubt': Doubt.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch doubt details',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  /// Add a response to a doubt
  Future<Map<String, dynamic>> addResponse({
    required String doubtId,
    required String message,
  }) async {
    try {
      final response = await _apiService.post(
        '/tickets/$doubtId/responses',
        data: {
          'message': message,
          'isInternal': false,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Response added successfully',
          'response': DoubtResponse.fromJson(response.data['data']),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to add response',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  /// Get ticket statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get('/tickets/stats');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'stats': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch statistics',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  /// Get subjects from backend
  Future<Map<String, dynamic>> getSubjects({String? gradeId, String? boardId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (gradeId != null) queryParams['grade'] = gradeId;
      if (boardId != null) queryParams['board'] = boardId;

      final response = await _apiService.get(
        '/subjects',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true || response.data['data'] != null) {
        return {
          'success': true,
          'subjects': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch subjects',
          'subjects': [],
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
        'subjects': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'subjects': [],
      };
    }
  }

  /// Get chapters for a subject
  Future<Map<String, dynamic>> getChapters(String subjectId) async {
    try {
      final response = await _apiService.get('/chapters?subject=$subjectId');

      if (response.data['success'] == true || response.data['data'] != null) {
        return {
          'success': true,
          'chapters': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch chapters',
          'chapters': [],
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
        'chapters': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'chapters': [],
      };
    }
  }

  /// Get available mentors
  Future<Map<String, dynamic>> getMentors({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get(
        '/mentors',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true || response.data['data'] != null) {
        return {
          'success': true,
          'mentors': response.data['data'],
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch mentors',
          'mentors': [],
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
        'mentors': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'mentors': [],
      };
    }
  }

  /// Helper method to handle errors
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'];
      }
      
      switch (error.response?.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Resource not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    } else {
      return 'Network error occurred.';
    }
  }
}
