import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../data/models/qna_model.dart';
import '../../../data/models/doubt_model.dart';
import '../../../data/services/qna_service.dart';
import '../../../data/services/doubt_service.dart';
import '../../../core/services/api_service.dart';

class MentorChatController extends GetxController {
  final QnaService _qnaService = QnaService();
  final ApiService _apiService = ApiService();
  final DoubtService _doubtService = DoubtService();

  final threads = <QnaThread>[].obs;
  final subscriptions = <Map<String, dynamic>>[].obs;
  final subjects = <Map<String, dynamic>>[].obs;
  final chapters = <Map<String, dynamic>>[].obs;
  final selectedSubscriptionId = Rxn<String>();
  final isLoading = false.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadThreads();
    loadSubscriptions();
  }

  Future<void> loadThreads() async {
    try {
      isLoading.value = true;
      final result = await _qnaService.getStudentThreads();
      if (result['success'] == true) {
        threads.value = List<QnaThread>.from(result['threads'] as List);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubscriptions() async {
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
          for (final s in subSubjects) {
            final id = (s as Map)['_id']?.toString() ?? '';
            if (id.isNotEmpty) subjectMap[id] = Map<String, dynamic>.from(s);
          }
        }
        subjects.value = subjectMap.values.toList();
      }
    } on DioException catch (_) {
    } catch (_) {}
  }

  void loadChapters(String subjectId) {
    final chapterMap = <String, Map<String, dynamic>>{};
    selectedSubscriptionId.value = null;
    for (final sub in subscriptions) {
      final chaps = sub['chapters'] as List<dynamic>? ?? [];
      for (final ch in chaps) {
        final c = ch as Map;
        final chapSubjectId = (c['subject'] is Map)
            ? (c['subject'] as Map)['_id']?.toString()
            : c['subject']?.toString();
        if (chapSubjectId == subjectId) {
          final id = c['_id']?.toString() ?? '';
          if (id.isNotEmpty && !chapterMap.containsKey(id)) {
            chapterMap[id] = {
              '_id': id,
              'name': c['name'],
              'subscriptionId': sub['_id']?.toString() ?? '',
            };
          }
        }
      }
    }
    chapters.value = chapterMap.values.toList();
  }

  void onChapterSelected(Map<String, dynamic> chapter) {
    selectedSubscriptionId.value = chapter['subscriptionId']?.toString();
  }

  Future<QnaThread?> askQuestion({
    required String chapterId,
    required String questionText,
    String? overridePackageId,
  }) async {
    final packageId = overridePackageId ?? selectedSubscriptionId.value;
    if (packageId == null || packageId.isEmpty) {
      Get.snackbar(
        'Subscription Not Found',
        'Could not detect your subscription for this chapter.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
    if (questionText.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your question.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
    try {
      isSending.value = true;
      final result = await _qnaService.askQuestion(
        chapterId: chapterId,
        packageId: packageId,
        questionText: questionText.trim(),
      );
      if (result['success'] == true) {
        final updatedThread = result['thread'] as QnaThread;
        final idx = threads.indexWhere((t) => t.id == updatedThread.id);
        if (idx != -1) {
          threads[idx] = updatedThread;
        } else {
          threads.insert(0, updatedThread);
        }
        threads.refresh();
        return updatedThread;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to ask question',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to ask question',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isSending.value = false;
    }
  }

  Future<QnaThread?> reloadThread(String chapterId, String packageId) async {
    final result = await _qnaService.getQnaThread(
      chapterId: chapterId,
      packageId: packageId,
    );
    if (result['success'] == true) {
      final t = result['thread'] as QnaThread;
      final idx = threads.indexWhere((th) => th.id == t.id);
      if (idx != -1) {
        threads[idx] = t;
        threads.refresh();
      }
      return t;
    }
    return null;
  }

  List<QnaThread> get pendingThreads =>
      threads.where((t) => t.hasUnanswered).toList();
  List<QnaThread> get answeredThreads =>
      threads.where((t) => t.totalQuestions > 0 && !t.hasUnanswered).toList();

  // ─── Doubt/Ticket helpers (used by DoubtDetailView) ──────────────────────

  /// Fetch full doubt details (with responses) by ticket ID.
  Future<Doubt?> getDoubtDetails(String doubtId) async {
    try {
      final result = await _doubtService.getDoubtById(doubtId);
      if (result['success'] == true) {
        return result['doubt'] as Doubt;
      }
    } catch (_) {}
    return null;
  }

  /// Add a text response to a doubt ticket.
  Future<void> addResponse(String doubtId, String message) async {
    try {
      isLoading.value = true;
      final result = await _doubtService.addResponse(
        doubtId: doubtId,
        message: message,
      );
      if (result['success'] != true) {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to send reply',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to send reply',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns an icon for the given ticket status string.
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.radio_button_unchecked;
      case 'inprogress':
      case 'in_progress':
        return Icons.autorenew;
      case 'resolved':
        return Icons.check_circle_outline;
      case 'closed':
        return Icons.lock_outline;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns a human-readable label for the given ticket status string.
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'inprogress':
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }
}
