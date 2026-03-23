import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/video_player_controller.dart' as learning;
import '../widgets/math_text_widget.dart';

class VideoPlayerView extends GetView<learning.VideoPlayerController> {
  const VideoPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    // Render the page immediately — each section shows its own loading state.
    // No full-screen splash so the user sees the UI the moment the route opens.
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: isMobile
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ),
    );
  }

  // Mobile Layout: Vertical stack with video on top
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Video Section
        _buildVideoSection(context, true),
        // Content Tabs Section
        Expanded(child: _buildContentTabsSection(context, true)),
      ],
    );
  }

  // Desktop Layout: Video + sidebar layout
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Main content area (video + tabs)
        Expanded(
          flex: 7,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.5, // Max 50% height
                    ),
                    child: SingleChildScrollView(
                      child: _buildVideoSection(context, false),
                    ),
                  ),
                  Expanded(child: _buildContentTabsSection(context, false)),
                ],
              );
            },
          ),
        ),
        // Right sidebar - Chapter playlist
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: _buildChapterPlaylist(context),
        ),
      ],
    );
  }

  // Video Section with player and controls
  Widget _buildVideoSection(BuildContext context, bool isMobile) {
    return Container(
      color: const Color(0xFF0F1419),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMainHeader(context, isMobile),
          if (!isMobile) _buildChapterInfo(context),
          _buildVideoPlayer(context, isMobile),
          // _buildVideoControls(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildChapterInfo(BuildContext context) {
    return Obx(() {
      final content = controller.currentContent.value;
      if (content == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.15),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.chapter.name,
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildInfoChip(
                        Icons.play_circle_outline,
                        content.videoType,
                      ),
                      _buildInfoChip(
                        Icons.description_outlined,
                        '${controller.documents.length} docs',
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTabsSection(BuildContext context, bool isMobile) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
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
            child: TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 14,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.video_library, size: isMobile ? 18 : 22),
                  text: 'Overview',
                ),
                Tab(
                  icon: Icon(Icons.description, size: isMobile ? 18 : 22),
                  text: 'Resources',
                ),
                Tab(
                  icon: Icon(Icons.assignment, size: isMobile ? 18 : 22),
                  text: 'Exercise',
                ),
                Tab(
                  icon: Icon(Icons.forum, size: isMobile ? 18 : 22),
                  text: 'Ask AI',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(context, isMobile),
                _buildResourcesTab(context, isMobile),
                _buildExerciseTab(context, isMobile),
                _buildQATab(context, isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final content = controller.currentContent.value;
            if (content == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assessment button if available
                Obx(() {
                  if (!controller.isAssessmentAvailable.value) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentColor.withOpacity(0.1),
                          AppTheme.accentColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentColor,
                                AppTheme.accentColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chapter Assessment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Test your understanding of this chapter',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            print('🎯 Start Assessment button clicked');
                            print(
                              '   Assessment available: ${controller.isAssessmentAvailable.value}',
                            );
                            print(
                              '   Assessment data: ${controller.assessmentData.value != null ? "Present" : "NULL"}',
                            );
                            controller.startAssessment();
                            Get.toNamed('/assessment');
                          },
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Text(
                  'About This Chapter',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Text(
                    content.overview.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Learning Objectives',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 10),
                _buildObjectiveItem('Understand core concepts and principles'),
                _buildObjectiveItem('Apply knowledge to practical problems'),
                _buildObjectiveItem('Master problem-solving techniques'),
                _buildObjectiveItem('Complete chapter assessment successfully'),
                const SizedBox(height: 16),
                _buildProgressCard(context, isMobile),
                const SizedBox(height: 20),
                _buildRatingCard(isMobile),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRatingCard(bool isMobile) {
    return Obx(() {
      final rated = controller.hasRated.value;
      final existing = controller.existingRating.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: rated
                ? [const Color(0xFFFFFBEB), const Color(0xFFFFF8E1)]
                : [const Color(0xFFF8FAFC), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rated
                ? const Color(0xFFF59E0B).withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rated ? 'Your Rating' : 'Rate This Video',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        rated
                            ? 'Tap to update your rating'
                            : 'Help your mentor improve by sharing feedback',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Star row
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () {
                    controller.selectedRating.value = star;
                    controller.showVideoRatingDialog();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      star <= (rated ? existing : 0)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: star <= (rated ? existing : 0)
                          ? const Color(0xFFF59E0B)
                          : Colors.grey[300],
                      size: isMobile ? 36 : 42,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await controller.loadMyRating();
                  controller.showVideoRatingDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: rated
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF6A3DE8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  rated ? 'Update Rating  (${existing}★)' : 'Rate This Video',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildObjectiveItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildProgressStat('Video', '45%', Icons.play_circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildProgressStat('Docs', '3/5', Icons.description),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildProgressStat(
                  'Exercise',
                  'Pending',
                  Icons.assignment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildResourcesTab(BuildContext context, bool isMobile) {
    return Obx(() {
      final documents = controller.documents;

      if (documents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No Resources Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Resources for this chapter will appear here',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Learning Resources',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${documents.length} ${documents.length == 1 ? 'file' : 'files'} available',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resources list
            ...documents.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < documents.length - 1 ? 16 : 0,
                ),
                child: _buildResourceCard(doc, isMobile),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildResourceCard(Map<String, dynamic> doc, bool isMobile) {
    final resourceId = doc['_id'] as String? ?? '';

    return Obx(() {
      final isDownloading = controller.isResourceDownloading(resourceId);
      final downloadProgress = controller.getResourceDownloadProgress(
        resourceId,
      );

      return InkWell(
        onTap: isDownloading
            ? null
            : () => controller.downloadAndOpenResource(doc),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDownloading ? AppTheme.primaryColor : Colors.grey[200]!,
              width: isDownloading ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: isMobile ? 54 : 60,
                height: isMobile ? 54 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.15),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppTheme.primaryColor,
                  size: isMobile ? 28 : 32,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['title'] as String? ??
                          doc['fileName'] as String? ??
                          'Document',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    if (isDownloading)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Downloading... ${(downloadProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: downloadProgress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            doc['fileSize'] as String? ?? 'PDF File',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (doc['description'] != null &&
                              (doc['description'] as String).isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                doc['description'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Download button
              if (!isDownloading)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                )
              else
                SizedBox(
                  width: 46,
                  height: 46,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildExerciseTab(BuildContext context, bool isMobile) {
    return Obx(() {
      if (!controller.isExerciseAvailable.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No Exercise Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete the video to unlock the exercise',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return _buildExerciseViewer(context, isMobile);
    });
  }

  Widget _buildQATab(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Learning Assistant',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ask questions about this lesson',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  if (controller.chatMessages.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.grey[600],
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Clear Chat'),
                          content: const Text(
                            'Are you sure you want to clear the conversation history?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                controller.clearChat();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: Obx(() {
              if (controller.chatMessages.isEmpty) {
                return _buildEmptyChatState(isMobile);
              }
              return ListView.builder(
                controller: controller.chatScrollController,
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = controller.chatMessages[index];
                  final isUser = message['role'] == 'user';
                  return _buildChatMessage(message, isUser, isMobile);
                },
              );
            }),
          ),

          // Loading Indicator
          Obx(() {
            if (!controller.isSendingMessage.value) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Listening Indicator
          Obx(() {
            if (!controller.isListening.value) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Listening...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Speak your question',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Input Field
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.chatInputController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ask a question about this lesson...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (!controller.isSendingMessage.value) {
                        controller.sendChatMessage();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Microphone button
                Obx(() {
                  return Material(
                    color: controller.isListening.value
                        ? Colors.red
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: controller.isSendingMessage.value
                          ? null
                          : controller.toggleListening,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          controller.isListening.value
                              ? Icons.mic
                              : Icons.mic_none,
                          color: controller.isListening.value
                              ? Colors.white
                              : Colors.grey[600],
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // Send button
                Obx(() {
                  return Material(
                    color: controller.isSendingMessage.value
                        ? Colors.grey[300]
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: controller.isSendingMessage.value
                          ? null
                          : controller.sendChatMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: isMobile ? 48 : 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI Learning Assistant',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ask me anything about this lesson!\nI\'m here to help you understand the concepts better.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestedQuestion('Explain this chapter', Icons.menu_book),
              _buildSuggestedQuestion(
                'Real-life examples',
                Icons.lightbulb_outline,
              ),
              _buildSuggestedQuestion('Key concepts', Icons.key),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestion(String question, IconData icon) {
    return InkWell(
      onTap: () {
        controller.chatInputController.text = question;
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Text(
              question,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(
    Map<String, dynamic> message,
    bool isUser,
    bool isMobile,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MathTextWidget(
                    text: message['content'] ?? '',
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  if (!isUser && message['metadata'] != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildMetadataChip(
                          message['metadata']['subject'] ?? '',
                          Icons.book,
                        ),
                        _buildMetadataChip(
                          message['metadata']['grade'] ?? '',
                          Icons.school,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 20, color: AppTheme.primaryColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterPlaylist(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              const Text(
                'Course Content',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              final isActive = index == 2; // Current chapter
              final isCompleted = index < 2;
              return InkWell(
                onTap: () {
                  // Navigate to chapter
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                      left: isActive
                          ? BorderSide(color: AppTheme.primaryColor, width: 3)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isActive
                              ? AppTheme.primaryColor
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : isActive
                              ? Icons.play_arrow
                              : Icons.lock_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapter ${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chapter Title Here',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '15:30',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Get.back(),
              iconSize: isMobile ? 18 : 20,
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              constraints: const BoxConstraints(),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 16),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.packageName.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 12 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8,
                            vertical: isMobile ? 2 : 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.secondaryColor,
                                AppTheme.accentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            controller.subjectName.value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 8 : 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 4 : 8),
                      Text(
                        controller.grade.value,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: isMobile ? 9 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: !controller.isDownloadingVideo.value
                  ? IconButton(
                      icon: const Icon(
                        Icons.download_for_offline_rounded,
                        color: Colors.white,
                      ),
                      onPressed: controller.downloadVideoForOffline,
                      tooltip: 'Download for offline',
                      iconSize: isMobile ? 16 : 20,
                      padding: EdgeInsets.all(isMobile ? 8 : 12),
                      constraints: const BoxConstraints(),
                    )
                  : Padding(
                      padding: EdgeInsets.all(isMobile ? 8 : 10),
                      child: SizedBox(
                        width: isMobile ? 18 : 24,
                        height: isMobile ? 18 : 24,
                        child: CircularProgressIndicator(
                          value: controller.videoDownloadProgress.value,
                          color: AppTheme.accentColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
            ),
          ),
          // ── Rate this video button ──────────────────────────────────────
          Obx(
            () => Padding(
              padding: EdgeInsets.only(left: isMobile ? 6 : 10),
              child: GestureDetector(
                onTap: () async {
                  await controller.loadMyRating();
                  controller.showVideoRatingDialog();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: controller.hasRated.value
                        ? const Color(0xFFF59E0B).withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                    border: Border.all(
                      color: controller.hasRated.value
                          ? const Color(0xFFF59E0B)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.hasRated.value
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: controller.hasRated.value
                            ? const Color(0xFFF59E0B)
                            : Colors.white,
                        size: isMobile ? 16 : 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.hasRated.value
                            ? '${controller.existingRating.value}★'
                            : 'Rate',
                        style: TextStyle(
                          color: controller.hasRated.value
                              ? const Color(0xFFF59E0B)
                              : Colors.white,
                          fontSize: isMobile ? 11 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ────────────────────────────────────────────────────────────────
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, bool isMobile) {
    return Obx(() {
      if (!controller.isVideoInitialized.value) {
        // Still loading vs completely failed
        if (controller.isVideoLoading.value) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E14),
                borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Loading video...',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Failed to load
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E14),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Video unavailable',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: controller.isYoutubeVideo.value
                ? (controller.youtubeController != null
                      ? YoutubePlayer(
                          controller: controller.youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: AppTheme.primaryColor,
                          progressColors: ProgressBarColors(
                            playedColor: AppTheme.primaryColor,
                            handleColor: AppTheme.primaryColor,
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.3,
                            ),
                            bufferedColor: AppTheme.primaryColor.withOpacity(
                              0.5,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF0A0E14),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline_rounded,
                              size: 140,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ))
                : (controller.chewieController != null
                      ? Chewie(controller: controller.chewieController!)
                      : Container(
                          color: const Color(0xFF0A0E14),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline_rounded,
                              size: 140,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        )),
          ),
        ),
      );
    });
  }

  Widget _buildVideoControls(BuildContext context, bool isMobile) {
    return Obx(() {
      final position = controller.currentPosition.value;
      final duration = controller.totalDuration.value;
      final progress = duration.inSeconds > 0
          ? position.inSeconds / duration.inSeconds
          : 0.0;

      return Container(
        margin: EdgeInsets.all(isMobile ? 8 : 20),
        padding: EdgeInsets.all(isMobile ? 8 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.15),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: isMobile
            ? Row(
                children: [
                  // Play/Pause only on mobile
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      color: Colors.white,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      onPressed: controller.togglePlayPause,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Compact time display
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Progress bar
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: AppTheme.accentColor,
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                        overlayColor: AppTheme.accentColor.withOpacity(0.3),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          controller.seekTo(
                            Duration(
                              seconds: (value * duration.inSeconds).round(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time and progress bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                activeTrackColor: AppTheme.accentColor,
                                inactiveTrackColor: Colors.transparent,
                                thumbColor: Colors.white,
                                overlayColor: AppTheme.accentColor.withOpacity(
                                  0.3,
                                ),
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  controller.seekTo(
                                    Duration(
                                      seconds: (value * duration.inSeconds)
                                          .round(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(Icons.replay_10_rounded, () {
                        final newPosition =
                            position - const Duration(seconds: 10);
                        controller.seekTo(
                          newPosition.isNegative ? Duration.zero : newPosition,
                        );
                      }, false),
                      const SizedBox(width: 20),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            controller.isPlaying.value
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          color: Colors.white,
                          iconSize: 32,
                          onPressed: controller.togglePlayPause,
                        ),
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(Icons.forward_10_rounded, () {
                        final newPosition =
                            position + const Duration(seconds: 10);
                        controller.seekTo(
                          newPosition > duration ? duration : newPosition,
                        );
                      }, false),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        controller.isFullScreen.value
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        controller.toggleFullScreen,
                        controller.isFullScreen.value,
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressed,
    bool isActive,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppTheme.primaryColor
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 24,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDocumentSidebar(BuildContext context, bool isMobile) {
    return Obx(() {
      final documents = controller.documents;
      final selectedDoc = controller.selectedDocument.value;
      final isExerciseMode = controller.viewMode.value == 'exercise';

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          border: Border(
            left: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.1),
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            // Tabs Header
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      'Documents',
                      Icons.description_rounded,
                      !isExerciseMode,
                      controller.switchToDocuments,
                      isMobile,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildTabButton(
                          'Exercise',
                          Icons.assignment_rounded,
                          isExerciseMode,
                          controller.isExerciseAvailable.value
                              ? controller.switchToExercise
                              : null,
                          isMobile,
                        ),
                        if (controller.isExerciseAvailable.value &&
                            controller.exerciseSubmitted.value)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Document tabs
            if (!isExerciseMode)
              Container(
                constraints: BoxConstraints(
                  maxHeight: isMobile ? 120 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 8 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...documents.map((doc) {
                        final isSelected = selectedDoc?['id'] == doc['id'];
                        return Padding(
                          padding: EdgeInsets.only(bottom: isMobile ? 4 : 8),
                          child: InkWell(
                            onTap: () => controller.selectDocument(doc),
                            borderRadius: BorderRadius.circular(
                              isMobile ? 8 : 12,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 8 : 14),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.secondaryColor,
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppTheme.primaryColor.withOpacity(0.15),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : AppTheme.primaryColor.withOpacity(
                                              0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        isMobile ? 6 : 8,
                                      ),
                                    ),
                                    child: Icon(
                                      _getDocumentIcon(doc['icon'] as String),
                                      size: isMobile ? 14 : 18,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 8 : 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc['title'] as String? ??
                                              doc['fileName'] as String? ??
                                              'Document',
                                          style: TextStyle(
                                            fontSize: isMobile ? 11 : 13,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: isMobile ? 1 : 2),
                                        Text(
                                          '${doc['pages']} pages',
                                          style: TextStyle(
                                            fontSize: isMobile ? 8 : 10,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.8)
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: isMobile ? 16 : 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            if (!isExerciseMode)
              Divider(height: 1, color: AppTheme.primaryColor.withOpacity(0.1)),
            // Content area
            Expanded(
              child: isExerciseMode
                  ? _buildExerciseViewer(context, isMobile)
                  : (selectedDoc != null
                        ? _buildDocumentViewer(context, selectedDoc)
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Select a document\nto get started',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDocumentViewer(BuildContext context, Map<String, dynamic> doc) {
    return Obx(() {
      return Column(
        children: [
          // Document controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    doc['title'] as String? ??
                        doc['fileName'] as String? ??
                        'Document',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Sync toggle - compact
                InkWell(
                  onTap: controller.toggleDocumentSync,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: controller.isDocumentSyncEnabled.value
                          ? AppTheme.accentColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isDocumentSyncEnabled.value
                              ? Icons.sync_rounded
                              : Icons.sync_disabled_rounded,
                          size: 12,
                          color: controller.isDocumentSyncEnabled.value
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.isDocumentSyncEnabled.value ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: controller.isDocumentSyncEnabled.value
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PDF viewer with dummy content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // PDF Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.1),
                                AppTheme.secondaryColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.secondaryColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc['title'] as String? ??
                                          doc['fileName'] as String? ??
                                          'Document',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.isDocumentSyncEnabled.value)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.sync_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Synced',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Dummy PDF Content (Lecture Notes)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Document title section
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryColor,
                                            AppTheme.secondaryColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'LECTURE NOTES',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      doc['title'] as String? ??
                                          doc['fileName'] as String? ??
                                          'Document',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Chapter ${controller.currentPage.value}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Section 1
                              _buildNotesSection(
                                '1. Introduction',
                                'This chapter introduces the fundamental concepts and principles that form the foundation of our study. Understanding these core ideas is essential for mastering more advanced topics in subsequent chapters.',
                              ),
                              const SizedBox(height: 24),
                              // Key Points
                              _buildKeyPointsBox(),
                              const SizedBox(height: 24),
                              // Section 2
                              _buildNotesSection(
                                '2. Core Concepts',
                                'The following concepts are critical to understanding this subject:\n\n• Concept A: Explains the primary mechanism\n• Concept B: Describes the relationship between elements\n• Concept C: Provides practical applications\n• Concept D: Illustrates advanced techniques',
                              ),
                              const SizedBox(height: 24),
                              // Example Box
                              _buildExampleBox(),
                              const SizedBox(height: 24),
                              // Section 3
                              _buildNotesSection(
                                '3. Important Formula',
                                'The main formula to remember is:\n\nResult = (Input × Factor) + Constant\n\nWhere:\n• Input represents the initial value\n• Factor is the multiplication coefficient\n• Constant is the base adjustment',
                              ),
                              const SizedBox(height: 24),
                              // Practice Problems
                              _buildPracticeBox(),
                              const SizedBox(height: 32),
                              // Summary
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.1),
                                      AppTheme.secondaryColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.summarize_rounded,
                                          color: AppTheme.primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Summary',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'In this chapter, we covered the fundamental principles and their applications. Make sure to practice the examples and review the key points before moving to the next chapter.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.6,
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
                ),
              ),
            ),
          ),
          // Page navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: controller.currentPage.value > 1
                        ? AppTheme.primaryColor
                        : Colors.grey[400],
                  ),
                  onPressed: controller.currentPage.value > 1
                      ? controller.previousPage
                      : null,
                  padding: const EdgeInsets.all(8),
                ),
                Expanded(
                  child: Text(
                    'Page ${controller.currentPage.value} / ${controller.totalPages.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color:
                        controller.currentPage.value <
                            controller.totalPages.value
                        ? AppTheme.primaryColor
                        : Colors.grey[400],
                  ),
                  onPressed:
                      controller.currentPage.value < controller.totalPages.value
                      ? controller.nextPage
                      : null,
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabButton(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback? onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                )
              : null,
          color: isActive ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppTheme.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isMobile ? 14 : 18,
              color: isActive
                  ? Colors.white
                  : (onTap != null ? AppTheme.primaryColor : Colors.grey[400]),
            ),
            SizedBox(width: isMobile ? 4 : 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.white
                      : (onTap != null
                            ? const Color(0xFF1F2937)
                            : Colors.grey[400]),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseViewer(BuildContext context, bool isMobile) {
    return Obx(() {
      if (controller.isLoadingExercises.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Loading exercises...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      if (!controller.isExerciseAvailable.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Exercise Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No exercises found for this chapter',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        );
      }

      final exercise = controller.currentExercise.value!;
      final isSubmitted = controller.exerciseSubmitted.value;
      final answeredCount = controller.answeredQuestionsCount;
      final totalQuestions = exercise.questions.length;

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chapter: ${exercise.chapter.name}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!isMobile && isSubmitted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          controller.exerciseScore.value / totalQuestions >= 0.7
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          controller.exerciseScore.value / totalQuestions >= 0.7
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (controller.exerciseScore.value /
                                              totalQuestions >=
                                          0.7
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444))
                                  .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.exerciseScore.value / totalQuestions >= 0.7
                              ? Icons.check_circle
                              : Icons.info,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Score: ${controller.exerciseScore.value}/$totalQuestions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress stats cards
            Row(
              children: [
                Expanded(
                  child: _buildExerciseStatCard(
                    'Questions',
                    '$totalQuestions',
                    Icons.quiz,
                    AppTheme.primaryColor,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExerciseStatCard(
                    'Answered',
                    '$answeredCount/$totalQuestions',
                    Icons.check_circle_outline,
                    const Color(0xFF10B981),
                    isMobile,
                  ),
                ),
                if (!isMobile) const SizedBox(width: 12),
                if (!isMobile)
                  Expanded(
                    child: _buildExerciseStatCard(
                      'Status',
                      isSubmitted ? 'Submitted' : 'In Progress',
                      isSubmitted ? Icons.done_all : Icons.edit,
                      isSubmitted
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      isMobile,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            // Questions list
            ...exercise.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildQuestionCard(
                  question,
                  index,
                  isSubmitted,
                  isMobile,
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Submit/Reset button
            SizedBox(
              width: double.infinity,
              child: isSubmitted
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.resetExercise,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: controller.allQuestionsAnswered
                          ? controller.submitExercise
                          : null,
                      icon: controller.isSubmittingExercise.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        controller.isSubmittingExercise.value
                            ? 'Submitting...'
                            : 'Submit Exercise',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.allQuestionsAnswered
                            ? AppTheme.primaryColor
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),

            if (!isSubmitted && !controller.allQuestionsAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Please answer all questions to submit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestionCard(
    dynamic question,
    int index,
    bool isSubmitted,
    bool isMobile,
  ) {
    final isAnswered = question.selectedOptionIndex != null;
    final selectedIndex = question.selectedOptionIndex;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnswered
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    height: 1.5,
                  ),
                ),
              ),
              if (isSubmitted && isAnswered)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: question.isCorrect
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    question.isCorrect ? Icons.check : Icons.close,
                    color: question.isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == optionIndex;
            final isCorrectOption = option.isCorrect;
            final showCorrectAnswer = isSubmitted;

            Color borderColor = Colors.grey[300]!;
            Color backgroundColor = Colors.white;
            IconData? icon;
            Color? iconColor;

            if (isSelected && !showCorrectAnswer) {
              borderColor = AppTheme.primaryColor;
              backgroundColor = AppTheme.primaryColor.withOpacity(0.05);
            } else if (showCorrectAnswer) {
              if (isSelected && !isCorrectOption) {
                // User selected wrong answer
                borderColor = const Color(0xFFEF4444);
                backgroundColor = const Color(0xFFEF4444).withOpacity(0.05);
                icon = Icons.close;
                iconColor = const Color(0xFFEF4444);
              } else if (isCorrectOption) {
                // Show correct answer
                borderColor = const Color(0xFF10B981);
                backgroundColor = const Color(0xFF10B981).withOpacity(0.05);
                icon = Icons.check;
                iconColor = const Color(0xFF10B981);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: isSubmitted
                    ? null
                    : () => controller.selectAnswer(index, optionIndex),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 2),
                          color:
                              isSelected ||
                                  (showCorrectAnswer && isCorrectOption)
                              ? borderColor
                              : Colors.transparent,
                        ),
                        child:
                            isSelected || (showCorrectAnswer && isCorrectOption)
                            ? const Icon(
                                Icons.circle,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (icon != null) Icon(icon, color: iconColor, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isMobile ? 18 : 20),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
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
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Key Points to Remember',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            'Understanding the basics is crucial for advanced topics',
            'Practice regularly to reinforce concepts',
            'Review examples carefully before attempting problems',
            'Don\'t hesitate to revisit previous sections',
          ].map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
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
  }

  Widget _buildExampleBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Example',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Problem: Calculate the result when Input = 10, Factor = 3, Constant = 5',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Solution:\nResult = (10 × 3) + 5\nResult = 30 + 5\nResult = 35',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withOpacity(0.1),
            const Color(0xFFF59E0B).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Practice Problems',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            'Problem 1: If Input = 15, Factor = 2, Constant = 8, find Result',
            'Problem 2: Given Result = 50, Factor = 4, Constant = 10, calculate Input',
            'Problem 3: What is Result when Input = 7, Factor = 5, Constant = 3?',
          ].asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
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
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getDocumentIcon(String iconType) {
    switch (iconType) {
      case 'notes':
        return Icons.notes_rounded;
      case 'problems':
        return Icons.assignment_rounded;
      case 'solutions':
        return Icons.check_circle_outline_rounded;
      case 'reference':
        return Icons.bookmark_outline_rounded;
      default:
        return Icons.description_outlined;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
