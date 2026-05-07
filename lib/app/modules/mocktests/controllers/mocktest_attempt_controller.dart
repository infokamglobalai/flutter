import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/data/services/mocktest_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class MocktestAttemptController extends GetxController {
  final MocktestService _svc = Get.find<MocktestService>();

  final isLoading = true.obs;
  final error = ''.obs;
  final mocktest = Rxn<Map<String, dynamic>>();
  final currentIndex = 0.obs;
  final answers = <String, String?>{}.obs;

  late String mocktestId;
  late String packageId;
  late String title;
  DateTime? _startedAt;

  final PageController pageController = PageController();

  List<Map<String, dynamic>> get questions {
    final q = mocktest.value?['questions'];
    if (q is! List) return [];
    return q.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      mocktestId = args['mocktestId']?.toString() ?? '';
      packageId = args['packageId']?.toString() ?? '';
      title = args['title']?.toString() ?? 'Mock test';
    } else {
      mocktestId = '';
      packageId = '';
      title = 'Mock test';
    }
  }

  @override
  void onReady() {
    super.onReady();
    _load();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    if (mocktestId.isEmpty || packageId.isEmpty) {
      error.value = 'Invalid mock test';
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      final data = await _svc.getMocktestById(mocktestId, packageId);
      mocktest.value = data;
      _startedAt = DateTime.now();
    } on MocktestAlreadyCompletedException catch (e) {
      await Get.offNamed(
        Routes.MOCKTEST_RESULT,
        arguments: {'attemptId': e.attemptId},
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  String questionId(Map<String, dynamic> q) =>
      (q['_id'] ?? q['id']).toString();

  void selectOption(String qid, String optionText) {
    answers[qid] = optionText;
    answers.refresh();
  }

  void next() {
    final n = questions.length;
    if (currentIndex.value < n - 1) {
      currentIndex.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void prev() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> submit() async {
    final qs = questions;
    if (qs.isEmpty) return;

    final payload = <Map<String, dynamic>>[];
    for (final q in qs) {
      final id = questionId(q);
      payload.add({
        'questionId': id,
        'selectedOption': answers[id],
      });
    }

    final secs = _startedAt != null
        ? DateTime.now().difference(_startedAt!).inSeconds
        : 0;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final result = await _svc.submitAttempt(
        mocktestId: mocktestId,
        packageId: packageId,
        answers: payload,
        durationInSeconds: secs,
      );
      Get.back();
      await Get.offNamed(
        Routes.MOCKTEST_RESULT,
        arguments: {'result': result},
      );
    } catch (e) {
      Get.back();
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    }
  }
}
