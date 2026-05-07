import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentContentTestPageEntryView extends StatelessWidget {
  const StudentContentTestPageEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Web route is sometimes opened without params; safest fallback is dashboard.
      Get.offNamed(Routes.DASHBOARD);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

