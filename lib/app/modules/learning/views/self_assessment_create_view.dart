import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/self_assessment_controller.dart';

/// Lets the student pick chapters from their subscription and choose a question count,
/// then taps "Start Assessment" which calls createAssessment() on the controller.
class SelfAssessmentCreateView extends GetView<SelfAssessmentController> {
  const SelfAssessmentCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHint(),
                  const SizedBox(height: 20),
                  _buildChapterSection(),
                  const SizedBox(height: 24),
                  _buildQuestionCountSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildStartButton(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'New Self Assessment',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.primaryColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Select the chapters you want to be tested on, then choose how many questions (1–10).',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.list_alt_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Select Chapters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final chapters = controller.availableChapters;
          if (chapters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No chapters available.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            );
          }
          return Column(
            children: chapters.map((ch) {
              return Obx(() {
                final isSelected = controller.selectedChapterIds.contains(
                  ch.id,
                );
                return InkWell(
                  onTap: () => controller.toggleChapter(ch.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
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
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ch.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        Text(
                          ch.subject.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.numbers_rounded, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Number of Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(
          () => Row(
            children: List.generate(10, (i) {
              final n = i + 1;
              final isSelected = controller.numberOfQuestions.value == n;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => controller.setQuestionCount(n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 44,
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
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[300]!,
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
                      child: Center(
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Obx(() {
      final hasChapters = controller.selectedChapterIds.isNotEmpty;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: hasChapters && !controller.isCreating.value
                  ? controller.createAssessment
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: hasChapters ? 4 : 0,
              ),
              icon: controller.isCreating.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                controller.isCreating.value
                    ? 'Creating…'
                    : hasChapters
                    ? 'Start Assessment (${controller.numberOfQuestions.value} Qs)'
                    : 'Select at least one chapter',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
