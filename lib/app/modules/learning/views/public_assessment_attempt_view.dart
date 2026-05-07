import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/learning/controllers/public_assessment_attempt_controller.dart';

class PublicAssessmentAttemptView
    extends GetView<PublicAssessmentAttemptController> {
  const PublicAssessmentAttemptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Assessment'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Obx(() {
        final qs = controller.questions;
        if (controller.assessment.value == null || qs.isEmpty) {
          return const Center(child: Text('No questions'));
        }
        final idx = controller.currentIndex.value;
        final q = qs[idx] as Map;
        final qId = (q['_id'] ?? '').toString();
        final answerType = (q['answerType'] ?? 'single').toString();
        final options = (q['options'] as List? ?? const []);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Question ${idx + 1} / ${qs.length}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (answerType == 'multiple')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Multiple',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        (q['questionText'] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(options.length, (i) {
                    final opt = options[i] as Map;
                    final text = (opt['text'] ?? '').toString();

                    final selected = () {
                      final cur = controller.answersByQuestionId[qId];
                      if (answerType == 'multiple') {
                        final list = (cur is List)
                            ? cur.map((e) => e.toString()).toList()
                            : <String>[];
                        return list.contains(i.toString());
                      }
                      return cur != null && cur.toString() == i.toString();
                    }();

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: selected
                              ? AppTheme.primaryColor
                              : Colors.grey[200]!,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => answerType == 'multiple'
                            ? controller.toggleMultiple(qId, i)
                            : controller.selectSingle(qId, i),
                        leading: answerType == 'multiple'
                            ? Checkbox(
                                value: selected,
                                onChanged: (_) =>
                                    controller.toggleMultiple(qId, i),
                              )
                            : Radio<int>(
                                value: i,
                                groupValue: int.tryParse(
                                  controller.answersByQuestionId[qId]?.toString() ??
                                      '',
                                ),
                                onChanged: (_) => controller.selectSingle(qId, i),
                              ),
                        title: Text(text),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: idx == 0 ? null : controller.prev,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final submitting = controller.isSubmitting.value;
                        final isLast = idx == qs.length - 1;
                        return FilledButton(
                          onPressed: submitting
                              ? null
                              : (isLast ? controller.submit : controller.next),
                          child: submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isLast ? 'Submit' : 'Next'),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

