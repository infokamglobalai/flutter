import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/mocktests/controllers/mocktest_attempt_controller.dart';

class MocktestAttemptView extends GetView<MocktestAttemptController> {
  const MocktestAttemptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }

        final qs = controller.questions;
        if (qs.isEmpty) {
          return const Center(child: Text('No questions in this test.'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Obx(() {
                final idx = controller.currentIndex.value;
                return Row(
                  children: [
                    Text(
                      'Question ${idx + 1} / ${qs.length}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (controller.mocktest.value?['duration'] != null)
                      Text(
                        '${controller.mocktest.value!['duration']} min test',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                );
              }),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: qs.length,
                onPageChanged: (i) => controller.currentIndex.value = i,
                itemBuilder: (context, index) {
                  final q = qs[index];
                  final qid = controller.questionId(q);
                  final text = q['questionText']?.toString() ?? '';
                  final opts = (q['options'] as List<dynamic>?) ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...opts.map((o) {
                          final om = Map<String, dynamic>.from(o as Map);
                          final label = om['text']?.toString() ?? '';
                          return Obx(() {
                            final sel = controller.answers[qid];
                            final selected = sel == label;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: selected
                                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () =>
                                      controller.selectOption(qid, label),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Icon(
                                          selected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          color: selected
                                              ? AppTheme.primaryColor
                                              : Colors.grey,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Obx(() {
                      final idx = controller.currentIndex.value;
                      return TextButton(
                        onPressed: idx > 0 ? controller.prev : null,
                        child: const Text('Previous'),
                      );
                    }),
                    const Spacer(),
                    Obx(() {
                      final idx = controller.currentIndex.value;
                      final last = idx >= qs.length - 1;
                      if (!last) {
                        return FilledButton(
                          onPressed: controller.next,
                          child: const Text('Next'),
                        );
                      }
                      return FilledButton(
                        onPressed: controller.submit,
                        child: const Text('Submit'),
                      );
                    }),
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
