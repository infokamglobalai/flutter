import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/live_class_model.dart';
import '../../../data/services/live_class_service.dart';
import '../../../routes/app_pages.dart';

class LiveClassController extends GetxController {
  final LiveClassService _liveClassService = LiveClassService();

  final isLoading = false.obs;
  final liveClasses = <LiveClassModel>[].obs;
  final filterStatus = 'all'.obs; // 'all', 'live', 'scheduled', 'ended'

  @override
  void onInit() {
    super.onInit();
    loadLiveClasses();
  }

  Future<void> loadLiveClasses() async {
    isLoading.value = true;
    try {
      final result = await _liveClassService.fetchLiveClasses();
      liveClasses.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load live classes',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<LiveClassModel> get filteredClasses {
    if (filterStatus.value == 'live') {
      return liveClasses.where((c) => c.isLive).toList();
    } else if (filterStatus.value == 'scheduled') {
      return liveClasses.where((c) => c.isScheduled).toList();
    } else if (filterStatus.value == 'ended') {
      return liveClasses.where((c) => c.isEnded).toList();
    }
    return liveClasses;
  }

  List<LiveClassModel> get liveNowClasses =>
      liveClasses.where((c) => c.isLive).toList();

  List<LiveClassModel> get upcomingClasses =>
      liveClasses.where((c) => c.isScheduled).toList();

  Future<void> joinLiveClass(LiveClassModel liveClass) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final token = await _liveClassService.getLiveClassToken(liveClass.id);
    Get.back(); // Dismiss loading

    if (token != null && token.isNotEmpty) {
      Get.toNamed(
        Routes.LIVE_CLASS_ROOM,
        arguments: {
          'liveClass': liveClass,
          'token': token,
        },
      );
    } else {
      Get.snackbar(
        'Cannot Join',
        'Could not get access token for this live class.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
