import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentPackageMocktestsEntryView extends StatelessWidget {
  const StudentPackageMocktestsEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final packageId = (Get.parameters['packageId'] ?? '').toString().trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(
        Routes.STUDENT_MOCKTESTS,
        arguments: {'subscriptionId': packageId},
      );
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

