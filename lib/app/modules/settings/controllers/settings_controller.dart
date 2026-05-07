import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/fcm_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Observable settings
  final pushNotifications = true.obs;
  final emailNotifications = true.obs;
  final reminderAlerts = true.obs;
  final darkMode = false.obs;

  FCMService? _fcmService;

  // Preference keys
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _reminderAlertsKey = 'reminder_alerts';
  static const String _darkModeKey = 'dark_mode';

  @override
  void onInit() {
    super.onInit();
    // FCMService should be registered at app start. If it's not, we still keep
    // the Settings screen functional (push toggle will just persist locally).
    if (Get.isRegistered<FCMService>()) {
      _fcmService = Get.find<FCMService>();
    }
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      pushNotifications.value = prefs.getBool(_pushNotificationsKey) ?? true;
      emailNotifications.value = prefs.getBool(_emailNotificationsKey) ?? true;
      reminderAlerts.value = prefs.getBool(_reminderAlertsKey) ?? true;
      darkMode.value = prefs.getBool(_darkModeKey) ?? false;

      // Apply persisted theme on launch.
      Get.changeThemeMode(darkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      // Best-effort; keep defaults.
    }
  }

  Future<void> togglePushNotifications(bool value) async {
    try {
      pushNotifications.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pushNotificationsKey, value);

      if (value) {
        final fcm = _fcmService;
        if (fcm == null) {
          Get.snackbar(
            'Push Notifications',
            'Notification service not ready yet. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        final granted = await fcm.requestNotificationPermission();
        if (!granted) {
          // Permission denied → revert toggle so UI reflects reality.
          pushNotifications.value = false;
          await prefs.setBool(_pushNotificationsKey, false);
          Get.snackbar(
            'Push Notifications',
            'Permission denied. Enable notifications in device settings.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          return;
        }
        // Ensure FCM is initialized and token is available.
        await fcm.initializeFCM();
        await fcm.sendTokenAfterLogin();
      } else {
        final fcm = _fcmService;
        if (fcm == null) {
          return;
        }
        // Best-effort: remove token so backend stops sending pushes.
        await fcm.removeTokenOnLogout();
        await fcm.deleteToken();
      }

      Get.snackbar(
        'Push Notifications',
        value ? 'Push notifications enabled' : 'Push notifications disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Best-effort; keep UI responsive.
    }
  }

  Future<void> toggleEmailNotifications(bool value) async {
    try {
      emailNotifications.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_emailNotificationsKey, value);

      Get.snackbar(
        'Email Notifications',
        value ? 'Email notifications enabled' : 'Email notifications disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Best-effort.
    }
  }

  Future<void> toggleReminderAlerts(bool value) async {
    try {
      reminderAlerts.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderAlertsKey, value);

      Get.snackbar(
        'Reminder Alerts',
        value ? 'Reminder alerts enabled' : 'Reminder alerts disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Best-effort.
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    try {
      darkMode.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);

      Get.snackbar(
        'Dark Mode',
        value ? 'Dark mode enabled' : 'Dark mode disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Apply theme immediately.
      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      // Best-effort.
    }
  }

  void navigateToPersonalInformation() {
    Get.toNamed(Routes.STUDENT_PROFILE);
  }

  void navigateToChangeEmail() {
    // Email is part of profile identity; show profile screen.
    Get.toNamed(Routes.STUDENT_PROFILE);
  }

  void navigateToChangePassword() {
    // Uses OTP flow in-app.
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  void navigateToHelpSupport() {
    Get.toNamed(Routes.STUDENT_SUPPORT);
  }

  void navigateToAboutUs() {
    // Keep it simple: route to support entry which includes app info/help.
    Get.toNamed(Routes.STUDENT_SUPPORT);
  }
}
