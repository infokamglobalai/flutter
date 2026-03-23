import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/core/services/fcm_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/data/models/mentor_profile_model.dart';
import 'package:najahapp/app/data/models/qna_model.dart';
import 'package:najahapp/app/data/services/qna_service.dart';
import 'package:najahapp/app/core/services/ticket_service.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';

class MentorDashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  final TicketService _ticketService = TicketService();
  final QnaService _qnaService = QnaService();
  // Mentor data
  final mentorName = ''.obs;
  final mentorEmail = ''.obs;
  final mentorId = ''.obs;

  // Mentor Profile
  final Rxn<MentorProfileModel> mentorProfile = Rxn<MentorProfileModel>();
  final isLoadingProfile = false.obs;

  // Assigned data
  final assignedBoards = <String>[].obs;
  final assignedGrades = <String>[].obs;
  final assignedSubjects = <String>[].obs;
  final isLoadingAssignments = false.obs;

  // Students data for reports
  final studentsData = <Map<String, dynamic>>[].obs;
  final isLoadingStudents = false.obs;
  final selectedBoard = RxnString();
  final selectedGrade = RxnString();
  final selectedSubject = RxnString();

  // Messages
  final messages = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;
  final isLoadingMessages = false.obs;

  // Questions from students (threaded Q&A)
  final studentQuestions = <Map<String, dynamic>>[].obs;
  final qnaThreads = <QnaThread>[].obs;
  final unansweredQuestionsCount = 0.obs;
  final isLoadingQuestions = false.obs;

  // Coaching requests
  final coachingRequests = <Map<String, dynamic>>[].obs;
  final pendingRequestsCount = 0.obs;
  final isLoadingRequests = false.obs;

  // Calendar Management
  final availableTimeSlots = <Map<String, dynamic>>[].obs;
  final bookedSessions = <Map<String, dynamic>>[].obs;
  final isLoadingCalendar = false.obs;
  final selectedDate = DateTime.now().obs;
  final calendarView = 'month'.obs; // 'day', 'week', 'month'
  final upcomingSessionsCount = 0.obs;

  // Exercise Reports
  final exerciseReports = <Map<String, dynamic>>[].obs;
  final isLoadingExerciseReports = false.obs;

  // Assessment Management
  final assessments = <Map<String, dynamic>>[].obs;
  final assessmentSubmissions = <Map<String, dynamic>>[].obs;
  final questionBank = <Map<String, dynamic>>[].obs;
  final isLoadingAssessments = false.obs;
  final isLoadingQuestionBank = false.obs;
  final isCreatingAssessment = false.obs;
  final selectedAssessmentBoard = RxnString();
  final selectedAssessmentGrade = RxnString();
  final selectedAssessmentSubject = RxnString();
  final selectedAssessmentChapter = RxnString();
  final selectedAssessmentChapterId = RxnString(); // actual MongoDB ID
  final selectedAssessmentBoardId = RxnString(); // board MongoDB ID
  final selectedAssessmentGradeId = RxnString(); // grade MongoDB ID
  final selectedAssessmentSubjectId = RxnString(); // subject MongoDB ID
  final selectedQuestions = <String>[].obs;
  final pendingSubmissionsCount = 0.obs;

  // Question bank chapters loaded from API
  final questionBankAllChapters = <Map<String, dynamic>>[].obs; // all chapters
  final isLoadingChapters = false.obs;

  // Announcements/Notifications
  final announcements = <Map<String, dynamic>>[].obs;
  final isLoadingAnnouncements = false.obs;
  final isSendingAnnouncement = false.obs;

  // Announcement audio recording / picking
  final isRecordingAudio = false.obs;
  final audioDuration = 0.obs; // recording seconds
  final recordedAudioPath = RxnString();
  final pickedAudioPath = RxnString();
  final pickedAudioFileName = RxnString();
  AudioRecorder? _audioRecorder;
  Timer? _audioRecordingTimer;

  String? get announcementAudioPath =>
      recordedAudioPath.value ?? pickedAudioPath.value;
  String? get announcementAudioFileName {
    if (recordedAudioPath.value != null) {
      final m = audioDuration.value ~/ 60;
      final s = audioDuration.value % 60;
      return 'Voice Note (${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')})';
    }
    return pickedAudioFileName.value;
  }

  // Feedback & Ratings
  final videoFeedbacks = <Map<String, dynamic>>[].obs;
  final videoRatings = <Map<String, dynamic>>[].obs;
  final topVideos = <Map<String, dynamic>>[].obs;
  final isLoadingFeedbacks = false.obs;
  final selectedTopCount = 10.obs; // 10, 50, 100
  final selectedChartType = 'bar'.obs; // 'bar' or 'pie'
  final averageRating = 0.0.obs;
  final totalFeedbacks = 0.obs;

  // Support Tickets
  final supportTickets = <Ticket>[].obs;
  final isLoadingTickets = false.obs;
  final openTicketsCount = 0.obs;
  final inProgressTicketsCount = 0.obs;
  final resolvedTicketsCount = 0.obs;

  // Selected tab (0-9: Overview, Reports, Messages, Q&A, Coaching, Calendar, Assessments, Announcements, Feedbacks, Support)
  final selectedTab = 0.obs;

  // Total actionable notification count shown on the bell badge
  final notificationCount = 0.obs;

  // ── Baseline snapshots for delta-based push triggers ─────────────────────
  // These are set on the very first load and updated after each poll.
  // A local push is fired only when a value INCREASES vs the last known value.
  bool _baselineSet = false;
  int _prevUnread          = 0;
  int _prevQna             = 0;
  int _prevCoaching        = 0;
  int _prevImminent        = 0; // sessions starting < 1 h
  int _prevPendingSubmit   = 0;
  int _prevUnrepliedFeedback = 0;
  int _prevLowRated        = 0;
  int _prevOpenTickets     = 0;

  // Polling timer — fires every 60 s while the mentor dashboard is open
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 60);

  // Message input
  final messageText = ''.obs;
  final isSendingMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMentorData();
    loadMentorProfile();
    _loadAssignments();
    // Initial load — sets baselines, no push fired
    _initialLoad();
    // Re-compute badge count whenever any reactive list changes
    ever(messages,              (_) => computeNotifications());
    ever(qnaThreads,            (_) => computeNotifications());
    ever(coachingRequests,      (_) => computeNotifications());
    ever(bookedSessions,        (_) => computeNotifications());
    ever(assessmentSubmissions, (_) => computeNotifications());
    ever(videoFeedbacks,        (_) => computeNotifications());
    ever(videoRatings,          (_) => computeNotifications());
    ever(supportTickets,        (_) => computeNotifications());
    ever(announcements,         (_) => computeNotifications());
    // Start background polling — only fires push on delta
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollAndNotify());
  }

  /// Returns true only when the ApiService has a valid cached auth token.
  bool get _hasValidToken => _apiService.hasToken;

  /// First load: populates all data and records the baseline snapshot.
  /// No push notifications are fired here.
  Future<void> _initialLoad() async {
    if (!_hasValidToken) {
      debugPrint('⏭️  MentorDashboard: skipping initial load — no auth token');
      return;
    }
    await Future.wait([
      _loadMessages(),
      loadMentorQnaThreads(),
      _loadCoachingRequests(),
      _loadCalendarData(),
      _loadAssessments(),
      _loadAllChapters(),
      _loadAnnouncements(),
      _loadFeedbacksAndRatings(),
      _loadSupportTickets(),
    ]);
    _captureBaseline();
  }

  /// Capture the current state as the baseline — subsequent polls compare against this.
  void _captureBaseline() {
    _prevUnread           = messages.where((m) => m['read'] == false).length;
    _prevQna              = qnaThreads.where((t) => t.hasUnanswered).length +
                            studentQuestions.where((q) => q['answered'] == false).length;
    _prevCoaching         = coachingRequests.where((r) => r['status'] == 'pending').length;
    _prevImminent         = _imminentSessionCount();
    _prevPendingSubmit    = pendingSubmissionsCount.value;
    _prevUnrepliedFeedback = _unrepliedFeedbackCount();
    _prevLowRated         = _lowRatedCount();
    _prevOpenTickets      = openTicketsCount.value;
    _baselineSet          = true;
  }

  /// Poll all data sources and fire local push notifications only for NEW events
  /// (i.e., counts that grew since the last snapshot).
  Future<void> _pollAndNotify() async {
    if (!_baselineSet) return; // safety guard during first load
    if (!_hasValidToken) {
      debugPrint('⏭️  MentorDashboard: skipping poll — no auth token');
      return;
    }
    await Future.wait([
      _loadMessages(),
      loadMentorQnaThreads(),
      _loadCoachingRequests(),
      _loadCalendarData(),
      _loadAssessments(),
      _loadAnnouncements(),
      _loadFeedbacksAndRatings(),
      _loadSupportTickets(),
    ]);

    // ── Compare new counts vs previous baseline ─────────────────────────
    final newUnread    = messages.where((m) => m['read'] == false).length;
    final newQna       = qnaThreads.where((t) => t.hasUnanswered).length +
                         studentQuestions.where((q) => q['answered'] == false).length;
    final newCoaching  = coachingRequests.where((r) => r['status'] == 'pending').length;
    final newImminent  = _imminentSessionCount();
    final newSubmit    = pendingSubmissionsCount.value;
    final newFeedback  = _unrepliedFeedbackCount();
    final newLowRated  = _lowRatedCount();
    final newTickets   = openTicketsCount.value;

    // Only fire when count INCREASED (new backend event arrived)
    if (newUnread    > _prevUnread)           _triggerMessagePush(newUnread - _prevUnread);
    if (newQna       > _prevQna)              _triggerQnaPush(newQna - _prevQna);
    if (newCoaching  > _prevCoaching)         _triggerCoachingPush(newCoaching - _prevCoaching);
    if (newImminent  > _prevImminent)         _triggerSessionReminderPush(newImminent);
    if (newSubmit    > _prevPendingSubmit)    _triggerAssessmentPush(newSubmit - _prevPendingSubmit);
    if (newFeedback  > _prevUnrepliedFeedback) _triggerFeedbackPush(newFeedback - _prevUnrepliedFeedback);
    if (newLowRated  > _prevLowRated)         _triggerLowRatedPushBatch(newLowRated - _prevLowRated);
    if (newTickets   > _prevOpenTickets)      _triggerTicketPush(newTickets - _prevOpenTickets);

    // Update baseline for next poll
    _prevUnread            = newUnread;
    _prevQna               = newQna;
    _prevCoaching          = newCoaching;
    _prevImminent          = newImminent;
    _prevPendingSubmit     = newSubmit;
    _prevUnrepliedFeedback = newFeedback;
    _prevLowRated          = newLowRated;
    _prevOpenTickets       = newTickets;
  }

  // ── Helpers for snapshot counting ────────────────────────────────────────

  int _imminentSessionCount() {
    int count = 0;
    for (final s in bookedSessions) {
      final st = s['dateTime'] is DateTime
          ? s['dateTime'] as DateTime
          : (s['date'] is DateTime ? s['date'] as DateTime : DateTime.now());
      final diff = st.difference(DateTime.now());
      if (diff.inMinutes > 0 && diff.inMinutes <= 60) count++;
    }
    return count;
  }

  int _unrepliedFeedbackCount() => videoFeedbacks
      .where((fb) =>
          (fb['mentorReply']?.toString() ?? '').isEmpty &&
          (fb['feedback']?.toString() ?? '').isNotEmpty)
      .length;

  int _lowRatedCount() => videoRatings
      .where((v) =>
          (v['averageRating'] as double? ?? 5.0) < 3.5 &&
          (v['totalRatings'] as int? ?? 0) >= 3)
      .length;

  @override
  void onClose() {
    _pollTimer?.cancel();
    _audioRecordingTimer?.cancel();
    _audioRecorder?.dispose();
    super.onClose();
  }

  Future<void> logout() async {
    try {
      // Best-effort API logout — ignore any errors
      await _apiService.post('/auth/logout');
    } catch (_) {
      // Ignore — always proceed with local logout
    } finally {
      await _storageService.clearAuth();
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> loadMentorProfile() async {
    isLoadingProfile.value = true;
    try {
      final response = await _apiService.get(ApiConstants.mentorProfile);

      if (response.data['success'] == true) {
        mentorProfile.value = MentorProfileModel.fromJson(
          response.data['data'],
        );

        // Update basic mentor data
        mentorName.value = mentorProfile.value!.fullName;
        mentorEmail.value = mentorProfile.value!.email;
        mentorId.value = mentorProfile.value!.id;

        Get.snackbar(
          'Success',
          'Profile loaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void _loadMentorData() {
    final userData = _storageService.getUserData();
    if (userData != null) {
      mentorName.value =
          '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
      mentorEmail.value = userData['email'] ?? '';
      mentorId.value = userData['_id'] ?? userData['id'] ?? '';
    }
  }

  Future<void> _loadAssignments() async {
    isLoadingAssignments.value = true;
    try {
      // Simulate API call - Replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - Replace with actual API response
      assignedBoards.value = ['CBSE', 'ICSE'];
      assignedGrades.value = ['Grade 8', 'Grade 9', 'Grade 10'];
      assignedSubjects.value = [
        'Mathematics',
        'Science',
        'Physics',
        'Chemistry',
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load assignments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingAssignments.value = false;
    }
  }

  Future<void> loadStudentReports() async {
    isLoadingStudents.value = true;
    try {
      final response = await _apiService.get(
        ApiConstants.mentorExerciseProgressReport,
        queryParameters: _buildReportQueryParameters(),
      );

      if (response.data['success'] == true) {
        final List<dynamic> rawRows = response.data['data'] as List<dynamic>;

        final normalizedRows = rawRows
            .map(
              (row) => {
                'board': row['board'] ?? '',
                'grade': row['grade'] ?? '',
                'studentName': row['studentName'] ?? '',
                'studentId': row['studentId'] ?? '',
                'subject': row['subject'] ?? '',
                'chapter': row['chapter'] ?? '',
                'videoCompleted': row['videoCompleted'] == true,
                'assessmentCompleted':
                    row['assessmentCompleted'] == true ||
                    row['assessmentsCompleted'] == true,
                'assessmentPercentage':
                    (row['assessmentPercentage'] as num?)?.toDouble() ?? 0.0,
                'exerciseAttempted': row['exerciseCompleted'] == true,
                'totalChapters': row['totalChapters'] ?? 0,
                'videosCompleted': row['videosCompleted'] ?? 0,
                'exercisesCompleted': row['exercisesCompleted'] ?? 0,
              },
            )
            .toList();

        final uniqueRows = <String, Map<String, dynamic>>{};
        for (final row in normalizedRows) {
          final key = '${row['studentId']}|${row['subject']}|${row['chapter']}';

          if (!uniqueRows.containsKey(key)) {
            uniqueRows[key] = Map<String, dynamic>.from(row);
            continue;
          }

          final existing = uniqueRows[key]!;
          existing['videoCompleted'] =
              (existing['videoCompleted'] == true) ||
              (row['videoCompleted'] == true);
            existing['assessmentCompleted'] =
              (existing['assessmentCompleted'] == true) ||
              (row['assessmentCompleted'] == true);
            existing['assessmentPercentage'] =
              ((existing['assessmentPercentage'] as double) >
                (row['assessmentPercentage'] as double))
              ? existing['assessmentPercentage']
              : row['assessmentPercentage'];
          existing['exerciseAttempted'] =
              (existing['exerciseAttempted'] == true) ||
              (row['exerciseAttempted'] == true);
          existing['totalChapters'] =
              (existing['totalChapters'] as int) > (row['totalChapters'] as int)
              ? existing['totalChapters']
              : row['totalChapters'];
          existing['videosCompleted'] =
              (existing['videosCompleted'] as int) >
                  (row['videosCompleted'] as int)
              ? existing['videosCompleted']
              : row['videosCompleted'];
          existing['exercisesCompleted'] =
              (existing['exercisesCompleted'] as int) >
                  (row['exercisesCompleted'] as int)
              ? existing['exercisesCompleted']
              : row['exercisesCompleted'];
        }

        studentsData.value = uniqueRows.values.toList();

        final filters =
            response.data['meta']?['filters'] as Map<String, dynamic>?;
        if (filters != null) {
          assignedBoards.value = (filters['boards'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toSet()
              .toList();
          assignedGrades.value = (filters['grades'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toSet()
              .toList();
          assignedSubjects.value = (filters['subjects'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toSet()
              .toList();
        }
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load student reports',
        );
      }
    } catch (e) {
      studentsData.clear();
      Get.snackbar(
        'Error',
        'Failed to load student reports: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingStudents.value = false;
    }
  }

  Future<void> _loadMessages() async {
    isLoadingMessages.value = true;
    try {
      // Primary source: dedicated mentor messaging endpoint
      try {
        final response = await _apiService.get(
          ApiConstants.mentorMessages,
          queryParameters: {'limit': 100},
        );

        if (response.data['success'] == true) {
          final raw = (response.data['data'] as List<dynamic>? ?? []);
          messages.value = raw.map((m) {
            final item = Map<String, dynamic>.from(m as Map);
            return {
              'id': item['id']?.toString() ?? item['_id']?.toString() ?? '',
              'from':
                  item['fromName']?.toString() ??
                  item['senderName']?.toString() ??
                  item['from']?.toString() ??
                  'User',
              'fromId':
                  item['fromId']?.toString() ??
                  item['senderId']?.toString() ??
                  item['sender']?.toString() ??
                  '',
              'to':
                  item['toName']?.toString() ??
                  item['recipientName']?.toString() ??
                  item['to']?.toString(),
              'toId':
                  item['toId']?.toString() ??
                  item['recipientId']?.toString() ??
                  item['recipient']?.toString(),
              'message':
                  item['message']?.toString() ??
                  item['text']?.toString() ??
                  '',
              'timestamp':
                  DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
                  DateTime.tryParse(item['timestamp']?.toString() ?? '') ??
                  DateTime.now(),
              'read': item['read'] == true || item['isRead'] == true,
              'type': item['isSent'] == true || item['type'] == 'sent'
                  ? 'sent'
                  : 'received',
            };
          }).toList();
        }
      } catch (_) {
        // Fallback source: notifications feed (mentor_message)
        final response = await _apiService.get(
          ApiConstants.notifications,
          queryParameters: {'type': 'mentor_message', 'limit': 100},
        );

        if (response.data['success'] == true) {
          final payload = response.data['data'] as Map<String, dynamic>? ?? {};
          final raw =
              payload['notifications'] as List<dynamic>? ?? <dynamic>[];
          messages.value = raw.map((n) {
            final item = Map<String, dynamic>.from(n as Map);
            final metadata =
                (item['metadata'] as Map<String, dynamic>?) ??
                <String, dynamic>{};
            return {
              'id': item['_id']?.toString() ?? '',
              'from': metadata['senderName']?.toString() ?? 'User',
              'fromId': metadata['senderId']?.toString() ?? '',
              'message': item['message']?.toString() ?? '',
              'timestamp':
                  DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
                  DateTime.now(),
              'read': item['isRead'] == true,
              'type': 'received',
            };
          }).toList();
        }
      }

      messages.sort(
        (a, b) => (b['timestamp'] as DateTime).compareTo(
          a['timestamp'] as DateTime,
        ),
      );

      unreadCount.value = messages.where((m) => m['read'] == false).length;
    } catch (e) {
      messages.clear();
      unreadCount.value = 0;
      Get.snackbar(
        'Error',
        'Failed to load messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // ─── QnA Thread management ──────────────────────────────────────────────────

  Future<void> loadMentorQnaThreads() async {
    isLoadingQuestions.value = true;
    try {
      final result = await _qnaService.getMentorThreads();
      if (result['success'] == true) {
        qnaThreads.value = List<QnaThread>.from(result['threads'] as List);
        unansweredQuestionsCount.value = qnaThreads
            .where((t) => t.hasUnanswered)
            .length;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load student questions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingQuestions.value = false;
    }
  }

  /// Called from [MentorQnaChatView] after a reply is sent, to keep the list in sync.
  void updateQnaThread(QnaThread updated) {
    final idx = qnaThreads.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      qnaThreads[idx] = updated;
      qnaThreads.refresh();
      unansweredQuestionsCount.value = qnaThreads
          .where((t) => t.hasUnanswered)
          .length;
    }
  }

  // Legacy mock (kept for backward compat — now unused)
  Future<void> _loadStudentQuestions() => loadMentorQnaThreads();

  void selectTab(int index) {
    selectedTab.value = index;
    if (index == 1 && studentsData.isEmpty) {
      loadStudentReports();
    }
  }

  void applyFilters() {
    loadStudentReports();
  }

  void clearFilters() {
    selectedBoard.value = null;
    selectedGrade.value = null;
    selectedSubject.value = null;
    loadStudentReports();
  }

  List<Map<String, dynamic>> get filteredStudents {
    var filtered = studentsData.toList();

    if (selectedBoard.value != null) {
      filtered = filtered
          .where((s) => s['board'] == selectedBoard.value)
          .toList();
    }
    if (selectedGrade.value != null) {
      filtered = filtered
          .where((s) => s['grade'] == selectedGrade.value)
          .toList();
    }
    if (selectedSubject.value != null) {
      filtered = filtered
          .where((s) => s['subject'] == selectedSubject.value)
          .toList();
    }

    final uniqueFiltered = <String, Map<String, dynamic>>{};
    for (final row in filtered) {
      final key = '${row['studentId']}|${row['subject']}|${row['chapter']}';
      uniqueFiltered[key] = row;
    }

    return uniqueFiltered.values.toList();
  }

  // Get exercise summary by student
  Map<String, dynamic> getStudentExerciseSummary(String studentId) {
    final studentRows = studentsData
        .where((s) => s['studentId'] == studentId)
        .toList();

    if (studentRows.isEmpty) {
      return {};
    }

    final uniqueChapterRows = <String, Map<String, dynamic>>{};
    for (final row in studentRows) {
      final key = '${row['subject']}|${row['chapter']}';
      if (!uniqueChapterRows.containsKey(key)) {
        uniqueChapterRows[key] = row;
      } else {
        uniqueChapterRows[key]!['videoCompleted'] =
            (uniqueChapterRows[key]!['videoCompleted'] == true) ||
            (row['videoCompleted'] == true);
        uniqueChapterRows[key]!['assessmentCompleted'] =
          (uniqueChapterRows[key]!['assessmentCompleted'] == true) ||
          (row['assessmentCompleted'] == true);
        uniqueChapterRows[key]!['assessmentPercentage'] =
          ((uniqueChapterRows[key]!['assessmentPercentage'] as double) >
            (row['assessmentPercentage'] as double))
          ? uniqueChapterRows[key]!['assessmentPercentage']
          : row['assessmentPercentage'];
        uniqueChapterRows[key]!['exerciseAttempted'] =
            (uniqueChapterRows[key]!['exerciseAttempted'] == true) ||
            (row['exerciseAttempted'] == true);
      }
    }

    final studentData = uniqueChapterRows.values.toList();

    final firstRecord = studentData.first;
    final uniqueSubjects = studentData
        .map((s) => s['subject']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    final totalChapters = studentData.length;
    final videosCompleted = studentData
        .where((s) => s['videoCompleted'] == true)
        .length;
    final exercisesCompleted = studentData
        .where((s) => s['exerciseAttempted'] == true)
        .length;

    return {
      'studentName': firstRecord['studentName'],
      'studentId': studentId,
      'board': firstRecord['board'],
      'grade': firstRecord['grade'],
      'subject': uniqueSubjects.length <= 1
          ? (uniqueSubjects.isEmpty ? '' : uniqueSubjects.first)
          : 'Multiple Subjects',
      'totalChapters': totalChapters,
      'videosCompleted': videosCompleted,
      'exercisesCompleted': exercisesCompleted,
      'chapters': studentData,
    };
  }

  // Get all unique students for exercise report
  List<Map<String, dynamic>> getExerciseReportSummary() {
    final Map<String, Map<String, dynamic>> studentMap = {};
    final Map<String, Set<String>> studentSubjects = {};
    final Map<String, Set<String>> studentChapterKeys = {};

    for (var data in studentsData) {
      final studentId = data['studentId'] as String;
      final key = studentId;
      final chapterKey = '${data['subject']}|${data['chapter']}';

      if (!studentMap.containsKey(key)) {
        studentMap[key] = {
          'studentName': data['studentName'],
          'studentId': studentId,
          'board': data['board'],
          'grade': data['grade'],
          'subject': data['subject'],
          'totalChapters': 0,
          'videosCompleted': 0,
          'exercisesCompleted': 0,
        };
      }

      studentSubjects.putIfAbsent(key, () => <String>{});
      if ((data['subject']?.toString() ?? '').isNotEmpty) {
        studentSubjects[key]!.add(data['subject'].toString());
      }

      studentChapterKeys.putIfAbsent(key, () => <String>{});
      if (studentChapterKeys[key]!.contains(chapterKey)) {
        continue;
      }
      studentChapterKeys[key]!.add(chapterKey);

      studentMap[key]!['totalChapters'] =
          (studentMap[key]!['totalChapters'] as int) + 1;

      if (data['videoCompleted'] == true) {
        studentMap[key]!['videosCompleted'] =
            (studentMap[key]!['videosCompleted'] as int) + 1;
      }

      if (data['exerciseAttempted'] == true) {
        studentMap[key]!['exercisesCompleted'] =
            (studentMap[key]!['exercisesCompleted'] as int) + 1;
      }
    }

    for (final entry in studentMap.entries) {
      final subjects = studentSubjects[entry.key] ?? <String>{};
      entry.value['subject'] = subjects.length <= 1
          ? (subjects.isEmpty ? '' : subjects.first)
          : 'Multiple Subjects';
    }

    return studentMap.values.toList();
  }

  Future<void> exportToExcel() async {
    try {
      Get.snackbar(
        'Export Started',
        'Preparing exercise completion report...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final dioClient = dio.Dio();
      final response = await dioClient.get<List<int>>(
        '${ApiConstants.baseUrl}${ApiConstants.mentorExerciseProgressReportExport}',
        queryParameters: _buildReportQueryParameters(),
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token', 'Accept': 'text/csv'},
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Empty report received from server');
      }

      final now = DateTime.now();
      final dateTag =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final fileName = 'mentor_exercise_report_$dateTag.csv';
      final docsDir = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${docsDir.path}/MentorReports');
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final file = File('${reportsDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      Get.snackbar(
        'Success',
        'Report downloaded: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportExerciseReport() async {
    await exportToExcel();
  }

  Map<String, dynamic> _buildReportQueryParameters() {
    final params = <String, dynamic>{};
    if (selectedBoard.value != null && selectedBoard.value!.isNotEmpty) {
      params['board'] = selectedBoard.value;
    }
    if (selectedGrade.value != null && selectedGrade.value!.isNotEmpty) {
      params['grade'] = selectedGrade.value;
    }
    if (selectedSubject.value != null && selectedSubject.value!.isNotEmpty) {
      params['subject'] = selectedSubject.value;
    }
    return params;
  }

  Future<void> sendMessage(String recipientId, String recipientName) async {
    if (messageText.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a message',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSendingMessage.value = true;
    try {
      final text = messageText.value.trim();
      final isBroadcast =
          recipientId.trim().isEmpty || recipientId.trim().toLowerCase() == 'all';

      if (isBroadcast) {
        try {
          await _apiService.post(
            ApiConstants.mentorBroadcastMessage,
            data: {'message': text},
          );
        } catch (_) {
          // Fallback: announcement endpoint to reach all assigned users
          await _apiService.post(
            ApiConstants.mentorAnnouncements,
            data: {
              'title': 'Message from ${mentorName.value}',
              'message': text,
              'type': 'general',
            },
          );
        }
      } else {
        await _apiService.post(
          ApiConstants.mentorMessages,
          data: {'recipientId': recipientId, 'message': text},
        );
      }

      messages.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'from': 'Me',
        'fromId': mentorId.value,
        'to': recipientName,
        'toId': recipientId,
        'message': text,
        'timestamp': DateTime.now(),
        'read': true,
        'type': 'sent',
      });

      unreadCount.value = messages.where((m) => m['read'] == false).length;
      messageText.value = '';

      Get.snackbar(
        'Success',
        isBroadcast
            ? 'Message sent to all users'
            : 'Message sent to $recipientName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> answerQuestion(String questionId, String answer) async {
    if (answer.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an answer',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update question with threaded answer
      final index = studentQuestions.indexWhere((q) => q['id'] == questionId);
      if (index != -1) {
        final wasUnanswered = studentQuestions[index]['answered'] == false;

        // Add answer to the thread
        final answers = studentQuestions[index]['answers'] as List? ?? [];
        answers.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'mentorName': mentorName.value,
          'mentorId': mentorId.value,
          'answer': answer,
          'timestamp': DateTime.now(),
        });

        studentQuestions[index]['answers'] = answers;
        studentQuestions[index]['answered'] = true;
        studentQuestions.refresh();

        if (wasUnanswered) {
          unansweredQuestionsCount.value--;
        }
      }

      Get.snackbar(
        'Success',
        'Answer added to thread',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to answer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadCoachingRequests() async {
    isLoadingRequests.value = true;
    try {
      final response = await _apiService.get(
        ApiConstants.mentorCoachingRequests,
      );
      if (response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .map((item) {
              item['timestamp'] =
                  DateTime.tryParse(item['timestamp']?.toString() ?? '') ??
                  DateTime.now();
              if (item['responseTimestamp'] != null) {
                item['responseTimestamp'] =
                    DateTime.tryParse(item['responseTimestamp'].toString()) ??
                    DateTime.now();
              }
              return item;
            })
            .toList();
        coachingRequests.value = list;
      }

      pendingRequestsCount.value = coachingRequests
          .where((r) => r['status'] == 'pending')
          .length;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load coaching requests: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> respondToCoachingRequest(
    String requestId,
    String status,
    String response,
  ) async {
    if (response.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a response message',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _apiService.post(
        '${ApiConstants.mentorCoachingRequests}/$requestId/respond',
        data: {'status': status, 'response': response.trim()},
      );

      await _loadCoachingRequests();

      Get.snackbar(
        'Success',
        'Response sent to student',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send response: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Calendar Management Methods
  Future<void> _loadCalendarData() async {
    isLoadingCalendar.value = true;
    try {
      final response = await _apiService.get(
        ApiConstants.mentorCoachingCalendar,
        queryParameters: {
          'view': calendarView.value,
          'date': selectedDate.value.toIso8601String(),
        },
      );

      if (response.data['success'] == true) {
        final data = Map<String, dynamic>.from(response.data['data'] as Map);
        final slots = (data['slots'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .map((item) {
              item['date'] =
                  DateTime.tryParse(item['date']?.toString() ?? '') ??
                  selectedDate.value;
              return item;
            })
            .toList();
        final sessions = (data['sessions'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .map((item) {
              item['date'] =
                  DateTime.tryParse(item['date']?.toString() ?? '') ??
                  selectedDate.value;
              return item;
            })
            .toList();

        availableTimeSlots.value = slots;
        bookedSessions.value = sessions;
      }

      upcomingSessionsCount.value = bookedSessions
          .where((s) => s['status'] == 'confirmed' || s['status'] == 'pending')
          .length;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load calendar data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCalendar.value = false;
    }
  }

  void changeCalendarView(String view) {
    calendarView.value = view;
    _loadCalendarData();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _loadCalendarData();
  }

  void navigateCalendar(bool next) {
    final current = selectedDate.value;
    late DateTime updated;

    if (calendarView.value == 'day') {
      updated = current.add(Duration(days: next ? 1 : -1));
    } else if (calendarView.value == 'week') {
      updated = current.add(Duration(days: next ? 7 : -7));
    } else {
      updated = DateTime(
        current.year,
        current.month + (next ? 1 : -1),
        current.day,
      );
    }

    selectDate(updated);
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final diff = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: diff));
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String getCalendarDateTitle() {
    if (calendarView.value == 'day') {
      return _shortDate(selectedDate.value);
    }

    if (calendarView.value == 'week') {
      final start = _startOfWeek(selectedDate.value);
      final end = start.add(const Duration(days: 6));
      return '${_shortDate(start)} - ${_shortDate(end)}';
    }

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[selectedDate.value.month - 1]} ${selectedDate.value.year}';
  }

  List<Map<String, dynamic>> getSessionsForDate(DateTime date) {
    return bookedSessions.where((session) {
      final sessionDate = session['date'] as DateTime;
      return sessionDate.year == date.year &&
          sessionDate.month == date.month &&
          sessionDate.day == date.day;
    }).toList();
  }

  List<Map<String, dynamic>> getTimeSlotsForDate(DateTime date) {
    return availableTimeSlots.where((slot) {
      final slotDate = slot['date'] as DateTime;
      return slotDate.year == date.year &&
          slotDate.month == date.month &&
          slotDate.day == date.day;
    }).toList();
  }

  List<Map<String, dynamic>> getSessionsForCurrentView() {
    if (calendarView.value == 'day') {
      return getSessionsForDate(selectedDate.value);
    }

    if (calendarView.value == 'week') {
      final start = _startOfWeek(selectedDate.value);
      final end = start.add(const Duration(days: 6));
      return bookedSessions.where((session) {
        final date = session['date'] as DateTime;
        final normalized = DateTime(date.year, date.month, date.day);
        return !normalized.isBefore(start) && !normalized.isAfter(end);
      }).toList();
    }

    return bookedSessions.where((session) {
      final date = session['date'] as DateTime;
      return date.year == selectedDate.value.year &&
          date.month == selectedDate.value.month;
    }).toList();
  }

  List<Map<String, dynamic>> getTimeSlotsForCurrentView() {
    if (calendarView.value == 'day') {
      return getTimeSlotsForDate(selectedDate.value);
    }

    if (calendarView.value == 'week') {
      final start = _startOfWeek(selectedDate.value);
      final end = start.add(const Duration(days: 6));
      return availableTimeSlots.where((slot) {
        final date = slot['date'] as DateTime;
        final normalized = DateTime(date.year, date.month, date.day);
        return !normalized.isBefore(start) && !normalized.isAfter(end);
      }).toList();
    }

    return availableTimeSlots.where((slot) {
      final date = slot['date'] as DateTime;
      return date.year == selectedDate.value.year &&
          date.month == selectedDate.value.month;
    }).toList();
  }

  Future<void> createTimeSlot(
    DateTime date,
    String startTime,
    String endTime,
  ) async {
    try {
      await _apiService.post(
        ApiConstants.mentorCoachingSlots,
        data: {
          'date': DateTime(date.year, date.month, date.day).toIso8601String(),
          'startTime': startTime,
          'endTime': endTime,
        },
      );
      await _loadCalendarData();

      Get.snackbar(
        'Success',
        'Time slot created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create time slot: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> blockTimeSlot(String slotId) async {
    try {
      await _apiService.post(
        '${ApiConstants.mentorCoachingSlots}/$slotId/block',
      );
      await _loadCalendarData();

      Get.snackbar(
        'Success',
        'Time slot blocked',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to block time slot',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteTimeSlot(String slotId) async {
    try {
      await _apiService.delete('${ApiConstants.mentorCoachingSlots}/$slotId');
      await _loadCalendarData();

      Get.snackbar(
        'Success',
        'Time slot deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete time slot',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> confirmSession(String sessionId) async {
    try {
      await _apiService.post('/coaching/mentor/sessions/$sessionId/confirm');
      await _loadCalendarData();

      Get.snackbar(
        'Success',
        'Session confirmed and meeting link generated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm session',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> cancelSession(String sessionId, String reason) async {
    try {
      await _apiService.post(
        '/coaching/mentor/sessions/$sessionId/cancel',
        data: {'reason': reason.trim()},
      );
      await _loadCalendarData();

      Get.snackbar(
        'Success',
        'Session cancelled',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel session',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== Assessment Management ====================

  Future<void> _loadAssessments() async {
    isLoadingAssessments.value = true;
    try {
      final response = await _apiService.get(
        '${ApiConstants.assessments}?limit=50',
      );
      if (response.data['success'] == true) {
        final List data = response.data['data'] as List? ?? [];
        assessments.value = data.map((a) {
          final board = a['board'];
          final grade = a['grade'];
          final subject = a['subject'];
          final chapter = a['chapter'];
          final scheduledDate = a['scheduledDate'] != null
              ? DateTime.tryParse(a['scheduledDate'].toString()) ??
                    DateTime.now().add(const Duration(days: 1))
              : DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
                    DateTime.now().add(const Duration(days: 1));
          final questionsList = a['questions'] as List? ?? [];
          return {
            'id': a['_id']?.toString() ?? '',
            'name': a['title']?.toString() ?? '',
            'board': board is Map ? board['name']?.toString() ?? '' : '',
            'grade': grade is Map ? grade['name']?.toString() ?? '' : '',
            'subject': subject is Map ? subject['name']?.toString() ?? '' : '',
            'chapter': chapter is Map ? chapter['name']?.toString() ?? '' : '',
            'totalQuestions':
                (a['numberOfQuestions'] as num?)?.toInt() ??
                questionsList.length,
            'duration': (a['duration'] as num?)?.toInt() ?? 60,
            'scheduledDate': scheduledDate,
            'createdDate':
                DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
                DateTime.now(),
            'status': (a['isActive'] == true) ? 'active' : 'inactive',
            'totalStudents': 0,
            'completedCount': 0,
          };
        }).toList();

        // Clear old mock submissions — real submissions need a separate endpoint
        assessmentSubmissions.clear();
        pendingSubmissionsCount.value = 0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load assessments: ${e.toString()}');
    } finally {
      isLoadingAssessments.value = false;
    }
  }

  Future<void> _loadAllChapters() async {
    isLoadingChapters.value = true;
    try {
      final response = await _apiService.get(
        '${ApiConstants.chapters}?limit=500',
      );
      if (response.data['success'] == true) {
        final List data = response.data['data'] as List? ?? [];
        questionBankAllChapters.value = data.map((ch) {
          final subject = ch['subject'];
          final grade = ch['grade'];
          final boards = ch['boards'] as List? ?? [];
          return {
            'id': ch['_id']?.toString() ?? '',
            'name': ch['name']?.toString() ?? '',
            'subjectId': subject is Map
                ? subject['_id']?.toString()
                : subject?.toString(),
            'subjectName': subject is Map ? subject['name']?.toString() : '',
            'gradeId': grade is Map
                ? grade['_id']?.toString()
                : grade?.toString(),
            'gradeName': grade is Map ? grade['name']?.toString() : '',
            'boardNames': boards
                .map((b) => b is Map ? b['name']?.toString() ?? '' : '')
                .toList(),
          };
        }).toList();
      }
    } catch (e) {
      // Silently fail – chapters will be empty, filters gracefully handle it
    } finally {
      isLoadingChapters.value = false;
    }
  }

  /// Unique subject names extracted from all loaded chapters — used by the question bank filters.
  List<String> get questionBankSubjects {
    final names = questionBankAllChapters
        .map((ch) => (ch['subjectName'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  /// Unique grade names extracted from all loaded chapters — used by the question bank filters.
  List<String> get questionBankGrades {
    final names = questionBankAllChapters
        .map((ch) => (ch['gradeName'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  /// Returns chapters filtered by the currently selected subject (and optionally grade).
  List<Map<String, dynamic>> get filteredChaptersForAssessment {
    return questionBankAllChapters.where((ch) {
      bool match = true;
      if (selectedAssessmentSubject.value != null &&
          selectedAssessmentSubject.value!.isNotEmpty) {
        match =
            match &&
            (ch['subjectName'] ?? '').toString().toLowerCase() ==
                selectedAssessmentSubject.value!.toLowerCase();
      }
      if (selectedAssessmentGrade.value != null &&
          selectedAssessmentGrade.value!.isNotEmpty) {
        final gradeName = (ch['gradeName'] ?? '').toString().toLowerCase();
        final filter = selectedAssessmentGrade.value!.toLowerCase();
        // Accept both "Grade 10" and "10" style matches
        match =
            match && (gradeName.contains(filter) || filter.contains(gradeName));
      }
      return match;
    }).toList();
  }

  Future<void> loadQuestionBankForChapter(String chapterId) async {
    isLoadingQuestionBank.value = true;
    questionBank.clear();
    try {
      final response = await _apiService.get(
        '${ApiConstants.questions}?chapter=$chapterId&limit=200',
      );
      if (response.data['success'] == true) {
        final List data = response.data['data'] as List? ?? [];
        questionBank.value = data.map((q) {
          final chapter = q['chapter'];
          final subject = chapter is Map ? chapter['subject'] : null;
          final grade = chapter is Map ? chapter['grade'] : null;
          final boards = chapter is Map
              ? (chapter['boards'] as List? ?? [])
              : [];
          return {
            'id': q['_id']?.toString() ?? '',
            'questionText': q['questionText']?.toString() ?? '',
            'answerType': q['answerType']?.toString() ?? 'single',
            'options': (q['options'] as List? ?? [])
                .map(
                  (o) => {
                    'text': o['text']?.toString() ?? '',
                    'isCorrect': o['isCorrect'] == true,
                  },
                )
                .toList(),
            'marks': (q['marks'] as num?)?.toInt() ?? 1,
            'difficulty': q['difficulty']?.toString() ?? 'medium',
            'explanation': q['explanation']?.toString() ?? '',
            'chapterId': chapter is Map
                ? chapter['_id']?.toString()
                : chapter?.toString(),
            'chapterName': chapter is Map ? chapter['name']?.toString() : '',
            'subjectName': subject is Map ? subject['name']?.toString() : '',
            'gradeName': grade is Map ? grade['name']?.toString() : '',
            'boardNames': boards
                .map((b) => b is Map ? b['name']?.toString() ?? '' : '')
                .toList(),
          };
        }).toList();
      } else {
        Get.snackbar(
          'Notice',
          'No questions found for this chapter',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load questions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingQuestionBank.value = false;
    }
  }

  void onAssessmentChapterSelected(String chapterName, String chapterId) {
    selectedAssessmentChapter.value = chapterName;
    selectedAssessmentChapterId.value = chapterId;
    // Store related IDs for the API call
    final ch = questionBankAllChapters.firstWhereOrNull(
      (c) => c['id'] == chapterId,
    );
    if (ch != null) {
      selectedAssessmentSubjectId.value = ch['subjectId']?.toString();
      selectedAssessmentGradeId.value = ch['gradeId']?.toString();
      final boardIds = (ch['boardIds'] as List?)?.cast<String>() ?? [];
      selectedAssessmentBoardId.value = boardIds.isNotEmpty
          ? boardIds.first
          : null;
      selectedAssessmentSubject.value = ch['subjectName']?.toString();
      selectedAssessmentGrade.value = ch['gradeName']?.toString();
    }
    selectedQuestions.clear();
    questionBank.clear();
    loadQuestionBankForChapter(chapterId);
  }

  void clearAssessmentFilters() {
    selectedAssessmentBoard.value = null;
    selectedAssessmentGrade.value = null;
    selectedAssessmentSubject.value = null;
    selectedAssessmentChapter.value = null;
    selectedAssessmentChapterId.value = null;
    selectedAssessmentBoardId.value = null;
    selectedAssessmentGradeId.value = null;
    selectedAssessmentSubjectId.value = null;
    selectedQuestions.clear();
    questionBank.clear();
  }

  // Questions from the bank are already filtered by chapter on the server-side.
  // This getter simply returns the loaded list.
  List<Map<String, dynamic>> get filteredQuestions => questionBank.toList();

  void toggleQuestionSelection(String questionId) {
    if (selectedQuestions.contains(questionId)) {
      selectedQuestions.remove(questionId);
    } else {
      selectedQuestions.add(questionId);
    }
  }

  Future<void> createAssessment({
    required String name,
    String? board,
    String? grade,
    String? subject,
    String? chapter,
    String? chapterId,
    required DateTime scheduledDate,
    required int duration,
  }) async {
    if (selectedQuestions.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one question from the Question Bank tab',
      );
      return;
    }

    // Resolve the chapter to use (dialog selection takes priority over Question Bank tab selection)
    final resolvedChapterId = chapterId ?? selectedAssessmentChapterId.value;

    if (resolvedChapterId == null) {
      Get.snackbar(
        'Error',
        'Please select a chapter in the Question Bank tab before creating an assessment.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Optionally look up board/grade/subject IDs to include in the request.
    // The backend will auto-derive any missing ones from the chapter.
    String? boardId = selectedAssessmentBoardId.value;
    String? gradeId = selectedAssessmentGradeId.value;
    String? subjectId = selectedAssessmentSubjectId.value;

    if ((boardId == null || gradeId == null || subjectId == null)) {
      final ch = questionBankAllChapters.firstWhereOrNull(
        (c) => c['id'] == resolvedChapterId,
      );
      if (ch != null) {
        boardId ??=
            ((ch['boardIds'] as List?)?.cast<String>() ?? []).firstOrNull;
        gradeId ??= ch['gradeId']?.toString();
        subjectId ??= ch['subjectId']?.toString();
      }
    }

    isCreatingAssessment.value = true;
    try {
      final body = <String, dynamic>{
        'title': name,
        'chapter': resolvedChapterId,
        'difficulty': ['easy', 'medium', 'tough'],
        'numberOfQuestions': selectedQuestions.length,
        'duration': duration,
        'questions': List<String>.from(selectedQuestions),
        'scheduledDate': scheduledDate.toIso8601String(),
        // Include IDs if resolved; backend will derive from chapter if absent
        if (boardId != null) 'board': boardId,
        if (gradeId != null) 'grade': gradeId,
        if (subjectId != null) 'subject': subjectId,
      };

      final response = await _apiService.post(
        ApiConstants.assessments,
        data: body,
      );
      if (response.data['success'] == true) {
        await _loadAssessments();

        // Clear selections after creation
        selectedQuestions.clear();
        selectedAssessmentBoard.value = null;
        selectedAssessmentGrade.value = null;
        selectedAssessmentSubject.value = null;
        selectedAssessmentChapter.value = null;
        selectedAssessmentChapterId.value = null;
        selectedAssessmentBoardId.value = null;
        selectedAssessmentGradeId.value = null;
        selectedAssessmentSubjectId.value = null;
        questionBank.clear();

        Get.back();
        Get.snackbar(
          'Success',
          'Assessment "$name" created with ${body['numberOfQuestions']} questions!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final msg =
            response.data['message']?.toString() ??
            'Failed to create assessment';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create assessment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreatingAssessment.value = false;
    }
  }

  Future<void> submitFeedback({
    required String submissionId,
    required String feedback,
    required double score,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Update submission - Replace with actual API
      final index = assessmentSubmissions.indexWhere(
        (s) => s['id'] == submissionId,
      );
      if (index != -1) {
        assessmentSubmissions[index]['feedback'] = feedback;
        assessmentSubmissions[index]['score'] = score;
        assessmentSubmissions[index]['percentage'] =
            (score / assessmentSubmissions[index]['totalScore']) * 100;
        assessmentSubmissions[index]['status'] = 'reviewed';
        assessmentSubmissions.refresh();

        pendingSubmissionsCount.value--;

        Get.back();
        Get.snackbar(
          'Success',
          'Feedback submitted successfully. Student will be notified.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit feedback');
    }
  }

  Future<void> exportAssessmentReport() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Export to Excel - Replace with actual implementation
      Get.snackbar(
        'Success',
        'Assessment report exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to export report');
    }
  }

  List<Map<String, dynamic>> getSubmissionsForAssessment(String assessmentId) {
    return assessmentSubmissions
        .where((s) => s['assessmentId'] == assessmentId)
        .toList();
  }

  // ==================== Announcement Audio ====================

  Future<void> startAudioRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission Denied',
        'Microphone permission is required to record a voice note',
      );
      return;
    }
    _audioRecorder ??= AudioRecorder();
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/announcement_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder!.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    audioDuration.value = 0;
    _audioRecordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => audioDuration.value++,
    );
    isRecordingAudio.value = true;
  }

  Future<void> stopAudioRecording() async {
    _audioRecordingTimer?.cancel();
    final path = await _audioRecorder?.stop();
    isRecordingAudio.value = false;
    if (path != null && File(path).existsSync()) {
      recordedAudioPath.value = path;
      pickedAudioPath.value = null;
      pickedAudioFileName.value = null;
    }
  }

  Future<void> pickAnnouncementAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      pickedAudioPath.value = result.files.first.path;
      pickedAudioFileName.value = result.files.first.name;
      recordedAudioPath.value = null;
    }
  }

  void clearAnnouncementAudio() {
    _audioRecordingTimer?.cancel();
    if (isRecordingAudio.value) _audioRecorder?.stop();
    isRecordingAudio.value = false;
    recordedAudioPath.value = null;
    pickedAudioPath.value = null;
    pickedAudioFileName.value = null;
    audioDuration.value = 0;
  }

  // ==================== Announcements/Notifications ====================

  Future<void> _loadAnnouncements() async {
    isLoadingAnnouncements.value = true;
    try {
      final response = await _apiService.get(ApiConstants.mentorAnnouncements);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        announcements.value = data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id']?.toString() ?? '',
            'title': item['title'] ?? '',
            'message': item['message'] ?? '',
            'type': item['type'] ?? 'general',
            'targetBoard': item['targetBoard'],
            'targetGrade': item['targetGrade'],
            'targetSubject': item['targetSubject'],
            'sentDate': item['sentDate'] != null
                ? DateTime.tryParse(item['sentDate'].toString()) ??
                      DateTime.now()
                : DateTime.now(),
            'recipientCount': item['recipientCount'] ?? 0,
            'audioUrl': item['audioUrl'],
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Load announcements error: $e');
    } finally {
      isLoadingAnnouncements.value = false;
    }
  }

  Future<void> sendAnnouncement({
    required String title,
    required String message,
    required String type,
    String? board,
    String? grade,
    String? subject,
    String? audioFilePath,
    String? audioFileNameHint,
  }) async {
    if (title.trim().isEmpty || message.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill in title and message');
      return;
    }

    isSendingAnnouncement.value = true;
    try {
      dynamic requestData;

      if (audioFilePath != null && File(audioFilePath).existsSync()) {
        // Multipart upload
        final ext = audioFilePath.split('.').last;
        final fileName = audioFileNameHint ?? 'voice_note.$ext';
        final formData = dio.FormData.fromMap({
          'title': title.trim(),
          'message': message.trim(),
          'type': type,
          if (board != null && board.isNotEmpty) 'board': board,
          if (grade != null && grade.isNotEmpty) 'grade': grade,
          if (subject != null && subject.isNotEmpty) 'subject': subject,
          'audio': await dio.MultipartFile.fromFile(
            audioFilePath,
            filename: fileName,
          ),
        });
        requestData = formData;
      } else {
        requestData = {
          'title': title.trim(),
          'message': message.trim(),
          'type': type,
          if (board != null && board.isNotEmpty) 'board': board,
          if (grade != null && grade.isNotEmpty) 'grade': grade,
          if (subject != null && subject.isNotEmpty) 'subject': subject,
        };
      }

      final response = await _apiService.post(
        ApiConstants.mentorAnnouncements,
        data: requestData,
      );

      if (response.data['success'] == true) {
        final newAnn = response.data['data'];
        announcements.insert(0, {
          'id': newAnn['id']?.toString() ?? '',
          'title': newAnn['title'] ?? title,
          'message': newAnn['message'] ?? message,
          'type': newAnn['type'] ?? type,
          'targetBoard': newAnn['targetBoard'],
          'targetGrade': newAnn['targetGrade'],
          'targetSubject': newAnn['targetSubject'],
          'sentDate': newAnn['sentDate'] != null
              ? DateTime.tryParse(newAnn['sentDate'].toString()) ??
                    DateTime.now()
              : DateTime.now(),
          'recipientCount': newAnn['recipientCount'] ?? 0,
          'audioUrl': newAnn['audioUrl'],
        });
        announcements.refresh();
        Get.back();
        clearAnnouncementAudio();
        // ★ Push trigger: announcement delivery confirmation (fires immediately
        //    because this is an explicit mentor action, not background load)
        _triggerAnnouncementReplyPush(
          title,
          (newAnn['recipientCount'] as int? ?? 0),
        );
        Get.snackbar(
          'Sent',
          response.data['message'] ?? 'Announcement sent',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to send');
      }
    } catch (e) {
      debugPrint('Send announcement error: $e');
      Get.snackbar('Error', 'Failed to send announcement');
    } finally {
      isSendingAnnouncement.value = false;
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.mentorAnnouncements}/$announcementId',
      );
      if (response.data['success'] == true) {
        announcements.removeWhere((a) => a['id'] == announcementId);
        announcements.refresh();
        Get.snackbar(
          'Deleted',
          'Announcement deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Delete announcement error: $e');
      Get.snackbar('Error', 'Failed to delete announcement');
    }
  }

  Future<void> _loadFeedbacksAndRatings() async {
    isLoadingFeedbacks.value = true;
    try {
      // ── 1. Overview stats ───────────────────────────────────────────────
      final overviewRes = await _apiService.get(
        ApiConstants.mentorRatingsOverview,
      );
      if (overviewRes.data['success'] == true) {
        final d = overviewRes.data['data'] as Map<String, dynamic>? ?? {};
        averageRating.value = (d['averageRating'] as num?)?.toDouble() ?? 0.0;
        totalFeedbacks.value = (d['totalFeedbacks'] as num?)?.toInt() ?? 0;
      }

      // ── 2. Per-video stats for top-N chart (fetch max 100 and slice in UI) ─
      final statsRes = await _apiService.get(
        ApiConstants.mentorRatingsStats,
        queryParameters: {'top': 100},
      );
      if (statsRes.data['success'] == true) {
        final rawStats = (statsRes.data['data'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

        videoRatings.value = rawStats.map((s) {
          return {
            'videoId': s['videoId']?.toString() ?? '',
            'videoTitle': s['videoTitle'] ?? 'Unknown',
            'chapter': s['chapter'] ?? '',
            'subject': s['subject'] ?? '',
            'averageRating': (s['averageRating'] as num?)?.toDouble() ?? 0.0,
            'totalRatings': (s['totalRatings'] as num?)?.toInt() ?? 0,
            'ratings': s['ratings'] ?? {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
          };
        }).toList();
      }

      // ── 3. Individual feedbacks (first page) ────────────────────────────
      final feedbackRes = await _apiService.get(
        ApiConstants.mentorRatingsFeedbacks,
        queryParameters: {'page': 1, 'limit': 50},
      );
      if (feedbackRes.data['success'] == true) {
        final rawFb = (feedbackRes.data['data'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

        videoFeedbacks.value = rawFb.map((fb) {
          return {
            'id': fb['id']?.toString() ?? '',
            'studentName': fb['studentName'] ?? 'Unknown',
            'studentId': fb['studentId']?.toString() ?? '',
            'videoTitle': fb['videoTitle'] ?? 'Unknown',
            'videoId': fb['videoId']?.toString() ?? '',
            'chapter': fb['chapter'] ?? '',
            'subject': fb['subject'] ?? '',
            'rating': (fb['rating'] as num?)?.toInt() ?? 0,
            'feedback': fb['feedback'] ?? '',
            'mentorReply': fb['mentorReply'] ?? '',
            'mentorRepliedAt': fb['mentorRepliedAt'] != null
                ? DateTime.tryParse(fb['mentorRepliedAt'].toString())
                : null,
            'timestamp': fb['timestamp'] != null
                ? DateTime.tryParse(fb['timestamp'].toString()) ??
                      DateTime.now()
                : DateTime.now(),
            'isPositive': (fb['isPositive'] as bool?) ?? false,
          };
        }).toList();
      }

      _updateTopVideos();
      _calculateStatistics();
    } catch (e) {
      // Fall back to an empty state — no mock data
      videoFeedbacks.value = [];
      videoRatings.value = [];
      topVideos.value = [];
      averageRating.value = 0.0;
      totalFeedbacks.value = 0;
      debugPrint('⚠️ _loadFeedbacksAndRatings error: $e');
    } finally {
      isLoadingFeedbacks.value = false;
    }
  }

  void _updateTopVideos() {
    final sortedVideos = List<Map<String, dynamic>>.from(videoRatings)
      ..sort(
        (a, b) => (b['averageRating'] as double).compareTo(
          a['averageRating'] as double,
        ),
      );

    final count = selectedTopCount.value;
    topVideos.value = sortedVideos.take(count).toList();
  }

  void _calculateStatistics() {
    if (videoFeedbacks.isEmpty) {
      averageRating.value = 0.0;
      totalFeedbacks.value = 0;
      return;
    }

    final sum = videoFeedbacks.fold<int>(
      0,
      (prev, feedback) => prev + (feedback['rating'] as int),
    );
    averageRating.value = sum / videoFeedbacks.length;
    totalFeedbacks.value = videoFeedbacks.length;
  }

  void updateTopCount(int count) {
    selectedTopCount.value = count;
    _updateTopVideos();
  }

  void updateChartType(String type) {
    selectedChartType.value = type;
  }

  Future<void> replyToFeedback(String feedbackId, String reply) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.ratingsReply}/$feedbackId/reply',
        data: {'reply': reply},
      );

      if (response.data['success'] == true) {
        final index = videoFeedbacks.indexWhere(
          (fb) => fb['id'].toString() == feedbackId,
        );
        if (index != -1) {
          videoFeedbacks[index]['mentorReply'] = reply;
          videoFeedbacks[index]['mentorRepliedAt'] = DateTime.now();
          videoFeedbacks.refresh();
        }
        Get.back();
        Get.snackbar(
          'Success',
          'Reply sent to student',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Failed to send reply',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reply');
    }
  }

  // ==================== Support Tickets ====================

  Future<void> _loadSupportTickets() async {
    isLoadingTickets.value = true;
    try {
      final response = await _ticketService.getTickets(page: 1, limit: 100);

      if (response['success'] == true) {
        final ticketsData = response['data'] as List<dynamic>;
        supportTickets.value = ticketsData
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();

        _updateTicketCounts();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load support tickets: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoadingTickets.value = false;
    }
  }

  void _updateTicketCounts() {
    openTicketsCount.value = supportTickets
        .where((t) => t.status == TicketStatus.open)
        .length;
    inProgressTicketsCount.value = supportTickets
        .where((t) => t.status == TicketStatus.inProgress)
        .length;
    resolvedTicketsCount.value = supportTickets
        .where((t) => t.status == TicketStatus.resolved)
        .length;
  }

  Future<void> refreshTickets() async {
    await _loadSupportTickets();
  }

  Future<void> refreshData() async {
    await Future.wait([
      _loadAssignments(),
      _loadMessages(),
      _loadStudentQuestions(),
      _loadCoachingRequests(),
      _loadCalendarData(),
      _loadAssessments(),
      _loadAnnouncements(),
      _loadFeedbacksAndRatings(),
      _loadSupportTickets(),
      if (selectedTab.value == 1) loadStudentReports(),
    ]);
    // Manual refresh: treat result as new baseline so the NEXT poll
    // computes deltas from this fresh snapshot, not the old one.
    _captureBaseline();
    computeNotifications();
  }

  // ==================== Notification Badge & Push Triggers ====================

  /// Recomputes the total actionable notification count and updates the badge.
  /// This is called automatically via [ever] watchers whenever any list changes.
  void computeNotifications() {
    int count = 0;

    // Unread messages
    count += messages.where((m) => m['read'] == false).length;

    // Unanswered QnA threads
    count += qnaThreads.where((t) => t.hasUnanswered).length;

    // Legacy unanswered questions
    count += studentQuestions.where((q) => q['answered'] == false).length;

    // Pending coaching requests
    count += coachingRequests.where((r) => r['status'] == 'pending').length;

    // Upcoming sessions in the next 24 h
    for (final s in bookedSessions) {
      final st = s['dateTime'] is DateTime
          ? s['dateTime'] as DateTime
          : (s['date'] is DateTime ? s['date'] as DateTime : DateTime.now());
      final diff = st.difference(DateTime.now());
      if (diff.inMinutes > 0 && diff.inHours <= 24) count++;
    }

    // Pending assessment submissions
    count += pendingSubmissionsCount.value;

    // Low-rated videos
    count += videoRatings
        .where((v) =>
            (v['averageRating'] as double? ?? 5.0) < 3.5 &&
            (v['totalRatings'] as int? ?? 0) >= 3)
        .length;

    // Unreplied feedback
    count += videoFeedbacks
        .where((fb) =>
            (fb['mentorReply']?.toString() ?? '').isEmpty &&
            (fb['feedback']?.toString() ?? '').isNotEmpty)
        .length;

    // Open + in-progress tickets
    count += openTicketsCount.value + inProgressTicketsCount.value;

    notificationCount.value = count;
  }

  // ─── In-app push trigger helpers ─────────────────────────────────────────
  //
  // These are called from the data-loading methods above to raise
  // a local push notification the moment new actionable data arrives.
  // They use FCMService._showLocalNotificationOnChannel internally by
  // exposing a convenience public method showMentorLocalNotification.

  /// Trigger point: called after _loadMessages() detects new unread messages.
  void _triggerMessagePush(int newUnread) {
    if (newUnread <= 0) return;
    _fcmShowLocal(
      type: 'mentor_message',
      title: 'New Message${newUnread > 1 ? 's' : ''}',
      body: 'You have $newUnread unread message${newUnread > 1 ? 's' : ''} from students',
    );
  }

  /// Trigger point: called after loadMentorQnaThreads() finds unanswered threads.
  void _triggerQnaPush(int unanswered) {
    if (unanswered <= 0) return;
    _fcmShowLocal(
      type: 'mentor_qna',
      title: 'Student Question${unanswered > 1 ? 's' : ''}',
      body: '$unanswered student question${unanswered > 1 ? 's' : ''} need${unanswered == 1 ? 's' : ''} your answer',
    );
  }

  /// Trigger point: called after _loadCoachingRequests() finds pending requests.
  void _triggerCoachingPush(int pending) {
    if (pending <= 0) return;
    _fcmShowLocal(
      type: 'coaching_request',
      title: 'Coaching Request${pending > 1 ? 's' : ''}',
      body: '$pending student${pending > 1 ? 's' : ''} requested coaching sessions',
    );
  }

  /// Trigger point: called after _loadCalendarData() finds imminent sessions.
  void _triggerSessionReminderPush(int imminentCount) {
    if (imminentCount <= 0) return;
    _fcmShowLocal(
      type: 'session_reminder',
      title: 'Session Starting Soon',
      body: '$imminentCount session${imminentCount > 1 ? 's' : ''} start${imminentCount == 1 ? 's' : ''} within the next hour!',
    );
  }

  /// Trigger point: called after assessment submissions are loaded.
  void _triggerAssessmentPush(int submissionCount) {
    if (submissionCount <= 0) return;
    _fcmShowLocal(
      type: 'assessment_submit',
      title: 'Assessment Submissions',
      body: '$submissionCount student${submissionCount > 1 ? 's have' : ' has'} submitted work for your review',
    );
  }

  /// Trigger point: called after _loadFeedbacksAndRatings() finds unreplied feedback.
  void _triggerFeedbackPush(int unreplied) {
    if (unreplied <= 0) return;
    _fcmShowLocal(
      type: 'student_feedback',
      title: 'New Student Feedback',
      body: '$unreplied student${unreplied > 1 ? 's have' : ' has'} left feedback — tap to reply',
    );
  }

  /// Trigger point: called after _loadSupportTickets() when open tickets exist.
  void _triggerTicketPush(int openCount) {
    if (openCount <= 0) return;
    _fcmShowLocal(
      type: 'ticket_open',
      title: 'Open Support Ticket${openCount > 1 ? 's' : ''}',
      body: '$openCount support ticket${openCount > 1 ? 's' : ''} need${openCount == 1 ? 's' : ''} your attention',
    );
  }

  /// Trigger point: called after sendAnnouncement() confirms receipt count.
  void _triggerLowRatedPushBatch(int count) {
    _fcmShowLocal(
      type: 'low_rated_content',
      title: 'Low-Rated Content Detected',
      body: '$count video${count > 1 ? 's have' : ' has'} dropped below ★3.5 — consider improvements',
    );
  }

  /// Trigger point: called after sendAnnouncement() confirms receipt count.
  void _triggerAnnouncementReplyPush(String title, int recipients) {
    _fcmShowLocal(
      type: 'announcement_reply',
      title: 'Announcement Sent',
      body: '"$title" delivered to $recipients student${recipients > 1 ? 's' : ''}',
    );
  }

  /// Central dispatcher: calls FCMService.showMentorLocalNotification if available.
  void _fcmShowLocal({required String type, required String title, required String body}) {
    try {
      final fcm = Get.find<FCMService>();
      fcm.showMentorLocalNotification(type: type, title: title, body: body);
    } catch (_) {
      // FCMService not yet initialised — silently skip
    }
  }
}
