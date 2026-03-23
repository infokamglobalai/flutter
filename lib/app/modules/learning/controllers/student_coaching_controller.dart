import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/data/services/coaching_service.dart';

class StudentCoachingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final CoachingService _coachingService = CoachingService();

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final requests = <Map<String, dynamic>>[].obs;
  final availableSlots = <Map<String, dynamic>>[].obs;
  final sessions = <Map<String, dynamic>>[].obs;

  final subscriptions = <Map<String, dynamic>>[].obs;
  final subjects = <Map<String, dynamic>>[].obs;
  final chapters = <Map<String, dynamic>>[].obs;

  final selectedSubjectId = RxnString();
  final selectedChapterId = RxnString();

  final requestMessageController = TextEditingController();
  final preferredScheduleController = TextEditingController();
  final contactNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSubscriptions();
    loadDashboard();
  }

  @override
  void onClose() {
    requestMessageController.dispose();
    preferredScheduleController.dispose();
    contactNumberController.dispose();
    super.onClose();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final response = await _apiService.get('/subscriptions');
      if (response.data['success'] == true) {
        final subs = List<Map<String, dynamic>>.from(
          response.data['data'] as List,
        );
        subscriptions.value = subs;

        final subjectMap = <String, Map<String, dynamic>>{};
        for (final sub in subs) {
          final subSubjects = sub['subjects'] as List<dynamic>? ?? [];
          for (final raw in subSubjects) {
            final subject = Map<String, dynamic>.from(raw as Map);
            final id = subject['_id']?.toString() ?? '';
            if (id.isEmpty) continue;
            subjectMap[id] = {
              '_id': id,
              'name': subject['name']?.toString() ?? 'Subject',
            };
          }
        }
        subjects.value = subjectMap.values.toList();
      }
    } catch (_) {}
  }

  void onSubjectChanged(String? subjectId) {
    selectedSubjectId.value = subjectId;
    selectedChapterId.value = null;

    if (subjectId == null || subjectId.isEmpty) {
      chapters.clear();
      return;
    }

    final chapterMap = <String, Map<String, dynamic>>{};
    for (final sub in subscriptions) {
      final subChapters = sub['chapters'] as List<dynamic>? ?? [];
      for (final raw in subChapters) {
        final chapter = Map<String, dynamic>.from(raw as Map);
        final chapterSubject = chapter['subject'];
        final chapterSubjectId = chapterSubject is Map
            ? chapterSubject['_id']?.toString()
            : chapterSubject?.toString();

        if (chapterSubjectId != subjectId) continue;

        final chapterId = chapter['_id']?.toString() ?? '';
        if (chapterId.isEmpty) continue;

        chapterMap[chapterId] = {
          '_id': chapterId,
          'name': chapter['name']?.toString() ?? 'Chapter',
        };
      }
    }
    chapters.value = chapterMap.values.toList();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final result = await _coachingService.getStudentDashboard();
      if (result['success'] == true) {
        final data = Map<String, dynamic>.from(result['data'] as Map);

        requests.value = (data['requests'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .map((item) {
              item['createdAt'] =
                  DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
                  DateTime.now();
              if (item['responseTimestamp'] != null) {
                item['responseTimestamp'] =
                    DateTime.tryParse(item['responseTimestamp'].toString()) ??
                    DateTime.now();
              }
              return item;
            })
            .toList();

        availableSlots.value = (data['availableSlots'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .map((item) {
              item['date'] =
                  DateTime.tryParse(item['date']?.toString() ?? '') ??
                  DateTime.now();
              return item;
            })
            .toList();

        sessions.value = (data['sessions'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .map((item) {
              item['date'] =
                  DateTime.tryParse(item['date']?.toString() ?? '') ??
                  DateTime.now();
              return item;
            })
            .toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get acceptedRequests => requests
      .where((request) => (request['status']?.toString() ?? '') == 'accepted')
      .toList();

  Future<void> submitRequest() async {
    if (selectedSubjectId.value == null) {
      Get.snackbar('Error', 'Please select a subject');
      return;
    }
    if (requestMessageController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your request');
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await _coachingService.createRequest(
        subjectId: selectedSubjectId.value!,
        chapterId: selectedChapterId.value,
        requestMessage: requestMessageController.text.trim(),
        preferredSchedule: preferredScheduleController.text.trim(),
        contactNumber: contactNumberController.text.trim(),
      );

      if (result['success'] == true) {
        requestMessageController.clear();
        preferredScheduleController.clear();
        contactNumberController.clear();
        selectedSubjectId.value = null;
        selectedChapterId.value = null;
        chapters.clear();
        await loadDashboard();
        Get.snackbar(
          'Success',
          result['message']?.toString() ?? 'Request sent',
        );
      } else {
        Get.snackbar('Error', result['message']?.toString() ?? 'Failed');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> bookSlot(Map<String, dynamic> slot) async {
    final mappedRequestId = slot['requestIdForBooking']?.toString() ?? '';

    final mentorId = slot['mentorId']?.toString() ?? '';
    String fallbackRequestId = '';
    if (mentorId.isNotEmpty) {
      final requestsList = acceptedRequests;
      final requestIndex = requestsList.indexWhere(
        (request) => (request['mentorId']?.toString() ?? '') == mentorId,
      );
      if (requestIndex != -1) {
        fallbackRequestId = requestsList[requestIndex]['id']?.toString() ?? '';
      }
    }

    final requestId = mappedRequestId.isNotEmpty
        ? mappedRequestId
        : fallbackRequestId;

    final result = await _coachingService.bookSession(
      slotId: slot['id'].toString(),
      requestId: requestId,
    );

    if (result['success'] == true) {
      await loadDashboard();
      Get.snackbar(
        'Booked!',
        result['message']?.toString() ?? 'Session booked',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar('Error', result['message']?.toString() ?? 'Failed to book');
    }
  }

  Future<void> cancelSession(String sessionId) async {
    if (sessionId.isEmpty) return;
    try {
      final result = await _coachingService.cancelStudentSession(sessionId);
      if (result['success'] == true) {
        await loadDashboard();
        Get.snackbar(
          'Cancelled',
          result['message']?.toString() ?? 'Session cancelled',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar(
          'Error',
          result['message']?.toString() ?? 'Failed to cancel',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
