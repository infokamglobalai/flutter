import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentTestYourKnowledgeRedirectView extends StatelessWidget {
  const StudentTestYourKnowledgeRedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(Routes.STUDENT_PACKAGES);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

