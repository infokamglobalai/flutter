import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/settings/controllers/settings_controller.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get dashboard controller for user info
    final dashboardController = Get.find<DashboardController>();

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
          'Settings',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.red.shade400,
                size: 20,
              ),
            ),
            onPressed: () {
              Get.toNamed('/notifications');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(dashboardController),
            const SizedBox(height: 16),
            _buildAccountSettingsSection(),
            const SizedBox(height: 16),
            _buildSupportSection(),
            const SizedBox(height: 16),
            _buildNotificationSettingsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(DashboardController dashboardController) {
    return Obx(() {
      final profile = dashboardController.studentProfile.value;
      final user = dashboardController.user.value;

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            // Name and email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.fullName ?? 'Student',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Arrow button
            InkWell(
              onTap: () {
                Get.toNamed('/student-profile');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAccountSettingsSection() {
    final dashboardController = Get.find<DashboardController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          _buildSettingsItem(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF059669),
            iconBgColor: const Color(0xFFD1FAE5),
            title: 'Personal Information',
            onTap: controller.navigateToPersonalInformation,
          ),
          _buildDivider(),
          Obx(() {
            final user = dashboardController.user.value;
            return _buildSettingsItem(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFF3B82F6),
              iconBgColor: const Color(0xFFDBEAFE),
              title: 'Change Email',
              subtitle: user?.email ?? '',
              onTap: controller.navigateToChangeEmail,
            );
          }),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFD1FAE5),
            title: 'Change Password',
            onTap: controller.navigateToChangePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          _buildSettingsItem(
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFD1FAE5),
            title: 'Help & Support',
            onTap: controller.navigateToHelpSupport,
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFD1FAE5),
            title: 'About Us',
            onTap: controller.navigateToAboutUs,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Obx(
            () => _buildToggleItem(
              title: 'Push Notifications',
              value: controller.pushNotifications.value,
              onChanged: controller.togglePushNotifications,
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildToggleItem(
              title: 'Email Notifications',
              value: controller.emailNotifications.value,
              onChanged: controller.toggleEmailNotifications,
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildToggleItem(
              title: 'Reminder Alerts',
              value: controller.reminderAlerts.value,
              onChanged: controller.toggleReminderAlerts,
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildToggleItem(
              title: 'Dark Mode',
              value: controller.darkMode.value,
              onChanged: controller.toggleDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }
}
