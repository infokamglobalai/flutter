import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/notification_model.dart';
import 'package:najahapp/app/modules/notifications/controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey[800],
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            final unreadCount = controller.unreadCount.value;
            if (unreadCount > 0) {
              return TextButton(
                onPressed: controller.markAllAsRead,
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when something arrives',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          color: AppTheme.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _buildNotificationCard(notification, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    final isRead = notification.isRead;
    final type = notification.type;
    final title = notification.title;
    final message = notification.message;
    final time = notification.timeAgo;

    final typeConfig = _getNotificationTypeConfig(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isRead
            ? null
            : Border.all(color: typeConfig['color'].withOpacity(0.2), width: 2),
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
          onTap: () {
            controller.markAsRead(index);
            _showNotificationDetail(notification);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeConfig['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeConfig['icon'],
                    color: typeConfig['color'],
                    size: 24,
                  ),
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
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: typeConfig['color'],
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getNotificationTypeConfig(String type) {
    switch (type) {
      case 'course':
        return {'icon': Icons.school_rounded, 'color': const Color(0xFF6366F1)};
      case 'assessment':
        return {
          'icon': Icons.assignment_turned_in_rounded,
          'color': const Color(0xFF10B981),
        };
      case 'payment':
        return {
          'icon': Icons.payment_rounded,
          'color': const Color(0xFFF59E0B),
        };
      case 'announcement':
        return {
          'icon': Icons.campaign_rounded,
          'color': const Color(0xFFEC4899),
        };
      case 'reminder':
        return {'icon': Icons.alarm_rounded, 'color': const Color(0xFF8B5CF6)};
      case 'achievement':
        return {
          'icon': Icons.emoji_events_rounded,
          'color': const Color(0xFFF59E0B),
        };
      case 'mentor_message':
        return {
          'icon': Icons.message_rounded,
          'color': const Color(0xFF06B6D4),
        };
      case 'ticket':
        return {
          'icon': Icons.support_agent_rounded,
          'color': const Color(0xFF8B5CF6),
        };
      case 'subscription':
        return {
          'icon': Icons.card_membership_rounded,
          'color': const Color(0xFFF59E0B),
        };
      case 'system':
        return {'icon': Icons.info_rounded, 'color': const Color(0xFF3B82F6)};
      default:
        return {
          'icon': Icons.notifications_rounded,
          'color': AppTheme.primaryColor,
        };
    }
  }

  void _showNotificationDetail(NotificationModel notification) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getNotificationTypeConfig(
                        notification.type,
                      )['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getNotificationTypeConfig(notification.type)['icon'],
                      color: _getNotificationTypeConfig(
                        notification.type,
                      )['color'],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              if (notification.metadata?.audioUrl != null) ...[
                const SizedBox(height: 16),
                _NotifAudioPlayer(
                  audioUrl: notification.metadata!.audioUrl!,
                  typeColor: _getNotificationTypeConfig(
                    notification.type,
                  )['color'],
                ),
              ],
              if (notification.metadata?.action != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Handle action - can use notification.metadata?.actionUrl
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getNotificationTypeConfig(
                        notification.type,
                      )['color'],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      notification.metadata!.action!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final Color typeColor;

  const _NotifAudioPlayer({required this.audioUrl, required this.typeColor});

  @override
  State<_NotifAudioPlayer> createState() => _NotifAudioPlayerState();
}

class _NotifAudioPlayerState extends State<_NotifAudioPlayer> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted)
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      final url = ApiConstants.baseUrl.replaceAll('/api', '') + widget.audioUrl;
      await _player.play(UrlSource(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.typeColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.headphones_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                'Voice Announcement',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: color,
                        inactiveTrackColor: color.withOpacity(0.2),
                        thumbColor: color,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        trackHeight: 3,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: _duration.inSeconds > 0
                            ? _position.inSeconds.toDouble().clamp(
                                0,
                                _duration.inSeconds.toDouble(),
                              )
                            : 0.0,
                        max: _duration.inSeconds > 0
                            ? _duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (v) =>
                            _player.seek(Duration(seconds: v.toInt())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fmt(_position),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            _fmt(_duration),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
