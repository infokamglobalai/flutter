import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentMocktestAttemptEntryView extends StatelessWidget {
  const StudentMocktestAttemptEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final mocktestId = (Get.parameters['mocktestId'] ?? '').toString().trim();
    final packageId = (Get.parameters['packageId'] ?? '').toString().trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mocktestId.isEmpty) {
        Get.snackbar('Error', 'Missing mocktestId');
        return;
      }
      Get.offNamed(
        Routes.MOCKTEST_ATTEMPT,
        arguments: {'mocktestId': mocktestId, 'packageId': packageId},
      );
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

