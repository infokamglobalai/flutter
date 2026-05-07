import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/data/models/qna_model.dart';
import 'package:najahapp/app/data/services/qna_service.dart';

class StudentQnaThreadController extends GetxController {
  final QnaService _qna = Get.find<QnaService>();

  final chapterId = ''.obs;
  final subscriptionId = ''.obs;

  final isLoading = false.obs;
  final error = ''.obs;
  final thread = Rxn<QnaThread>();

  final questionCtrl = TextEditingController();
  final isAsking = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      chapterId.value = (args['chapterId'] ?? '').toString();
      subscriptionId.value = (args['subscriptionId'] ?? '').toString();
    }
    load();
  }

  @override
  void onClose() {
    questionCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _qna.getQnaThread(
        chapterId: chapterId.value,
        packageId: subscriptionId.value,
      );
      if (res['success'] == true) {
        thread.value = res['thread'] as QnaThread?;
      } else {
        error.value = (res['message'] ?? 'Failed to load thread').toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ask() async {
    final text = questionCtrl.text.trim();
    if (text.isEmpty) return;
    isAsking.value = true;
    try {
      final res = await _qna.askQuestion(
        chapterId: chapterId.value,
        packageId: subscriptionId.value,
        questionText: text,
      );
      if (res['success'] == true) {
        thread.value = res['thread'] as QnaThread;
        questionCtrl.clear();
      } else {
        Get.snackbar('Error', (res['message'] ?? 'Failed').toString());
      }
    } finally {
      isAsking.value = false;
    }
  }
}

