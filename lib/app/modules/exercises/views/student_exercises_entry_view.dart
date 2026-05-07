import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentExercisesEntryView extends StatelessWidget {
  const StudentExercisesEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(Routes.EXERCISES);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

