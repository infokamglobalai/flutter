import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'package:image_picker/image_picker.dart';

class StudentProfileView extends GetView<DashboardController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Load progress when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadStudentProgress();
    });

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
          'Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        final profile = controller.studentProfile.value;
        final user = controller.user.value;

        if (profile == null) {
          return _buildLoadingOrError();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileCard(profile, user),
              _buildStatsCards(),
              _buildLevelProgress(),
              _buildMenuItems(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileCard(dynamic profile, dynamic user) {
    String resolveAvatarUrl(String? raw) {
      final v = (raw ?? '').toString().trim();
      if (v.isEmpty) return '';
      if (v.startsWith('http://') || v.startsWith('https://')) return v;
      if (v.startsWith('/uploads/')) return 'https://lms.eduaitutors.com$v';
      if (v.startsWith('uploads/')) return 'https://lms.eduaitutors.com/$v';
      return 'https://lms.eduaitutors.com/uploads/$v';
    }

    final avatarUrl = resolveAvatarUrl(user?.avatar?.toString());

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: AppTheme.primaryColor,
                        )
                      : Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppTheme.primaryColor,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName ?? 'Student',
                      style: const TextStyle(
                        fontSize: 20,
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
            ],
          ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Show student profile details in modal
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow('User ID', profile.userId ?? 'N/A'),
                            _buildDetailRow('Board', profile.board ?? 'N/A'),
                            _buildDetailRow('Grade', profile.grade ?? 'N/A'),
                            if (profile.phone != null && profile.phone!.isNotEmpty)
                              _buildDetailRow('Phone', profile.phone!),
                            if (profile.city != null && profile.city!.isNotEmpty)
                              _buildDetailRow('City', profile.city!),
                            if (profile.state != null && profile.state!.isNotEmpty)
                              _buildDetailRow('State', profile.state!),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Close'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isScrollControlled: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showEditProfileModal(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(dynamic user) {
    if (user == null) return;
    
    // Split name safely
    final nameParts = user.name?.split(' ') ?? [];
    final firstNameStr = nameParts.isNotEmpty ? nameParts.first : '';
    final lastNameStr = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    final firstNameController = TextEditingController(text: firstNameStr);
    final lastNameController = TextEditingController(text: lastNameStr);
    final phoneController = TextEditingController(text: user.phone ?? '');

    XFile? picked;
    final picker = ImagePicker();

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setModalState) {
                    String resolveAvatarUrl(String? raw) {
                      final v = (raw ?? '').toString().trim();
                      if (v.isEmpty) return '';
                      if (v.startsWith('http://') || v.startsWith('https://')) {
                        return v;
                      }
                      if (v.startsWith('/uploads/')) {
                        return 'https://lms.eduaitutors.com$v';
                      }
                      if (v.startsWith('uploads/')) {
                        return 'https://lms.eduaitutors.com/$v';
                      }
                      return 'https://lms.eduaitutors.com/uploads/$v';
                    }

                    final currentAvatarUrl = picked != null
                        ? picked!.path
                        : resolveAvatarUrl(user.avatar?.toString());

                    return Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: ClipOval(
                            child: picked != null
                                ? Image.network(
                                    picked!.path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(
                                      Icons.person_rounded,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : (currentAvatarUrl.isEmpty
                                    ? Icon(
                                        Icons.person_rounded,
                                        color: AppTheme.primaryColor,
                                      )
                                    : Image.network(
                                        currentAvatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Icon(
                                          Icons.person_rounded,
                                          color: AppTheme.primaryColor,
                                        ),
                                      )),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() {
                            final busy = controller.isUpdatingProfilePicture.value;
                            return OutlinedButton.icon(
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final img = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 85,
                                      );
                                      if (img == null) return;
                                      setModalState(() => picked = img);
                                      await controller.updateProfilePicture(img);
                                    },
                              icon: busy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.photo_camera_back_rounded),
                              label: Text(busy ? 'Uploading…' : 'Change photo'),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isUpdatingProfile.value
                        ? null
                        : () {
                            controller.updateProfile(
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                              phone: phoneController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isUpdatingProfile.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      final progressData = controller.studentProgressData.value;
      int completedVideos = 0;
      int passedQuizzes = 0;

      if (progressData != null) {
        final packages = progressData['packages'] as List<dynamic>? ?? [];
        for (var package in packages) {
          final chapters = package['chapters'] as List<dynamic>? ?? [];
          for (var chapter in chapters) {
            if (chapter['videoCompleted'] == true) {
              completedVideos++;
            }
            final assessment = chapter['assessment'];
            if (assessment != null && assessment['attempts'] > 0) {
              final percentage = ((assessment['percentage'] ?? 0) as num)
                  .toDouble();
              if (percentage >= 60) {
                passedQuizzes++;
              }
            }
          }
          final selfAssessments =
              package['selfAssessments'] as List<dynamic>? ?? [];
          for (var selfAssessment in selfAssessments) {
            final percentage = ((selfAssessment['percentage'] ?? 0) as num)
                .toDouble();
            if (percentage >= 60) {
              passedQuizzes++;
            }
          }
        }
      }

      // Calculate XP (example calculation)
      final xp = (completedVideos * 50) + (passedQuizzes * 100);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '$xp XP',
                'Weekly\nProgress',
                Icons.trending_up_rounded,
                const Color(0xFFE3F2FD),
                const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '$completedVideos',
                'Lessons\nCompleted',
                Icons.play_circle_outline_rounded,
                const Color(0xFFFCE4EC),
                const Color(0xFFC2185B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '$passedQuizzes',
                'Quizzes\nPassed',
                Icons.emoji_events_outlined,
                const Color(0xFFFFF3E0),
                const Color(0xFFF57C00),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    return Obx(() {
      final progressData = controller.studentProgressData.value;
      int completedVideos = 0;
      int totalVideos = 0;

      if (progressData != null) {
        final packages = progressData['packages'] as List<dynamic>? ?? [];
        for (var package in packages) {
          final chapters = package['chapters'] as List<dynamic>? ?? [];
          for (var chapter in chapters) {
            totalVideos++;
            if (chapter['videoCompleted'] == true) {
              completedVideos++;
            }
          }
        }
      }

      // Calculate level (example calculation)
      final level = (completedVideos / 10).floor() + 1;
      final currentLevelXP = (completedVideos * 50) % 10000;
      final percentage = totalVideos > 0 ? (currentLevelXP / 10000) * 100 : 0.0;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $level Learner',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$currentLevelXP XP / 10,000 XP',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuItems() {
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
        children: [
          _buildMenuItem(
            icon: Icons.payment_rounded,
            iconColor: const Color(0xFF059669),
            iconBgColor: const Color(0xFFD1FAE5),
            title: 'Payment History',
            onTap: () {
              // Navigate to payment history
              Get.toNamed('/payment-history');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF7C3AED),
            iconBgColor: const Color(0xFFEDE9FE),
            title: 'My Packages',
            onTap: () {
              // Show only enrolled packages (subscriptions)
              Get.toNamed(Routes.MY_SUBSCRIPTIONS);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFFEA580C),
            iconBgColor: const Color(0xFFFFEDD5),
            title: 'My Progress',
            onTap: () {
              // Navigate to student progress view
              Get.toNamed(Routes.STUDENT_PROGRESS);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFF3B82F6),
            iconBgColor: const Color(0xFFDBEAFE),
            title: 'Notifications',
            onTap: () {
              Get.toNamed('/notifications');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            iconColor: const Color(0xFF64748B),
            iconBgColor: const Color(0xFFF1F5F9),
            title: 'Settings',
            onTap: () {
              Get.toNamed('/settings');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFDC2626),
            iconBgColor: const Color(0xFFFEE2E2),
            title: 'Logout',
            onTap: () async {
              // Show confirmation dialog
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final authController = Get.find<AuthController>();
                await authController.logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? badge,
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOrError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Profile information not available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
