import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/video_player_controller.dart' as learning;

class ChapterAssessmentPage extends GetView<learning.VideoPlayerController> {
  const ChapterAssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    // Check if controller exists
    try {
      if (!Get.isRegistered<learning.VideoPlayerController>()) {
        print('❌ VideoPlayerController not found!');
        return Scaffold(
          appBar: AppBar(title: const Text('Assessment')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Controller not found'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error checking controller: $e');
    }

    return Obx(() {
      final assessment = controller.assessmentData.value;
      print(
        '🔍 Assessment page - assessmentData: ${assessment != null ? "Found" : "NULL"}',
      );

      if (assessment == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Assessment')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No assessment available'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      }

      final questions = assessment['questions'] as List;
      final hasStarted = controller.hasStartedAssessment.value;

      return WillPopScope(
        onWillPop: () async {
          // Reset the started flag when going back
          controller.hasStartedAssessment.value = false;
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: hasStarted
                ? _buildAssessmentContent(context, questions, isMobile)
                : _buildWelcomeScreen(context, assessment, isMobile),
          ),
        ),
      );
    });
  }

  Widget _buildWelcomeScreen(
    BuildContext context,
    Map<String, dynamic> assessment,
    bool isMobile,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 40),
          // Icon
          Center(
            child: Container(
              width: isMobile ? 120 : 140,
              height: isMobile ? 120 : 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Icon(
                Icons.quiz_rounded,
                size: isMobile ? 60 : 70,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          // Title
          Text(
            'Chapter Assessment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            assessment['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isMobile ? 40 : 56),
          // Info cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.quiz_outlined,
                  '${(assessment['questions'] as List).length}',
                  'Questions',
                  isMobile,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  Icons.timer_outlined,
                  '${assessment['duration'] ?? ((assessment['questions'] as List).length * 2)}',
                  'Minutes',
                  isMobile,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 32 : 48),
          // Instructions
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accentColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: isMobile ? 24 : 28,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInstruction('Answer all questions to complete', isMobile),
                _buildInstruction(
                  'You can navigate between questions',
                  isMobile,
                ),
                _buildInstruction(
                  'Your score will be shown after submission',
                  isMobile,
                ),
                _buildInstruction(
                  'Once submitted, you cannot change your answers',
                  isMobile,
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 40 : 56),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.hasStartedAssessment.value = false;
                    controller.skipAssessment();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
                    side: BorderSide(color: Colors.grey[400]!, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Skip for Now',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: isMobile ? 1 : 2,
                child: ElevatedButton(
                  onPressed: controller.startAssessment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Start Assessment',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String value,
    String label,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: isMobile ? 36 : 44, color: AppTheme.primaryColor),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentContent(
    BuildContext context,
    List questions,
    bool isMobile,
  ) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Exit Assessment?'),
                        content: const Text(
                          'Your progress will not be saved. Are you sure you want to exit?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Exit'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter Assessment',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          'Question ${controller.currentQuestionIndex.value + 1} of ${questions.length}',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 15,
                            color: Colors.white70,
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
        // Progress bar
        Obx(() {
          final progress =
              (controller.currentQuestionIndex.value + 1) / questions.length;
          return LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            minHeight: 8,
          );
        }),
        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            child: Obx(() {
              final currentIndex = controller.currentQuestionIndex.value;
              final question = questions[currentIndex] as Map<String, dynamic>;
              final selectedAnswer = controller.assessmentAnswers[currentIndex];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question header
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Q${currentIndex + 1}',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            question['questionText'] as String? ??
                                question['question'] as String? ??
                                '',
                            style: TextStyle(
                              fontSize: isMobile ? 17 : 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 32),
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
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => controller.selectAssessmentAnswer(
                          currentIndex,
                          index,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: isMobile ? 40 : 48,
                                height: isMobile ? 40 : 48,
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
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: isMobile ? 15 : 18,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : const Color(0xFF1F2937),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryColor,
                                  size: isMobile ? 24 : 28,
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
          padding: EdgeInsets.all(isMobile ? 20 : 32),
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
            final isLastQuestion = currentIndex == questions.length - 1;
            final currentAnswer = controller.assessmentAnswers[currentIndex];
            final allAnswered =
                controller.assessmentAnswers.length == questions.length;

            return Row(
              children: [
                // Previous button
                if (!isFirstQuestion)
                  OutlinedButton.icon(
                    onPressed: controller.previousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(isMobile ? 'Back' : 'Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 14 : 16,
                      ),
                      side: BorderSide(color: AppTheme.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (!isFirstQuestion) const SizedBox(width: 12),
                // Next/Submit button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: currentAnswer != null
                        ? () {
                            if (isLastQuestion) {
                              if (allAnswered) {
                                _showSubmitConfirmation(questions.length);
                              } else {
                                Get.snackbar(
                                  'Incomplete',
                                  'Please answer all questions before submitting',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Get.theme.colorScheme.error
                                      .withOpacity(0.9),
                                  colorText: Colors.white,
                                );
                              }
                            } else {
                              controller.nextQuestion();
                            }
                          }
                        : null,
                    icon: Icon(
                      isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
                    ),
                    label: Text(
                      isLastQuestion ? 'Submit Assessment' : 'Next Question',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastQuestion && allAnswered
                          ? AppTheme.accentColor
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 14 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  void _showSubmitConfirmation(int totalQuestions) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in, color: AppTheme.accentColor),
            const SizedBox(width: 12),
            const Text('Submit Assessment?'),
          ],
        ),
        content: Text(
          'You have answered all $totalQuestions questions. Once submitted, you cannot change your answers.\n\nAre you ready to submit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Review Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.submitAssessment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
