import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/custom_assessment_controller.dart';

class CustomAssessmentView extends GetView<CustomAssessmentController> {
  const CustomAssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.assessmentCompleted.value) {
          return _buildResultsView();
        }
        return _buildAssessmentView();
      }),
    );
  }

  Widget _buildAssessmentView() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildProgressIndicator(),
          Expanded(child: _buildQuestionContent()),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
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
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Exit Assessment?'),
                    content: const Text(
                      'Your progress will be lost. Are you sure you want to exit?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.back(); // Close dialog
                          controller.backToConfiguration();
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Assessment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.selectedSubject.value ?? "Test"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          _buildTimer(),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 4),
            Text(
              controller.getFormattedTime(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProgressIndicator() {
    return Obx(() {
      final current = controller.currentQuestionIndex.value + 1;
      final total = controller.assessmentQuestions.length;
      final progress = current / total;

      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $current of $total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${controller.assessmentAnswers.length} answered',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestionContent() {
    return Obx(() {
      if (controller.assessmentQuestions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final question =
          controller.assessmentQuestions[controller.currentQuestionIndex.value];
      final options = question['options'] as List<String>;
      final selectedAnswer =
          controller.assessmentAnswers[controller.currentQuestionIndex.value];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                question['chapterName'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Question text
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Options
            ...List.generate(options.length, (index) {
              final isSelected = selectedAnswer == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionCard(
                  option: options[index],
                  optionLabel: String.fromCharCode(65 + index), // A, B, C, D
                  isSelected: isSelected,
                  onTap: () {
                    controller.selectAnswer(
                      controller.currentQuestionIndex.value,
                      index,
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
            // Question grid navigator
            _buildQuestionGrid(),
          ],
        ),
      );
    });
  }

  Widget _buildOptionCard({
    required String option,
    required String optionLabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppTheme.primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    optionLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionGrid() {
    return Obx(() {
      final questions = controller.assessmentQuestions;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question Navigator',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(questions.length, (index) {
                final isAnswered = controller.assessmentAnswers.containsKey(
                  index,
                );
                final isCurrent =
                    controller.currentQuestionIndex.value == index;

                return InkWell(
                  onTap: () => controller.goToQuestion(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primaryColor
                          : isAnswered
                          ? AppTheme.secondaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.primaryColor
                            : isAnswered
                            ? AppTheme.secondaryColor
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCurrent || isAnswered
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem(AppTheme.primaryColor, 'Current'),
                const SizedBox(width: 12),
                _buildLegendItem(AppTheme.secondaryColor, 'Answered'),
                const SizedBox(width: 12),
                _buildLegendItem(Colors.grey[300]!, 'Unanswered'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Obx(() {
      final isFirst = controller.currentQuestionIndex.value == 0;
      final isLast =
          controller.currentQuestionIndex.value ==
          controller.assessmentQuestions.length - 1;
      final isSubmitting = controller.isSubmittingAssessment.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // Previous button
            Expanded(
              child: OutlinedButton(
                onPressed: isFirst ? null : controller.previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isFirst ? Colors.grey[300]! : AppTheme.primaryColor,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Next/Submit button
            Expanded(
              flex: isLast ? 2 : 1,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : isLast
                    ? controller.submitAssessment
                    : controller.nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast
                      ? Colors.green
                      : AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Submit Assessment' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast ? Icons.check_circle : Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildResultsView() {
    return Obx(() {
      final score = controller.assessmentScore.value;
      final correctCount = controller.correctAnswersCount.value;
      final totalQuestions = controller.assessmentQuestions.length;
      final isPassed = score >= 60;
      final timeSpent = controller.getFormattedTime();

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isPassed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Result icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPassed
                          ? [Colors.green, Colors.green[700]!]
                          : [Colors.orange, Colors.orange[700]!],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPassed ? Colors.green : Colors.orange)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPassed ? Icons.celebration : Icons.emoji_events,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isPassed ? 'Excellent Work!' : 'Good Effort!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPassed
                      ? 'You have passed the assessment!'
                      : 'Keep practicing to improve!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                // Score card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        'Correct Answers',
                        '$correctCount / $totalQuestions',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'Wrong Answers',
                        '${totalQuestions - correctCount} / $totalQuestions',
                        Icons.cancel,
                        Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'Time Taken',
                        timeSpent,
                        Icons.timer,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.resetAssessment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Retry Assessment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: controller.backToConfiguration,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.create, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Create New Assessment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.exitAssessment,
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildResultRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
