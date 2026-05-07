import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/qna_model.dart';
import 'package:najahapp/app/modules/learning/controllers/student_qna_thread_controller.dart';

class StudentQnaThreadView extends GetView<StudentQnaThreadController> {
  const StudentQnaThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Q&A Thread'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
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

        final t = controller.thread.value;
        final items = t?.items ?? const <QnaItem>[];

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final it = items[i];
                  return _QnaItemCard(item: it);
                },
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.questionCtrl,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Ask your question...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(() {
                      final busy = controller.isAsking.value;
                      return FilledButton(
                        onPressed: busy ? null : controller.ask,
                        child: busy
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Send'),
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

class _QnaItemCard extends StatelessWidget {
  const _QnaItemCard({required this.item});

  final QnaItem item;

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('dd MMM, hh:mm a').format(item.createdAt);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.questionText,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ts, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 12),
            if (item.isAnswered) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.answerText,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Pending mentor reply',
                    style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

