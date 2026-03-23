import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/learning/controllers/watch_history_controller.dart';
import 'package:intl/intl.dart';

class WatchHistoryView extends GetView<WatchHistoryController> {
  const WatchHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildStatsSection(context),
                const SizedBox(height: 24),
                _buildOverallProgressCard(context),
                const SizedBox(height: 24),
                _buildFiltersSection(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildActivitiesList(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF3B82F6),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 56,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Watch History & Reports',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your learning progress',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.play_circle_filled_rounded,
                value: controller.totalVideosWatched.toString(),
                label: 'Videos',
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.description_rounded,
                value: controller.totalDocumentsViewed.toString(),
                label: 'Documents',
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.assessment_rounded,
                value: controller.totalAssessments.toString(),
                label: 'Assessments',
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
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

  Widget _buildOverallProgressCard(BuildContext context) {
    return Obx(() {
      final avgScore = controller.averageAssessmentScore;
      final status = controller.overallProgressStatus;
      final statusText = controller.getProgressStatusText(status);
      final statusColor = _getStatusColor(status);
      final totalTime = controller.totalWatchTimeFormatted;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor, statusColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${avgScore.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Avg Score',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      Text(
                        totalTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Watch Time',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFiltersSection(BuildContext context) {
    final filters = ['All', 'Videos', 'Documents', 'Assessments'];

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text(
              'Activity Type:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((filter) {
                    final isSelected =
                        controller.selectedFilter.value == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) controller.setFilter(filter);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(
                          0xFF3B82F6,
                        ).withOpacity(0.15),
                        checkmarkColor: const Color(0xFF3B82F6),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActivitiesList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.filteredActivities.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No activities found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start learning to see your history here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final activity = controller.filteredActivities[index];
            return _buildActivityCard(activity);
          }, childCount: controller.filteredActivities.length),
        ),
      );
    });
  }

  Widget _buildActivityCard(ActivityItem activity) {
    final status = controller.getActivityProgressStatus(activity);
    final statusColor = _getStatusColor(status);
    final typeColor = _getTypeColor(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type and date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(activity.type),
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(activity.date),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (activity.type == ActivityType.assessment)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.getProgressStatusText(status),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.book_rounded, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      activity.subject,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.folder_rounded,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.chapter,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 12),

                // Stats row
                if (activity.type == ActivityType.assessment)
                  _buildAssessmentStats(activity, statusColor)
                else
                  _buildDurationStats(activity, typeColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentStats(ActivityItem activity, Color statusColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.grade_rounded,
            label: 'Score',
            value: '${activity.score}%',
            color: statusColor,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.quiz_rounded,
            label: 'Questions',
            value: '${activity.correctAnswers}/${activity.totalQuestions}',
            color: const Color(0xFF6366F1),
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.timer_rounded,
            label: 'Duration',
            value: activity.formattedDuration,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationStats(ActivityItem activity, Color typeColor) {
    return Row(
      children: [
        Icon(Icons.timer_rounded, size: 16, color: typeColor),
        const SizedBox(width: 6),
        Text(
          'Duration: ${activity.formattedDuration}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: typeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Color _getStatusColor(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.excellent:
        return const Color(0xFF10B981);
      case ProgressStatus.good:
        return const Color(0xFF3B82F6);
      case ProgressStatus.needsImprovement:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getStatusIcon(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.excellent:
        return Icons.emoji_events_rounded;
      case ProgressStatus.good:
        return Icons.thumb_up_rounded;
      case ProgressStatus.needsImprovement:
        return Icons.trending_up_rounded;
    }
  }

  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.video:
        return const Color(0xFFEF4444);
      case ActivityType.document:
        return const Color(0xFF10B981);
      case ActivityType.assessment:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.video:
        return Icons.play_circle_filled_rounded;
      case ActivityType.document:
        return Icons.description_rounded;
      case ActivityType.assessment:
        return Icons.assessment_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
