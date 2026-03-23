import 'package:get/get.dart';
import 'package:najahapp/app/data/models/notification_model.dart';
import 'package:najahapp/app/data/services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      notifications.clear();
    }

    if (!hasMore.value && !refresh) return;

    isLoading.value = true;

    try {
      final result = await _notificationService.getAllNotifications(
        page: currentPage.value,
        limit: 20,
      );

      final List<NotificationModel> newNotifications = result['notifications'];
      final pagination = result['pagination'];

      if (refresh) {
        notifications.value = newNotifications;
      } else {
        notifications.addAll(newNotifications);
      }

      unreadCount.value = result['unreadCount'];
      hasMore.value = currentPage.value < pagination['pages'];

      if (hasMore.value) {
        currentPage.value++;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];

      if (!notification.isRead) {
        try {
          await _notificationService.markAsRead(notification.id);

          // Update local state
          notifications[index] = notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          notifications.refresh();
          _updateUnreadCount();
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to mark notification as read',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local state
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      }
      notifications.refresh();
      unreadCount.value = 0;

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteNotification(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];

      try {
        await _notificationService.deleteNotification(notification.id);

        // Update local state
        notifications.removeAt(index);
        _updateUnreadCount();

        Get.snackbar(
          'Success',
          'Notification deleted',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete notification',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount.value = await _notificationService.getUnreadCount();
    } catch (e) {
      // Silently fail for unread count
    }
  }
}
