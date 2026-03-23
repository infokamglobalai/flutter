import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Notification channel constants ────────────────────────────────────────
const String _kGeneralChannelId   = 'najah_notifications';
const String _kGeneralChannelName = 'Najah Notifications';
const String _kMentorChannelId    = 'najah_mentor_high';
const String _kMentorChannelName  = 'Mentor Notifications';
const String _kMentorUrgentChannelId   = 'najah_mentor_urgent';
const String _kMentorUrgentChannelName = 'Mentor Urgent Alerts';

// ─── Mentor FCM push-notification types (must match backend data["type"]) ──
// mentor_message      → new student message
// mentor_qna          → unanswered student question
// coaching_request    → new coaching request
// session_booked      → student booked a session (pending confirmation)
// session_reminder    → session starting in < 1 h
// assessment_submit   → student submitted an assessment
// student_feedback    → new video feedback / rating
// low_rated_content   → video average rating < 3 stars
// ticket_open         → new support ticket opened
// ticket_update       → support ticket status changed
// announcement_reply  → student replied to an announcement

/// Background message handler – must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

class FCMService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  final RxString fcmToken = ''.obs;
  final RxBool isInitialized = false.obs;
  final RxBool permissionGranted = false.obs;

  // Stream controller for notification taps
  final StreamController<Map<String, dynamic>> notificationTapStream =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  void onInit() {
    super.onInit();
    print('⚡ FCMService onInit called');
    // Initialize FCM async but don't await to avoid blocking
    initializeFCM().catchError((error) {
      print('❌ Fatal FCM initialization error: $error');
      print('   Stack trace: ${StackTrace.current}');
    });
  }

  @override
  void onClose() {
    notificationTapStream.close();
    super.onClose();
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> initializeFCM() async {
    try {
      print('🔧 Starting FCM initialization...');

      // Initialize local notifications first
      print('   Initializing local notifications...');
      await _initializeLocalNotifications();

      // Request permission for iOS
      if (Platform.isIOS) {
        print('   Requesting iOS permissions...');
        await _requestIOSPermission();
      }

      // Request permission for Android 13+
      print('   Requesting Android permissions...');
      await _requestAndroidPermission();

      // Get FCM token
      print('   Getting FCM token...');
      await _getFCMToken();

      // Configure foreground notification presentation
      print('   Configuring foreground presentation...');
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Set up message handlers
      print('   Setting up message handlers...');
      _setupMessageHandlers();

      // Set up background message handler
      print('   Setting up background handler...');
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      isInitialized.value = true;
      print('✅ FCM Service initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Error initializing FCM: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  /// Initialize local notifications (plus dedicated Android mentor channels)
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create dedicated Android notification channels
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // General channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kGeneralChannelId,
          _kGeneralChannelName,
          description: 'General notifications from Najah App',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Mentor high-priority channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kMentorChannelId,
          _kMentorChannelName,
          description: 'Mentor activity — messages, Q&A, coaching, sessions, assessments',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Mentor urgent channel (imminent sessions, low-rated content)
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kMentorUrgentChannelId,
          _kMentorUrgentChannelName,
          description: 'Urgent mentor alerts — imminent sessions, low-rated content',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      );
    }

    print('✅ Local notifications initialized (mentor channels created)');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    if (response.payload != null) {
      // Parse payload and navigate
      try {
        final data = <String, dynamic>{};
        notificationTapStream.add(data);
        _navigateToNotification(data);
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Request iOS notification permissions
  Future<void> _requestIOSPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('iOS permission status: ${settings.authorizationStatus}');
    permissionGranted.value =
        settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request Android 13+ notification permissions
  Future<void> _requestAndroidPermission() async {
    if (Platform.isAndroid) {
      try {
        // Check if Android 13+ (API 33+)
        final status = await Permission.notification.status;
        print('📱 Android notification permission status: $status');

        if (status.isDenied) {
          print('   Requesting notification permission...');
          final result = await Permission.notification.request();
          permissionGranted.value = result.isGranted;

          if (result.isGranted) {
            print('✅ Notification permission granted');
          } else if (result.isPermanentlyDenied) {
            print('❌ Notification permission permanently denied');
            _showPermissionDeniedMessage();
          } else {
            print('⚠️  Notification permission denied');
          }
        } else if (status.isGranted) {
          permissionGranted.value = true;
          print('✅ Notification permission already granted');
        } else if (status.isPermanentlyDenied) {
          permissionGranted.value = false;
          print('❌ Notification permission permanently denied');
          _showPermissionDeniedMessage();
        }
      } catch (e) {
        print('❌ Error requesting Android notification permission: $e');
      }
    }
  }

  /// Show permission denied message
  void _showPermissionDeniedMessage() {
    Get.snackbar(
      'Notifications Disabled',
      'Please enable notifications in your device settings to receive updates',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () => openAppSettings(),
        child: const Text(
          'Open Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Get FCM token and save it
  Future<void> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        print('📱 FCM Token: $token');
        print('   Token length: ${token.length}');

        // Save token to storage
        await _storageService.saveFCMToken(token);
        print('   Token saved to storage');

        // Send token to backend
        await _sendTokenToBackend(token);
      } else {
        print('❌ Failed to get FCM token');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        fcmToken.value = newToken;
        _storageService.saveFCMToken(newToken);
        _sendTokenToBackend(newToken);
      });
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Check if user is authenticated using both the persistent token and the
      // ApiService in-memory cache.  If either is missing the user is not (or
      // is no longer) logged in and we should defer until after login.
      final authToken = await _storageService.getToken();
      if (authToken == null || authToken.isEmpty) {
        print('⏭️  User not authenticated, skipping FCM token send');
        print('   Token will be sent after login');
        return;
      }
      if (!_apiService.hasToken) {
        print('⏭️  ApiService has no cached token, skipping FCM token send');
        print('   Token will be sent after login');
        return;
      }

      print('📤 Sending FCM token to backend...');
      await _apiService.post(
        '/auth/fcm-token',
        data: {'fcmToken': token, 'platform': Platform.operatingSystem},
      );
      print('✅ FCM token sent to backend successfully');
    } catch (e) {
      print('❌ Error sending FCM token to backend: $e');
      print('   This is expected if user is not logged in');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification tap when app is terminated
    _handleInitialMessage();
  }

  /// Handle foreground messages with mentor-specific channel routing.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Foreground message received: ${message.messageId}');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    final notification = message.notification;
    final data = message.data;
    final type = data['type'] as String? ?? '';

    if (notification != null) {
      final (channelId, channelName) = _channelForType(type);
      await _showLocalNotificationOnChannel(
        channelId: channelId,
        channelName: channelName,
        title: notification.title ?? 'Najah',
        body: notification.body ?? '',
        payload: data,
        type: type,
      );

      // Show in-app snackbar while mentor is using the app
      if (_isMentorType(type)) {
        _showMentorInAppSnackbar(
          title: notification.title ?? 'New Notification',
          body: notification.body ?? '',
          type: type,
          data: data,
        );
      }

      _refreshNotificationCount();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Mentor topic subscriptions
  // ─────────────────────────────────────────────────────────────────────────

  /// Subscribe this device to all mentor FCM topics.
  /// Call this immediately after a mentor logs in.
  Future<void> subscribeToMentorTopics(String mentorId) async {
    await subscribeToTopic('mentors');
    if (mentorId.isNotEmpty) await subscribeToTopic('mentor_$mentorId');
    print('✅ Subscribed to mentor topics (mentors, mentor_$mentorId)');
  }

  /// Unsubscribe this device from all mentor FCM topics.
  /// Call this on mentor logout.
  Future<void> unsubscribeFromMentorTopics(String mentorId) async {
    await unsubscribeFromTopic('mentors');
    if (mentorId.isNotEmpty) await unsubscribeFromTopic('mentor_$mentorId');
    print('✅ Unsubscribed from mentor topics');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────────────

  bool _isMentorType(String type) {
    const mentorTypes = {
      'mentor_message', 'mentor_qna', 'coaching_request',
      'session_booked', 'session_reminder', 'assessment_submit',
      'student_feedback', 'low_rated_content', 'ticket_update',
      'ticket_open', 'announcement_reply',
    };
    return mentorTypes.contains(type);
  }

  (String, String) _channelForType(String type) {
    if (type == 'session_reminder' || type == 'low_rated_content') {
      return (_kMentorUrgentChannelId, _kMentorUrgentChannelName);
    }
    if (_isMentorType(type)) {
      return (_kMentorChannelId, _kMentorChannelName);
    }
    return (_kGeneralChannelId, _kGeneralChannelName);
  }

  /// Show an in-app snackbar for mentor foreground notifications.
  void _showMentorInAppSnackbar({
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
  }) {
    final (icon, color) = _iconColorForType(type);
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      backgroundColor: color,
      colorText: Colors.white,
      borderRadius: 14,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      icon: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          _navigateToNotification(data);
        },
        child: const Text(
          'View',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  (IconData, Color) _iconColorForType(String type) {
    switch (type) {
      case 'mentor_message':     return (Icons.message_rounded,               const Color(0xFF3B82F6));
      case 'mentor_qna':         return (Icons.help_outline_rounded,          const Color(0xFFFF9800));
      case 'coaching_request':   return (Icons.school_outlined,               const Color(0xFF8B5CF6));
      case 'session_booked':     return (Icons.event_rounded,                 const Color(0xFF10B981));
      case 'session_reminder':   return (Icons.video_call_rounded,            const Color(0xFFEF4444));
      case 'assessment_submit':  return (Icons.assignment_turned_in_rounded,  const Color(0xFFFF6B6B));
      case 'student_feedback':   return (Icons.rate_review_rounded,           const Color(0xFFF59E0B));
      case 'low_rated_content':  return (Icons.star_half_rounded,             const Color(0xFFEF4444));
      case 'ticket_open':        return (Icons.confirmation_number_rounded,   const Color(0xFF6366F1));
      case 'ticket_update':      return (Icons.pending_actions_rounded,       const Color(0xFF0EA5E9));
      case 'announcement_reply': return (Icons.campaign_rounded,              const Color(0xFF14B8A6));
      default:                   return (Icons.notifications_rounded,         const Color(0xFF6A3DE8));
    }
  }

  Color _colorForType(String type) => _iconColorForType(type).$2;

  /// Show a local notification on a specific Android channel.
  Future<void> _showLocalNotificationOnChannel({
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    String type = '',
  }) async {
    try {
      final isUrgent = channelId == _kMentorUrgentChannelId;
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelName,
        importance: isUrgent ? Importance.max : Importance.high,
        priority: isUrgent ? Priority.max : Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        enableLights: isUrgent,
        color: _colorForType(type),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload?.toString(),
      );

      print('✅ Local notification shown [$channelId]: $title');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  // Legacy wrapper — kept so any existing callers still compile
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) =>
      _showLocalNotificationOnChannel(
        channelId: _kGeneralChannelId,
        channelName: _kGeneralChannelName,
        title: title,
        body: body,
        payload: payload,
      );

  /// Handle notification opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📬 Notification opened: ${message.messageId}');
    _navigateToNotification(message.data);
  }

  /// Handle initial message when app is opened from terminated state
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();

    if (initialMessage != null) {
      print('🚀 App opened from notification: ${initialMessage.messageId}');
      _navigateToNotification(initialMessage.data);
    }
  }

  /// Navigate based on notification data — handles both student and mentor types.
  ///
  /// Mentor tab indices (mirror MentorDashboardController.selectTab):
  ///   0=Overview  1=Reports  2=Messages  3=Q&A  4=Coaching
  ///   5=Calendar  6=Assessments  7=Announcements  8=Feedback  9=Support
  void _navigateToNotification(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final resourceId = data['resourceId'] as String?;

    switch (type) {
      // ── Student / general ──────────────────────────────────────────────
      case 'course':
        if (resourceId != null) Get.toNamed('/course/$resourceId');
        break;
      case 'assessment':
        if (resourceId != null) Get.toNamed('/assessment/$resourceId');
        break;
      case 'payment':
        Get.toNamed('/payment-history');
        break;
      case 'ticket':
        if (resourceId != null) Get.toNamed('/ticket/$resourceId');
        break;

      // ── Mentor — navigate to mentor dashboard + correct tab ────────────
      case 'mentor_message':
        _openMentorDashboardTab(2);
        break;
      case 'mentor_qna':
        _openMentorDashboardTab(3);
        break;
      case 'coaching_request':
        _openMentorDashboardTab(4);
        break;
      case 'session_booked':
      case 'session_reminder':
        _openMentorDashboardTab(5);
        break;
      case 'assessment_submit':
        _openMentorDashboardTab(6);
        break;
      case 'announcement_reply':
        _openMentorDashboardTab(7);
        break;
      case 'student_feedback':
      case 'low_rated_content':
        _openMentorDashboardTab(8);
        break;
      case 'ticket_open':
      case 'ticket_update':
        _openMentorDashboardTab(9);
        break;

      default:
        Get.toNamed('/mentor-dashboard');
    }
  }

  /// Navigate to the mentor dashboard and switch to [tab].
  void _openMentorDashboardTab(int tab) {
    Get.toNamed('/mentor-dashboard');
    // Give the route time to build, then switch tab
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        // MentorDashboardController is registered without a tag
        final dynamic ctrl =
            Get.find(tag: 'MentorDashboardController');
        (ctrl as dynamic).selectTab(tab);
      } catch (_) {
        try {
          // Fallback: find by type name
          final dynamic ctrl = Get.find();
          (ctrl as dynamic).selectTab(tab);
        } catch (_) {}
      }
    });
  }

  /// Refresh notification count on any active dashboard controller.
  void _refreshNotificationCount() {
    // Student dashboard
    try {
      Get.find<dynamic>().loadNotificationCount();
    } catch (_) {}

    // Mentor dashboard — recompute the notification centre
    try {
      final dynamic ctrl = Get.find();
      if ((ctrl as dynamic).runtimeType.toString() ==
          'MentorDashboardController') {
        (ctrl as dynamic).computeNotifications();
      }
    } catch (_) {}
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      fcmToken.value = '';
      await _storageService.deleteFCMToken();
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }

  /// Send saved FCM token to backend (call after login)
  Future<void> sendTokenAfterLogin() async {
    final token = fcmToken.value;
    if (token.isNotEmpty) {
      await _sendTokenToBackend(token);
    } else {
      // Try to get token from storage
      final savedToken = _storageService.getFCMToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        await _sendTokenToBackend(savedToken);
      }
    }
  }

  /// Check notification permission status
  Future<bool> checkNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      permissionGranted.value = status.isGranted;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      permissionGranted.value =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  /// Request notification permission manually
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      await _requestAndroidPermission();
      return permissionGranted.value;
    } else if (Platform.isIOS) {
      await _requestIOSPermission();
      return permissionGranted.value;
    }
    return false;
  }

  /// Get FCM token (useful for debugging)
  String? getToken() {
    return fcmToken.value.isEmpty ? null : fcmToken.value;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Public local-push API for the MentorDashboardController trigger points
  // ─────────────────────────────────────────────────────────────────────────

  /// Show a local push notification for a mentor event.
  ///
  /// [type] must be one of the mentor FCM types listed at the top of this file.
  /// This is called by MentorDashboardController._fcmShowLocal() immediately
  /// after new data is loaded from the backend.
  ///
  /// Trigger-point map (what calls this and when):
  ///
  /// | type                 | Called after                          | Tab |
  /// |----------------------|---------------------------------------|-----|
  /// | mentor_message       | _loadMessages()  → new unread msgs    |  2  |
  /// | mentor_qna           | loadMentorQnaThreads() → unanswered   |  3  |
  /// | coaching_request     | _loadCoachingRequests() → pending     |  4  |
  /// | session_reminder     | _loadCalendarData() → starts < 1h    |  5  |
  /// | assessment_submit    | _loadAssessments() → pendingCount > 0 |  6  |
  /// | announcement_reply   | sendAnnouncement() → delivered        |  7  |
  /// | student_feedback     | _loadFeedbacksAndRatings() → unreplied|  8  |
  /// | low_rated_content    | _loadFeedbacksAndRatings() → avg < 3.5|  8  |
  /// | ticket_open          | _loadSupportTickets() → open > 0      |  9  |
  Future<void> showMentorLocalNotification({
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? extra,
  }) async {
    if (!isInitialized.value) return;
    final (channelId, channelName) = _channelForType(type);
    await _showLocalNotificationOnChannel(
      channelId: channelId,
      channelName: channelName,
      title: title,
      body: body,
      payload: {'type': type, ...?extra},
      type: type,
    );
  }
}
