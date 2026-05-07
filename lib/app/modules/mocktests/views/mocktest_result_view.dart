import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/mocktests/controllers/mocktest_result_controller.dart';

class MocktestResultView extends GetView<MocktestResultController> {
  const MocktestResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock test result'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }
        if (controller.error.value.isNotEmpty && controller.payload.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(controller.error.value, textAlign: TextAlign.center),
            ),
          );
        }

        final p = controller.payload.value;
        if (p == null) {
          return const Center(child: Text('No data'));
        }

        final pct = (p['percentage'] as num?)?.toDouble() ?? 0;
        final score = p['score'];
        final total = p['totalMarks'];
        final title = p['mocktest'] is Map
            ? (p['mocktest']['title']?.toString() ?? 'Mock test')
            : 'Mock test';
        final results = (p['results'] as List<dynamic>?) ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: pct >= 60 ? Colors.green[800] : Colors.orange[900],
                    ),
                  ),
                  if (score != null && total != null)
                    Text(
                      'Score: $score / $total',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...results.asMap().entries.map((e) {
              final i = e.key + 1;
              final row = Map<String, dynamic>.from(e.value as Map);
              final qtext = row['questionText']?.toString() ?? '';
              final correct = row['correctOption']?.toString();
              final sel = row['selectedOption']?.toString();
              final ok = row['isCorrect'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text(
                    'Q$i',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    ok ? 'Correct' : 'Incorrect',
                    style: TextStyle(
                      color: ok ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(qtext),
                          const SizedBox(height: 8),
                          Text('Your answer: ${sel ?? "—"}'),
                          Text('Correct: ${correct ?? "—"}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Get.back(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Done'),
            ),
          ],
        );
      }),
    );
  }
}
