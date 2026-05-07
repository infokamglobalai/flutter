import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/parent_service.dart';

class KidDetailedProgressController extends GetxController {
  final ParentService _parentService = Get.find<ParentService>();
  final kidData = <String, dynamic>{}.obs;
  final isLoading = false.obs;
  final subjectProgress = <Map<String, dynamic>>[].obs;
  final recentActivities = <Map<String, dynamic>>[].obs;
  final assessmentHistory = <Map<String, dynamic>>[].obs;
  final kidId = ''.obs;

  Color get performanceColor {
    final performance = kidData['performance'] as String? ?? 'good';
    switch (performance) {
      case 'excellent':
        return const Color(0xFF10B981);
      case 'good':
        return const Color(0xFF6366F1);
      case 'needs-improvement':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String get performanceLabel {
    final performance = kidData['performance'] as String? ?? 'good';
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

  @override
  void onInit() {
    super.onInit();
    _loadKidData();
  }

  void _loadKidData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['kid'] != null) {
      kidData.value = Map<String, dynamic>.from(args['kid'] as Map);
      kidId.value = (kidData['id'] ?? '').toString();
      _processRealData();
      // Immediately try to refresh from backend to ensure data is current
      refreshData();
    }
  }

  void _processRealData() {
    isLoading.value = true;
    try {
      _computeSubjectProgress();
      _computeAssessmentHistory();
      _buildRecentActivities();
    } catch (e) {
      print('Error processing kid data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Build per-subject aggregated progress from packages → chapters
  void _computeSubjectProgress() {
    final packages = ((kidData['packages'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

    // Group chapters by subject
    final Map<String, Map<String, dynamic>> bySubject = {};

    for (final pkg in packages) {
      final chapters = ((pkg['chapters'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
      for (final ch in chapters) {
        final subject = ch['subjectName']?.toString() ?? 'General';
        bySubject.putIfAbsent(
          subject,
          () => {
            'name': subject,
            'totalChapters': 0,
            'videosWatched': 0,
            'assessmentsCompleted': 0,
            'scoreSum': 0.0,
            'scoreCount': 0,
          },
        );

        final entry = bySubject[subject]!;
        entry['totalChapters'] = (entry['totalChapters'] as int) + 1;
        if (ch['videoCompleted'] == true) {
          entry['videosWatched'] = (entry['videosWatched'] as int) + 1;
        }
        final assessment = ch['assessment'] as Map<String, dynamic>?;
        if (assessment != null) {
          entry['assessmentsCompleted'] =
              (entry['assessmentsCompleted'] as int) + 1;
          final pct = (assessment['percentage'] as num?)?.toDouble() ?? 0.0;
          entry['scoreSum'] = (entry['scoreSum'] as double) + pct;
          entry['scoreCount'] = (entry['scoreCount'] as int) + 1;
        }
      }
    }

    subjectProgress.value =
        bySubject.values.map((s) {
          final total = s['totalChapters'] as int;
          final watched = s['videosWatched'] as int;
          final count = s['scoreCount'] as int;
          final avgScore = count > 0
              ? ((s['scoreSum'] as double) / count).round()
              : 0;
          return {
            'name': s['name'],
            'videosWatched': watched,
            'totalVideos': total,
            'progress': total > 0 ? watched / total : 0.0,
            'assessmentsCompleted': s['assessmentsCompleted'],
            'averageScore': avgScore,
            'scoreCount': count,
          };
        }).toList()..sort(
          (a, b) =>
              (b['averageScore'] as int).compareTo(a['averageScore'] as int),
        );
  }

  /// Build a flat sorted list of all chapter & self-assessment attempts
  void _computeAssessmentHistory() {
    final packages = ((kidData['packages'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

    final List<Map<String, dynamic>> history = [];

    for (final pkg in packages) {
      final chapters = ((pkg['chapters'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
      final selfAttempts = ((pkg['selfAssessments'] as List?) ?? [])
          .cast<Map<String, dynamic>>();

      for (final ch in chapters) {
        final assessment = ch['assessment'] as Map<String, dynamic>?;
        if (assessment == null) continue;
        history.add({
          'type': 'chapter',
          'subject': ch['subjectName'] ?? 'Subject',
          'chapter': ch['chapterName'] ?? '',
          'score': (assessment['lastScore'] as num?)?.toInt() ?? 0,
          'totalMarks': (assessment['totalMarks'] as num?)?.toInt() ?? 0,
          'percentage': (assessment['percentage'] as num?)?.toDouble() ?? 0.0,
          'date': assessment['lastAttemptAt']?.toString() ?? '',
          'packageName': pkg['packageName'] ?? '',
        });
      }

      for (final sa in selfAttempts) {
        history.add({
          'type': 'self',
          'subject': 'Self Assessment',
          'chapter': sa['title'] ?? 'Test',
          'score': (sa['obtainedMarks'] as num?)?.toInt() ?? 0,
          'totalMarks': (sa['totalMarks'] as num?)?.toInt() ?? 0,
          'percentage': (sa['percentage'] as num?)?.toDouble() ?? 0.0,
          'date': sa['completedAt']?.toString() ?? '',
          'packageName': pkg['packageName'] ?? '',
        });
      }
    }

    history.sort((a, b) {
      if ((a['date'] as String).isEmpty) return 1;
      if ((b['date'] as String).isEmpty) return -1;
      return (b['date'] as String).compareTo(a['date'] as String);
    });

    assessmentHistory.value = history;
  }

  /// Build recent activities from videos watched + assessment history
  void _buildRecentActivities() {
    final packages = ((kidData['packages'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

    final List<Map<String, dynamic>> activities = [];

    for (final pkg in packages) {
      final chapters = ((pkg['chapters'] as List?) ?? [])
          .cast<Map<String, dynamic>>();

      for (final ch in chapters) {
        if (ch['videoCompleted'] == true) {
          activities.add({
            'type': 'video',
            'title': 'Watched Video',
            'subtitle':
                '${ch['subjectName'] ?? ''} — ${ch['chapterName'] ?? ''}',
            'time': '',
            'score': null,
          });
        }
        final assessment = ch['assessment'] as Map<String, dynamic>?;
        if (assessment != null) {
          activities.add({
            'type': 'assessment',
            'title': 'Completed Assessment',
            'subtitle':
                '${ch['subjectName'] ?? ''} — ${ch['chapterName'] ?? ''}',
            'time': _formatDate(assessment['lastAttemptAt']?.toString() ?? ''),
            'score': (assessment['percentage'] as num?)?.toInt() ?? 0,
          });
        }
      }
    }

    recentActivities.value = activities.take(10).toList();
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String getPerformanceMessage() {
    final performance = kidData['performance'] as String? ?? 'good';
    final int avgScore = kidData['averageScore'] as int? ?? 0;
    switch (performance) {
      case 'excellent':
        return 'Outstanding! Your child is excelling across subjects with an average score of $avgScore%.';
      case 'good':
        return 'Great progress! Your child performs well with an average of $avgScore%. Encourage consistency.';
      case 'needs-improvement':
        return 'Your child is making progress with an average of $avgScore%. Consider extra support in weaker areas.';
      default:
        return 'Your child is performing with an average score of $avgScore%.';
    }
  }

  Future<void> refreshData() async {
    final id = kidId.value;
    if (id.isEmpty) {
      _processRealData();
      return;
    }

    isLoading.value = true;
    try {
      final resp = await _parentService.getStudentProgress(id);
      if (resp['success'] == true) {
        final progressData = (resp['data'] as Map?)?.cast<String, dynamic>() ?? {};
        final stats = ParentService.computeStats(progressData);
        kidData.addAll(stats);
        kidData.refresh();
      }
    } catch (_) {
      // best-effort; keep existing data
    } finally {
      _processRealData();
    }
  }
}
