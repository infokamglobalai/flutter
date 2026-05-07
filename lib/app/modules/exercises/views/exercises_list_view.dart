import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class ExercisesListView extends StatelessWidget {
  const ExercisesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Exercises'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final subs = dashboard.userSubscriptions;
        if (dashboard.isLoadingSubscriptions.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (dashboard.subscriptionsError.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dashboard.subscriptionsError.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: dashboard.loadUserSubscriptions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (subs.isEmpty) {
          return Center(
            child: Text(
              'No subscriptions found.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          );
        }

        // Flatten chapters across subscriptions; dedupe by id.
        final Map<String, ({String id, String name})> byId = {};
        for (final sub in subs) {
          for (final ch in sub.chapters) {
            final id = ch.id.trim();
            if (id.isEmpty) continue;
            byId.putIfAbsent(
              id,
              () => (id: id, name: ch.name.trim().isEmpty ? 'Chapter' : ch.name),
            );
          }
        }
        final chapters = byId.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        if (chapters.isEmpty) {
          return Center(
            child: Text(
              'No chapters found in your subscriptions.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: chapters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final ch = chapters[index];
            final chapterId = ch.id;
            final title = ch.name;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Get.toNamed(
                  Routes.CHAPTER_EXERCISES,
                  arguments: {'chapterId': chapterId, 'chapterName': title},
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

