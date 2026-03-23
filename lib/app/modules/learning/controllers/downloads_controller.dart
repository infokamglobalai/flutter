import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadsController extends GetxController {
  // Downloaded content
  final downloadedVideos = <Map<String, dynamic>>[].obs;
  final downloadedDocuments = <Map<String, dynamic>>[].obs;

  // Filters
  final selectedFilter = 'all'.obs; // 'all', 'videos', 'documents'
  final selectedSubject = Rxn<String>();
  final searchQuery = ''.obs;

  // Statistics
  final totalVideosWatched = 0.obs;
  final totalDurationWatched = 0.obs; // in minutes
  final totalAssessmentsCompleted = 0.obs;
  final averageAssessmentScore = 0.obs;
  final totalExercisesSubmitted = 0.obs;
  final totalNotesWritten = 0.obs;

  // Loading states
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDownloads();
    loadStatistics();
  }

  Future<void> loadDownloads() async {
    try {
      isLoading.value = true;

      // Simulate API call - Replace with actual API
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock downloaded videos with comprehensive data
      downloadedVideos.value = [
        {
          'id': 'vid001',
          'title': 'Introduction to Quadratic Equations',
          'subject': 'Mathematics',
          'chapter': 'Chapter 4: Quadratic Equations',
          'grade': 'Grade 10',
          'board': 'CBSE',
          'duration': 1845, // seconds (30 min 45 sec)
          'thumbnail': 'https://via.placeholder.com/320x180',
          'downloadedAt': DateTime.now().subtract(const Duration(days: 2)),
          'lastWatchedAt': DateTime.now().subtract(const Duration(hours: 5)),
          'watchProgress': 0.75, // 75% watched
          'watched': true,
          'timeWatched': 1384, // seconds actually watched
          'downloadSize': '156 MB',
          'notesCount': 8,
          'assessmentCompleted': true,
          'assessmentScore': 85,
          'exerciseSubmitted': true,
        },
        {
          'id': 'vid002',
          'title': 'Chemical Reactions and Equations',
          'subject': 'Science',
          'chapter': 'Chapter 1: Chemical Reactions',
          'grade': 'Grade 10',
          'board': 'CBSE',
          'duration': 2160, // 36 minutes
          'thumbnail': 'https://via.placeholder.com/320x180',
          'downloadedAt': DateTime.now().subtract(const Duration(days: 5)),
          'lastWatchedAt': DateTime.now().subtract(const Duration(days: 1)),
          'watchProgress': 1.0, // 100% watched
          'watched': true,
          'timeWatched': 2160,
          'downloadSize': '189 MB',
          'notesCount': 12,
          'assessmentCompleted': true,
          'assessmentScore': 92,
          'exerciseSubmitted': true,
        },
        {
          'id': 'vid003',
          'title': 'Photosynthesis Process',
          'subject': 'Biology',
          'chapter': 'Chapter 6: Life Processes',
          'grade': 'Grade 10',
          'board': 'CBSE',
          'duration': 1560, // 26 minutes
          'thumbnail': 'https://via.placeholder.com/320x180',
          'downloadedAt': DateTime.now().subtract(const Duration(days: 1)),
          'lastWatchedAt': null,
          'watchProgress': 0.0,
          'watched': false,
          'timeWatched': 0,
          'downloadSize': '142 MB',
          'notesCount': 0,
          'assessmentCompleted': false,
          'assessmentScore': null,
          'exerciseSubmitted': false,
        },
        {
          'id': 'vid004',
          'title': 'Linear Equations in Two Variables',
          'subject': 'Mathematics',
          'chapter': 'Chapter 3: Linear Equations',
          'grade': 'Grade 10',
          'board': 'CBSE',
          'duration': 1920, // 32 minutes
          'thumbnail': 'https://via.placeholder.com/320x180',
          'downloadedAt': DateTime.now().subtract(const Duration(days: 7)),
          'lastWatchedAt': DateTime.now().subtract(const Duration(days: 3)),
          'watchProgress': 0.45,
          'watched': false,
          'timeWatched': 864,
          'downloadSize': '167 MB',
          'notesCount': 5,
          'assessmentCompleted': false,
          'assessmentScore': null,
          'exerciseSubmitted': false,
        },
        {
          'id': 'vid005',
          'title': 'Electricity and Circuits',
          'subject': 'Physics',
          'chapter': 'Chapter 12: Electricity',
          'grade': 'Grade 10',
          'board': 'CBSE',
          'duration': 2400, // 40 minutes
          'thumbnail': 'https://via.placeholder.com/320x180',
          'downloadedAt': DateTime.now().subtract(const Duration(days: 3)),
          'lastWatchedAt': DateTime.now().subtract(const Duration(hours: 12)),
          'watchProgress': 1.0,
          'watched': true,
          'timeWatched': 2400,
          'downloadSize': '198 MB',
          'notesCount': 15,
          'assessmentCompleted': true,
          'assessmentScore': 78,
          'exerciseSubmitted': true,
        },
        {
          'id': 'vid006',
          'title': 'Polynomials - Basics',
          'subject': 'Mathematics',
          'chapter': 'Chapter 2: Polynomials',
          'grade': 'Grade 10',
          'board': 'CBSE',
          'duration': 1680, // 28 minutes
          'thumbnail': 'https://via.placeholder.com/320x180',
          'downloadedAt': DateTime.now().subtract(const Duration(hours: 18)),
          'lastWatchedAt': DateTime.now().subtract(const Duration(hours: 2)),
          'watchProgress': 0.60,
          'watched': false,
          'timeWatched': 1008,
          'downloadSize': '151 MB',
          'notesCount': 7,
          'assessmentCompleted': false,
          'assessmentScore': null,
          'exerciseSubmitted': true,
        },
      ];

      // Mock downloaded documents
      downloadedDocuments.value = [
        {
          'id': 'doc001',
          'name': 'Quadratic Equations - Study Notes',
          'type': 'PDF',
          'subject': 'Mathematics',
          'chapter': 'Chapter 4: Quadratic Equations',
          'grade': 'Grade 10',
          'size': '2.4 MB',
          'pages': 15,
          'downloadedAt': DateTime.now().subtract(const Duration(days: 2)),
          'lastOpenedAt': DateTime.now().subtract(const Duration(hours: 6)),
        },
        {
          'id': 'doc002',
          'name': 'Chemical Reactions - Formula Sheet',
          'type': 'PDF',
          'subject': 'Science',
          'chapter': 'Chapter 1: Chemical Reactions',
          'grade': 'Grade 10',
          'size': '1.8 MB',
          'pages': 8,
          'downloadedAt': DateTime.now().subtract(const Duration(days: 5)),
          'lastOpenedAt': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': 'doc003',
          'name': 'Physics Formulas Handbook',
          'type': 'PDF',
          'subject': 'Physics',
          'chapter': 'Chapter 12: Electricity',
          'grade': 'Grade 10',
          'size': '3.2 MB',
          'pages': 24,
          'downloadedAt': DateTime.now().subtract(const Duration(days: 3)),
          'lastOpenedAt': DateTime.now().subtract(const Duration(hours: 15)),
        },
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load downloads: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStatistics() async {
    try {
      // Calculate statistics from downloaded videos
      int watchedCount = 0;
      int totalWatchTime = 0;
      int assessmentsCompleted = 0;
      int totalAssessmentScore = 0;
      int exercisesSubmitted = 0;
      int notesCount = 0;

      for (var video in downloadedVideos) {
        if (video['watched'] == true) {
          watchedCount++;
        }
        totalWatchTime += (video['timeWatched'] as int);
        notesCount += (video['notesCount'] as int);

        if (video['assessmentCompleted'] == true) {
          assessmentsCompleted++;
          totalAssessmentScore += (video['assessmentScore'] as int? ?? 0);
        }

        if (video['exerciseSubmitted'] == true) {
          exercisesSubmitted++;
        }
      }

      totalVideosWatched.value = watchedCount;
      totalDurationWatched.value = (totalWatchTime / 60)
          .round(); // Convert to minutes
      totalAssessmentsCompleted.value = assessmentsCompleted;
      averageAssessmentScore.value = assessmentsCompleted > 0
          ? (totalAssessmentScore / assessmentsCompleted).round()
          : 0;
      totalExercisesSubmitted.value = exercisesSubmitted;
      totalNotesWritten.value = notesCount;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load statistics: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<Map<String, dynamic>> get filteredContent {
    var content = <Map<String, dynamic>>[];

    // Apply type filter
    if (selectedFilter.value == 'videos' || selectedFilter.value == 'all') {
      content.addAll(downloadedVideos);
    }
    if (selectedFilter.value == 'documents' || selectedFilter.value == 'all') {
      content.addAll(downloadedDocuments);
    }

    // Apply subject filter
    if (selectedSubject.value != null) {
      content = content
          .where((item) => item['subject'] == selectedSubject.value)
          .toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      content = content
          .where(
            (item) =>
                (item['title']?.toLowerCase().contains(query) ?? false) ||
                (item['name']?.toLowerCase().contains(query) ?? false) ||
                (item['subject']?.toLowerCase().contains(query) ?? false) ||
                (item['chapter']?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    // Sort by download date (newest first)
    content.sort((a, b) {
      final dateA = a['downloadedAt'] as DateTime;
      final dateB = b['downloadedAt'] as DateTime;
      return dateB.compareTo(dateA);
    });

    return content;
  }

  List<String> get availableSubjects {
    final subjects = <String>{};
    for (var video in downloadedVideos) {
      subjects.add(video['subject'] as String);
    }
    for (var doc in downloadedDocuments) {
      subjects.add(doc['subject'] as String);
    }
    return subjects.toList()..sort();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSubjectFilter(String? subject) {
    selectedSubject.value = subject;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearFilters() {
    selectedFilter.value = 'all';
    selectedSubject.value = null;
    searchQuery.value = '';
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    await loadDownloads();
    await loadStatistics();
    isRefreshing.value = false;
  }

  void openVideo(Map<String, dynamic> video) {
    Get.toNamed(
      '/video-player',
      arguments: {
        'chapter': {
          'id': video['id'],
          'name': video['title'],
          'subject': video['subject'],
          'chapterName': video['chapter'],
        },
        'offline': true,
      },
    );
  }

  void openDocument(Map<String, dynamic> document) {
    Get.toNamed(
      '/document-viewer',
      arguments: {'document': document, 'offline': true},
    );
  }

  Future<void> deleteDownload(String id, String type) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Download?'),
          content: const Text(
            'This will remove the downloaded content from your device. You can download it again later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Simulate deletion - Replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 500));

      if (type == 'video') {
        downloadedVideos.removeWhere((v) => v['id'] == id);
      } else {
        downloadedDocuments.removeWhere((d) => d['id'] == id);
      }

      await loadStatistics(); // Recalculate stats

      Get.snackbar(
        'Deleted',
        'Download removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete download: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
