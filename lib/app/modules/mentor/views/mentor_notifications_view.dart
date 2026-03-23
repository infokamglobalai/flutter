import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/mentor/controllers/mentor_dashboard_controller.dart';

class MentorNotificationsView extends GetView<MentorDashboardController> {
  const MentorNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6A3DE8),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _markAllAsRead(),
            icon: const Icon(
              Icons.done_all_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final notifications = _getAllNotifications();

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A3DE8).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification);
          },
        );
      }),
    );
  }

  List<Map<String, dynamic>> _getAllNotifications() {
    List<Map<String, dynamic>> allNotifications = [];

    // Add unread messages
    for (var message in controller.messages) {
      if (!(message['read'] ?? true)) {
        allNotifications.add({
          'type': 'message',
          'title': 'New Message',
          'subtitle': message['from'] ?? 'Student',
          'message': message['message'],
          'time': message['timestamp'] ?? DateTime.now(),
          'icon': Icons.message_rounded,
          'color': const Color(0xFF3B82F6),
          'data': message,
        });
      }
    }

    // Add unanswered questions
    for (var question in controller.studentQuestions) {
      if (!(question['answered'] ?? false)) {
        allNotifications.add({
          'type': 'question',
          'title': 'Student Question',
          'subtitle': question['studentName'] ?? 'Student',
          'message': question['question'],
          'time': question['timestamp'] ?? DateTime.now(),
          'icon': Icons.help_outline_rounded,
          'color': const Color(0xFFFF9800),
          'data': question,
        });
      }
    }

    // Add pending coaching requests
    for (var request in controller.coachingRequests) {
      if (request['status'] == 'pending') {
        allNotifications.add({
          'type': 'coaching',
          'title': 'Coaching Request',
          'subtitle': request['studentName'] ?? 'Student',
          'message': request['message'] ?? 'New coaching session request',
          'time': request['timestamp'] ?? DateTime.now(),
          'icon': Icons.school_outlined,
          'color': const Color(0xFF8B5CF6),
          'data': request,
        });
      }
    }

    // Add upcoming sessions
    for (var session in controller.bookedSessions) {
      final sessionTime = session['dateTime'] as DateTime? ?? DateTime.now();
      final timeDiff = sessionTime.difference(DateTime.now());

      if (timeDiff.inHours > 0 && timeDiff.inHours <= 24) {
        allNotifications.add({
          'type': 'session',
          'title': 'Upcoming Session',
          'subtitle': session['studentName'] ?? 'Student',
          'message': 'Session scheduled for ${_formatDateTime(sessionTime)}',
          'time': sessionTime,
          'icon': Icons.video_call_rounded,
          'color': const Color(0xFF10B981),
          'data': session,
        });
      }
    }

    // Add pending assessment submissions
    if (controller.pendingSubmissionsCount.value > 0) {
      allNotifications.add({
        'type': 'assessment',
        'title': 'Pending Submissions',
        'subtitle': '${controller.pendingSubmissionsCount.value} assessments',
        'message': 'Students have submitted assessments for review',
        'time': DateTime.now(),
        'icon': Icons.assignment_turned_in_rounded,
        'color': const Color(0xFFFF6B6B),
        'data': {},
      });
    }

    // Sort by time (most recent first)
    allNotifications.sort((a, b) {
      final timeA = a['time'] as DateTime;
      final timeB = b['time'] as DateTime;
      return timeB.compareTo(timeA);
    });

    return allNotifications;
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final title = notification['title'] as String;
    final subtitle = notification['subtitle'] as String;
    final message = notification['message'] as String;
    final time = notification['time'] as DateTime;
    final icon = notification['icon'] as IconData;
    final color = notification['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Text(
                            _formatTimeAgo(time),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    Get.back(); // Go back to dashboard

    switch (type) {
      case 'message':
        controller.selectTab(2); // Messages tab
        break;
      case 'question':
        controller.selectTab(3); // Q&A tab
        break;
      case 'coaching':
        controller.selectTab(4); // Coaching requests tab
        break;
      case 'session':
        controller.selectTab(5); // Calendar tab
        break;
      case 'assessment':
        controller.selectTab(6); // Assessments tab
        break;
    }
  }

  void _markAllAsRead() {
    // Mark all messages as read
    for (var message in controller.messages) {
      message['read'] = true;
    }

    // Update counts
    controller.unreadCount.value = 0;

    Get.snackbar(
      'Success',
      'All notifications marked as read',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = 'Today';
    } else if (date == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr at $hour:$minute $period';
  }
}
