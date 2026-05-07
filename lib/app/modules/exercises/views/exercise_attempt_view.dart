import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/exercises/controllers/exercise_attempt_controller.dart';

class ExerciseAttemptView extends GetView<ExerciseAttemptController> {
  const ExerciseAttemptView({super.key});

  void _showResult(BuildContext context) {
    final total = controller.totalQuestions;
    final correct = controller.correctCount;
    final answered = controller.answeredCount;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Result'),
        content: Text(
          'Answered: $answered/$total\nCorrect: $correct/$total',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ex = controller.exercise;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(ex.title.isEmpty ? 'Exercise' : ex.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: ex.questions.isEmpty ? null : () => _showResult(context),
            child: const Text(
              'Finish',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: ex.questions.isEmpty
          ? Center(
              child: Text(
                'No questions found.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            )
          : Obx(() {
              // Rebuild when selections change
              controller.currentIndex.value;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ex.questions.length,
                itemBuilder: (context, qIndex) {
                  final q = ex.questions[qIndex];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${qIndex + 1}. ${q.questionText}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(q.options.length, (optIndex) {
                          final opt = q.options[optIndex];
                          final selected = q.selectedOptionIndex == optIndex;
                          final bool showCorrectness = q.isAnswered;
                          Color? border;
                          Color? fill;
                          if (showCorrectness) {
                            if (opt.isCorrect) {
                              border = const Color(0xFF10B981);
                              fill = const Color(0xFF10B981).withOpacity(0.10);
                            } else if (selected && !opt.isCorrect) {
                              border = const Color(0xFFEF4444);
                              fill = const Color(0xFFEF4444).withOpacity(0.10);
                            }
                          }
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: fill ?? Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: border ?? Colors.grey[300]!,
                                width: selected ? 1.4 : 1.0,
                              ),
                            ),
                            child: RadioListTile<int>(
                              value: optIndex,
                              groupValue: q.selectedOptionIndex,
                              onChanged: (_) =>
                                  controller.selectOption(qIndex, optIndex),
                              title: Text(
                                opt.text,
                                style: const TextStyle(fontSize: 13),
                              ),
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              );
            }),
    );
  }
}

