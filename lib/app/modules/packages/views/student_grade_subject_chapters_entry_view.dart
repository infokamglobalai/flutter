import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentGradeSubjectChaptersEntryView extends StatelessWidget {
  const StudentGradeSubjectChaptersEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final gradeId = (Get.parameters['gradeId'] ?? '').toString().trim();
    final subjectId = (Get.parameters['subjectId'] ?? '').toString().trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(
        Routes.SUBJECT_SELECTION,
        arguments: {
          'preselectGradeId': gradeId,
        },
      );
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

