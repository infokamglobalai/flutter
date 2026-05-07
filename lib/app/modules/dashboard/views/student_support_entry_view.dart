import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/modules/dashboard/views/dashboard_view.dart';

class StudentSupportEntryView extends StatelessWidget {
  const StudentSupportEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.bottomNavIndex.value = 2; // Support tab
    });
    return const DashboardView();
  }
}

