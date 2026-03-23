import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:najahapp/app/data/repositories/worksheets_repository.dart';
import 'package:najahapp/app/data/models/worksheet_model.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/core/services/storage_service.dart';

class WorksheetsController extends GetxController {
  final WorksheetsRepository _worksheetsRepository = WorksheetsRepository();
  final DataService _dataService = DataService();
  final StorageService _storageService = Get.find<StorageService>();

  // State
  final worksheets = <WorksheetModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalWorksheets = 0.obs;
  final hasMorePages = false.obs;

  // Filters
  final selectedGradeId = Rx<String?>(null);
  final selectedSubjectId = Rx<String?>(null);
  final selectedChapterId = Rx<String?>(null);
  final selectedYear = Rx<int?>(null);

  // Filter Options (populated from API)
  final grades = <Map<String, String>>[].obs;
  final subjects = <Map<String, String>>[].obs;
  final chapters = <Map<String, String>>[].obs;
  final years = <int>[].obs;

  // Download state
  final downloadingIds = <String>[].obs;
  final downloadProgress = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadFilterOptions();
    fetchWorksheets();
  }

  /// Load filter options from API
  Future<void> loadFilterOptions() async {
    try {
      // Load grades
      final gradesResult = await _dataService.fetchGrades(limit: 100);
      if (gradesResult['success'] == true) {
        final gradesList = (gradesResult['grades'] as List)
            .map(
              (g) => <String, String>{
                'id': g.id.toString(),
                'name': g.name.toString(),
              },
            )
            .toList();
        grades.value = gradesList;
      }

      // Load subjects
      final subjectsResult = await _dataService.fetchSubjects(limit: 100);
      if (subjectsResult['success'] == true) {
        final subjectsList = (subjectsResult['subjects'] as List)
            .map(
              (s) => <String, String>{
                'id': s.id.toString(),
                'name': s.name.toString(),
              },
            )
            .toList();
        subjects.value = subjectsList;
      }

      // Generate years (last 3 years)
      final currentYear = DateTime.now().year;
      years.value = List.generate(3, (index) => currentYear - index);
    } catch (e) {
      print('Error loading filter options: $e');
    }
  }

  /// Fetch chapters when subject changes
  Future<void> loadChaptersForSubject(String subjectId) async {
    try {
      final subjectChaptersResult = await _dataService.fetchChaptersForSubjects(
        [subjectId],
      );
      if (subjectChaptersResult.isNotEmpty) {
        final subjectChapters = subjectChaptersResult.first;
        final chaptersList = subjectChapters.chapters
            .map(
              (c) => <String, String>{
                'id': c.id.toString(),
                'name': c.name.toString(),
              },
            )
            .toList();
        chapters.value = chaptersList;
      } else {
        chapters.clear();
      }
    } catch (e) {
      print('Error loading chapters: $e');
      chapters.clear();
    }
  }

  /// Fetch worksheets from API
  Future<void> fetchWorksheets({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMorePages.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
      currentPage.value++;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
      worksheets.clear();
      errorMessage.value = '';
    }

    try {
      final response = await _worksheetsRepository.getWorksheets(
        page: currentPage.value,
        limit: 20,
        gradeId: selectedGradeId.value,
        subjectId: selectedSubjectId.value,
        chapterId: selectedChapterId.value,
        academicYear: selectedYear.value,
      );

      if (loadMore) {
        worksheets.addAll(response.data);
      } else {
        worksheets.value = response.data;
      }

      totalWorksheets.value = response.pagination.total;
      totalPages.value = response.pagination.pages;
      hasMorePages.value = currentPage.value < totalPages.value;

      errorMessage.value = '';
    } catch (e) {
      print('Error fetching worksheets: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Error',
        'Failed to load worksheets: ${errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Apply filters and refresh
  void applyFilters() {
    fetchWorksheets();
  }

  /// Clear all filters
  void clearFilters() {
    selectedGradeId.value = null;
    selectedSubjectId.value = null;
    selectedChapterId.value = null;
    selectedYear.value = null;
    chapters.clear();
    fetchWorksheets();
  }

  /// Set grade filter
  void setGradeFilter(String? gradeId) {
    selectedGradeId.value = gradeId;
    // Clear dependent filters
    selectedSubjectId.value = null;
    selectedChapterId.value = null;
    chapters.clear();
    applyFilters();
  }

  /// Set subject filter
  void setSubjectFilter(String? subjectId) {
    selectedSubjectId.value = subjectId;
    selectedChapterId.value = null;

    if (subjectId != null) {
      loadChaptersForSubject(subjectId);
    } else {
      chapters.clear();
    }
    applyFilters();
  }

  /// Set chapter filter
  void setChapterFilter(String? chapterId) {
    selectedChapterId.value = chapterId;
    applyFilters();
  }

  /// Set year filter
  void setYearFilter(int? year) {
    selectedYear.value = year;
    applyFilters();
  }

  /// Download worksheet and open automatically
  Future<void> downloadWorksheet(WorksheetModel worksheet) async {
    // Check if already downloading
    if (downloadingIds.contains(worksheet.id)) {
      Get.snackbar(
        'Download in Progress',
        'This worksheet is already being downloaded',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Request storage permission on Android (only needed for older versions)
    if (Platform.isAndroid) {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return;
      }
    }

    downloadingIds.add(worksheet.id);
    downloadProgress[worksheet.id] = 0.0;

    try {
      // Get download directory
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/${worksheet.fileName}';

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        downloadingIds.remove(worksheet.id);
        downloadProgress.remove(worksheet.id);

        // Ask user if they want to redownload or just open
        final shouldRedownload = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('File Already Exists'),
            content: Text(
              '${worksheet.fileName} already exists. Do you want to open it or download again?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Open Existing'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Download Again'),
              ),
            ],
          ),
        );

        if (shouldRedownload != true) {
          await _openFile(filePath, worksheet.fileName);
          return;
        }
      }

      // Show downloading snackbar
      Get.snackbar(
        'Downloading',
        worksheet.fileName,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );

      // Get authentication token
      final token = await _storageService.getToken();

      // Download file using Dio with authentication
      final dio = Dio();
      final downloadUrl = _worksheetsRepository.getDownloadUrl(
        worksheet.filePath,
      );

      // Debug logging
      print('📥 Downloading worksheet:');
      print('   File: ${worksheet.fileName}');
      print('   URL: $downloadUrl');
      print('   Save to: $filePath');

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      await dio.download(
        downloadUrl,
        filePath,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress[worksheet.id] = progress;
          }
        },
      );

      downloadingIds.remove(worksheet.id);
      downloadProgress.remove(worksheet.id);

      // Show success message
      Get.snackbar(
        'Download Complete',
        worksheet.fileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Automatically open the downloaded file
      await _openFile(filePath, worksheet.fileName);
    } catch (e) {
      downloadingIds.remove(worksheet.id);
      downloadProgress.remove(worksheet.id);

      print('Error downloading worksheet: $e');
      Get.snackbar(
        'Download Failed',
        'Failed to download ${worksheet.fileName}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Get download directory based on platform
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Try to get external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Create NajahApp/Worksheets folder
        final worksheetsDir = Directory(
          '${directory.path}/NajahApp/Worksheets',
        );
        if (!await worksheetsDir.exists()) {
          await worksheetsDir.create(recursive: true);
        }
        return worksheetsDir;
      }
    }
    // Fallback to application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final worksheetsDir = Directory('${directory.path}/Worksheets');
    if (!await worksheetsDir.exists()) {
      await worksheetsDir.create(recursive: true);
    }
    return worksheetsDir;
  }

  /// Request storage permission for Android
  Future<bool> _requestStoragePermission() async {
    // For Android 13+ (API 33+), we don't need storage permissions for app-specific directories
    // For Android 10-12, we still need to request permissions
    try {
      // Check if permission is already granted
      if (await Permission.storage.isGranted) {
        return true;
      }

      // For Android 13+, check if we can access our app directory without permission
      if (Platform.isAndroid) {
        final testDir = await getExternalStorageDirectory();
        if (testDir != null) {
          // We can access app-specific directory without permission
          return true;
        }
      }

      // Request permission
      final status = await Permission.storage.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        final shouldOpenSettings = await Get.dialog<bool>(
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.folder, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('Storage Permission Required'),
              ],
            ),
            content: const Text(
              'This app needs storage permission to download worksheets. '
              'Please grant the permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
        return false;
      } else if (status.isDenied) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is needed to download files',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      return false;
    } catch (e) {
      print('Error requesting storage permission: $e');
      // If permission handling fails, try to continue anyway
      // (app-specific directory doesn't require permission on Android 10+)
      return true;
    }
  }

  /// Open downloaded file
  Future<void> _openFile(String filePath, String fileName) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        Get.snackbar(
          'Unable to Open',
          'No app found to open $fileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      Get.snackbar(
        'Error',
        'Failed to open $fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Helper methods for UI
  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'worksheet':
        return Icons.description;
      case 'exercise':
        return Icons.fitness_center;
      case 'practice set':
        return Icons.quiz;
      default:
        return Icons.file_copy;
    }
  }

  /// Get grade name by ID
  String? getGradeName(String? gradeId) {
    if (gradeId == null) return null;
    return grades.firstWhereOrNull((g) => g['id'] == gradeId)?['name'];
  }

  /// Get subject name by ID
  String? getSubjectName(String? subjectId) {
    if (subjectId == null) return null;
    return subjects.firstWhereOrNull((s) => s['id'] == subjectId)?['name'];
  }

  /// Get chapter name by ID
  String? getChapterName(String? chapterId) {
    if (chapterId == null) return null;
    return chapters.firstWhereOrNull((c) => c['id'] == chapterId)?['name'];
  }
}
