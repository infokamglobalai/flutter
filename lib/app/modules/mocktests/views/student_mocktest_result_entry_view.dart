import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentMocktestResultEntryView extends StatelessWidget {
  const StudentMocktestResultEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final attemptId = (Get.parameters['attemptId'] ?? '').toString().trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attemptId.isEmpty) {
        Get.snackbar('Error', 'Missing attemptId');
        return;
      }
      Get.offNamed(Routes.MOCKTEST_RESULT, arguments: {'attemptId': attemptId});
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

