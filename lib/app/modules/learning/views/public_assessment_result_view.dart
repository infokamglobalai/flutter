import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/learning/controllers/public_assessment_result_controller.dart';

class PublicAssessmentResultView
    extends GetView<PublicAssessmentResultController> {
  const PublicAssessmentResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.result.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty && controller.result.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.error.value),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = controller.result.value ?? const <String, dynamic>{};
        final pct = ((data['percentage'] ?? 0) as num).toDouble();
        final obtained = (data['obtainedMarks'] ?? 0).toString();
        final total = (data['totalMarks'] ?? 0).toString();
        final results = (data['results'] as List<dynamic>? ?? const []);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${pct.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Marks: $obtained / $total',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...results.map((r) {
              final m = (r as Map).cast<String, dynamic>();
              final qText = (m['questionText'] ?? '').toString();
              final isCorrect = m['isCorrect'] == true;
              final explanation = (m['explanation'] ?? '').toString();
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  title: Text(
                    qText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: explanation.isEmpty
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            explanation,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  trailing: Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Get.back(),
              child: const Text('Done'),
            ),
          ],
        );
      }),
    );
  }
}

