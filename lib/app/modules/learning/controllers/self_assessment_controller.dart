import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/data/models/self_assessment_model.dart';
import 'package:najahapp/app/data/models/subscription_model.dart';

class SelfAssessmentController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();

  // ── Passed arguments ──────────────────────────────────────────────
  final subscription = Rxn<SubscriptionModel>();

  /// Optional pre-selected subject (used when opening from subject card).
  final preSelectedSubject = RxnString();

  // ── List view state ───────────────────────────────────────────────
  final assessmentList = <SelfAssessmentModel>[].obs;
  final isLoadingList = false.obs;
  final listError = RxnString();

  // ── Create flow state ─────────────────────────────────────────────
  final selectedChapterIds = <String>[].obs;
  final numberOfQuestions = 5.obs;
  final isCreating = false.obs;

  // ── Attempt view state ────────────────────────────────────────────
  final currentDetail = Rxn<SelfAssessmentDetail>();
  final isLoadingDetail = false.obs;
  final currentQuestionIndex = 0.obs;

  /// questionId -> selected option index (single) or List<int> (multiple)
  final answers = <String, dynamic>{}.obs;
  final isSubmitting = false.obs;

  // ── Result state ──────────────────────────────────────────────────
  final submitResult = Rxn<SelfAssessmentSubmitResult>();

  // ── Timer ─────────────────────────────────────────────────────────
  final elapsedSeconds = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      subscription.value = args['subscription'] as SubscriptionModel?;
      preSelectedSubject.value = args['subject'] as String?;
    }
    if (subscription.value != null) {
      fetchList();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // LIST
  // ──────────────────────────────────────────────────────────────────

  Future<void> fetchList() async {
    if (subscription.value == null) return;
    isLoadingList.value = true;
    listError.value = null;
    try {
      final resp = await _api.get(
        ApiConstants.selfAssessments,
        queryParameters: {'subscriptionId': subscription.value!.id},
      );
      final raw = resp.data;
      if (raw['success'] == true && raw['data'] is List) {
        assessmentList.value = (raw['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(SelfAssessmentModel.fromJson)
            .toList();
      }
    } catch (e) {
      listError.value = e.toString();
    } finally {
      isLoadingList.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // CREATE
  // ──────────────────────────────────────────────────────────────────

  void toggleChapter(String chapterId) {
    if (selectedChapterIds.contains(chapterId)) {
      selectedChapterIds.remove(chapterId);
    } else {
      selectedChapterIds.add(chapterId);
    }
  }

  void setQuestionCount(int count) {
    numberOfQuestions.value = count.clamp(1, 10);
  }

  /// Returns chapters filtered by preSelectedSubject (or all chapters).
  List<ChapterInfo> get availableChapters {
    if (subscription.value == null) return [];
    final all = subscription.value!.chapters;
    final subj = preSelectedSubject.value;
    if (subj == null || subj.isEmpty) return all;
    return all.where((c) => c.subject.name == subj).toList();
  }

  Future<void> createAssessment() async {
    if (subscription.value == null) return;
    if (selectedChapterIds.isEmpty) {
      Get.snackbar(
        'Select chapters',
        'Please select at least one chapter.',
        backgroundColor: Colors.red[100],
      );
      return;
    }
    isCreating.value = true;
    try {
      final resp = await _api.post(
        ApiConstants.selfAssessments,
        data: {
          'subscriptionId': subscription.value!.id,
          'chapterIds': selectedChapterIds.toList(),
          'numberOfQuestions': numberOfQuestions.value,
        },
      );
      final raw = resp.data;
      if (raw['success'] == true && raw['data'] != null) {
        final created = SelfAssessmentModel.fromJson(
          raw['data'] as Map<String, dynamic>,
        );
        // Navigate straight into the attempt
        await loadAndAttempt(created.id);
        // Refresh list silently in background
        fetchList();
      } else {
        Get.snackbar(
          'Error',
          raw['message']?.toString() ?? 'Could not create assessment.',
          backgroundColor: Colors.red[100],
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red[100]);
    } finally {
      isCreating.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // ATTEMPT
  // ──────────────────────────────────────────────────────────────────

  Future<void> loadAndAttempt(String assessmentId) async {
    isLoadingDetail.value = true;
    currentDetail.value = null;
    answers.clear();
    currentQuestionIndex.value = 0;
    submitResult.value = null;
    try {
      final resp = await _api.get(
        ApiConstants.selfAssessmentById(assessmentId),
      );
      final raw = resp.data;
      if (raw['success'] == true && raw['data'] != null) {
        currentDetail.value = SelfAssessmentDetail.fromJson(
          raw['data'] as Map<String, dynamic>,
        );
        Get.toNamed('/self-assessment-attempt');
      } else {
        Get.snackbar(
          'Error',
          raw['message']?.toString() ?? 'Could not load assessment.',
          backgroundColor: Colors.red[100],
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red[100]);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void selectAnswer(String questionId, dynamic value) {
    answers[questionId] = value;
  }

  bool isAnswered(String questionId) => answers.containsKey(questionId);

  void nextQuestion() {
    final total = currentDetail.value?.questions.length ?? 0;
    if (currentQuestionIndex.value < total - 1) {
      currentQuestionIndex.value++;
    }
  }

  void prevQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToQuestion(int index) {
    currentQuestionIndex.value = index;
  }

  // ──────────────────────────────────────────────────────────────────
  // SUBMIT
  // ──────────────────────────────────────────────────────────────────

  Future<void> submitAttempt() async {
    if (currentDetail.value == null) return;
    isSubmitting.value = true;
    try {
      // Build the answers map expected by the backend:
      //   { "<questionId>": optionIndex_or_[indices] }
      final payload = <String, dynamic>{};
      for (final entry in answers.entries) {
        payload[entry.key] = entry.value;
      }

      final resp = await _api.post(
        ApiConstants.selfAssessmentSubmit(currentDetail.value!.id),
        data: {'answers': payload},
      );
      final raw = resp.data;
      if (raw['success'] == true && raw['data'] != null) {
        submitResult.value = SelfAssessmentSubmitResult.fromJson(
          raw['data'] as Map<String, dynamic>,
        );
        Get.toNamed('/self-assessment-result');
      } else {
        Get.snackbar(
          'Error',
          raw['message']?.toString() ?? 'Submission failed.',
          backgroundColor: Colors.red[100],
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red[100]);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────

  void resetCreate() {
    selectedChapterIds.clear();
    numberOfQuestions.value = 5;
  }

  Color scoreColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String scoreLabel(double percentage) {
    if (percentage >= 80) return 'Excellent!';
    if (percentage >= 60) return 'Good Job!';
    if (percentage >= 40) return 'Keep Practicing';
    return 'Needs Improvement';
  }
}
