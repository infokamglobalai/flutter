import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/self_assessment_model.dart';
import '../controllers/self_assessment_controller.dart';

class SelfAssessmentAttemptView extends GetView<SelfAssessmentController> {
  const SelfAssessmentAttemptView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final confirm = await _showExitDialog(context);
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Obx(() {
          final detail = controller.currentDetail.value;
          if (detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final questions = detail.questions;
          if (questions.isEmpty) {
            return const Center(child: Text('No questions found.'));
          }
          final idx = controller.currentQuestionIndex.value;
          final question = questions[idx];
          return Column(
            children: [
              _buildProgressHeader(idx, questions.length),
              Expanded(child: _buildQuestionCard(question, idx)),
              _buildNavBar(idx, questions.length),
            ],
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () async {
          final confirm = await _showExitDialog(Get.context!);
          if (confirm == true) Get.back();
        },
      ),
      title: Obx(() {
        final detail = controller.currentDetail.value;
        return Text(
          detail?.title ?? 'Self Assessment',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }),
      actions: [
        // Question map button
        Obx(() {
          final detail = controller.currentDetail.value;
          final total = detail?.questions.length ?? 0;
          return IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            onPressed: () => _showQuestionMap(Get.context!, total),
          );
        }),
      ],
    );
  }

  Widget _buildProgressHeader(int idx, int total) {
    final progress = total > 0 ? (idx + 1) / total : 0.0;
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${idx + 1} of $total',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Obx(() {
                final answered = controller.answers.length;
                return Text(
                  '$answered/$total answered',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(SelfAssessmentQuestion question, int idx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + marks
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${idx + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (question.difficulty != null)
                _difficultyBadge(question.difficulty!),
              const Spacer(),
              Text(
                '${question.marks} mark${question.marks == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
          const SizedBox(height: 20),
          // Options
          ...List.generate(question.options.length, (optIdx) {
            final opt = question.options[optIdx];
            return _buildOptionTile(question, optIdx, opt, idx);
          }),
          const SizedBox(height: 16),
          if (question.answerType == 'multiple')
            Text(
              '* Select all correct answers',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    SelfAssessmentQuestion question,
    int optIdx,
    QuestionOption opt,
    int qIdx,
  ) {
    return Obx(() {
      final qId = question.id;
      final stored = controller.answers[qId];
      bool isSelected;

      if (question.answerType == 'multiple') {
        final list = stored is List ? stored.cast<int>() : <int>[];
        isSelected = list.contains(optIdx);
      } else {
        isSelected = stored is int && stored == optIdx;
      }

      return InkWell(
        onTap: () {
          if (question.answerType == 'multiple') {
            final list = (controller.answers[qId] is List)
                ? List<int>.from(controller.answers[qId] as List)
                : <int>[];
            if (list.contains(optIdx)) {
              list.remove(optIdx);
            } else {
              list.add(optIdx);
            }
            controller.selectAnswer(qId, list);
          } else {
            controller.selectAnswer(qId, optIdx);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Option letter circle
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + optIdx), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opt.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : const Color(0xFF374151),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  question.answerType == 'multiple'
                      ? Icons.check_box_rounded
                      : Icons.radio_button_checked_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavBar(int idx, int total) {
    final isLast = idx == total - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            // Previous
            if (idx > 0)
              OutlinedButton.icon(
                onPressed: controller.prevQuestion,
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                label: const Text('Prev'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const Spacer(),
            // Next / Submit
            Obx(() {
              return ElevatedButton.icon(
                onPressed: isLast
                    ? (controller.isSubmitting.value ? null : _confirmSubmit)
                    : controller.nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast
                      ? Colors.green[600]
                      : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        isLast
                            ? Icons.check_circle_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                label: Text(
                  controller.isSubmitting.value
                      ? 'Submitting…'
                      : isLast
                      ? 'Submit'
                      : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _difficultyBadge(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'hard':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _confirmSubmit() {
    final total = controller.currentDetail.value?.questions.length ?? 0;
    final answered = controller.answers.length;
    final unanswered = total - answered;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Assessment?'),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered question${unanswered > 1 ? 's' : ''}. Once submitted you cannot change your answers.'
              : 'You have answered all $total questions. Submit now?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Review')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.submitAttempt();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showQuestionMap(BuildContext context, int total) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question Map',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(total, (i) {
                  final detail = controller.currentDetail.value;
                  final qId = detail != null ? detail.questions[i].id : '';
                  final isAnswered = controller.isAnswered(qId);
                  final isCurrent = controller.currentQuestionIndex.value == i;
                  return GestureDetector(
                    onTap: () {
                      controller.goToQuestion(i);
                      Get.back();
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.primaryColor
                            : isAnswered
                            ? Colors.green[100]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? AppTheme.primaryColor
                              : isAnswered
                              ? Colors.green
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : isAnswered
                                ? Colors.green[700]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
            const SizedBox(height: 20),
            Row(
              children: [
                _mapLegend(Colors.green[100]!, Colors.green, 'Answered'),
                const SizedBox(width: 16),
                _mapLegend(Colors.grey[100]!, Colors.grey, 'Not answered'),
                const SizedBox(width: 16),
                _mapLegend(
                  AppTheme.primaryColor,
                  AppTheme.primaryColor,
                  'Current',
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapLegend(
    Color bg,
    Color border,
    String label, {
    Color textColor = const Color(0xFF374151),
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Assessment?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
