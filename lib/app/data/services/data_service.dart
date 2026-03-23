import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../models/board_model.dart';
import '../models/grade_model.dart';
import '../models/subject_model.dart';
import '../models/chapter_model.dart';
import '../models/subscription_model.dart';
import '../models/payment_history_model.dart';
import '../models/chapter_content_model.dart';
import '../models/chapter_resource_model.dart';
import '../models/exercise_model.dart';

class DataService {
  final ApiService _apiService = ApiService();

  // Fetch Boards
  Future<Map<String, dynamic>> fetchBoards({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _apiService.get(
        '/boards',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<BoardModel> boards = (response.data['data'] as List)
            .map((board) => BoardModel.fromJson(board))
            .toList();

        return {
          'success': true,
          'boards': boards,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch boards',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Fetch Grades
  Future<Map<String, dynamic>> fetchGrades({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _apiService.get(
        '/grades',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<GradeModel> grades = (response.data['data'] as List)
            .map((grade) => GradeModel.fromJson(grade))
            .toList();

        return {
          'success': true,
          'grades': grades,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch grades',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Fetch Public Grades (no auth required)
  Future<List<GradeModel>> fetchPublicGrades() async {
    try {
      final response = await _apiService.get('/grades/public');

      if (response.data['success'] == true) {
        final List<GradeModel> grades = (response.data['data'] as List)
            .map((grade) => GradeModel.fromJson(grade))
            .toList();
        return grades;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch grades');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fetch Public Boards (no auth required)
  Future<List<BoardModel>> fetchPublicBoards() async {
    try {
      final response = await _apiService.get('/boards/public');

      if (response.data['success'] == true) {
        final List<BoardModel> boards = (response.data['data'] as List)
            .map((board) => BoardModel.fromJson(board))
            .toList();
        return boards;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch boards');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fetch Subjects with pagination
  Future<Map<String, dynamic>> fetchSubjects({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _apiService.get(
        '/subjects',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<SubjectModel> subjects = (response.data['data'] as List)
            .map((subject) => SubjectModel.fromJson(subject))
            .toList();

        return {
          'success': true,
          'subjects': subjects,
          'pagination': response.data['pagination'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch subjects');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fetch Chapters for specific subjects
  Future<List<SubjectChapters>> fetchChaptersForSubjects(
    List<String> subjectIds,
  ) async {
    try {
      if (subjectIds.isEmpty) {
        return [];
      }

      final response = await _apiService.get(
        '/chapters/public/subjects',
        queryParameters: {'subjectIds': subjectIds.join(',')},
      );

      if (response.data['success'] == true) {
        final List<SubjectChapters> subjectChapters =
            (response.data['data'] as List)
                .map((item) => SubjectChapters.fromJson(item))
                .toList();
        return subjectChapters;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch chapters');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Create Subscription (legacy – kept for compatibility)
  Future<Map<String, dynamic>> createSubscription({
    required String packageId,
    required String packageType,
    required String boardId,
    required String gradeId,
    required List<String> subjectIds,
    required List<String> chapterIds,
    bool fakePayment = true,
  }) async {
    try {
      final response = await _apiService.post(
        '/subscriptions',
        data: {
          'packageId': packageId,
          'packageType': packageType,
          'boardId': boardId,
          'gradeId': gradeId,
          'subjectIds': subjectIds,
          'chapterIds': chapterIds,
          'fakePayment': fakePayment,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message':
              response.data['message'] ?? 'Subscription created successfully',
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to create subscription',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // ── Ottu Payment Gateway ─────────────────────────────────────────────────

  /// Calls backend to create a subscription (pending) + Ottu checkout session.
  /// Returns { success, checkoutUrl, sessionId, subscriptionId, amount }
  Future<Map<String, dynamic>> initiateOttuPayment({
    required String packageId,
    required String packageType,
    required String boardId,
    required String gradeId,
    required List<String> subjectIds,
    required List<String> chapterIds,
  }) async {
    try {
      final response = await _apiService.post(
        '/payment/ottu/initiate',
        data: {
          'packageId': packageId,
          'packageType': packageType,
          'boardId': boardId,
          'gradeId': gradeId,
          'subjectIds': subjectIds,
          'chapterIds': chapterIds,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'success': true,
          'checkoutUrl': data['checkoutUrl'] as String,
          'sessionId': data['sessionId'] as String,
          'subscriptionId': data['subscriptionId'] as String,
          'amount': data['amount'],
          'message': response.data['message'] ?? 'Payment session created',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to initiate payment',
        };
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final message = (responseData is Map)
          ? (responseData['message'] ?? 'Network error occurred')
          : 'Network error occurred';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// Cancels/deletes a pending subscription when the user abandons payment.
  Future<void> cancelOttuPayment(String subscriptionId) async {
    try {
      await _apiService.delete('/payment/ottu/cancel/$subscriptionId');
    } catch (_) {
      // Non-critical – best-effort cleanup
    }
  }

  /// Polls the backend for the status of an Ottu payment session.
  /// Returns { success, paymentStatus, isActive, subscriptionId, subscription }
  Future<Map<String, dynamic>> getOttuPaymentStatus(String sessionId) async {
    try {
      final response = await _apiService.get('/payment/ottu/status/$sessionId');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'success': true,
          'paymentStatus': data['paymentStatus'],
          'isActive': data['isActive'],
          'subscriptionId': data['subscriptionId'],
          'subscription': data['subscription'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get payment status',
        };
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final message = (responseData is Map)
          ? (responseData['message'] ?? 'Network error occurred')
          : 'Network error occurred';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // Fetch User Subscriptions
  Future<List<SubscriptionModel>> fetchUserSubscriptions() async {
    try {
      final response = await _apiService.get('/subscriptions');

      if (response.data['success'] == true) {
        final List<SubscriptionModel> subscriptions =
            (response.data['data'] as List)
                .map((sub) => SubscriptionModel.fromJson(sub))
                .toList();
        return subscriptions;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch subscriptions',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fetch Payment History
  Future<List<PaymentHistoryModel>> fetchPaymentHistory() async {
    try {
      final response = await _apiService.get('/subscriptions/payments/my');

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Handle null or empty data
        if (data == null || (data is List && data.isEmpty)) {
          return [];
        }

        final List<PaymentHistoryModel> payments = (data as List)
            .map((payment) => PaymentHistoryModel.fromJson(payment))
            .toList();
        return payments;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch payment history',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fetch Chapter Contents (Videos)
  Future<List<ChapterContentModel>> fetchChapterContents(
    String chapterId,
  ) async {
    try {
      final response = await _apiService.get('/content/chapter/$chapterId');

      print('🌐 API Response for chapter contents:');
      print('   Success: ${response.data['success']}');
      print('   Data count: ${(response.data['data'] as List?)?.length ?? 0}');

      if ((response.data['data'] as List?)?.isNotEmpty == true) {
        final firstContent = response.data['data'][0];
        print('   First content title: ${firstContent['title']}');
        print(
          '   First content has assessment: ${firstContent['assessment'] != null}',
        );
        if (firstContent['assessment'] != null) {
          print('   Assessment data: ${firstContent['assessment']}');
        }
      }

      if (response.data['success'] == true) {
        final List<ChapterContentModel> contents =
            (response.data['data'] as List)
                .map((content) => ChapterContentModel.fromJson(content))
                .toList();
        return contents;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch chapter contents',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fetch Chapter Resources (Documents)
  Future<List<ChapterResourceModel>> fetchChapterResources(
    String chapterId,
  ) async {
    try {
      final response = await _apiService.get('/resources/chapter/$chapterId');

      if (response.data['success'] == true) {
        final List<ChapterResourceModel> resources =
            (response.data['data'] as List)
                .map((resource) => ChapterResourceModel.fromJson(resource))
                .toList();
        return resources;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch chapter resources',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fetch Chapter Exercises
  Future<List<ExerciseModel>> fetchChapterExercises(String chapterId) async {
    try {
      final response = await _apiService.get(
        '/exercises/public/chapter/$chapterId',
      );

      if (response.data['success'] == true) {
        final List<ExerciseModel> exercises = (response.data['data'] as List)
            .map((exercise) => ExerciseModel.fromJson(exercise))
            .toList();
        return exercises;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch chapter exercises',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Fire-and-forget prefetch: warms the cache for chapter contents and
  /// resources so the VideoPlayer screen loads faster. Errors are silently
  /// swallowed because this is purely an optimisation.
  void prefetchChapterData(String chapterId) {
    fetchChapterContents(chapterId).catchError((_) {});
    fetchChapterResources(chapterId).catchError((_) {});
    fetchChapterExercises(chapterId).catchError((_) {});
  }

  // Submit Assessment Answers
  Future<Map<String, dynamic>> submitAssessment({
    required String assessmentId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      print('🌐 API Call: POST /assessments/$assessmentId/submit');
      print('📦 Request body: ${{'answers': answers}}');

      final response = await _apiService.post(
        '/assessments/$assessmentId/submit',
        data: {'answers': answers},
      );

      print('📥 Response: ${response.data}');

      if (response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to submit assessment',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // Mark video as complete
  Future<Map<String, dynamic>> markVideoComplete(
    String chapterId,
    Map<String, dynamic> data,
  ) async {
    try {
      print('🌐 API Call: POST /progress/chapter/$chapterId/video-complete');
      print('📦 Request body: $data');

      final response = await _apiService.post(
        '/progress/chapter/$chapterId/video-complete',
        data: data,
      );

      print('📥 Response: ${response.data}');

      if (response.data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to mark video as complete',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // Fetch student progress
  Future<Map<String, dynamic>> fetchStudentProgress() async {
    try {
      print('🌐 API Call: GET /progress/me');

      final response = await _apiService.get('/progress/me');

      print('📥 Response: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch student progress',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Record exercise completion on submit
  Future<Map<String, dynamic>> recordExerciseSubmission({
    required String exerciseId,
    required String chapterId,
    required int obtainedMarks,
    required int totalMarks,
    required double percentage,
    String? subscriptionId,
  }) async {
    try {
      final payload = {
        'chapterId': chapterId,
        'obtainedMarks': obtainedMarks,
        'totalMarks': totalMarks,
        'percentage': percentage,
        if (subscriptionId != null && subscriptionId.isNotEmpty)
          'subscriptionId': subscriptionId,
      };

      print('🌐 API Call: POST /progress/exercise/$exerciseId/score');
      print('📦 Request body: $payload');

      final response = await _apiService.post(
        '/progress/exercise/$exerciseId/score',
        data: payload,
      );

      print('📥 Response: ${response.data}');

      if (response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to submit exercise',
      };
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // AI Assistant - Ask Question
  Future<Map<String, dynamic>> askAIQuestion({
    required String contentId,
    required String question,
    required List<Map<String, String>> conversationHistory,
  }) async {
    try {
      print('🤖 AI API Call: POST /ai/chat');
      print('📝 Question: $question');

      final response = await _apiService.post(
        '/ai/chat',
        data: {
          'contentId': contentId,
          'question': question,
          'conversationHistory': conversationHistory,
        },
      );

      print('📥 AI Response: ${response.data}');

      if (response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get AI response',
        };
      }
    } on DioException catch (e) {
      print('❌ AI DioException: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('❌ AI Exception: $e');
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }
}
