import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/data/models/notification_model.dart';

class NotificationService {
  final ApiService _apiService = Get.find<ApiService>();

  // Get all notifications
  Future<Map<String, dynamic>> getAllNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (type != null) queryParams['type'] = type;
      if (isRead != null) queryParams['isRead'] = isRead;

      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final notifications = (data['notifications'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        return {
          'notifications': notifications,
          'pagination': data['pagination'],
          'unreadCount': data['unreadCount'],
        };
      } else {
        throw Exception('Failed to load notifications');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load notifications',
      );
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(ApiConstants.notificationsUnreadCount);

      if (response.statusCode == 200) {
        return response.data['data']['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      // Return 0 if error occurs to prevent app crash
      return 0;
    }
  }

  // Get specific notification
  Future<NotificationModel> getNotificationById(String id) async {
    try {
      final response = await _apiService.get(ApiConstants.notificationById(id));

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data['data']);
      } else {
        throw Exception('Notification not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Notification not found');
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load notification',
      );
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  // Mark notification as read
  Future<NotificationModel> markAsRead(String id) async {
    try {
      final response = await _apiService.patch(ApiConstants.notificationMarkRead(id));

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Notification not found');
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to mark notification as read',
      );
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  Future<int> markAllAsRead() async {
    try {
      final response = await _apiService.patch(ApiConstants.notificationsMarkAllRead);

      if (response.statusCode == 200) {
        return response.data['data']['modifiedCount'] ?? 0;
      } else {
        throw Exception('Failed to mark all notifications as read');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to mark all notifications as read',
      );
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      final response = await _apiService.delete(ApiConstants.notificationById(id));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Notification not found');
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete notification',
      );
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  // Create notification (admin/system use)
  Future<NotificationModel> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String priority = 'medium',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post(
        '/notifications/create',
        data: {
          'userId': userId,
          'type': type,
          'title': title,
          'message': message,
          'priority': priority,
          'metadata': metadata,
        },
      );

      if (response.statusCode == 201) {
        return NotificationModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create notification');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create notification',
      );
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }
}
