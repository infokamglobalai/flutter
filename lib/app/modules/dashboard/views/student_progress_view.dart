import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';

class StudentProgressView extends GetView<DashboardController> {
  const StudentProgressView({super.key});

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
          'My Progress',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoadingProgress.value;
        final progressData = controller.studentProgressData.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (progressData == null) {
          return _buildEmptyState();
        }

        return _buildProgressContent(progressData);
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No progress data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start learning to track your progress',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressContent(Map<String, dynamic> progressData) {
    final packages = progressData['packages'] as List<dynamic>? ?? [];

    // Calculate overall stats
    int totalVideos = 0;
    int completedVideos = 0;
    int totalAssessments = 0;
    double totalScore = 0.0;
    int totalSelfAssessments = 0;

    for (var package in packages) {
      final chapters = package['chapters'] as List<dynamic>? ?? [];
      for (var chapter in chapters) {
        totalVideos++;
        if (chapter['videoCompleted'] == true) {
          completedVideos++;
        }

        final assessment = chapter['assessment'];
        if (assessment != null && assessment['attempts'] > 0) {
          totalAssessments++;
          totalScore += ((assessment['percentage'] ?? 0) as num).toDouble();
        }
      }

      final selfAssessments =
          package['selfAssessments'] as List<dynamic>? ?? [];
      for (var selfAssessment in selfAssessments) {
        totalSelfAssessments++;
        totalScore += ((selfAssessment['percentage'] ?? 0) as num).toDouble();
      }
    }

    final int totalAllAssessments = totalAssessments + totalSelfAssessments;
    final double averageScore = totalAllAssessments > 0
        ? totalScore / totalAllAssessments
        : 0.0;
    final double videoProgress = totalVideos > 0
        ? (completedVideos / totalVideos) * 100
        : 0.0;

    // Collect and group self-assessments
    List<Map<String, dynamic>> allSelfAssessments = [];
    for (var package in packages) {
      final selfAssessments =
          package['selfAssessments'] as List<dynamic>? ?? [];
      for (var assessment in selfAssessments) {
        allSelfAssessments.add({
          ...assessment,
          'packageName': package['packageName'],
          'packageBoard': package['board'],
          'packageGrade': package['grade'],
        });
      }
    }

    // Group self-assessments by ID
    Map<String, List<Map<String, dynamic>>> groupedAssessments = {};
    for (var assessment in allSelfAssessments) {
      final assessmentId =
          assessment['_id']?.toString() ??
          assessment['id']?.toString() ??
          assessment['title']?.toString() ??
          '';
      if (assessmentId.isNotEmpty) {
        if (!groupedAssessments.containsKey(assessmentId)) {
          groupedAssessments[assessmentId] = [];
        }
        groupedAssessments[assessmentId]!.add(assessment);
      }
    }

    // Sort each group by date and flatten
    List<Map<String, dynamic>> sortedGroupedAssessments = [];
    groupedAssessments.forEach((id, assessments) {
      assessments.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['completedAt'] ?? '') ?? DateTime(2000);
        final dateB =
            DateTime.tryParse(b['completedAt'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      sortedGroupedAssessments.add({
        'isGroup': true,
        'assessmentId': id,
        'attempts': assessments,
        'latestAttempt': assessments.first,
      });
    });

    // Sort groups by latest attempt date
    sortedGroupedAssessments.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['latestAttempt']['completedAt'] ?? '') ??
          DateTime(2000);
      final dateB =
          DateTime.tryParse(b['latestAttempt']['completedAt'] ?? '') ??
          DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          // Overall Performance Card
          _buildOverallPerformance(averageScore, totalAllAssessments),

          // Videos Progress Card
          _buildVideosProgress(completedVideos, totalVideos, videoProgress),

          // Packages Progress
          if (packages.isNotEmpty) ...[
            _buildSectionHeader('Package Progress'),
            ...packages.map((package) => _buildPackageCard(package)).toList(),
          ],

          // Self-Assessments
          if (sortedGroupedAssessments.isNotEmpty) ...[
            _buildSectionHeader('Self-Assessments'),
            ...sortedGroupedAssessments
                .map((group) => _buildSelfAssessmentCard(group))
                .toList(),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOverallPerformance(double averageScore, int totalAssessments) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            averageScore >= 60
                ? const Color(0xFFD1FAE5)
                : const Color(0xFFFEE2E2),
            averageScore >= 60
                ? const Color(0xFFA7F3D0)
                : const Color(0xFFFECACA),
          ],
        ),
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: averageScore >= 60
                      ? Colors.green[700]
                      : Colors.red[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalAssessments assessment${totalAssessments != 1 ? 's' : ''} completed',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${averageScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: averageScore >= 60
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: averageScore / 100,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                averageScore >= 60 ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on all assessments and self-assessments',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosProgress(int completed, int total, double percentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Videos Watched',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                '$completed / $total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}% of lectures completed',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final packageName = package['packageName'] ?? 'Unknown Package';
    final board = package['board'] ?? '';
    final grade = package['grade'] ?? '';
    final chapters = package['chapters'] as List<dynamic>? ?? [];

    int totalChapters = chapters.length;
    int completedChapters = chapters
        .where((c) => c['videoCompleted'] == true)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          packageName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          '$grade • $board',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$completedChapters/$totalChapters',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        children: [
          ...chapters.map((chapter) => _buildChapterItem(chapter)).toList(),
        ],
      ),
    );
  }

  Widget _buildChapterItem(Map<String, dynamic> chapter) {
    final title = chapter['chapterTitle'] ?? chapter['title'] ?? 'Chapter';
    final videoCompleted = chapter['videoCompleted'] ?? false;
    final assessment = chapter['assessment'];

    bool hasAssessment = assessment != null && assessment['attempts'] > 0;
    double percentage = 0;
    if (hasAssessment) {
      percentage = ((assessment['percentage'] ?? 0) as num).toDouble();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                videoCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: videoCompleted ? Colors.green : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          if (hasAssessment) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.quiz_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Assessment: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 60 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: percentage >= 60
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    percentage >= 60 ? 'Passed' : 'Retry',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 60 ? Colors.green : Colors.orange,
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

  Widget _buildSelfAssessmentCard(Map<String, dynamic> group) {
    final attempts = group['attempts'] as List<Map<String, dynamic>>;
    final latestAttempt = group['latestAttempt'] as Map<String, dynamic>;
    final hasMultipleAttempts = attempts.length > 1;
    final assessmentId = group['assessmentId'] as String;

    final title = latestAttempt['title'] ?? 'Self-Assessment';
    final packageName = latestAttempt['packageName'] ?? '';

    // Find best score
    double bestPercentage = 0.0;
    for (var attempt in attempts) {
      final percentage = ((attempt['percentage'] ?? 0) as num).toDouble();
      if (percentage > bestPercentage) {
        bestPercentage = percentage;
      }
    }

    return Obx(() {
      final isExpanded = controller.expandedAssessments[assessmentId] ?? false;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: bestPercentage >= 60
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                controller.expandedAssessments[assessmentId] = !isExpanded;
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: bestPercentage >= 60
                              ? [Colors.green[400]!, Colors.green[600]!]
                              : [Colors.orange[400]!, Colors.orange[600]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (packageName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              packageName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (hasMultipleAttempts) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.repeat_rounded,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${attempts.length} attempts',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bestPercentage >= 60
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${bestPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: bestPercentage >= 60
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                        if (hasMultipleAttempts) ...[
                          const SizedBox(height: 4),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey[600],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded && hasMultipleAttempts) ...[
              Divider(height: 1, color: Colors.grey[200]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: attempts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attempt = entry.value;
                    return _buildAttemptItem(
                      attempt,
                      attempts.length - index,
                      bestPercentage,
                      index == 0,
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAttemptItem(
    Map<String, dynamic> attempt,
    int attemptNumber,
    double bestPercentage,
    bool isLatest,
  ) {
    final obtainedMarks = attempt['obtainedMarks'] ?? 0;
    final totalMarks = attempt['totalMarks'] ?? 0;
    final percentage = ((attempt['percentage'] ?? 0) as num).toDouble();
    final completedAt = attempt['completedAt'] ?? '';
    final isBestScore = percentage == bestPercentage;

    String formattedDate = '';
    if (completedAt.isNotEmpty) {
      try {
        final date = DateTime.parse(completedAt);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBestScore
              ? Colors.amber.withOpacity(0.5)
              : Colors.grey[200]!,
          width: isBestScore ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLatest
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Attempt #$attemptNumber',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isLatest ? AppTheme.primaryColor : Colors.grey[700],
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
                      '$obtainedMarks/$totalMarks',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (formattedDate.isNotEmpty) ...[
                      Text(' • ', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                if (isBestScore) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 12,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Best Score',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: percentage >= 60
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: percentage >= 60
                    ? Colors.green[700]
                    : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
