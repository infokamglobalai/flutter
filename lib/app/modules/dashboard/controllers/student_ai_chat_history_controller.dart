import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/data/services/data_service.dart';

class StudentAiChatHistoryController extends GetxController {
  final DataService _data = Get.find<DataService>();
  final StorageService _storage = Get.find<StorageService>();

  final isLoadingCounsellor = false.obs;
  final isLoadingContent = false.obs;
  final counsellorMessages = <Map<String, dynamic>>[].obs;
  final contentMessages = <Map<String, dynamic>>[].obs;

  final contentTargetId = ''.obs; // chapterId for content_test context
  late final TextEditingController contentTargetController;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    contentTargetId.value = _storage.getString('lastChapterId') ?? '';
    contentTargetController =
        TextEditingController(text: contentTargetId.value);
    refreshAll();
  }

  @override
  void onClose() {
    contentTargetController.dispose();
    super.onClose();
  }

  Future<void> refreshAll() async {
    error.value = '';
    await Future.wait([
      loadCounsellorHistory(),
      loadContentHistory(),
    ]);
  }

  Future<void> loadCounsellorHistory() async {
    isLoadingCounsellor.value = true;
    try {
      final items = await _data.fetchAiChatHistory(context: 'counsellor');
      counsellorMessages.assignAll(items);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingCounsellor.value = false;
    }
  }

  Future<void> loadContentHistory() async {
    final targetId = contentTargetId.value.trim();
    if (targetId.isEmpty) {
      contentMessages.clear();
      return;
    }

    isLoadingContent.value = true;
    try {
      final items = await _data.fetchAiChatHistory(
        context: 'content_test',
        targetId: targetId,
      );
      contentMessages.assignAll(items);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingContent.value = false;
    }
  }

  void setContentTargetId(String id) {
    contentTargetId.value = id.trim();
    if (contentTargetController.text != contentTargetId.value) {
      contentTargetController.text = contentTargetId.value;
      contentTargetController.selection = TextSelection.fromPosition(
        TextPosition(offset: contentTargetController.text.length),
      );
    }
    if (contentTargetId.value.isNotEmpty) {
      _storage.saveString('lastChapterId', contentTargetId.value);
    }
  }
}

