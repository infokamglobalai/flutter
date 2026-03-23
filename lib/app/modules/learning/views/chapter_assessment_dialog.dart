import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/video_player_controller.dart' as learning;

class ChapterAssessmentDialog extends GetView<learning.VideoPlayerController> {
  const ChapterAssessmentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showAssessmentDialog.value) {
        return const SizedBox.shrink();
      }

      final assessment = controller.assessmentData.value;
      if (assessment == null) {
        return const SizedBox.shrink();
      }

      final questions = assessment['questions'] as List;
      final hasStarted =
          controller.assessmentAnswers.isNotEmpty ||
          controller.currentQuestionIndex.value > 0;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppTheme.primaryColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: hasStarted
              ? _buildAssessmentContent(questions)
              : _buildWelcomeScreen(assessment),
        ),
      );
    });
  }

  Widget _buildWelcomeScreen(Map<String, dynamic> assessment) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.quiz_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Chapter Assessment',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            assessment['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          // Info cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoCard(
                Icons.quiz_outlined,
                '${(assessment['questions'] as List).length}',
                'Questions',
              ),
              _buildInfoCard(
                Icons.timer_outlined,
                '${assessment['duration'] ?? ((assessment['questions'] as List).length * 2)}',
                'Minutes',
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstruction('Answer all questions to complete'),
                _buildInstruction('You can navigate between questions'),
                _buildInstruction('Your score will be shown after submission'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.skipAssessment,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Skip for Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.startAssessment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Start Assessment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppTheme.primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
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

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentContent(List questions) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chapter Assessment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        'Question ${controller.currentQuestionIndex.value + 1} of ${questions.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Close Assessment?'),
                      content: const Text(
                        'Your progress will not be saved. Are you sure you want to close?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.closeAssessmentDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Progress bar
        Obx(() {
          final progress =
              (controller.currentQuestionIndex.value + 1) / questions.length;
          return LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            minHeight: 6,
          );
        }),
        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              final currentIndex = controller.currentQuestionIndex.value;
              final question = questions[currentIndex] as Map<String, dynamic>;
              final selectedAnswer = controller.assessmentAnswers[currentIndex];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      question['questionText'] as String? ??
                          question['question'] as String? ??
                          '',
                      style: const TextStyle(
                        fontSize: 18,
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
                    final optionData = question['options'][index];
                    final option = optionData is String
                        ? optionData
                        : (optionData as Map<String, dynamic>)['text']
                              as String;
                    final isSelected = selectedAnswer == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => controller.selectAssessmentAnswer(
                          currentIndex,
                          index,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
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
                                      fontSize: 16,
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
                                    fontSize: 16,
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
                                  size: 24,
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
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Obx(() {
            final currentIndex = controller.currentQuestionIndex.value;
            final isFirstQuestion = currentIndex == 0;
            final isLastQuestion = currentIndex == questions.length - 1;
            final allAnswered =
                controller.assessmentAnswers.length == questions.length;

            return Row(
              children: [
                if (!isFirstQuestion)
                  OutlinedButton.icon(
                    onPressed: controller.previousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      side: BorderSide(color: AppTheme.primaryColor),
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                const Spacer(),
                if (isLastQuestion)
                  Obx(
                    () => ElevatedButton.icon(
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
                            : 'Submit',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        backgroundColor: AppTheme.accentColor,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: controller.nextQuestion,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
