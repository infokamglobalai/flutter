import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/kid_detailed_progress_controller.dart';

class KidDetailedProgressView extends GetView<KidDetailedProgressController> {
  const KidDetailedProgressView({super.key});

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

  static Color _scoreColor(double pct) {
    if (pct >= 80) return _emerald;
    if (pct >= 60) return _indigo;
    if (pct >= 40) return _amber;
    return _rose;
  }

  static Color _subjectColor(int index) {
    const colors = [_indigo, _emerald, _violet, _sky, _amber, _rose];
    return colors[index % colors.length];
  }

  static IconData _activityIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.smart_display_rounded;
      case 'assessment':
        return Icons.fact_check_rounded;
      case 'self':
        return Icons.quiz_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // ── Root ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Obx(() {
        final perf = controller.kidData['performance'] as String? ?? 'good';
        final Color pc = _performanceGradientEnd(perf);
        return Scaffold(
          backgroundColor: _surface,
          body: controller.isLoading.value
              ? _buildLoadingScreen()
              : RefreshIndicator(
                  onRefresh: controller.refreshData,
                  color: _primary,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverAppBar(
                        pinned: true,
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
                        title: Obx(() {
                          final n = controller.kidData['name'] as String? ?? '';
                          return Text(
                            n.isNotEmpty ? n : 'Student Progress',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                        centerTitle: false,
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: Colors.grey[600],
                            ),
                            onPressed: controller.refreshData,
                          ),
                        ],
                      ),
                    ],
                    body: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStudentCard(pc, perf),
                          _buildPerformanceBanner(perf),
                          const SizedBox(height: 16),
                          _buildStatsGrid(),
                          const SizedBox(height: 16),
                          _buildSubjectsSection(),
                          const SizedBox(height: 16),
                          _buildAssessmentHistorySection(),
                          const SizedBox(height: 16),
                          _buildRecentActivitiesSection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildStudentCard(Color pc, String perf) {
    return Obx(() {
      final String name = controller.kidData['name'] as String? ?? 'Student';
      final String grade = controller.kidData['grade'] as String? ?? '';
      final String board = controller.kidData['board'] as String? ?? '';
      final String initials = name.trim().isNotEmpty
          ? name.trim()[0].toUpperCase()
          : 'S';
      final int avgScore = (controller.kidData['averageScore'] as int?) ?? 0;
      final int videos = (controller.kidData['videosWatched'] as int?) ?? 0;
      final int assessments =
          (controller.kidData['assessmentsCompleted'] as int?) ?? 0;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [pc, pc.withValues(alpha: 0.65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: pc.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
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
                              _chip(grade, const Color(0xFFE0F2FE), _sky),
                            if (board.isNotEmpty)
                              _chip(board, const Color(0xFFEDE9FE), _violet),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(_performanceIcon(perf), color: pc, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              controller.performanceLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pc,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Score badge
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _scoreColor(
                        avgScore.toDouble(),
                      ).withValues(alpha: 0.1),
                      border: Border.all(
                        color: _scoreColor(
                          avgScore.toDouble(),
                        ).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$avgScore',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _scoreColor(avgScore.toDouble()),
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            fontSize: 9,
                            color: _scoreColor(
                              avgScore.toDouble(),
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Quick stats strip
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  _quickStat(
                    Icons.smart_display_rounded,
                    '$videos',
                    'Videos',
                    _violet,
                  ),
                  _stripDivider(),
                  _quickStat(
                    Icons.fact_check_rounded,
                    '$assessments',
                    'Tests',
                    _emerald,
                  ),
                  _stripDivider(),
                  _quickStat(
                    Icons.emoji_events_rounded,
                    '$avgScore%',
                    'Avg Score',
                    _amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _quickStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _stripDivider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _performanceGradientEnd(String p) {
    switch (p) {
      case 'excellent':
        return _emerald;
      case 'needs-improvement':
        return _amber;
      default:
        return _indigo;
    }
  }

  // ── Loading ────────────────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF2E7D9F),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 20),
            Text(
              'Loading progress...',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  IconData _performanceIcon(String p) {
    switch (p) {
      case 'excellent':
        return Icons.workspace_premium_rounded;
      case 'needs-improvement':
        return Icons.trending_up_rounded;
      default:
        return Icons.thumb_up_rounded;
    }
  }

  // ── Performance Banner ─────────────────────────────────────────────────────
  Widget _buildPerformanceBanner(String perf) {
    return Obx(() {
      final Color pc = controller.performanceColor;
      final int avgScore = (controller.kidData['averageScore'] as int?) ?? 0;
      final String msg = controller.getPerformanceMessage();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Colored top accent
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: pc,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Circular score
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: CircularProgressIndicator(
                              value: avgScore / 100,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(pc),
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$avgScore',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: pc,
                                ),
                              ),
                              Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: pc.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: pc.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _performanceIcon(perf),
                                  color: pc,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.performanceLabel,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: pc,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            msg,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Stats Grid ─────────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    return Obx(() {
      final int videos = (controller.kidData['videosWatched'] as int?) ?? 0;
      final int totalVideos = (controller.kidData['totalVideos'] as int?) ?? 0;
      final int assessments =
          (controller.kidData['assessmentsCompleted'] as int?) ?? 0;
      final int totalChapters =
          (controller.kidData['totalAssessmentChapters'] as int?) ?? 0;
      final int avgScore = (controller.kidData['averageScore'] as int?) ?? 0;
      final int selfTests =
          (controller.kidData['selfAssessmentsCompleted'] as int?) ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Key Statistics', Icons.bar_chart_rounded, _indigo),
            const SizedBox(height: 14),
            Row(
              children: [
                _stat2Card(
                  Icons.smart_display_rounded,
                  '$videos/$totalVideos',
                  'Videos Watched',
                  _violet,
                  videos / (totalVideos > 0 ? totalVideos : 1),
                ),
                const SizedBox(width: 12),
                _stat2Card(
                  Icons.fact_check_rounded,
                  '$assessments/$totalChapters',
                  'Assessments Done',
                  _emerald,
                  assessments / (totalChapters > 0 ? totalChapters : 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat2Card(
                  Icons.emoji_events_rounded,
                  '$avgScore%',
                  'Average Score',
                  _scoreColor(avgScore.toDouble()),
                  avgScore / 100,
                ),
                const SizedBox(width: 12),
                _stat2Card(
                  Icons.quiz_rounded,
                  selfTests.toString(),
                  'Self Tests Done',
                  _sky,
                  null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _stat2Card(
    IconData icon,
    String value,
    String label,
    Color color,
    double? progress,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _navy,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                height: 1.2,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Subject Progress ───────────────────────────────────────────────────────
  Widget _buildSubjectsSection() {
    return Obx(() {
      if (controller.subjectProgress.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Subject Progress', Icons.school_rounded, _violet),
            const SizedBox(height: 14),
            ...controller.subjectProgress.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _subjectCard(e.value, e.key),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _subjectCard(Map<String, dynamic> subject, int index) {
    final String name = subject['name'] as String? ?? 'Subject';
    final int watched = (subject['videosWatched'] as int?) ?? 0;
    final int totalVideos = (subject['totalVideos'] as int?) ?? 1;
    final double progress = (subject['progress'] as double?) ?? 0.0;
    final int assessmentsDone = (subject['assessmentsCompleted'] as int?) ?? 0;
    final int avgScore = (subject['averageScore'] as int?) ?? 0;
    final int scoreCount = (subject['scoreCount'] as int?) ?? 0;
    final Color color = _subjectColor(index);
    final String initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
    final Color scorec = _scoreColor(avgScore.toDouble());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left color accent bar with initials
            Container(
              width: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _navy,
                            ),
                          ),
                        ),
                        if (scoreCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: scorec.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$avgScore%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: scorec,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$assessmentsDone assessment${assessmentsDone != 1 ? 's' : ''} · $scoreCount score${scoreCount != 1 ? 's' : ''} recorded',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 14),
                    // Progress row
                    Row(
                      children: [
                        Icon(
                          Icons.smart_display_rounded,
                          size: 12,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$watched / $totalVideos videos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Assessment History ─────────────────────────────────────────────────────
  Widget _buildAssessmentHistorySection() {
    return Obx(() {
      if (controller.assessmentHistory.isEmpty) return const SizedBox.shrink();
      final list = controller.assessmentHistory.take(10).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _sectionTitle(
                    'Assessment History',
                    Icons.history_edu_rounded,
                    _emerald,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.assessmentHistory.length} total',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _emerald,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
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
                children: list.asMap().entries.map((e) {
                  final isLast = e.key == list.length - 1;
                  return _assessmentHistoryCard(e.value, e.key, isLast);
                }).toList(),
              ),
            ),
            if (controller.assessmentHistory.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    '+${controller.assessmentHistory.length - 10} more assessments',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _assessmentHistoryCard(
    Map<String, dynamic> assessment,
    int index,
    bool isLast,
  ) {
    final String type = assessment['type'] as String? ?? 'chapter';
    final String subject = assessment['subject'] as String? ?? '';
    final String chapter = assessment['chapter'] as String? ?? '';
    final int score = (assessment['score'] as int?) ?? 0;
    final int totalMarks = (assessment['totalMarks'] as int?) ?? 0;
    final double pct =
        (assessment['percentage'] as double?) ??
        (totalMarks > 0 ? score / totalMarks * 100 : 0.0);
    final String date = assessment['date'] as String? ?? '';
    final String pkg = assessment['packageName'] as String? ?? '';
    final Color sc = _scoreColor(pct);
    final bool isSelf = type == 'self';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sc.withValues(alpha: 0.1),
              border: Border.all(color: sc.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${pct.round()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: sc,
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 8,
                    color: sc.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _navy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelf
                            ? const Color(0xFFE0F2FE)
                            : const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSelf ? 'Self' : 'Chapter',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelf ? _sky : _emerald,
                        ),
                      ),
                    ),
                  ],
                ),
                if (chapter.isNotEmpty)
                  Text(
                    chapter,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (pkg.isNotEmpty && !isSelf)
                  Text(
                    pkg,
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '$score / $totalMarks marks',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sc,
                      ),
                    ),
                    const Spacer(),
                    if (date.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
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

  // ── Recent Activities ──────────────────────────────────────────────────────
  Widget _buildRecentActivitiesSection() {
    return Obx(() {
      if (controller.recentActivities.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Recent Activity', Icons.timeline_rounded, _sky),
            const SizedBox(height: 14),
            Container(
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
                children: controller.recentActivities
                    .take(10)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) {
                      final isLast =
                          e.key == controller.recentActivities.length - 1 ||
                          e.key == 9;
                      return _activityItem(e.value, e.key, isLast);
                    })
                    .toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _activityItem(Map<String, dynamic> activity, int index, bool isLast) {
    final String type = activity['type'] as String? ?? 'video';
    final String title = activity['title'] as String? ?? '';
    final String subtitle = activity['subtitle'] as String? ?? '';
    final String time = activity['time'] as String? ?? '';
    final int? score = activity['score'] as int?;

    Color iconColor;
    Color iconBg;
    IconData actIcon = _activityIcon(type);
    switch (type) {
      case 'video':
        iconColor = _violet;
        iconBg = const Color(0xFFEDE9FE);
        break;
      case 'assessment':
        iconColor = _emerald;
        iconBg = const Color(0xFFD1FAE5);
        break;
      default:
        iconColor = _sky;
        iconBg = const Color(0xFFE0F2FE);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(actIcon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _navy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _scoreColor(score.toDouble()).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(score.toDouble()),
                    ),
                  ),
                ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
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
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
