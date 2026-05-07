import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/qna_model.dart';
import '../controllers/mentor_dashboard_controller.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';
import 'mentor_notifications_view.dart';
import 'mentor_qna_chat_view.dart';

class MentorDashboardView extends GetView<MentorDashboardController> {
  const MentorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Obx(() {
                  // Map bottom navigation indices to actual tab indices
                  // BottomNav: 0=Overview, 1=Assessments, 2=Messages, 3=Calendar, 4=More
                  // More menu directly changes selectedTab to: 1=Reports, 3=Q&A, 4=Coaching, 7=Announcements, 8=Feedbacks, 9=Profile, 10=Support
                  switch (controller.selectedTab.value) {
                    case 0:
                      return _buildOverviewTab();
                    case 1:
                      return _buildReportsTab();
                    case 2:
                      return _buildMessagesTab();
                    case 3:
                      return _buildQuestionsTab();
                    case 4:
                      return _buildCoachingRequestsTab();
                    case 5:
                      return _buildCalendarTab();
                    case 6:
                      return _buildAssessmentsTab();
                    case 7:
                      return _buildAnnouncementsTab();
                    case 8:
                      return _buildFeedbacksTab();
                    case 9:
                      return _buildProfileTab();
                    case 10:
                      return _buildSupportTab();
                    default:
                      return _buildOverviewTab();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting and name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Welcome back ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const Text(
                                  '👋',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Obx(() {
                              return Text(
                                controller.mentorName.value.isEmpty
                                    ? 'Mentor'
                                    : controller.mentorName.value,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notification icon
                      Obx(() {
                        final totalNotifications =
                            controller.unreadCount.value +
                            controller.unansweredQuestionsCount.value +
                            controller.pendingRequestsCount.value;

                        return Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                    () => const MentorNotificationsView(),
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                                child: Icon(
                                  Icons.notifications,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                            if (totalNotifications > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      totalNotifications > 9
                                          ? '9+'
                                          : '$totalNotifications',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(width: 12),
                      // Profile avatar
                      InkWell(
                        onTap: () => controller.selectTab(9),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
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

  int _getBottomNavIndex() {
    // Map actual tab indices to bottom nav indices
    // Tab 0 (Overview) -> BottomNav 0
    // Tab 6 (Assessments) -> BottomNav 1
    // Tab 2 (Messages) -> BottomNav 2
    // Tab 5 (Calendar) -> BottomNav 3
    // Tab 1,3,4,7,8 (More menu items) -> BottomNav 4
    switch (controller.selectedTab.value) {
      case 0:
        return 0; // Overview
      case 6:
        return 1; // Assessments
      case 2:
        return 2; // Messages
      case 5:
        return 3; // Calendar
      default:
        return 4; // More menu items (Reports, Q&A, Coaching, Announcements, Feedbacks)
    }
  }

  Widget _buildBottomNav() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _getBottomNavIndex(),
          onTap: (index) {
            if (index == 4) {
              // Show More menu
              _showMoreMenu();
            } else {
              // Map bottom nav indices to actual tab indices
              // 0 -> 0 (Overview)
              // 1 -> 6 (Assessments)
              // 2 -> 2 (Messages)
              // 3 -> 5 (Calendar)
              final tabMapping = [0, 6, 2, 5];
              controller.selectTab(tabMapping[index]);
            }
          },
          selectedItemColor: const Color(0xFF6A3DE8),
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.assignment_turned_in_rounded),
                  if (controller.pendingSubmissionsCount.value > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '${controller.pendingSubmissionsCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Assessments',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.message_rounded),
                  if ((controller.unreadCount.value +
                          controller.unansweredQuestionsCount.value) >
                      0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '${controller.unreadCount.value + controller.unansweredQuestionsCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.calendar_month_rounded),
                  if (controller.upcomingSessionsCount.value > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '${controller.upcomingSessionsCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.more_horiz_rounded),
                  if ((controller.pendingRequestsCount.value) > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'More Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMoreMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    subtitle: 'View and manage your profile',
                    onTap: () {
                      Get.back();
                      controller.selectTab(9);
                    },
                  ),
                  _buildMoreMenuItem(
                    icon: Icons.assessment_rounded,
                    title: 'Reports',
                    subtitle: 'View student progress reports',
                    onTap: () {
                      Get.back();
                      controller.selectTab(1);
                    },
                  ),
                  _buildMoreMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Q&A',
                    subtitle: 'Answer student questions',
                    badge: controller.unansweredQuestionsCount.value,
                    onTap: () {
                      Get.back();
                      controller.selectTab(3);
                    },
                  ),
                  _buildMoreMenuItem(
                    icon: Icons.school_outlined,
                    title: 'Coaching Requests',
                    subtitle: 'Manage coaching sessions',
                    badge: controller.pendingRequestsCount.value,
                    onTap: () {
                      Get.back();
                      controller.selectTab(4);
                    },
                  ),
                  _buildMoreMenuItem(
                    icon: Icons.campaign_rounded,
                    title: 'Announcements',
                    subtitle: 'Send updates to students',
                    onTap: () {
                      Get.back();
                      controller.selectTab(7);
                    },
                  ),
                  _buildMoreMenuItem(
                    icon: Icons.rate_review_rounded,
                    title: 'Feedbacks',
                    subtitle: 'View student feedback & ratings',
                    onTap: () {
                      Get.back();
                      controller.selectTab(8);
                    },
                  ),
                  _buildMoreMenuItem(
                    icon: Icons.support_agent_rounded,
                    title: 'Support',
                    subtitle: 'Get help or report issues',
                    badge: controller.openTicketsCount.value,
                    onTap: () {
                      Get.back();
                      controller.selectTab(10);
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[200], thickness: 1),
                  const SizedBox(height: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.back();
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                controller.logout();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Sign out of your account',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.red.withOpacity(0.5),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
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
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    'Total Students',
                    '${controller.assignedBoards.length + controller.assignedGrades.length}',
                    Icons.people_rounded,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernStatCard(
                    'Active Sessions',
                    '${controller.upcomingSessionsCount.value}',
                    Icons.video_call_rounded,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    'Pending Tasks',
                    '${controller.pendingRequestsCount.value + controller.unansweredQuestionsCount.value}',
                    Icons.assignment_outlined,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernStatCard(
                    'Unread Msgs',
                    '${controller.unreadCount.value}',
                    Icons.mail_outline_rounded,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Your Assignments',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingAssignments.value) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                _buildModernAssignmentCard(
                  'Boards',
                  controller.assignedBoards,
                  Icons.business_rounded,
                  AppTheme.primaryColor,
                ),
                const SizedBox(height: 12),
                _buildModernAssignmentCard(
                  'Grades',
                  controller.assignedGrades,
                  Icons.school_rounded,
                  AppTheme.primaryColor,
                ),
                const SizedBox(height: 12),
                _buildModernAssignmentCard(
                  'Subjects',
                  controller.assignedSubjects,
                  Icons.book_rounded,
                  AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '${items.length} assigned',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAssignmentCard(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${items.length} items',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items.take(5).map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (items.length > 5) ...[
              const SizedBox(height: 10),
              Text(
                '+${items.length - 5} more',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Reports',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Track chapter-wise video and exercise completion',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: controller.exportToExcel,
                        icon: const Icon(
                          Icons.file_download_outlined,
                          size: 18,
                        ),
                        label: const Text('Export'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                      () => Text(
                        'Showing ${controller.filteredStudents.length} report rows',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(height: 40, text: 'Detailed Reports'),
                  Tab(height: 40, text: 'Exercise Summary'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 620,
            child: TabBarView(
              children: [
                _buildDetailedReportsView(),
                _buildExerciseSummaryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedReportsView() {
    return Obx(() {
      if (controller.isLoadingStudents.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredStudents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No reports found',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: _buildFilters()),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppTheme.primaryColor.withValues(alpha: 0.08),
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      fontSize: 12,
                    ),
                    dataTextStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                    ),
                    horizontalMargin: 12,
                    columnSpacing: 18,
                    columns: const [
                      DataColumn(label: Text('Board')),
                      DataColumn(label: Text('Grade')),
                      DataColumn(label: Text('Student Name')),
                      DataColumn(label: Text('Student ID')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Chapter')),
                      DataColumn(label: Text('Video Completed')),
                      DataColumn(label: Text('Assessments Completed')),
                      DataColumn(label: Text('Assessment %')),
                      DataColumn(label: Text('Exercise Attempted')),
                      DataColumn(label: Text('Total Chapters')),
                      DataColumn(label: Text('Videos Completed')),
                      DataColumn(label: Text('Exercises Completed')),
                    ],
                    rows: controller.filteredStudents.map((student) {
                      return DataRow(
                        cells: [
                          DataCell(Text(student['board'] ?? '-')),
                          DataCell(Text(student['grade'] ?? '-')),
                          DataCell(Text(student['studentName'] ?? '-')),
                          DataCell(Text(student['studentId'] ?? '-')),
                          DataCell(Text(student['subject'] ?? '-')),
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                student['chapter'] ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            _buildStatusIndicator(
                              student['videoCompleted'] == true,
                            ),
                          ),
                          DataCell(
                            _buildStatusIndicator(
                              student['assessmentCompleted'] == true,
                            ),
                          ),
                          DataCell(
                            Text(
                              '${((student['assessmentPercentage'] as num?) ?? 0).toStringAsFixed(2)}%',
                            ),
                          ),
                          DataCell(
                            _buildStatusIndicator(
                              student['exerciseAttempted'] == true,
                            ),
                          ),
                          DataCell(Text('${student['totalChapters'] ?? 0}')),
                          DataCell(Text('${student['videosCompleted'] ?? 0}')),
                          DataCell(
                            Text('${student['exercisesCompleted'] ?? 0}'),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildExerciseSummaryView() {
    return Obx(() {
      if (controller.isLoadingStudents.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final exerciseData = controller.getExerciseReportSummary();

      if (exerciseData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No exercise data available',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exerciseData.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exercise Completion Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Student-wise chapter completion overview',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: controller.exportExerciseReport,
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 15,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Student card par tap karke chapter-wise details dekhein.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Student cards
          final data = exerciseData[index - 1];
          return _buildExerciseSummaryCard(data);
        },
      );
    });
  }

  Widget _buildExerciseSummaryCard(Map<String, dynamic> data) {
    final totalChapters = data['totalChapters'] as int;
    final videosCompleted = data['videosCompleted'] as int;
    final exercisesCompleted = data['exercisesCompleted'] as int;

    final videoProgress = totalChapters > 0
        ? (videosCompleted / totalChapters)
        : 0.0;
    final exerciseProgress = totalChapters > 0
        ? (exercisesCompleted / totalChapters)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showStudentExerciseDetails(data['studentId'] as String),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (data['studentName'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['studentName'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${data['studentId']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: exercisesCompleted >= totalChapters
                          ? Colors.green
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$exercisesCompleted/$totalChapters done',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildInfoChip(
                    Icons.account_balance,
                    data['board'] as String,
                    const Color(0xFF8B5CF6),
                  ),
                  _buildInfoChip(
                    Icons.school,
                    'Grade ${data['grade']}',
                    const Color(0xFF10B981),
                  ),
                  _buildInfoChip(
                    Icons.menu_book,
                    data['subject'] as String,
                    const Color(0xFF3B82F6),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildReportStatTile(
                      value: '$totalChapters',
                      label: 'Chapters',
                      valueColor: const Color(0xFF1F2937),
                      backgroundColor: Colors.grey[50]!,
                      borderColor: Colors.grey[200]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildReportStatTile(
                      value: '$videosCompleted/$totalChapters',
                      label: 'Videos',
                      valueColor: const Color(0xFF3B82F6),
                      backgroundColor: Colors.blue[50]!,
                      borderColor: Colors.blue[100]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildReportStatTile(
                      value: '$exercisesCompleted/$totalChapters',
                      label: 'Exercises',
                      valueColor: const Color(0xFFF97316),
                      backgroundColor: Colors.orange[50]!,
                      borderColor: Colors.orange[100]!,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildReportProgressRow(
                      icon: Icons.play_circle_outline,
                      title: 'Video Progress',
                      valueLabel: '$videosCompleted/$totalChapters',
                      progress: videoProgress,
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 12),
                    _buildReportProgressRow(
                      icon: Icons.assignment_outlined,
                      title: 'Exercise Progress',
                      valueLabel: '$exercisesCompleted/$totalChapters',
                      progress: exerciseProgress,
                      color: const Color(0xFFF97316),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Tap to view chapter-wise details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportStatTile({
    required String value,
    required String label,
    required Color valueColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildReportProgressRow({
    required IconData icon,
    required String title,
    required String valueLabel,
    required double progress,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.18),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  void _showStudentExerciseDetails(String studentId) {
    final summary = controller.getStudentExerciseSummary(studentId);

    if (summary.isEmpty) {
      Get.snackbar(
        'Error',
        'No data found for this student',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(() => _StudentExerciseDetailsScreen(summary: summary));
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Obx(
                () => _buildCompactDropdown(
                  hint: 'Board',
                  value: controller.selectedBoard.value,
                  items: controller.assignedBoards,
                  onChanged: (value) => controller.selectedBoard.value = value,
                ),
              ),
              Obx(
                () => _buildCompactDropdown(
                  hint: 'Grade',
                  value: controller.selectedGrade.value,
                  items: controller.assignedGrades,
                  onChanged: (value) => controller.selectedGrade.value = value,
                ),
              ),
              Obx(
                () => _buildCompactDropdown(
                  hint: 'Subject',
                  value: controller.selectedSubject.value,
                  items: controller.assignedSubjects,
                  onChanged: (value) =>
                      controller.selectedSubject.value = value,
                ),
              ),
              ElevatedButton(
                onPressed: controller.applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 12)),
              ),
              TextButton(
                onPressed: controller.clearFilters,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                ),
                child: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        hint: Text(hint, style: const TextStyle(fontSize: 12)),
        value: value,
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStatusIndicator(bool status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ? 'Completed' : 'Pending',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingMessages.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.messages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return _buildMessageCard(message);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final isSent = message['type'] == 'sent';
    final isRead = message['read'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSent
            ? AppTheme.primaryColor.withOpacity(0.05)
            : isRead
            ? Colors.white
            : AppTheme.accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSent
              ? AppTheme.primaryColor.withOpacity(0.2)
              : isRead
              ? Colors.grey[300]!
              : AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSent
                        ? [AppTheme.primaryColor, AppTheme.secondaryColor]
                        : [Colors.blue, Colors.blueAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (message['from'] as String).substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          message['from'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        if (!isRead && !isSent) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatTimestamp(message['timestamp']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (!isSent)
                IconButton(
                  icon: Icon(Icons.reply, color: AppTheme.primaryColor),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('Reply to ${message['from']}'),
                        content: TextField(
                          onChanged: (value) =>
                              controller.messageText.value = value,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              controller.sendMessage(
                                message['fromId'],
                                message['from'],
                              );
                            },
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message['message'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  Q&A QUESTIONS TAB  — real‑time thread‑based chat
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuestionsTab() {
    final filterIndex = 0.obs; // 0=All, 1=Pending, 2=Answered

    return Column(
      children: [
        // ─── Header bar ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Student Q&A',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  // Refresh button
                  Obx(
                    () => controller.isLoadingQuestions.value
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Color(0xFF8B5CF6),
                            ),
                            onPressed: controller.loadMentorQnaThreads,
                          ),
                  ),
                  // Unread badge
                  Obx(() {
                    final count = controller.unansweredQuestionsCount.value;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Chat with students and answer their doubts',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              // ─── Filter chips ──────────────────────────────────────────
              Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 0, filterIndex),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 1, filterIndex),
                      const SizedBox(width: 8),
                      _buildFilterChip('Answered', 2, filterIndex),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // ─── Thread list ───────────────────────────────────────────────────
        SizedBox(
          height: MediaQuery.sizeOf(Get.context!).height - 280,
          child: Obx(() {
            if (controller.isLoadingQuestions.value &&
                controller.qnaThreads.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              );
            }

            final allThreads = controller.qnaThreads;
            final filter = filterIndex.value;
            final threads = filter == 1
                ? allThreads.where((t) => t.hasUnanswered).toList()
                : filter == 2
                ? allThreads
                      .where((t) => t.totalQuestions > 0 && !t.hasUnanswered)
                      .toList()
                : allThreads.toList();

            if (threads.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.question_answer_outlined,
                        size: 52,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      filter == 1
                          ? 'No pending questions'
                          : filter == 2
                          ? 'No answered questions yet'
                          : 'No student questions yet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Students can ask doubts from the learning section',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadMentorQnaThreads,
              color: const Color(0xFF8B5CF6),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: threads.length,
                itemBuilder: (ctx, i) => _buildQnaThreadCard(threads[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int value, RxInt selected) {
    final isSelected = selected.value == value;
    return GestureDetector(
      onTap: () => selected.value = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildQnaThreadCard(QnaThread thread) {
    final hasPending = thread.hasUnanswered;
    final statusColor = hasPending
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);
    final lastItem = thread.lastItem;

    return GestureDetector(
      onTap: () => Get.to(() => MentorQnaChatView(thread: thread)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: status tag + time ──────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasPending ? Icons.schedule : Icons.check_circle,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasPending
                            ? '${thread.pendingCount} Pending'
                            : 'All Answered',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (lastItem != null)
                  Text(
                    timeago.format(lastItem.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 2: student avatar + name ──────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.12),
                  child: Text(
                    (thread.studentName ?? 'S').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.studentName ?? 'Student',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book,
                            size: 12,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              thread.chapter?.name ?? 'Chapter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),

            // ── Row 3: last question preview ──────────────────────────
            if (lastItem != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      lastItem.isAnswered ? Icons.school : Icons.help_outline,
                      size: 15,
                      color: lastItem.isAnswered
                          ? const Color(0xFF10B981)
                          : Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lastItem.isAnswered
                            ? lastItem.answerText
                            : lastItem.questionText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: lastItem.isAnswered
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Row 4: stats ──────────────────────────────────────────
            const SizedBox(height: 10),
            Row(
              children: [
                _buildQnaStatChip(
                  Icons.help_outline,
                  '${thread.totalQuestions}',
                  'Questions',
                  Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                _buildQnaStatChip(
                  Icons.check_circle_outline,
                  '${thread.answeredCount}',
                  'Answered',
                  const Color(0xFF10B981),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Open Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQnaStatChip(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── (Legacy — kept for compile compat) ────────────────────────────────────
  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return const SizedBox.shrink();
  }

  Widget _buildCoachingRequestsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coaching Requests',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students requesting one-on-one coaching',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingRequests.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.coachingRequests.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No coaching requests yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.coachingRequests.length,
              itemBuilder: (context, index) {
                final request = controller.coachingRequests[index];
                return _buildCoachingRequestCard(request);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCoachingRequestCard(Map<String, dynamic> request) {
    final status = request['status'] as String;
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';

    Color statusColor = isPending
        ? Colors.orange
        : (isAccepted ? Colors.green : Colors.red);
    Color bgColor = statusColor.withOpacity(0.05);
    Color borderColor = statusColor.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and timestamp
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(request['timestamp']),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Student info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purpleAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (request['studentName'] as String).substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['studentName'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'ID: ${request['studentId']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Request details
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  Icons.menu_book,
                  request['subject'] as String,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                  Icons.class_,
                  request['grade'] as String,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoChip(
            Icons.business,
            request['board'] as String,
            Colors.purple,
          ),
          const SizedBox(height: 16),

          // Request message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Message:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request['requestMessage'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Schedule and contact
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Schedule:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['preferredSchedule'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Contact:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['contactNumber'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show mentor's response if not pending
          if (!isPending && request['response'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAccepted
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAccepted
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        'Your Response:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(request['responseTimestamp']),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request['response'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1F2937),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons for pending requests
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showResponseDialog(request['id'], 'accepted');
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showResponseDialog(request['id'], 'rejected');
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showResponseDialog(String requestId, String status) {
    String response = '';
    final isAccepting = status == 'accepted';

    Get.dialog(
      AlertDialog(
        title: Text(
          isAccepting ? 'Accept Coaching Request' : 'Decline Coaching Request',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAccepting
                  ? 'Please provide details about how you will proceed with this coaching request:'
                  : 'Please provide a reason for declining this request:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => response = value,
              decoration: InputDecoration(
                hintText: isAccepting
                    ? 'e.g., I will contact you within 24 hours to schedule sessions...'
                    : 'e.g., Currently fully booked, please try again next month...',
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.respondToCoachingRequest(requestId, status, response);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccepting ? Colors.green : Colors.red,
            ),
            child: Text(isAccepting ? 'Accept & Send' : 'Decline & Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendar Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateTimeSlotDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Slot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your availability and coaching sessions',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Calendar View Switcher
          Obx(
            () => Row(
              children: [
                _buildViewButton('Day', 'day'),
                const SizedBox(width: 8),
                _buildViewButton('Week', 'week'),
                const SizedBox(width: 8),
                _buildViewButton('Month', 'month'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Date Selector
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => controller.navigateCalendar(false),
                  ),
                  Text(
                    controller.getCalendarDateTitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => controller.navigateCalendar(true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Booked Sessions Section
          const Text(
            'Booked Coaching Sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingCalendar.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final sessions = controller.getSessionsForCurrentView();

            if (sessions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No sessions booked for selected ${controller.calendarView.value}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: sessions
                  .map((session) => _buildSessionCard(session))
                  .toList(),
            );
          }),
          const SizedBox(height: 24),

          // Available Time Slots Section
          const Text(
            'Available Time Slots',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final slots = controller.getTimeSlotsForCurrentView();

            if (slots.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No time slots available for selected ${controller.calendarView.value}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: slots.map((slot) => _buildTimeSlotCard(slot)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, String view) {
    final isSelected = controller.calendarView.value == view;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => controller.changeCalendarView(view),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppTheme.primaryColor
              : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final status = session['status'] as String;
    final isPending = status == 'pending';
    final isCancelled = status == 'cancelled';
    final Color statusColor = isPending
        ? Colors.orange
        : isCancelled
        ? Colors.red
        : Colors.green;

    final sessionDate = session['date'] as DateTime?;
    final meetingLink = session['meetingLink']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (session['studentName'] as String)
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['studentName'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sessionDate != null)
                      Text(
                        _formatDateDisplay(sessionDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Time
          _buildSessionInfo(
            Icons.access_time,
            '${session['startTime']} – ${session['endTime']}',
            Colors.blue,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSessionInfo(
                  Icons.business,
                  session['board'] as String,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSessionInfo(
                  Icons.class_,
                  session['grade'] as String,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSessionInfo(
            Icons.book,
            session['subject'] as String,
            Colors.orange,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session['chapter'] as String,
                    style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),

          // Copy Meeting Link
          if (meetingLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: meetingLink));
                Get.snackbar(
                  'Copied!',
                  'Meeting link copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy Meeting Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],

          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.confirmSession(session['id']),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCancelSessionDialog(session['id']),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionInfo(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
    final status = slot['status'] as String;
    final isBlocked = status == 'blocked';
    final slotDate = slot['date'] as DateTime?;
    final Color accentColor = isBlocked ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (slotDate != null) ...[
                  Text(
                    slotDate.day.toString(),
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1,
                    ),
                  ),
                  Text(
                    _monthShortLabel(slotDate),
                    style: TextStyle(color: accentColor, fontSize: 10),
                  ),
                ] else
                  Icon(
                    isBlocked ? Icons.block : Icons.check_circle,
                    color: accentColor,
                    size: 28,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot['startTime']} – ${slot['endTime']}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (slotDate != null)
                  Text(
                    _formatDateDisplay(slotDate),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                Text(
                  isBlocked ? 'Blocked' : 'Available',
                  style: TextStyle(
                    fontSize: 13,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'block') {
                controller.blockTimeSlot(slot['id']);
              } else if (value == 'delete') {
                controller.deleteTimeSlot(slot['id']);
              }
            },
            itemBuilder: (context) => [
              if (!isBlocked)
                const PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 18),
                      SizedBox(width: 8),
                      Text('Block Slot'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Slot', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateTimeSlotDialog() {
    DateTime selectedDate = controller.selectedDate.value;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    Get.dialog(
      AlertDialog(
        title: const Text('Create Time Slot'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(_formatDateDisplay(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(
                    startTime != null ? startTime!.format(context) : 'Select',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        startTime = time;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(
                    endTime != null ? endTime!.format(context) : 'Select',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        endTime = time;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (startTime != null && endTime != null) {
                Get.back();
                controller.createTimeSlot(
                  selectedDate,
                  startTime!.format(Get.context!),
                  endTime!.format(Get.context!),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Please select start and end times',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCancelSessionDialog(String sessionId) {
    String reason = '';
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for canceling this session:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => reason = value,
              decoration: const InputDecoration(
                hintText: 'Reason for cancellation...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelSession(sessionId, reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDateDisplay(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _monthShortLabel(DateTime date) {
    const m = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return m[date.month - 1];
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // ==================== Assessment Tab ====================

  Widget _buildAssessmentsTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assessments',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Create, manage, and review assessments',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showCreateAssessmentDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(height: 38, text: 'All Assessments'),
                      Tab(height: 38, text: 'Submissions'),
                      Tab(height: 38, text: 'Question Bank'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 600,
            child: TabBarView(
              children: [
                _buildAssessmentsListView(),
                _buildSubmissionsView(),
                _buildQuestionBankView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentsListView() {
    return Obx(() {
      if (controller.isLoadingAssessments.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.assessments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No assessments yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _showCreateAssessmentDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Assessment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.assessments.length,
        itemBuilder: (context, index) {
          final assessment = controller.assessments[index];
          return _buildAssessmentCard(assessment);
        },
      );
    });
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final status = assessment['status'] as String;
    final scheduledDate = assessment['scheduledDate'] as DateTime;
    final completedCount = assessment['completedCount'] as int;
    final totalStudents = assessment['totalStudents'] as int;

    Color statusColor = status == 'scheduled'
        ? Colors.blue
        : status == 'active'
        ? Colors.green
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAssessmentDetails(assessment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${assessment['board']} • ${assessment['grade']} • ${assessment['subject']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                assessment['chapter'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${assessment['totalQuestions']} questions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${assessment['duration']} mins',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateDisplay(scheduledDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (status == 'completed') ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: totalStudents > 0 ? completedCount / totalStudents : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount / $totalStudents students completed',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionsView() {
    return Obx(() {
      if (controller.isLoadingAssessments.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.assessmentSubmissions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No submissions yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.assessmentSubmissions.length} Total Submissions',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Export (N/A)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.assessmentSubmissions.length,
              itemBuilder: (context, index) {
                final submission = controller.assessmentSubmissions[index];
                return _buildSubmissionCard(submission);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    final status = submission['status'] as String;
    final percentage = submission['percentage'] as double;

    Color percentageColor = percentage >= 80
        ? Colors.green
        : percentage >= 60
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showSubmissionDetails(submission),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (submission['studentName'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission['studentName'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          submission['assessmentName'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: percentageColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: percentageColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${submission['score']}/${submission['totalScore']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.school, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${submission['grade']} • ${submission['subject']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(submission['submittedDate'] as DateTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (status == 'submitted') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pending_actions,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pending review - Tap to provide feedback',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (submission['feedback'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Feedback: ${submission['feedback']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBankView() {
    return Column(
      children: [
        // ── Header with selection count ──
        Obx(() {
          final count = controller.selectedQuestions.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: count > 0 ? AppTheme.primaryColor : Colors.grey[50]!,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  count > 0 ? Icons.check_circle_rounded : Icons.quiz_outlined,
                  color: count > 0 ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    count > 0
                        ? '$count question${count == 1 ? '' : 's'} selected — tap "Create Assessment" to use them'
                        : 'Select a Subject & Chapter to browse questions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: count > 0 ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
                if (count > 0)
                  GestureDetector(
                    onTap: _showCreateAssessmentDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),

        // ── Cascade filters: Subject → Grade → Chapter ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject + Grade row
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildFilterDropdown(
                        hint: 'Subject',
                        icon: Icons.menu_book_rounded,
                        value: controller.selectedAssessmentSubject.value,
                        items: controller.questionBankSubjects,
                        onChanged: (value) {
                          controller.selectedAssessmentSubject.value = value;
                          controller.selectedAssessmentChapter.value = null;
                          controller.selectedAssessmentChapterId.value = null;
                          controller.questionBank.clear();
                          controller.selectedQuestions.clear();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => _buildFilterDropdown(
                        hint: 'Grade',
                        icon: Icons.school_rounded,
                        value: controller.selectedAssessmentGrade.value,
                        items: controller.questionBankGrades,
                        onChanged: (value) {
                          controller.selectedAssessmentGrade.value = value;
                          controller.selectedAssessmentChapter.value = null;
                          controller.selectedAssessmentChapterId.value = null;
                          controller.questionBank.clear();
                          controller.selectedQuestions.clear();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Chapter dropdown (filtered from API chapters)
              Obx(() {
                final chapters = controller.filteredChaptersForAssessment;
                final chapterNames = chapters
                    .map((c) => c['name'] as String)
                    .toList();
                return _buildFilterDropdown(
                  hint: controller.isLoadingChapters.value
                      ? 'Loading chapters...'
                      : 'Chapter (select Subject first)',
                  icon: Icons.list_alt_rounded,
                  value: controller.selectedAssessmentChapter.value,
                  items: chapterNames,
                  onChanged: (value) {
                    if (value == null) return;
                    final ch = chapters.firstWhere(
                      (c) => c['name'] == value,
                      orElse: () => {},
                    );
                    if (ch.isEmpty) return;
                    controller.onAssessmentChapterSelected(
                      ch['name'] as String,
                      ch['id'] as String,
                    );
                  },
                );
              }),
            ],
          ),
        ),

        const Divider(height: 1),

        // ── Question list ──
        Expanded(
          child: Obx(() {
            if (controller.selectedAssessmentChapterId.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 36,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Subject & Chapter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Questions from the question bank will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            if (controller.isLoadingQuestionBank.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final questions = controller.filteredQuestions;
            if (questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No questions found for this chapter',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return _buildQuestionBankCard(question);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // Deduplicate items to prevent DropdownButton assertion failures
    final uniqueItems = items.toSet().toList();
    // Null out value if it is not present in the deduplicated list
    final safeValue = (value != null && uniqueItems.contains(value))
        ? value
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButton<String>(
              hint: Text(hint, style: const TextStyle(fontSize: 12)),
              value: safeValue,
              underline: const SizedBox(),
              isDense: true,
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: uniqueItems
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
          if (safeValue != null)
            GestureDetector(
              onTap: () => onChanged(null),
              child: Icon(Icons.close, size: 14, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionBankCard(Map<String, dynamic> question) {
    final qId = question['id'] as String;
    final answerType = question['answerType'] as String? ?? 'single';
    final difficulty = question['difficulty'] as String? ?? 'medium';
    final marks = question['marks'] as int? ?? 1;
    final options =
        (question['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final explanation = question['explanation'] as String? ?? '';

    Color difficultyColor = difficulty == 'easy'
        ? Colors.green
        : difficulty == 'medium'
        ? Colors.orange
        : Colors.red;

    return Obx(() {
      final isSelected = controller.selectedQuestions.contains(qId);
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: isSelected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => controller.toggleQuestionSelection(qId),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    // Question text
                    Expanded(
                      child: Text(
                        question['questionText'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Badges row
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _questionBadge(
                      label:
                          difficulty[0].toUpperCase() + difficulty.substring(1),
                      color: difficultyColor,
                    ),
                    _questionBadge(
                      label: answerType == 'single'
                          ? 'Single MCQ'
                          : 'Multi MCQ',
                      color: Colors.blue,
                    ),
                    _questionBadge(
                      label: '$marks mark${marks > 1 ? 's' : ''}',
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
                // MCQ Options (always shown)
                if (options.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...options.asMap().entries.map((e) {
                    final idx = e.key;
                    final opt = e.value;
                    final isCorrect = opt['isCorrect'] == true;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCorrect
                                    ? Colors.green
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + idx), // A, B, C, D
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              opt['text'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isCorrect
                                    ? Colors.green[700]
                                    : Colors.grey[800],
                                fontWeight: isCorrect
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Colors.green[600],
                            ),
                        ],
                      ),
                    );
                  }),
                ],
                if (explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            explanation,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _questionBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _showCreateAssessmentDialog() {
    final nameController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    String? selectedBoard = controller.selectedAssessmentBoard.value;
    String? selectedGrade = controller.selectedAssessmentGrade.value;
    String? selectedSubject = controller.selectedAssessmentSubject.value;
    String? selectedChapter = controller.selectedAssessmentChapter.value;

    final selectedQuestionCount = controller.selectedQuestions.length;

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 680),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─ Header ─
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.assignment_add,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Assessment',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Set details & schedule for students',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─ Selected questions banner ─
                  if (selectedQuestionCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      color: Colors.green[50],
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green[600],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$selectedQuestionCount question${selectedQuestionCount > 1 ? 's' : ''} selected from Question Bank',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (selectedQuestionCount == 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      color: Colors.orange[50],
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No questions selected. Go to the Question Bank tab to select questions first.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ─ Form Fields ─
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Assessment Name
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Assessment Name *',
                              prefixIcon: const Icon(
                                Icons.title_rounded,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Board + Grade
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Board',
                                    prefixIcon: const Icon(
                                      Icons.account_balance_rounded,
                                      size: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                  ),
                                  value: selectedBoard,
                                  isDense: true,
                                  isExpanded: true,
                                  items: controller.assignedBoards
                                      .map(
                                        (b) => DropdownMenuItem(
                                          value: b,
                                          child: Text(
                                            b,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => selectedBoard = value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Grade',
                                    prefixIcon: const Icon(
                                      Icons.school_rounded,
                                      size: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                  ),
                                  value: selectedGrade,
                                  isDense: true,
                                  isExpanded: true,
                                  items: controller.assignedGrades
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(
                                            g,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => selectedGrade = value),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Subject
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Subject',
                              prefixIcon: const Icon(
                                Icons.menu_book_rounded,
                                size: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            value: selectedSubject,
                            isDense: true,
                            isExpanded: true,
                            items: controller.assignedSubjects
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              selectedSubject = value;
                              selectedChapter = null;
                            }),
                          ),
                          const SizedBox(height: 12),

                          // Chapter
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Chapter',
                              prefixIcon: const Icon(
                                Icons.list_alt_rounded,
                                size: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            value: selectedChapter,
                            isDense: true,
                            isExpanded: true,
                            hint: Text(
                              selectedSubject == null
                                  ? 'Select Subject first'
                                  : 'Select Chapter',
                              style: const TextStyle(fontSize: 12),
                            ),
                            items: controller.filteredChaptersForAssessment
                                .map((c) => c['name'] as String)
                                .toSet()
                                .map(
                                  (name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedChapter = value),
                          ),
                          const SizedBox(height: 12),

                          // Duration
                          TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Duration (minutes)',
                              prefixIcon: const Icon(
                                Icons.timer_rounded,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Date + Time pickers
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: Get.context!,
                                      initialDate: selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (date != null)
                                      setState(() => selectedDate = date);
                                  },
                                  icon: const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: Get.context!,
                                      initialTime: selectedTime,
                                    );
                                    if (time != null)
                                      setState(() => selectedTime = time);
                                  },
                                  icon: const Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    selectedTime.format(Get.context!),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // ─ Actions ─
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.isCreatingAssessment.value
                                  ? null
                                  : () {
                                      if (nameController.text.isEmpty) {
                                        Get.snackbar(
                                          'Error',
                                          'Please enter assessment name',
                                        );
                                        return;
                                      }
                                      if (selectedQuestionCount == 0) {
                                        Get.snackbar(
                                          'No Questions',
                                          'Please select questions from the Question Bank tab first',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return;
                                      }
                                      final scheduledDateTime = DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                        selectedTime.hour,
                                        selectedTime.minute,
                                      );
                                      controller.createAssessment(
                                        name: nameController.text.trim(),
                                        board: selectedBoard ?? '',
                                        grade: selectedGrade ?? '',
                                        subject: selectedSubject ?? '',
                                        chapter: selectedChapter ?? '',
                                        scheduledDate: scheduledDateTime,
                                        duration:
                                            int.tryParse(
                                              durationController.text,
                                            ) ??
                                            60,
                                      );
                                    },
                              icon: controller.isCreatingAssessment.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.rocket_launch_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                controller.isCreatingAssessment.value
                                    ? 'Creating...'
                                    : 'Create Assessment',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAssessmentDetails(Map<String, dynamic> assessment) {
    Get.dialog(
      AlertDialog(
        title: Text(assessment['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Board: ${assessment['board']}'),
            Text('Grade: ${assessment['grade']}'),
            Text('Subject: ${assessment['subject']}'),
            Text('Chapter: ${assessment['chapter']}'),
            Text('Questions: ${assessment['totalQuestions']}'),
            Text('Duration: ${assessment['duration']} minutes'),
            Text(
              'Scheduled: ${_formatDateDisplay(assessment['scheduledDate'])}',
            ),
            if (assessment['status'] == 'completed')
              Text(
                'Completed: ${assessment['completedCount']}/${assessment['totalStudents']} students',
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSubmissionDetails(Map<String, dynamic> submission) {
    final feedbackController = TextEditingController(
      text: submission['feedback'],
    );
    final scoreController = TextEditingController(
      text: submission['score'].toString(),
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission['studentName'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          submission['assessmentName'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${submission['percentage'].toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Board: ${submission['board']}'),
                    Text('Grade: ${submission['grade']}'),
                    Text('Subject: ${submission['subject']}'),
                    Text(
                      'Submitted: ${_formatTimestamp(submission['submittedDate'])}',
                    ),
                    Text(
                      'Upload Type: ${submission['uploadType'].toString().toUpperCase()}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Open uploaded file (PDF/Image)
                  Get.snackbar(
                    'Info',
                    'Opening ${submission['uploadType']} file...',
                  );
                },
                icon: const Icon(Icons.file_open),
                label: const Text('View Uploaded File'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Score (out of ${submission['totalScore']})',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Feedback (will be sent to student)',
                  border: OutlineInputBorder(),
                  hintText: 'Provide constructive feedback...',
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Submit Feedback (N/A)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Announcements Tab ====================

  Widget _buildAnnouncementsTab() {
    return Obx(() {
      if (controller.isLoadingAnnouncements.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Loading announcements...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        );
      }

      if (controller.announcements.isEmpty) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header even on empty state
            _buildAnnouncementsHeader(),
            SizedBox(
              height: 560,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.primaryColor.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.campaign_outlined,
                        size: 48,
                        color: AppTheme.primaryColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Announcements Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send your first notification to students',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: _showSendAnnouncementDialog,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Send Announcement',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnnouncementsHeader(),
          SizedBox(
            height: 560,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: controller.announcements.length,
              itemBuilder: (context, index) {
                final announcement = controller.announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAnnouncementsHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.85),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Notify your students instantly',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSendAnnouncementDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Send New',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final type = announcement['type'] as String;
    final sentDate = announcement['sentDate'] as DateTime;
    final recipientCount = announcement['recipientCount'] as int;

    IconData typeIcon;
    Color typeColor;
    Color typeBg;
    String typeLabel;

    switch (type) {
      case 'assignment':
        typeIcon = Icons.assignment_rounded;
        typeColor = const Color(0xFF1976D2);
        typeBg = const Color(0xFFE3F2FD);
        typeLabel = 'Assignment';
        break;
      case 'assessment':
        typeIcon = Icons.quiz_rounded;
        typeColor = const Color(0xFFE65100);
        typeBg = const Color(0xFFFFF3E0);
        typeLabel = 'Assessment';
        break;
      case 'tip':
        typeIcon = Icons.lightbulb_rounded;
        typeColor = const Color(0xFFF9A825);
        typeBg = const Color(0xFFFFFDE7);
        typeLabel = 'Study Tip';
        break;
      default:
        typeIcon = Icons.notifications_rounded;
        typeColor = const Color(0xFF6A1B9A);
        typeBg = const Color(0xFFF3E5F5);
        typeLabel = 'General';
    }

    final subtitle = [
      announcement['targetGrade'],
      announcement['targetSubject'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showAnnouncementDetails(announcement),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored left accent bar
              Container(
                width: 5,
                height: 120,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type icon circle
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(typeIcon, size: 20, color: typeColor),
                          ),
                          const SizedBox(width: 10),
                          // Title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  announcement['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Type pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Message preview
                      Text(
                        announcement['message'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Audio indicator
                      if (announcement['audioUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.graphic_eq_rounded,
                                      size: 13,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Voice Note',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Footer
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people_alt_rounded,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$recipientCount notified',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(sentDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _confirmDeleteAnnouncement(
                              announcement['id'] as String,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 15,
                                color: Colors.red[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSendAnnouncementDialog() {
    controller.clearAnnouncementAudio();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'general';
    String? selectedBoard;
    String? selectedGrade;
    String? selectedSubject;

    InputDecoration _fieldDecoration(String label, IconData icon) =>
        InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        );

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final types = [
            (
              'assignment',
              'Assignment',
              Icons.assignment_rounded,
              const Color(0xFF1976D2),
              const Color(0xFFE3F2FD),
            ),
            (
              'assessment',
              'Assessment',
              Icons.quiz_rounded,
              const Color(0xFFE65100),
              const Color(0xFFFFF3E0),
            ),
            (
              'tip',
              'Study Tip',
              Icons.lightbulb_rounded,
              const Color(0xFFF9A825),
              const Color(0xFFFFFDE7),
            ),
            (
              'general',
              'General',
              Icons.notifications_rounded,
              const Color(0xFF6A1B9A),
              const Color(0xFFF3E5F5),
            ),
          ];

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                // Gradient header
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send Announcement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Notify your students instantly',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: _fieldDecoration(
                            'Title *',
                            Icons.title_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: messageController,
                          maxLines: 4,
                          decoration:
                              _fieldDecoration(
                                'Message *',
                                Icons.message_rounded,
                              ).copyWith(
                                alignLabelWithHint: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: types.map((t) {
                            final isSelected = selectedType == t.$1;
                            return GestureDetector(
                              onTap: () => setState(() => selectedType = t.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? t.$5
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? t.$4
                                        : Colors.grey[200]!,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      t.$3,
                                      size: 16,
                                      color: isSelected
                                          ? t.$4
                                          : Colors.grey[500],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      t.$2,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? t.$4
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Target Students (Optional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: _fieldDecoration(
                            'Board',
                            Icons.account_balance_rounded,
                          ),
                          value: selectedBoard,
                          items: controller.assignedBoards
                              .map(
                                (b) =>
                                    DropdownMenuItem(value: b, child: Text(b)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedBoard = value),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _fieldDecoration(
                            'Grade',
                            Icons.school_rounded,
                          ),
                          value: selectedGrade,
                          items: controller.assignedGrades
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedGrade = value),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _fieldDecoration(
                            'Subject',
                            Icons.menu_book_rounded,
                          ),
                          value: selectedSubject,
                          items: controller.assignedSubjects
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedSubject = value),
                        ),
                        const SizedBox(height: 16),
                        // ── Voice Announcement Section ──
                        const Text(
                          'Voice Announcement (Optional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          if (controller.isRecordingAudio.value) {
                            return _buildDialogRecordingIndicator();
                          } else if (controller.announcementAudioPath != null) {
                            return _buildDialogAudioPreview();
                          }
                          return _buildDialogAudioButtons();
                        }),
                        const SizedBox(height: 20),
                        // Send button
                        Obx(
                          () => GestureDetector(
                            onTap: controller.isSendingAnnouncement.value
                                ? null
                                : () => controller.sendAnnouncement(
                                    title: titleController.text,
                                    message: messageController.text,
                                    type: selectedType,
                                    board: selectedBoard,
                                    grade: selectedGrade,
                                    subject: selectedSubject,
                                    audioFilePath:
                                        controller.announcementAudioPath,
                                    audioFileNameHint:
                                        controller.announcementAudioFileName,
                                  ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: controller.isSendingAnnouncement.value
                                      ? [Colors.grey[300]!, Colors.grey[300]!]
                                      : [
                                          AppTheme.primaryColor,
                                          AppTheme.primaryColor.withOpacity(
                                            0.8,
                                          ),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow:
                                    controller.isSendingAnnouncement.value
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: controller.isSendingAnnouncement.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Send Announcement',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    Get.bottomSheet(
      _AnnouncementDetailsSheet(
        announcement: announcement,
        formatTimestamp: _formatTimestamp,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _detailChip(
    IconData icon,
    String label,
    String value,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Audio helpers for _showSendAnnouncementDialog ──

  Widget _buildDialogAudioButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: controller.startAudioRecording,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_rounded, color: Colors.red[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Record Voice',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: controller.pickAnnouncementAudio,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upload File',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recording...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
                Obx(() {
                  final m = controller.audioDuration.value ~/ 60;
                  final s = controller.audioDuration.value % 60;
                  return Text(
                    '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: Colors.red[300]),
                  );
                }),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.stopAudioRecording,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stop_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Stop',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogAudioPreview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Ready to Send',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Obx(
                  () => Text(
                    controller.announcementAudioFileName ?? '',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.clearAnnouncementAudio,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red[400],
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAnnouncement(String announcementId) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_rounded,
                size: 34,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Announcement',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This announcement will be permanently removed.\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.deleteAnnouncement(announcementId);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[600]!, Colors.red[400]!],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // Feedbacks & Ratings Tab
  Widget _buildFeedbacksTab() {
    return Obx(() {
      if (controller.isLoadingFeedbacks.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistics Cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEF0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFeedbackStatCard(
                          'Avg Rating',
                          controller.averageRating.value.toStringAsFixed(1),
                          Icons.star_rounded,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: const Color(0xFFEEEEF0),
                        indent: 12,
                        endIndent: 12,
                      ),
                      Expanded(
                        child: _buildFeedbackStatCard(
                          'Feedbacks',
                          '${controller.totalFeedbacks.value}',
                          Icons.chat_bubble_outline_rounded,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: const Color(0xFFEEEEF0),
                        indent: 12,
                        endIndent: 12,
                      ),
                      Expanded(
                        child: _buildFeedbackStatCard(
                          'Videos Rated',
                          '${controller.videoRatings.length}',
                          Icons.play_circle_outline_rounded,
                          const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top Videos Chart Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Top Rated Videos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      // Top count dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<int>(
                          value: controller.selectedTopCount.value,
                          underline: const SizedBox(),
                          items: [10, 50, 100].map((count) {
                            return DropdownMenuItem(
                              value: count,
                              child: Text('Top $count'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.updateTopCount(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chart type toggle
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildChartTypeButton(Icons.bar_chart, 'bar'),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[300],
                            ),
                            _buildChartTypeButton(Icons.pie_chart, 'pie'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  controller.selectedChartType.value == 'bar'
                      ? _buildBarChart()
                      : _buildPieChart(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Student Feedbacks Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Student Feedbacks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Feedbacks List
            controller.videoFeedbacks.isEmpty
                ? Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No student feedbacks yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.videoFeedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = controller.videoFeedbacks[index];
                      return _buildFeedbackCard(feedback);
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildFeedbackStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(IconData icon, String type) {
    final isSelected = controller.selectedChartType.value == type;
    return InkWell(
      onTap: () => controller.updateChartType(type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: controller.topVideos.length,
        itemBuilder: (context, index) {
          final video = controller.topVideos[index];
          final rating = video['averageRating'] as double;
          final maxRating = 5.0;
          final percentage = (rating / maxRating) * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getRatingColor(rating),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video['videoTitle'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${video['subject']} • ${video['totalRatings']} ratings',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getRatingColor(rating),
                              _getRatingColor(rating).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          // Pie chart visualization (simplified representation)
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: _PieChartPainter(controller.topVideos),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Top Videos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${controller.topVideos.length} videos',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(controller.topVideos.length.clamp(0, 8), (
              index,
            ) {
              final video = controller.topVideos[index];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getChartColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${video['videoTitle'].toString().substring(0, video['videoTitle'].toString().length.clamp(0, 20))}...',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.amber;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  Color _getChartColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feedback['isPositive']
              ? Colors.green[200]!
              : Colors.orange[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFeedbackDetails(feedback),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        feedback['studentName'][0],
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feedback['studentName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${feedback['board']} • ${feedback['grade']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating stars
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${feedback['rating']}/5',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              feedback['videoTitle'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${feedback['subject']} • ${feedback['chapter']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  feedback['feedback'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(feedback['timestamp']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    if (feedback['mentorReply'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Replied',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: () => _showReplyDialog(feedback),
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('Reply'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDetails(Map<String, dynamic> feedback) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Feedback Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        feedback['studentName'][0],
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feedback['studentName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: ${feedback['studentId']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${feedback['board']} • ${feedback['grade']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Video',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback['videoTitle'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${feedback['subject']} • ${feedback['chapter']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < feedback['rating']
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    );
                  }),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    feedback['feedback'],
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
                if (feedback['mentorReply'] != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Your Reply',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback['mentorReply'],
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Replied ${_formatTimestamp(feedback['replyTimestamp'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Submitted ${_formatTimestamp(feedback['timestamp'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (feedback['mentorReply'] == null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showReplyDialog(feedback);
                      },
                      icon: const Icon(Icons.reply),
                      label: const Text('Reply to Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(Map<String, dynamic> feedback) {
    final replyController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Reply to Feedback',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback['studentName'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback['feedback'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: replyController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (replyController.text.trim().isNotEmpty) {
                          controller.replyToFeedback(
                            feedback['id'],
                            replyController.text.trim(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send Reply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Obx(() {
      if (controller.isLoadingProfile.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final profile = controller.mentorProfile.value;
      if (profile == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadMentorProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating and Verification Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              profile.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Verification Badge
                      if (profile.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information
            _buildProfileSection(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow('First Name', profile.firstName),
                _buildInfoRow('Last Name', profile.lastName),
                _buildInfoRow('Email', profile.email),
                if (profile.phone.isNotEmpty)
                  _buildInfoRow('Phone', profile.phone),
                _buildInfoRow('Role', profile.role),
                _buildInfoRow(
                  'Experience',
                  '${profile.experience} ${profile.experience == 1 ? 'year' : 'years'}',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Verification Status
            _buildProfileSection(
              title: 'Verification Status',
              icon: Icons.verified_user_outlined,
              children: [
                _buildVerificationRow(
                  'Email Verification',
                  profile.isEmailVerified,
                ),
                _buildVerificationRow(
                  'Phone Verification',
                  profile.isPhoneVerified,
                ),
                _buildVerificationRow(
                  'Mentor Verification',
                  profile.isVerified,
                ),
                _buildVerificationRow(
                  'Account Status',
                  profile.isActive,
                  activeText: 'Active',
                  inactiveText: 'Inactive',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Teaching Details
            _buildProfileSection(
              title: 'Teaching Details',
              icon: Icons.school_outlined,
              children: [
                if (profile.boards.isNotEmpty)
                  _buildChipsRow(
                    'Boards',
                    profile.boards.map((b) => b.name).toList(),
                  ),
                if (profile.grades.isNotEmpty)
                  _buildChipsRow(
                    'Grades',
                    profile.grades.map((g) => g.name).toList(),
                  ),
                if (profile.subjects.isNotEmpty)
                  _buildChipsRow(
                    'Subjects',
                    profile.subjects.map((s) => s.name).toList(),
                  ),
                if (profile.specialization.isNotEmpty)
                  _buildChipsRow('Specialization', profile.specialization),
              ],
            ),
            const SizedBox(height: 16),

            // Bio
            if (profile.bio != null && profile.bio!.isNotEmpty)
              _buildProfileSection(
                title: 'Bio',
                icon: Icons.description_outlined,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      profile.bio!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Account Details
            _buildProfileSection(
              title: 'Account Details',
              icon: Icons.info_outline,
              children: [
                _buildInfoRow('Member Since', _formatDate(profile.createdAt)),
                _buildInfoRow('Last Updated', _formatDate(profile.updatedAt)),
                if (profile.lastLogin != null)
                  _buildInfoRow('Last Login', _formatDate(profile.lastLogin!)),
                _buildInfoRow('Account ID', profile.id),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
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
            flex: 3,
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

  Widget _buildVerificationRow(
    String label,
    bool isVerified, {
    String activeText = 'Verified',
    String inactiveText = 'Not Verified',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  isVerified ? activeText : inactiveText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsRow(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ==================== Support Tab ====================

  Widget _buildSupportTab() {
    return Obx(() {
      if (controller.isLoadingTickets.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    const Text(
                      'Support Tickets',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/raise-ticket')?.then((_) {
                          controller.refreshTickets();
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTicketStatCard(
                        'Open',
                        controller.openTicketsCount.value.toString(),
                        Icons.assignment_outlined,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTicketStatCard(
                        'In Progress',
                        controller.inProgressTicketsCount.value.toString(),
                        Icons.pending_outlined,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTicketStatCard(
                        'Resolved',
                        controller.resolvedTicketsCount.value.toString(),
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tickets List
          SizedBox(
            height: 600,
            child: controller.supportTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No support tickets yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a ticket if you need help',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed('/raise-ticket')?.then((_) {
                              controller.refreshTickets();
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: controller.refreshTickets,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.supportTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = controller.supportTickets[index];
                        return _buildSupportTicketCard(ticket);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildTicketStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTicketCard(Ticket ticket) {
    Color statusColor;
    IconData statusIcon;

    switch (ticket.status) {
      case TicketStatus.open:
        statusColor = Colors.orange;
        statusIcon = Icons.fiber_new_rounded;
        break;
      case TicketStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.pending_rounded;
        break;
      case TicketStatus.resolved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case TicketStatus.closed:
        statusColor = Colors.grey;
        statusIcon = Icons.archive_rounded;
        break;
    }

    Color priorityColor;
    switch (ticket.priority) {
      case TicketPriority.low:
        priorityColor = Colors.green;
        break;
      case TicketPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TicketPriority.high:
        priorityColor = Colors.red;
        break;
      case TicketPriority.urgent:
        priorityColor = Colors.deepPurple;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/ticket-details/${ticket.id}')?.then((_) {
              controller.refreshTickets();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.ticketNumber,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket.subject,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: priorityColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        ticket.priority.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  ticket.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(ticket.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    if (ticket.responses.isNotEmpty) ...[
                      Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ticket.responses.length} ${ticket.responses.length == 1 ? 'reply' : 'replies'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentExerciseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _StudentExerciseDetailsScreen({required this.summary});

  @override
  Widget build(BuildContext context) {
    final chapters = (summary['chapters'] as List?) ?? [];
    final totalChapters = summary['totalChapters'] as int? ?? 0;
    final videosCompleted = summary['videosCompleted'] as int? ?? 0;
    final exercisesCompleted = summary['exercisesCompleted'] as int? ?? 0;
    final board = summary['board'] as String? ?? '-';
    final grade = summary['grade'] as String? ?? '-';
    final subject = summary['subject'] as String? ?? '-';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(summary['studentName'] as String? ?? 'Student Progress'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _detailTag(Icons.account_balance, board),
                              _detailTag(Icons.school, 'Grade $grade'),
                              _detailTag(Icons.menu_book, subject),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _summaryTile('Chapters', '$totalChapters'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryTile(
                            'Videos',
                            '$videosCompleted/$totalChapters',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryTile(
                            'Exercises',
                            '$exercisesCompleted/$totalChapters',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Chapter-wise Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: chapters.isEmpty
                    ? Center(
                        child: Text(
                          'No chapter data available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: chapters.length,
                        itemBuilder: (context, index) {
                          final chapter =
                              chapters[index] as Map<String, dynamic>;
                          final videoCompleted =
                              chapter['videoCompleted'] == true;
                          final exerciseAttempted =
                              chapter['exerciseAttempted'] == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter['chapter'] as String? ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _chapterStatusChip(
                                      icon: videoCompleted
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      label: videoCompleted
                                          ? 'Video Completed'
                                          : 'Video Pending',
                                      success: videoCompleted,
                                    ),
                                    const SizedBox(width: 8),
                                    _chapterStatusChip(
                                      icon: exerciseAttempted
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      label: exerciseAttempted
                                          ? 'Exercise Completed'
                                          : 'Exercise Pending',
                                      success: exerciseAttempted,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _chapterStatusChip({
    required IconData icon,
    required String label,
    required bool success,
  }) {
    final color = success ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for pie chart
class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> videos;

  _PieChartPainter(this.videos);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Calculate total ratings
    final totalRatings = videos.fold<int>(
      0,
      (sum, video) => sum + (video['totalRatings'] as int),
    );

    if (totalRatings == 0) return;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (int i = 0; i < videos.length.clamp(0, 8); i++) {
      final video = videos[i];
      final ratings = video['totalRatings'] as int;
      final sweepAngle = (ratings / totalRatings) * 2 * 3.14159;

      final paint = Paint()
        ..color = _getColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw white circle in center for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  Color _getColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => true;
}

// ─── Announcement Details Sheet ──────────────────────────────────────────────

class _AnnouncementDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> announcement;
  final String Function(DateTime) formatTimestamp;

  const _AnnouncementDetailsSheet({
    required this.announcement,
    required this.formatTimestamp,
  });

  @override
  State<_AnnouncementDetailsSheet> createState() =>
      _AnnouncementDetailsSheetState();
}

class _AnnouncementDetailsSheetState extends State<_AnnouncementDetailsSheet> {
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
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
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

  Future<void> _togglePlay(String audioUrl) async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      final url = ApiConstants.baseUrl.replaceAll('/api', '') + audioUrl;
      await _player.play(UrlSource(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ann = widget.announcement;
    final typeColor = ann['type'] == 'urgent'
        ? const Color(0xFFEF4444)
        : ann['type'] == 'important'
        ? const Color(0xFFFF8C00)
        : const Color(0xFF10B981);
    final typeBg = ann['type'] == 'urgent'
        ? const Color(0xFFFEF2F2)
        : ann['type'] == 'important'
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFF0FDF4);
    DateTime? ts;
    if (ann['createdAt'] != null) {
      ts = DateTime.tryParse(ann['createdAt'].toString());
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type chip + timestamp
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: typeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: typeColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ann['type'] == 'urgent'
                                  ? Icons.priority_high_rounded
                                  : ann['type'] == 'important'
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline_rounded,
                              size: 14,
                              color: typeColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (ann['type'] ?? 'general')
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (ts != null)
                        Text(
                          widget.formatTimestamp(ts),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    ann['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    ann['message'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),

                  // Audio player (if audioUrl present)
                  if (ann['audioUrl'] != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: typeColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.headphones_rounded,
                                size: 16,
                                color: typeColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Voice Announcement',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: typeColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Play / Pause button
                              GestureDetector(
                                onTap: () => _togglePlay(ann['audioUrl']),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: typeColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: typeColor.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: typeColor,
                                        inactiveTrackColor: typeColor
                                            .withOpacity(0.2),
                                        thumbColor: typeColor,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 7,
                                        ),
                                        trackHeight: 4,
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 14,
                                            ),
                                      ),
                                      child: Slider(
                                        value: _duration.inSeconds > 0
                                            ? (_position.inSeconds
                                                  .toDouble()
                                                  .clamp(
                                                    0,
                                                    _duration.inSeconds
                                                        .toDouble(),
                                                  ))
                                            : 0.0,
                                        max: _duration.inSeconds > 0
                                            ? _duration.inSeconds.toDouble()
                                            : 1.0,
                                        onChanged: (v) async {
                                          await _player.seek(
                                            Duration(seconds: v.toInt()),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
