import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/full_assessment_controller.dart';

class FullAssessmentView extends GetView<FullAssessmentController> {
  const FullAssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (!controller.allVideosCompleted.value) {
          return _buildLockedView();
        }

        if (controller.assessmentCompleted.value) {
          return _buildResultsView();
        }

        return _buildAssessmentView();
      }),
    );
  }

  Widget _buildLockedView() {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final lockIconSize = isSmallScreen
        ? 90.0
        : (isMediumScreen ? 105.0 : 120.0);
    final titleFontSize = isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 28.0);
    final bodyFontSize = isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final horizontalPadding = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 24.0 : 32.0);
    final headerFontSize = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 22.0 : 24.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Full Assessment',
                      style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Locked content
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lock icon
                      Container(
                        width: lockIconSize,
                        height: lockIconSize,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[300]!, Colors.grey[400]!],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: lockIconSize * 0.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'Assessment Locked',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Message
                      Text(
                        'Complete all chapter videos to unlock the full assessment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Progress indicator
                      Container(
                        padding: EdgeInsets.all(
                          isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Videos Completed',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14.0 : 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    '${controller.completedVideos.value}/${controller.totalVideos.value}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18.0 : 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              final progress = controller.totalVideos.value > 0
                                  ? controller.completedVideos.value /
                                        controller.totalVideos.value
                                  : 0.0;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentColor,
                                  ),
                                  minHeight: 12,
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            Text(
                              'Keep watching to unlock this assessment!',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12.0 : 14.0,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Back button
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 32.0 : 48.0,
                            vertical: isSmallScreen ? 12.0 : 16.0,
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back to Chapters',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentView() {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final headerFontSize = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 18.0 : 20.0);
    final subjectFontSize = isSmallScreen ? 12.0 : 14.0;
    final counterFontSize = isSmallScreen ? 14.0 : 16.0;
    final questionFontSize = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 17.0 : 18.0);
    final optionFontSize = isSmallScreen
        ? 14.0
        : (isMediumScreen ? 15.0 : 16.0);
    final optionCircleSize = isSmallScreen ? 36.0 : 40.0;
    final buttonPaddingH = isSmallScreen ? 16.0 : 20.0;
    final buttonPaddingV = isSmallScreen ? 10.0 : 12.0;
    final cardPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor.withOpacity(0.05), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Subject Assessment',
                              style: TextStyle(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Obx(
                              () => Text(
                                controller.selectedSubject.value,
                                style: TextStyle(
                                  fontSize: subjectFontSize,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${controller.currentQuestionIndex.value + 1}/${controller.allQuestions.length}',
                            style: TextStyle(
                              fontSize: counterFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Obx(() {
                    final progress = controller.allQuestions.isNotEmpty
                        ? (controller.currentQuestionIndex.value + 1) /
                              controller.allQuestions.length
                        : 0.0;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 8,
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                child: Obx(() {
                  if (controller.allQuestions.isEmpty) {
                    return const Center(child: Text('No questions available'));
                  }

                  final currentIndex = controller.currentQuestionIndex.value;
                  final question = controller.allQuestions[currentIndex];
                  final selectedAnswer =
                      controller.assessmentAnswers[currentIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chapter indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentColor,
                              AppTheme.accentColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Chapter ${question['chapterNum']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Question
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          question['question'] as String,
                          style: TextStyle(
                            fontSize: questionFontSize,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Options
                      ...List.generate((question['options'] as List).length, (
                        index,
                      ) {
                        final option = question['options'][index] as String;
                        final isSelected = selectedAnswer == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () =>
                                controller.selectAnswer(currentIndex, index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 12.0 : 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: optionCircleSize,
                                    height: optionCircleSize,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16.0 : 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: optionFontSize,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryColor,
                                      size: 28,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
            // Bottom navigation
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
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
              child: Obx(() {
                final currentIndex = controller.currentQuestionIndex.value;
                final isFirstQuestion = currentIndex == 0;
                final isLastQuestion =
                    currentIndex == controller.allQuestions.length - 1;
                final allAnswered =
                    controller.assessmentAnswers.length ==
                    controller.allQuestions.length;

                return Row(
                  children: [
                    if (!isFirstQuestion)
                      OutlinedButton.icon(
                        onPressed: controller.previousQuestion,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonPaddingH,
                            vertical: buttonPaddingV,
                          ),
                          side: BorderSide(color: AppTheme.primaryColor),
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    const Spacer(),
                    if (isLastQuestion)
                      ElevatedButton.icon(
                        onPressed:
                            allAnswered &&
                                !controller.isSubmittingAssessment.value
                            ? controller.submitAssessment
                            : null,
                        icon: controller.isSubmittingAssessment.value
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
                            : const Icon(Icons.check_circle),
                        label: Text(
                          controller.isSubmittingAssessment.value
                              ? 'Submitting...'
                              : 'Submit Assessment',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24.0 : 32.0,
                            vertical: isSmallScreen ? 12.0 : 16.0,
                          ),
                          backgroundColor: AppTheme.accentColor,
                          disabledBackgroundColor: Colors.grey[300],
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: controller.nextQuestion,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonPaddingH,
                            vertical: buttonPaddingV,
                          ),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    // Responsive values
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final trophySize = isSmallScreen ? 100.0 : (isMediumScreen ? 120.0 : 140.0);
    final scoreFontSize = isSmallScreen ? 48.0 : (isMediumScreen ? 56.0 : 64.0);
    final titleFontSize = isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 28.0);
    final headerFontSize = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 22.0 : 24.0);
    final cardPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final horizontalPadding = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 24.0 : 32.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Assessment Results',
                      style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Results
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon
                      Container(
                        width: trophySize,
                        height: trophySize,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: controller.assessmentScore.value >= 60
                                ? [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                  ]
                                : [Colors.orange, Colors.deepOrange],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (controller.assessmentScore.value >= 60
                                          ? AppTheme.primaryColor
                                          : Colors.orange)
                                      .withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Icon(
                          controller.assessmentScore.value >= 60
                              ? Icons.emoji_events_rounded
                              : Icons.star_rounded,
                          size: trophySize * 0.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Score
                      Obx(
                        () => Text(
                          '${controller.assessmentScore.value}%',
                          style: TextStyle(
                            fontSize: scoreFontSize,
                            fontWeight: FontWeight.bold,
                            color: controller.assessmentScore.value >= 60
                                ? AppTheme.primaryColor
                                : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.assessmentScore.value >= 60
                            ? 'Great Job!'
                            : 'Keep Practicing!',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Stats
                      Container(
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(
                              'Correct Answers',
                              '${controller.correctAnswersCount.value}/${controller.allQuestions.length}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              'Incorrect Answers',
                              '${controller.allQuestions.length - controller.correctAnswersCount.value}/${controller.allQuestions.length}',
                              Icons.cancel,
                              Colors.red,
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              'Total Questions',
                              '${controller.allQuestions.length}',
                              Icons.quiz,
                              AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: controller.restartAssessment,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retake'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 24.0 : 32.0,
                                vertical: isSmallScreen ? 12.0 : 16.0,
                              ),
                              side: BorderSide(color: AppTheme.primaryColor),
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.home),
                            label: const Text('Finish'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 24.0 : 32.0,
                                vertical: isSmallScreen ? 12.0 : 16.0,
                              ),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
