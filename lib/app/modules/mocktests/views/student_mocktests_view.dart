import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/mocktests/controllers/student_mocktests_controller.dart';

class StudentMocktestsView extends GetView<StudentMocktestsController> {
  const StudentMocktestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mock tests'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text(
                    controller.error.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final list = controller.items;
        final sub = controller.subscription;

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No mock tests yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When your teachers schedule tests for your grade, they will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.reload,
          color: AppTheme.primaryColor,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (sub != null) ...[
                Text(
                  sub.package.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sub.grade.name} · ${sub.board.name}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),
              ],
              ...list.map((t) => _TestCard(test: t, onOpen: controller.openAttempt)),
            ],
          ),
        );
      }),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({required this.test, required this.onOpen});

  final Map<String, dynamic> test;
  final void Function(Map<String, dynamic>) onOpen;

  @override
  Widget build(BuildContext context) {
    final title = test['title']?.toString() ?? 'Mock test';
    final duration = test['duration'];
    final nq = test['numberOfQuestions'];
    final attempted = test['hasAttempted'] == true;
    final status = test['attemptStatus']?.toString();
    final score = test['score'];
    final pct = test['percentage'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => onOpen(test),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (duration != null)
                    _chip(Icons.timer_outlined, '$duration min'),
                  if (nq != null) _chip(Icons.help_outline, '$nq Qs'),
                ],
              ),
              if (attempted && status == 'completed') ...[
                const SizedBox(height: 12),
                Text(
                  score != null && pct != null
                      ? 'Score: $score · ${pct is num ? pct.toStringAsFixed(1) : pct}%'
                      : 'Completed',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                attempted && status == 'completed'
                    ? 'Tap to view results'
                    : 'Tap to start',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
