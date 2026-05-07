import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/qna_model.dart';
import 'package:najahapp/app/modules/learning/controllers/student_qna_threads_controller.dart';

class StudentQnaThreadsView extends GetView<StudentQnaThreadsController> {
  const StudentQnaThreadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Q&A'),
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
        if (controller.threads.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No Q&A threads yet',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.threads.length,
          itemBuilder: (context, i) {
            final QnaThread t = controller.threads[i];
            final title = t.chapter?.name.isNotEmpty == true
                ? '${t.chapter!.subjectName} • ${t.chapter!.name}'
                : 'Thread';
            final last = t.lastItem;
            final subtitle = last == null
                ? '${t.totalQuestions} questions'
                : last.isAnswered
                    ? 'Answered • ${last.questionText}'
                    : 'Pending • ${last.questionText}';

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                onTap: () => controller.openThread(t),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  t.hasUnanswered ? Icons.mark_chat_unread_rounded : Icons.chevron_right_rounded,
                  color: t.hasUnanswered ? Colors.orange : Colors.grey,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

