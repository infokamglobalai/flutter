import 'package:get/get.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class PublicAssessmentsController extends GetxController {
  final DataService _data = Get.find<DataService>();

  // Filters / context (optional)
  final chapterId = ''.obs;
  final subscriptionId = ''.obs;

  // List state
  final isLoading = false.obs;
  final error = ''.obs;
  final assessments = <Map<String, dynamic>>[].obs;

  // Paging
  final page = 1.obs;
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      chapterId.value = (args['chapterId'] ?? '').toString();
      subscriptionId.value = (args['subscriptionId'] ?? '').toString();
    }
    load(refresh: true);
  }

  Future<void> load({bool refresh = false}) async {
    if (isLoading.value) return;
    if (!refresh && !hasMore.value) return;

    isLoading.value = true;
    error.value = '';
    try {
      final nextPage = refresh ? 1 : page.value + 1;
      final res = await _data.fetchPublicAssessments(
        page: nextPage,
        limit: 20,
        chapterId: chapterId.value.isEmpty ? null : chapterId.value,
      );

      if (res['success'] == true) {
        final list = (res['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        if (refresh) {
          assessments.assignAll(list);
          page.value = 1;
        } else {
          assessments.addAll(list);
          page.value = nextPage;
        }
        final pagination = res['pagination'] as Map<String, dynamic>?;
        final totalPages = (pagination?['pages'] as num?)?.toInt();
        if (totalPages != null) {
          hasMore.value = page.value < totalPages;
        } else {
          hasMore.value = list.isNotEmpty;
        }
      } else {
        error.value = (res['message'] ?? 'Failed to load assessments').toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void openAssessment(Map<String, dynamic> assessment) {
    Get.toNamed(
      Routes.PUBLIC_ASSESSMENT_ATTEMPT,
      arguments: {
        'assessment': assessment,
        'chapterId': chapterId.value,
        'subscriptionId': subscriptionId.value,
      },
    );
  }
}

