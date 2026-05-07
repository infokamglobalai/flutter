import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentGradeSubjectChapterEntryView extends StatelessWidget {
  const StudentGradeSubjectChapterEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final chapterId = (Get.parameters['chapterId'] ?? '').toString().trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chapterId.isEmpty) {
        Get.snackbar('Error', 'Missing chapterId');
        return;
      }
      Get.offNamed(
        Routes.VIDEO_PLAYER,
        arguments: {
          'chapter': {'chapterId': chapterId, '_id': chapterId},
        },
      );
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

