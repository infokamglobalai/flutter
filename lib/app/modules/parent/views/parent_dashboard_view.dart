import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/parent_dashboard_controller.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';

class ParentDashboardView extends GetView<ParentDashboardController> {
  const ParentDashboardView({super.key});

  // ── Palette (matching student_profile_view pattern) ─────────────────────
  static const _primary = Color(0xFF2E7D9F); // AppTheme.primaryColor
  static const _navy = Color(0xFF1F2937); // main text dark
  static const _indigo = Color(0xFF4F46E5);
  static const _emerald = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _rose = Color(0xFFF43F5E);
  static const _violet = Color(0xFF8B5CF6);
  static const _sky = Color(0xFF0EA5E9);
  static const _surface = Color(0xFFF5F5F5);
  static const _card = Colors.white;

  static Color _pColor(String p) {
    switch (p) {
      case 'excellent':
        return _emerald;
      case 'needs-improvement':
        return _amber;
      default:
        return _indigo;
    }
  }

  static String _pLabel(String p) {
    switch (p) {
      case 'excellent':
        return 'Excellent';
      case 'needs-improvement':
        return 'Needs Help';
      default:
        return 'Good';
    }
  }

  static IconData _pIcon(String p) {
    switch (p) {
      case 'excellent':
        return Icons.workspace_premium_rounded;
      case 'needs-improvement':
        return Icons.trending_up_rounded;
      default:
        return Icons.thumb_up_alt_rounded;
    }
  }

  static Color _scoreColor(double pct) {
    if (pct >= 80) return _emerald;
    if (pct >= 60) return _indigo;
    return _amber;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: _primary,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildProfileCard(),
                Obx(() {
                  switch (controller.selectedTab.value) {
                    case 0:
                      return _buildDashboardTab();
                    case 1:
                      return _buildResourcesTab();
                    case 2:
                      return _buildReferralTab();
                    case 3:
                      return _buildSupportTab();
                    default:
                      return _buildDashboardTab();
                  }
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Avatar + name column
                Obx(() {
                  final name = controller.parentName.value;
                  final initials = name.trim().isNotEmpty
                      ? name
                            .trim()
                            .split(' ')
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                      : 'P';
                  return Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primary, _sky],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name.isNotEmpty
                                ? 'Welcome back,'
                                : 'Parent Dashboard',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (name.isNotEmpty)
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _navy,
                                letterSpacing: -0.2,
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                }),
                const Spacer(),
                // Notification button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Logout button
                GestureDetector(
                  onTap: _showLogoutDialog,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _rose.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: _rose.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.face_rounded, size: 40, color: _primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.parentName.value.isNotEmpty
                        ? 'Hi, ${controller.parentName.value}! 👋'
                        : 'Welcome Back! 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todayString(),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: _primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Parent Portal',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Obx(
                      () => Text(
                        '· ${controller.kids.length} student${controller.kids.length != 1 ? "s" : ""}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildSliverHeader and _buildHeaderBg replaced by _buildAppBar and _buildProfileCard above

  String _todayString() {
    final now = DateTime.now();
    const months = [
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: _rose, size: 22),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Get.back();
              final auth = Get.find<AuthController>();
              final storage = Get.find<StorageService>();
              await storage.clearAuth();
              auth.logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _navItem(
                1,
                Icons.play_lesson_rounded,
                Icons.play_lesson_outlined,
                'Resources',
              ),
              _navItem(
                2,
                Icons.card_giftcard_rounded,
                Icons.card_giftcard_outlined,
                'Refer',
              ),
              _navItem(
                3,
                Icons.headset_mic_rounded,
                Icons.headset_mic_outlined,
                'Support',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.selectTab(index),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isSelected ? active : inactive,
                  color: isSelected ? _primary : Colors.grey[400],
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _primary : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDashboardTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.kids.isEmpty) return const SizedBox.shrink();
            return _buildFamilyOverview();
          }),
          const SizedBox(height: 20),
          _sectionHeader(
            'Your Children',
            Icons.groups_rounded,
            trailing: Obx(() => _badge('${controller.kids.length}', _primary)),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (controller.isLoadingKids.value)
              return _loading('Fetching student data...');
            if (controller.kidsError.value.isNotEmpty)
              return _errorWidget(
                controller.kidsError.value,
                controller.refreshData,
              );
            if (controller.kids.isEmpty) return _emptyKids();
            return Column(
              children: controller.kids
                  .map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _kidCard(k),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFamilyOverview() {
    final total = controller.kids.length;
    final avgScore = total > 0
        ? controller.kids.fold<double>(
                0,
                (s, k) => s + ((k['averageScore'] as int?) ?? 0),
              ) /
              total
        : 0.0;
    final totalVideos = controller.kids.fold<int>(
      0,
      (s, k) => s + ((k['videosWatched'] as int?) ?? 0),
    );
    final totalTests = controller.kids.fold<int>(
      0,
      (s, k) => s + ((k['assessmentsCompleted'] as int?) ?? 0),
    );
    final excellent = controller.kids
        .where((k) => k['performance'] == 'excellent')
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              const Text(
                'Family Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              if (excellent > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: _emerald,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$excellent Excellent',
                        style: const TextStyle(
                          color: _emerald,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _overviewTile(
                Icons.person_rounded,
                total.toString(),
                'Students',
                _sky,
              ),
              _overviewDivider(),
              _overviewTile(
                Icons.emoji_events_rounded,
                '${avgScore.round()}%',
                'Avg Score',
                _amber,
              ),
              _overviewDivider(),
              _overviewTile(
                Icons.smart_display_rounded,
                totalVideos.toString(),
                'Videos',
                _violet,
              ),
              _overviewDivider(),
              _overviewTile(
                Icons.fact_check_rounded,
                totalTests.toString(),
                'Tests Done',
                _emerald,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewTile(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _overviewDivider() =>
      Container(width: 1, height: 50, color: Colors.grey.shade200);

  Widget _kidCard(Map<String, dynamic> kid) {
    final String perf = kid['performance'] as String? ?? 'good';
    final Color pc = _pColor(perf);
    final String name = kid['name'] as String? ?? 'Student';
    final String grade = kid['grade'] as String? ?? '';
    final String board = kid['board'] as String? ?? '';
    final int avgScore = (kid['averageScore'] as int?) ?? 0;
    final int videosWatched = (kid['videosWatched'] as int?) ?? 0;
    final int totalVideos = (kid['totalVideos'] as int?) ?? 1;
    final int assessmentsDone = (kid['assessmentsCompleted'] as int?) ?? 0;
    final int totalChapters = (kid['totalAssessmentChapters'] as int?) ?? 1;
    final int selfTests = (kid['selfAssessmentsCompleted'] as int?) ?? 0;
    final double videoPct = totalVideos > 0 ? videosWatched / totalVideos : 0;
    final double assessPct = totalChapters > 0
        ? assessmentsDone / totalChapters
        : 0;
    final initials = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'S';
    final recentAssessments = ((kid['recentAssessments'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

    return GestureDetector(
      onTap: () => controller.viewKidDetails(kid),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: pc.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: pc.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top band
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: pc.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(23),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [pc, pc.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: pc.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (grade.isNotEmpty)
                              _pill(grade, _sky.withValues(alpha: 0.15), _sky),
                            if (board.isNotEmpty)
                              _pill(
                                board,
                                _violet.withValues(alpha: 0.12),
                                _violet,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: pc,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: pc.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(_pIcon(perf), color: Colors.white, size: 16),
                        const SizedBox(height: 3),
                        Text(
                          _pLabel(perf),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    _scoreCell(
                      Icons.emoji_events_rounded,
                      '$avgScore%',
                      'Score',
                      _amber,
                    ),
                    _vLine(),
                    _scoreCell(
                      Icons.smart_display_rounded,
                      '$videosWatched/$totalVideos',
                      'Videos',
                      _violet,
                    ),
                    _vLine(),
                    _scoreCell(
                      Icons.fact_check_rounded,
                      '$assessmentsDone/$totalChapters',
                      'Tests',
                      _emerald,
                    ),
                    _vLine(),
                    _scoreCell(
                      Icons.quiz_rounded,
                      selfTests.toString(),
                      'Self Tests',
                      _sky,
                    ),
                  ],
                ),
              ),
            ),
            // Progress bars
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                children: [
                  _progressBar(
                    Icons.smart_display_rounded,
                    'Video Completion',
                    '$videosWatched of $totalVideos videos watched',
                    videoPct,
                    _violet,
                  ),
                  const SizedBox(height: 10),
                  _progressBar(
                    Icons.fact_check_rounded,
                    'Assessment Progress',
                    '$assessmentsDone of $totalChapters chapters assessed',
                    assessPct,
                    _emerald,
                  ),
                  const SizedBox(height: 10),
                  _progressBar(
                    Icons.emoji_events_rounded,
                    'Overall Score',
                    '$avgScore% average across all tests',
                    avgScore / 100,
                    _scoreColor(avgScore.toDouble()),
                  ),
                ],
              ),
            ),
            // Recent assessments
            if (recentAssessments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: pc,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      'Recent Assessments',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${recentAssessments.length > 3 ? 3 : recentAssessments.length} of ${recentAssessments.length}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              ...recentAssessments.take(3).map((a) => _assessmentRow(a)),
            ],
            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => controller.viewKidDetails(kid),
                  icon: const Icon(Icons.bar_chart_rounded, size: 18),
                  label: const Text(
                    'View Full Progress Report',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pc,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreCell(IconData icon, String val, String lbl, Color c) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: c, size: 16),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            lbl,
            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _vLine() =>
      Container(width: 1, height: 36, color: Colors.grey.shade200);

  Widget _progressBar(
    IconData icon,
    String title,
    String subtitle,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(value * 100).clamp(0, 100).round()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
      ],
    );
  }

  Widget _assessmentRow(Map<String, dynamic> a) {
    final int score = (a['score'] as int?) ?? 0;
    final int total = (a['totalMarks'] as int?) ?? 0;
    final double pct =
        (a['percentage'] as double?) ?? (total > 0 ? score / total * 100 : 0.0);
    final String subject = a['subject'] as String? ?? '';
    final String chapter = a['chapter'] as String? ?? '';
    final Color sc = _scoreColor(pct);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sc.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${pct.round()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: sc,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                  ),
                  if (chapter.isNotEmpty)
                    Text(
                      chapter,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score/$total',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sc,
                  ),
                ),
                Text(
                  'marks',
                  style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primary, size: 20),
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
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _loading(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _errorWidget(String msg, VoidCallback retry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _rose.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _rose.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded, color: _rose, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyKids() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_rounded, size: 48, color: _primary),
          ),
          const SizedBox(height: 18),
          const Text(
            'No Students Linked',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your children's profiles will appear here once the admin links their accounts.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _sectionHeader('Parent Resources', Icons.play_lesson_rounded),
          const SizedBox(height: 6),
          Text(
            'Curated videos & guides to help you support your child',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 18),
          Obx(() {
            if (controller.isLoadingResources.value)
              return _loading('Loading resources...');
            if (controller.resources.isEmpty) return _emptyResources();
            return Column(
              children: controller.resources
                  .map((r) => _resourceCard(r))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyResources() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library_rounded,
              size: 40,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No resources yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Resources will appear here once they are added',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _resourceCard(Map<String, dynamic> resource) {
    final bool isYoutube =
        (resource['videoType'] as String? ?? '') == 'youtube';
    final Color accent = isYoutube ? _rose : _primary;
    final String category = resource['category'] as String? ?? '';
    final String title = resource['title'] as String? ?? '';
    final String thumbUrl = resource['thumbnail'] as String? ?? '';

    return GestureDetector(
      onTap: () => controller.playResource(resource),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: SizedBox(
                width: 100,
                height: 86,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumbUrl.isNotEmpty
                        ? Image.network(
                            thumbUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: accent.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.video_library_rounded,
                                color: accent,
                                size: 30,
                              ),
                            ),
                          )
                        : Container(
                            color: accent.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.video_library_rounded,
                              color: accent,
                              size: 30,
                            ),
                          ),
                    // Dark gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Play button
                    Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: accent,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                        height: 1.35,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (category.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isYoutube
                                ? _rose.withValues(alpha: 0.07)
                                : _primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isYoutube
                                  ? _rose.withValues(alpha: 0.22)
                                  : _primary.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isYoutube
                                    ? Icons.smart_display_rounded
                                    : Icons.cloud_upload_rounded,
                                size: 9,
                                color: isYoutube ? _rose : _primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isYoutube ? 'YouTube' : 'Video',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isYoutube ? _rose : _primary,
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
            ),
            // ── Arrow ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _referralHeroCard(),
          const SizedBox(height: 16),
          _howItWorksCard(),
          const SizedBox(height: 16),
          _referralFormCard(),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.referralHistory.isEmpty)
              return const SizedBox.shrink();
            return _referralHistoryCard();
          }),
        ],
      ),
    );
  }

  Widget _referralHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient top accent
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _sky],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _sky],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.diversity_1_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invite a Friend',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share the joy of quality education.\nHelp another family discover Najah!',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => _badge(
                          controller.referralHistory.isEmpty
                              ? 'No invites yet'
                              : '${controller.referralHistory.length} invitation${controller.referralHistory.length == 1 ? '' : 's'} sent',
                          controller.referralHistory.isEmpty
                              ? Colors.grey
                              : _emerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 3 benefit pills
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                _benefitPill('📚', 'Smart\nCurriculum'),
                const SizedBox(width: 10),
                _benefitPill('🤖', 'AI\nTutors'),
                const SizedBox(width: 10),
                _benefitPill('📊', 'Progress\nReports'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitPill(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: _navy,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _howItWorksCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('How It Works', Icons.auto_awesome_rounded),
          const SizedBox(height: 18),
          _howStep(
            1,
            'Fill Friend\'s Details',
            'Enter their name and email below',
            _primary,
          ),
          _howStep(
            2,
            'We Send the Invite',
            'A beautiful invitation email is delivered instantly',
            _sky,
          ),
          _howStep(
            3,
            'They Join Najah',
            'Your friend downloads the app and begins learning',
            _emerald,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _howStep(
    int n,
    String title,
    String sub,
    Color c, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c, c.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: c.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$n',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _referralFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EFFE),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: _primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Friend's Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _formField(
            label: 'Full Name *',
            hint: "Friend's full name",
            icon: Icons.person_rounded,
            textController: controller.referralNameCtrl,
            onChanged: (v) => controller.referralName.value = v,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Email Address *',
            hint: "friend@example.com",
            icon: Icons.alternate_email_rounded,
            keyboard: TextInputType.emailAddress,
            textController: controller.referralEmailCtrl,
            onChanged: (v) => controller.referralEmail.value = v,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Phone Number (optional)',
            hint: '+91 98765 43210',
            icon: Icons.phone_rounded,
            keyboard: TextInputType.phone,
            textController: controller.referralPhoneCtrl,
            onChanged: (v) => controller.referralPhone.value = v,
          ),
          const SizedBox(height: 22),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.isSubmittingReferral.value
                    ? null
                    : controller.submitReferral,
                icon: controller.isSubmittingReferral.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 19),
                label: Text(
                  controller.isSubmittingReferral.value
                      ? 'Sending Invitation...'
                      : 'Send Invitation',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: _emerald,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sent Invitations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navy,
                ),
              ),
              const Spacer(),
              Obx(
                () => _badge('${controller.referralHistory.length}', _emerald),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final items = controller.referralHistory.reversed.take(5).toList();
            return Column(
              children: List.generate(items.length, (i) {
                return _referralHistoryItem(items[i], i == items.length - 1);
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _referralHistoryItem(Map<String, dynamic> item, bool isLast) {
    final name = item['name'] as String? ?? '';
    final email = item['email'] as String? ?? '';
    final initials = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';
    final sentAt = item['sentAt'] as String? ?? '';
    final isOffline = item['offline'] == true;

    String relTime = '';
    try {
      final dt = DateTime.parse(sentAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) {
        relTime = 'Just now';
      } else if (diff.inHours < 1) {
        relTime = '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        relTime = '${diff.inHours}h ago';
      } else {
        relTime = '${diff.inDays}d ago';
      }
    } catch (_) {}

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primary,
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
                      name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _navy,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOffline
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOffline ? 'Queued' : 'Sent ✓',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOffline ? _amber : _emerald,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    relTime,
                    style: TextStyle(fontSize: 9.5, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 0, thickness: 1, color: Colors.grey.shade100),
      ],
    );
  }

  Widget _formField({
    required String label,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    TextInputType keyboard = TextInputType.text,
    TextEditingController? textController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _navy,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: textController,
          onChanged: onChanged,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: _primary, size: 20),
            filled: true,
            fillColor: _surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportTab() {
    return Obx(() {
      if (controller.isLoadingTickets.value)
        return _loading('Loading support center...');
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Support Center', Icons.headset_mic_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                _supportStatTile(
                  controller.openTicketsCount.value.toString(),
                  'Open',
                  Icons.radio_button_checked_rounded,
                  _amber,
                ),
                const SizedBox(width: 10),
                _supportStatTile(
                  controller.inProgressTicketsCount.value.toString(),
                  'In Progress',
                  Icons.timelapse_rounded,
                  _sky,
                ),
                const SizedBox(width: 10),
                _supportStatTile(
                  controller.resolvedTicketsCount.value.toString(),
                  'Resolved',
                  Icons.check_circle_rounded,
                  _emerald,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    Icons.add_comment_rounded,
                    'New Ticket',
                    _primary,
                    () => Get.toNamed(
                      '/raise-ticket',
                    )?.then((_) => controller.refreshTickets()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionBtn(
                    Icons.refresh_rounded,
                    'Refresh',
                    _emerald,
                    () => controller.refreshTickets(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'My Tickets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _navy,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.supportTickets.length} total',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.supportTickets.isEmpty)
              _emptyTickets()
            else
              ...controller.supportTickets.map(_ticketCard),
          ],
        ),
      );
    });
  }

  Widget _supportStatTile(
    String val,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              val,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyTickets() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, size: 40, color: _primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Tickets Yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a ticket if you need help from our support team.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(
              '/raise-ticket',
            )?.then((_) => controller.refreshTickets()),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Create Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketCard(Ticket ticket) {
    Color sc;
    IconData si;
    String sl;
    switch (ticket.status) {
      case TicketStatus.open:
        sc = _amber;
        si = Icons.radio_button_checked_rounded;
        sl = 'OPEN';
        break;
      case TicketStatus.inProgress:
        sc = _sky;
        si = Icons.timelapse_rounded;
        sl = 'IN PROGRESS';
        break;
      case TicketStatus.resolved:
        sc = _emerald;
        si = Icons.check_circle_rounded;
        sl = 'RESOLVED';
        break;
      case TicketStatus.closed:
        sc = Colors.grey;
        si = Icons.archive_rounded;
        sl = 'CLOSED';
        break;
    }
    String pe;
    switch (ticket.priority) {
      case TicketPriority.low:
        pe = '🟢';
        break;
      case TicketPriority.medium:
        pe = '🟡';
        break;
      case TicketPriority.high:
        pe = '🔴';
        break;
      case TicketPriority.urgent:
        pe = '🚨';
        break;
    }
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/ticket-details/${ticket.id}',
      )?.then((_) => controller.refreshTickets()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: sc.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.07),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
              ),
              child: Row(
                children: [
                  Icon(si, color: sc, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    sl,
                    style: TextStyle(
                      color: sc,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(pe, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    _getCategoryLabel(ticket.category),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ticket.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(ticket.createdAt),
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 10,
                                color: _primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 9,
                              color: _primary,
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
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0)
        return diff.inMinutes == 0 ? 'Just now' : '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getCategoryLabel(TicketCategory category) {
    switch (category) {
      case TicketCategory.technical:
        return 'Technical';
      case TicketCategory.subjectRelated:
        return 'Subject';
      case TicketCategory.paymentRelated:
        return 'Payment';
      case TicketCategory.contentIssue:
        return 'Content';
      case TicketCategory.featureRequest:
        return 'Feature';
      case TicketCategory.other:
        return 'Other';
    }
  }
}
