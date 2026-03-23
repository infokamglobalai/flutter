import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/services/parent_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'package:najahapp/app/core/services/ticket_service.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentDashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ParentService _parentService = ParentService();
  final TicketService _ticketService = TicketService();

  // Parent data
  final parentName = ''.obs;
  final parentEmail = ''.obs;

  // Kids data  — each entry is a merged map of student info + computed stats
  final kids = <Map<String, dynamic>>[].obs;
  final isLoadingKids = false.obs;
  final kidsError = ''.obs;

  // Resources
  final resources = <Map<String, dynamic>>[].obs;
  final isLoadingResources = false.obs;

  // Referral
  final referralName = ''.obs;
  final referralEmail = ''.obs;
  final referralPhone = ''.obs;
  final isSubmittingReferral = false.obs;
  final referralHistory = <Map<String, dynamic>>[].obs;

  // TextEditingControllers for referral form (managed here for lifecycle safety)
  final referralNameCtrl = TextEditingController();
  final referralEmailCtrl = TextEditingController();
  final referralPhoneCtrl = TextEditingController();

  // Support Tickets
  final supportTickets = <Ticket>[].obs;
  final isLoadingTickets = false.obs;
  final openTicketsCount = 0.obs;
  final inProgressTicketsCount = 0.obs;
  final resolvedTicketsCount = 0.obs;

  // Selected tab
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadParentData();
    _loadKids();
    _loadResources();
    _loadSupportTickets();
  }

  @override
  void onClose() {
    referralNameCtrl.dispose();
    referralEmailCtrl.dispose();
    referralPhoneCtrl.dispose();
    super.onClose();
  }

  void _loadParentData() {
    final userData = _storageService.getUserData();
    if (userData != null) {
      parentName.value =
          '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
      parentEmail.value = userData['email'] ?? '';
    }
  }

  Future<void> _loadKids() async {
    isLoadingKids.value = true;
    kidsError.value = '';
    try {
      final studentsResp = await _parentService.getMyStudents();
      if (studentsResp['success'] != true) {
        kidsError.value = studentsResp['message'] ?? 'Failed to load students';
        return;
      }

      final studentList = ((studentsResp['data'] as List?) ?? [])
          .cast<Map<String, dynamic>>();

      // Fetch each student's progress in parallel
      final futures = studentList.map((student) async {
        final studentId = student['_id']?.toString() ?? '';
        if (studentId.isEmpty) return null;

        String boardName = _extractName(student['board']);
        String gradeName = _extractName(student['grade']);
        final studentName =
            student['fullName']?.toString() ??
            '${student['firstName'] ?? ''} ${student['lastName'] ?? ''}'.trim();

        try {
          final progressResp = await _parentService.getStudentProgress(
            studentId,
          );
          if (progressResp['success'] != true) {
            return _buildKidFallback(
              studentId,
              studentName,
              boardName,
              gradeName,
              student,
            );
          }
          final progressData =
              progressResp['data'] as Map<String, dynamic>? ?? {};
          final stats = ParentService.computeStats(progressData);

          return <String, dynamic>{
            'id': studentId,
            'name': studentName,
            'email': student['email']?.toString() ?? '',
            'grade': gradeName,
            'board': boardName,
            'avatar': null,
            ...stats,
          };
        } catch (_) {
          return _buildKidFallback(
            studentId,
            studentName,
            boardName,
            gradeName,
            student,
          );
        }
      });

      final results = await Future.wait(futures);
      kids.value = results.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      kidsError.value = 'Failed to load student data. Please try again.';
    } finally {
      isLoadingKids.value = false;
    }
  }

  String _extractName(dynamic value) {
    if (value is Map) return value['name']?.toString() ?? '';
    if (value is String) return value;
    return '';
  }

  Map<String, dynamic> _buildKidFallback(
    String id,
    String name,
    String board,
    String grade,
    Map<String, dynamic> student,
  ) {
    return {
      'id': id,
      'name': name,
      'email': student['email']?.toString() ?? '',
      'grade': grade,
      'board': board,
      'avatar': null,
      'videosWatched': 0,
      'totalVideos': 0,
      'assessmentsCompleted': 0,
      'totalAssessmentChapters': 0,
      'selfAssessmentsCompleted': 0,
      'averageScore': 0,
      'performance': 'good',
      'recentAssessments': <Map<String, dynamic>>[],
      'packages': <Map<String, dynamic>>[],
    };
  }

  Future<void> _loadResources() async {
    isLoadingResources.value = true;
    try {
      final resp = await _parentService.getParentResources();
      if (resp['success'] == true) {
        // Base URL for relative media paths (strip trailing /api)
        final mediaBase = ApiConstants.baseUrl.replaceAll(RegExp(r'/api$'), '');

        final rawList = ((resp['data'] as List?) ?? [])
            .cast<Map<String, dynamic>>();
        resources.value = rawList.where((r) => r['isActive'] == true).map((r) {
          final videoType = r['videoType'] as String? ?? 'upload';
          final rawVideoUrl = r['videoUrl'] as String? ?? '';
          final rawThumbUrl = r['thumbnailUrl'] as String? ?? '';

          // Build absolute URLs for uploaded files
          final String videoUrl = rawVideoUrl.startsWith('http')
              ? rawVideoUrl
              : '$mediaBase$rawVideoUrl';
          final String thumbUrl = rawThumbUrl.startsWith('http')
              ? rawThumbUrl
              : '$mediaBase$rawThumbUrl';

          return <String, dynamic>{
            'id': r['_id']?.toString() ?? '',
            'title': r['title'] ?? '',
            'description': r['description'] ?? '',
            'category': r['category'] ?? '',
            'type': 'video',
            'videoType': videoType,
            'url': videoUrl,
            'thumbnail': thumbUrl,
            'createdAt': r['createdAt'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading parent resources: $e');
    } finally {
      isLoadingResources.value = false;
    }
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void viewKidDetails(Map<String, dynamic> kid) {
    Get.toNamed(Routes.KID_DETAILED_PROGRESS, arguments: {'kid': kid});
  }

  void playResource(Map<String, dynamic> resource) {
    final videoType = resource['videoType'] as String? ?? 'upload';
    final url = resource['url'] as String? ?? '';

    if (videoType == 'youtube' && url.isNotEmpty) {
      // Open YouTube URL in the external browser / YouTube app
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (url.isNotEmpty) {
      Get.toNamed(
        '/promotional-video-player',
        arguments: {
          'videoUrl': url,
          'title': resource['title'],
          'description': resource['description'] ?? 'Parent resource video',
        },
      );
    }
  }

  Future<void> submitReferral() async {
    final name = referralName.value.trim();
    final email = referralEmail.value.trim();
    final phone = referralPhone.value.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Missing Name',
        "Please enter your friend's name",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF43F5E),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_rounded, color: Colors.white),
      );
      return;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF43F5E),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_rounded, color: Colors.white),
      );
      return;
    }

    isSubmittingReferral.value = true;
    try {
      final res = await _parentService.sendReferral(
        name: name,
        email: email,
        phone: phone.isEmpty ? null : phone,
      );

      if (res['success'] == true) {
        // Add to local history
        referralHistory.add({
          'name': name,
          'email': email,
          'phone': phone.isEmpty ? null : phone,
          'sentAt': DateTime.now().toIso8601String(),
        });

        // Clear form
        referralName.value = '';
        referralEmail.value = '';
        referralPhone.value = '';
        referralNameCtrl.clear();
        referralEmailCtrl.clear();
        referralPhoneCtrl.clear();

        Get.snackbar(
          '🎉 Invitation Sent!',
          '$name will receive an invite email shortly.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
          borderRadius: 16,
        );
      } else {
        Get.snackbar(
          'Failed',
          res['message'] as String? ?? 'Could not send invitation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF43F5E),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // ── Debug: surface real error ──────────────────────────────────────────
      String errMsg = e.toString();
      // Dio errors carry a readable message
      if (errMsg.contains('DioException') || errMsg.contains('DioError')) {
        final match = RegExp(r'"message":"([^"]+)"').firstMatch(errMsg);
        if (match != null) errMsg = match.group(1)!;
      }
      debugPrint('📧 Referral error: $errMsg');

      // Fallback: add to history as "Queued" so UX feels complete
      referralHistory.add({
        'name': name,
        'email': email,
        'phone': phone.isEmpty ? null : phone,
        'sentAt': DateTime.now().toIso8601String(),
        'offline': true,
        'error': errMsg,
      });
      referralName.value = '';
      referralEmail.value = '';
      referralPhone.value = '';
      referralNameCtrl.clear();
      referralEmailCtrl.clear();
      referralPhoneCtrl.clear();

      Get.snackbar(
        '⚠️ Could Not Send',
        errMsg.length > 100 ? 'Network error — invitation queued.' : errMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
    } finally {
      isSubmittingReferral.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([_loadKids(), _loadResources(), _loadSupportTickets()]);
  }

  String getPerformanceLabel(String performance) {
    switch (performance) {
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Good';
      case 'needs-improvement':
        return 'Needs Improvement';
      default:
        return 'Good';
    }
  }

  String getPerformanceEmoji(String performance) {
    switch (performance) {
      case 'excellent':
        return '🌟';
      case 'good':
        return '👍';
      case 'needs-improvement':
        return '📈';
      default:
        return '📊';
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
      print('Error loading support tickets: $e');
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
}
