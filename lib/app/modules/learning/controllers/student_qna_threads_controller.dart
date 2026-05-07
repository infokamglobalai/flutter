import 'package:get/get.dart';
import 'package:najahapp/app/data/models/qna_model.dart';
import 'package:najahapp/app/data/services/qna_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentQnaThreadsController extends GetxController {
  final QnaService _qna = Get.find<QnaService>();

  final isLoading = false.obs;
  final error = ''.obs;
  final threads = <QnaThread>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _qna.getStudentThreads();
      if (res['success'] == true) {
        threads.assignAll((res['threads'] as List<QnaThread>));
      } else {
        error.value = (res['message'] ?? 'Failed to load threads').toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void openThread(QnaThread t) {
    Get.toNamed(
      Routes.STUDENT_QNA_THREAD,
      arguments: {
        'chapterId': t.chapter?.id ?? '',
        'subscriptionId': t.packageSubscriptionId,
      },
    );
  }
}

