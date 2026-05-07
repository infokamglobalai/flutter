import 'package:get/get.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class PublicAssessmentAttemptController extends GetxController {
  final DataService _data = Get.find<DataService>();

  final assessment = Rxn<Map<String, dynamic>>();
  final chapterId = ''.obs;
  final subscriptionId = ''.obs;

  final isSubmitting = false.obs;
  final currentIndex = 0.obs;
  final answersByQuestionId = <String, dynamic>{}.obs; // qId -> answer (int or List<String>)

  List<dynamic> get questions =>
      (assessment.value?['questions'] as List<dynamic>? ?? const []);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      assessment.value = (args['assessment'] as Map?)?.cast<String, dynamic>();
      chapterId.value = (args['chapterId'] ?? '').toString();
      subscriptionId.value = (args['subscriptionId'] ?? '').toString();
    }
  }

  void selectSingle(String qId, int optionIndex) {
    answersByQuestionId[qId] = optionIndex;
    answersByQuestionId.refresh();
  }

  void toggleMultiple(String qId, int optionIndex) {
    final current = answersByQuestionId[qId];
    final list = (current is List)
        ? current.map((e) => e.toString()).toList()
        : <String>[];
    final key = optionIndex.toString();
    if (list.contains(key)) {
      list.remove(key);
    } else {
      list.add(key);
    }
    answersByQuestionId[qId] = list;
    answersByQuestionId.refresh();
  }

  void next() {
    if (currentIndex.value < questions.length - 1) currentIndex.value++;
  }

  void prev() {
    if (currentIndex.value > 0) currentIndex.value--;
  }

  Future<void> submit() async {
    final a = assessment.value;
    if (a == null) return;
    final assessmentId = (a['_id'] ?? '').toString();
    if (assessmentId.isEmpty) return;

    isSubmitting.value = true;
    try {
      final res = await _data.submitAssessment(
        assessmentId: assessmentId,
        answers: Map<String, dynamic>.from(answersByQuestionId),
        chapterId: chapterId.value.isEmpty ? null : chapterId.value,
        subscriptionId: subscriptionId.value.isEmpty ? null : subscriptionId.value,
      );

      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final attemptId = (data['attemptId'] ?? '').toString();
        Get.offNamed(
          Routes.PUBLIC_ASSESSMENT_RESULT,
          arguments: {'attemptId': attemptId, 'fallback': data},
        );
      } else {
        Get.snackbar('Error', (res['message'] ?? 'Failed to submit').toString());
      }
    } finally {
      isSubmitting.value = false;
    }
  }
}

