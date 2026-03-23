import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';

class TicketService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Create a new ticket
  Future<Map<String, dynamic>> createTicket({
    required String category,
    required String subject,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post(
        '/tickets',
        data: {
          'category': category,
          'subject': subject,
          'description': description,
          if (metadata != null) 'metadata': metadata,
        },
      );

      return response.data;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all tickets for the current user
  Future<Map<String, dynamic>> getTickets({
    int page = 1,
    int limit = 10,
    String? status,
    String? category,
    String? priority,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get(
        '/tickets',
        queryParameters: queryParams,
      );

      return response.data;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single ticket by ID
  Future<Map<String, dynamic>> getTicketById(String ticketId) async {
    try {
      final response = await _apiService.get('/tickets/$ticketId');
      return response.data;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add a response to a ticket
  Future<Map<String, dynamic>> addTicketResponse({
    required String ticketId,
    required String message,
    bool isInternal = false,
  }) async {
    try {
      final response = await _apiService.post(
        '/tickets/$ticketId/responses',
        data: {'message': message, 'isInternal': isInternal},
      );

      return response.data;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update ticket (admin only)
  Future<Map<String, dynamic>> updateTicket({
    required String ticketId,
    String? status,
    String? priority,
    String? assignedTo,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (priority != null) data['priority'] = priority;
      if (assignedTo != null) data['assignedTo'] = assignedTo;

      final response = await _apiService.put('/tickets/$ticketId', data: data);

      return response.data;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete ticket (admin only)
  Future<Map<String, dynamic>> deleteTicket(String ticketId) async {
    try {
      final response = await _apiService.delete('/tickets/$ticketId');
      return response.data;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get ticket statistics (admin only)
  Future<Map<String, dynamic>> getTicketStats() async {
    try {
      final response = await _apiService.get('/tickets/stats');
      return response.data;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Convert category enum to API format
  static String categoryToApi(TicketCategory category) {
    switch (category) {
      case TicketCategory.technical:
        return 'technical';
      case TicketCategory.subjectRelated:
        return 'subjectRelated';
      case TicketCategory.paymentRelated:
        return 'paymentRelated';
      case TicketCategory.contentIssue:
        return 'contentIssue';
      case TicketCategory.featureRequest:
        return 'featureRequest';
      case TicketCategory.other:
        return 'other';
    }
  }

  /// Convert API category to enum
  static TicketCategory categoryFromApi(String category) {
    switch (category) {
      case 'technical':
        return TicketCategory.technical;
      case 'subjectRelated':
        return TicketCategory.subjectRelated;
      case 'paymentRelated':
        return TicketCategory.paymentRelated;
      case 'contentIssue':
        return TicketCategory.contentIssue;
      case 'featureRequest':
        return TicketCategory.featureRequest;
      case 'other':
        return TicketCategory.other;
      default:
        return TicketCategory.other;
    }
  }

  /// Convert status enum to API format
  static String statusToApi(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in-progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }

  /// Convert API status to enum
  static TicketStatus statusFromApi(String status) {
    switch (status) {
      case 'open':
        return TicketStatus.open;
      case 'in-progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  /// Convert priority enum to API format
  static String priorityToApi(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return 'low';
      case TicketPriority.medium:
        return 'medium';
      case TicketPriority.high:
        return 'high';
      case TicketPriority.urgent:
        return 'urgent';
    }
  }

  /// Convert API priority to enum
  static TicketPriority priorityFromApi(String priority) {
    switch (priority) {
      case 'low':
        return TicketPriority.low;
      case 'medium':
        return TicketPriority.medium;
      case 'high':
        return TicketPriority.high;
      case 'urgent':
        return TicketPriority.urgent;
      default:
        return TicketPriority.medium;
    }
  }

  /// Handle DioException and return a user-friendly error message
  String _handleError(dio.DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == dio.DioExceptionType.connectionTimeout ||
        error.type == dio.DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == dio.DioExceptionType.connectionError) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
