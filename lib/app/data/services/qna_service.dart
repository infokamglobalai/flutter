import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/data/models/qna_model.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';

class QnaService {
  final ApiService _api = Get.find<ApiService>();

  // ─── Student ──────────────────────────────────────────────────────────────

  /// Returns all QnA threads for the logged-in student.
  Future<Map<String, dynamic>> getStudentThreads() async {
    try {
      final resp = await _api.get(ApiConstants.qnaThreads);
      if (resp.data['success'] == true) {
        final list = (resp.data['data'] as List<dynamic>)
            .map((e) => QnaThread.fromJson(e as Map<String, dynamic>))
            .toList();
        return {'success': true, 'threads': list};
      }
      return {'success': false, 'message': resp.data['message'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Returns a single QnA thread by chapter + subscription ID.
  Future<Map<String, dynamic>> getQnaThread({
    required String chapterId,
    required String packageId,
  }) async {
    try {
      final resp = await _api.get(
        ApiConstants.qnaGetThread,
        queryParameters: {'chapterId': chapterId, 'packageId': packageId},
      );
      if (resp.data['success'] == true) {
        final raw = resp.data['data'];
        if (raw == null) {
          return {'success': true, 'thread': null};
        }
        return {
          'success': true,
          'thread': QnaThread.fromJson(raw as Map<String, dynamic>),
        };
      }
      return {'success': false, 'message': resp.data['message'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Student asks a question in a thread.
  Future<Map<String, dynamic>> askQuestion({
    required String chapterId,
    required String packageId,
    required String questionText,
  }) async {
    try {
      final resp = await _api.post(
        ApiConstants.qnaAskQuestion,
        data: {
          'chapterId': chapterId,
          'packageId': packageId,
          'questionText': questionText,
        },
      );
      if (resp.data['success'] == true) {
        final thread = QnaThread.fromJson(
          resp.data['data'] as Map<String, dynamic>,
        );
        return {'success': true, 'thread': thread};
      }
      return {'success': false, 'message': resp.data['message'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Mentor ───────────────────────────────────────────────────────────────

  /// Returns all QnA threads from students assigned to this mentor.
  Future<Map<String, dynamic>> getMentorThreads() async {
    try {
      final resp = await _api.get('/qna/mentor/threads');
      if (resp.data['success'] == true) {
        final list = (resp.data['data'] as List<dynamic>)
            .map((e) => QnaThread.fromJson(e as Map<String, dynamic>))
            .toList();
        return {'success': true, 'threads': list};
      }
      return {'success': false, 'message': resp.data['message'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Mentor answers a specific item inside a thread.
  Future<Map<String, dynamic>> answerItem({
    required String threadId,
    required String itemId,
    required String answerText,
  }) async {
    try {
      final resp = await _api.post(
        '/qna/mentor/threads/$threadId/items/$itemId/answer',
        data: {'answerText': answerText},
      );
      if (resp.data['success'] == true) {
        final thread = QnaThread.fromJson(
          resp.data['data'] as Map<String, dynamic>,
        );
        return {'success': true, 'thread': thread};
      }
      return {'success': false, 'message': resp.data['message'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
