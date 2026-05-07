import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/learning/controllers/public_assessments_controller.dart';

class PublicAssessmentsView extends GetView<PublicAssessmentsController> {
  const PublicAssessmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Assessments'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.assessments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty &&
            controller.assessments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.error.value),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => controller.load(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.load(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.assessments.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.assessments.length) {
                if (!controller.hasMore.value) return const SizedBox(height: 40);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: OutlinedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.load(),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load more'),
                    ),
                  ),
                );
              }

              final a = controller.assessments[index];
              final title = (a['title'] ?? 'Assessment').toString();
              final duration = (a['duration'] ?? '').toString();
              final qCount = (a['numberOfQuestions'] ?? (a['questions'] is List ? (a['questions'] as List).length : 0)).toString();
              final chapter = (a['chapter'] is Map) ? (a['chapter']['name'] ?? '').toString() : '';

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  onTap: () => controller.openAssessment(a),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      [
                        if (chapter.isNotEmpty) chapter,
                        if (qCount.isNotEmpty) '$qCount questions',
                        if (duration.isNotEmpty) '$duration min',
                      ].join(' • '),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

