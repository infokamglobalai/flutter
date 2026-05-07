import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentReportsRedirectView extends StatelessWidget {
  const StudentReportsRedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(Routes.STUDENT_PROGRESS);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

