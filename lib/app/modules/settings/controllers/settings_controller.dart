import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Observable settings
  final pushNotifications = true.obs;
  final emailNotifications = true.obs;
  final reminderAlerts = true.obs;
  final darkMode = false.obs;

  // Preference keys
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _reminderAlertsKey = 'reminder_alerts';
  static const String _darkModeKey = 'dark_mode';

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      pushNotifications.value = prefs.getBool(_pushNotificationsKey) ?? true;
      emailNotifications.value = prefs.getBool(_emailNotificationsKey) ?? true;
      reminderAlerts.value = prefs.getBool(_reminderAlertsKey) ?? true;
      darkMode.value = prefs.getBool(_darkModeKey) ?? false;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> togglePushNotifications(bool value) async {
    try {
      pushNotifications.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pushNotificationsKey, value);

      Get.snackbar(
        'Push Notifications',
        value ? 'Push notifications enabled' : 'Push notifications disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error saving push notifications setting: $e');
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
      print('Error saving email notifications setting: $e');
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
      print('Error saving reminder alerts setting: $e');
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

      // You can implement theme switching here if needed
      // Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      print('Error saving dark mode setting: $e');
    }
  }

  void navigateToPersonalInformation() {
    Get.snackbar(
      'Personal Information',
      'This feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToChangeEmail() {
    Get.snackbar(
      'Change Email',
      'This feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToChangePassword() {
    Get.snackbar(
      'Change Password',
      'This feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToHelpSupport() {
    Get.snackbar(
      'Help & Support',
      'This feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToAboutUs() {
    Get.snackbar(
      'About Us',
      'This feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
