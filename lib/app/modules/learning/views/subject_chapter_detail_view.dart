import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/subject_chapter_controller.dart';

class SubjectChapterDetailView extends GetView<SubjectChapterController> {
  const SubjectChapterDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPackageInfo(context),
                const SizedBox(height: 12),
                _buildPackageSelfAssessmentButton(context),
                const SizedBox(height: 16),
                _buildSubjectFilter(context),
                const SizedBox(height: 24),
                _buildSubjectsAndChapters(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final appBarHeight = isSmallScreen
        ? 100.0
        : (isMediumScreen ? 110.0 : 120.0);
    final circleSize = isSmallScreen ? 100.0 : 120.0;
    final titleFontSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);
    final subtitleFontSize = isSmallScreen ? 10.0 : 12.0;

    return SliverAppBar(
      expandedHeight: appBarHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.secondaryColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 10 : 12,
                      ),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 24.0 : 28.0,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'My Learning',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Subjects & Chapters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildPackageInfo(BuildContext context) {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final cardPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final iconSize = isSmallScreen ? 24.0 : 28.0;
    final titleFontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
    final badgeFontSize = isSmallScreen ? 10.0 : 11.0;
    final marginH = isSmallScreen ? 12.0 : 16.0;

    return Obx(() {
      final subscription = controller.subscription.value;
      if (subscription == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.fromLTRB(marginH, marginH, marginH, 0),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.package.name,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 10,
                          vertical: isSmallScreen ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            isSmallScreen ? 5 : 6,
                          ),
                        ),
                        child: Text(
                          subscription.grade.name,
                          style: TextStyle(
                            fontSize: badgeFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 10,
                          vertical: isSmallScreen ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            isSmallScreen ? 5 : 6,
                          ),
                        ),
                        child: Text(
                          subscription.board.name,
                          style: TextStyle(
                            fontSize: badgeFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryColor,
                          ),
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
    });
  }

  Widget _buildSubjectFilter(BuildContext context) {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;

    final marginH = isSmallScreen ? 12.0 : 16.0;
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;
    final spacing = isSmallScreen ? 10.0 : 12.0;

    return Obx(() {
      final subjects = controller.subjects;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: marginH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Subject',
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: spacing),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // "All Subjects" filter
                _buildFilterChip(
                  label: 'All Subjects',
                  isSelected: controller.selectedSubject.value == null,
                  onTap: () => controller.selectSubject(null),
                ),
                // Individual subject filters
                ...subjects.map(
                  (subject) => _buildFilterChip(
                    label: subject,
                    isSelected: controller.selectedSubject.value == subject,
                    onTap: () => controller.selectSubject(subject),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final paddingH = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final paddingV = isSmallScreen ? 8.0 : 10.0;
    final fontSize = isSmallScreen ? 12.0 : 13.0;
    final borderRadius = isSmallScreen ? 16.0 : 20.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsAndChapters(BuildContext context) {
    return Obx(() {
      final selectedSubject = controller.selectedSubject.value;
      final subjects = selectedSubject != null
          ? [selectedSubject]
          : controller.subjects;

      return Column(
        children: subjects.map((subject) {
          final chapterData = controller.getChaptersForSubject(subject);
          final chapters =
              chapterData['chapters'] as List<Map<String, dynamic>>;

          return _buildSubjectSection(context, subject, chapters);
        }).toList(),
      );
    });
  }

  Widget _buildSubjectSection(
    BuildContext context,
    String subject,
    List<Map<String, dynamic>> chapters,
  ) {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final marginH = isSmallScreen ? 12.0 : 16.0;
    final marginV = isSmallScreen ? 10.0 : 12.0;
    final borderRadius = isSmallScreen ? 16.0 : 20.0;
    final headerPadding = isSmallScreen ? 16.0 : 20.0;
    final iconPadding = isSmallScreen ? 8.0 : 10.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
    final subtitleFontSize = isSmallScreen ? 11.0 : 12.0;
    final progressFontSize = isSmallScreen ? 12.0 : 14.0;

    final color = _getSubjectColor(subject);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: isSmallScreen ? 12 : 16,
            offset: Offset(0, isSmallScreen ? 4 : 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject header
          Container(
            padding: EdgeInsets.all(headerPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.85)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: Icon(
                    _getSubjectIcon(subject),
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 3 : 4),
                      Text(
                        '${chapters.length} chapters',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 5 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: Text(
                    '${_calculateProgress(chapters)}%',
                    style: TextStyle(
                      fontSize: progressFontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chapters list
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
            child: Column(
              children: chapters.map((chapter) {
                return _buildChapterCard(context, chapter, subject, color);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(
    BuildContext context,
    Map<String, dynamic> chapter,
    String subject,
    Color color,
  ) {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;

    final cardPadding = isSmallScreen ? 12.0 : 14.0;
    final borderRadius = isSmallScreen ? 10.0 : 12.0;
    final badgeSize = isSmallScreen ? 44.0 : 48.0;
    final badgeIconSize = isSmallScreen ? 20.0 : 24.0;
    final badgeFontSize = isSmallScreen ? 14.0 : 16.0;
    final titleFontSize = isSmallScreen ? 13.0 : 14.0;
    final metaFontSize = isSmallScreen ? 10.0 : 11.0;
    final metaIconSize = isSmallScreen ? 12.0 : 14.0;
    final arrowSize = isSmallScreen ? 16.0 : 18.0;

    final progress = chapter['progress'] as double? ?? 0.0;
    final isCompleted = chapter['completed'] as bool? ?? false;

    return InkWell(
      onTap: () => controller.navigateToVideoPlayer(chapter, subject),
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            // Chapter number badge
            Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: isCompleted ? color.withOpacity(0.15) : Colors.grey[200],
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        size: badgeIconSize,
                      )
                    : Text(
                        '${chapter['id']}',
                        style: TextStyle(
                          fontSize: badgeFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 14),
            // Chapter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter['title'] as String,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 5 : 6),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: metaIconSize,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Text(
                        chapter['duration'] as String,
                        style: TextStyle(
                          fontSize: metaFontSize,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Icon(
                        Icons.description_outlined,
                        size: metaIconSize,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Text(
                        '${(chapter['documents'] as List).length} docs',
                        style: TextStyle(
                          fontSize: metaFontSize,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (progress > 0 && progress < 1) ...[
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 3 : 4,
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: isSmallScreen ? 3 : 4,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: arrowSize,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageSelfAssessmentButton(BuildContext context) {
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    final marginH = isSmallScreen ? 12.0 : 16.0;

    return Obx(() {
      final subscription = controller.subscription.value;
      if (subscription == null) return const SizedBox.shrink();

      final totalChapters = subscription.chapters.length;
      final titleFontSize = isSmallScreen
          ? 14.0
          : (isMediumScreen ? 15.0 : 16.0);
      final subtitleFontSize = isSmallScreen ? 11.0 : 12.0;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: marginH),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              '/self-assessment-list',
              arguments: {
                'subscription': subscription,
                // no 'subject' → controller shows all chapters
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 14.0 : 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 24.0 : 28.0,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Self Assessment',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 3 : 4),
                      Text(
                        'All subjects · $totalChapters chapters available',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  int _calculateProgress(List<Map<String, dynamic>> chapters) {
    if (chapters.isEmpty) return 0;
    final completed = chapters.where((ch) => ch['completed'] == true).length;
    return ((completed / chapters.length) * 100).round();
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF8B5CF6);
      case 'science':
        return const Color(0xFF10B981);
      case 'english':
        return const Color(0xFFF59E0B);
      case 'social science':
        return const Color(0xFF3B82F6);
      case 'computer science':
        return const Color(0xFFEC4899);
      case 'hindi':
        return const Color(0xFF14B8A6);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'english':
        return Icons.menu_book_rounded;
      case 'social science':
        return Icons.public_rounded;
      case 'computer science':
        return Icons.computer_rounded;
      case 'hindi':
        return Icons.translate_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
