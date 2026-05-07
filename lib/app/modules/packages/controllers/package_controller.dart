import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/data/models/package_model.dart';
import 'package:najahapp/app/data/models/grade_model.dart';
import 'package:najahapp/app/data/models/board_model.dart';
import 'package:najahapp/app/data/models/subject_model.dart';
import 'package:najahapp/app/data/models/chapter_model.dart';
import 'package:najahapp/app/data/services/package_service.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/data/services/coupon_service.dart';

class PackageController extends GetxController {
  final PackageService _packageService = PackageService();
  final DataService _dataService = DataService();
  final CouponService _couponService = Get.find<CouponService>();

  // Package data from API
  final RxList<PackageModel> publicPackages = <PackageModel>[].obs;
  final RxBool isLoadingPackages = false.obs;
  final RxString packagesError = ''.obs;
  final RxList<String> availablePackageTypes = <String>[].obs;
  final Rx<PackageModel?> selectedPackageModel = Rx<PackageModel?>(null);

  // Grades data from API
  final RxList<GradeModel> publicGrades = <GradeModel>[].obs;
  final RxBool isLoadingGrades = false.obs;
  final RxString gradesError = ''.obs;

  // Boards data from API
  final RxList<BoardModel> publicBoards = <BoardModel>[].obs;
  final RxBool isLoadingBoards = false.obs;
  final RxString boardsError = ''.obs;

  // Subjects data from API
  final RxList<SubjectModel> publicSubjects = <SubjectModel>[].obs;
  final RxBool isLoadingSubjects = false.obs;
  final RxString subjectsError = ''.obs;

  // Chapters data from API
  final RxList<SubjectChapters> subjectChapters = <SubjectChapters>[].obs;
  final RxBool isLoadingChapters = false.obs;
  final RxString chaptersError = ''.obs;

  // Selection state
  final Rx<GradeModel?> selectedGradeModel = Rx<GradeModel?>(null);
  final Rx<BoardModel?> selectedBoardModel = Rx<BoardModel?>(null);
  final selectedPackage = ''.obs;
  final selectedBoard = ''.obs;
  final RxList<SubjectModel> selectedSubjectModels = <SubjectModel>[].obs;
  final selectedSubjects = <String>[].obs;
  final RxMap<String, List<String>> selectedChapters =
      <String, List<String>>{}.obs;

  // Pricing
  final double pricePerChapter = 299.0; // Base price per chapter
  final cartItems = <Map<String, dynamic>>[].obs;

  // Coupon
  final couponCode = ''.obs;
  final couponDiscount = 0.0.obs;
  final couponFinalAmount = 0.0.obs;
  final isApplyingCoupon = false.obs;
  final couponMessage = ''.obs;

  // Deep-link preselects (web parity: /student/grade/:gradeId/subjects...)
  final RxString _preselectGradeId = ''.obs;
  final RxString _preselectSubjectId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      final args = (Get.arguments as Map).cast<String, dynamic>();
      // These are optional; used when opening selection screens from deep-links.
      _setPreselects(
        gradeId: args['preselectGradeId']?.toString(),
        subjectId: args['preselectSubjectId']?.toString(),
      );
    }
    // Load grades, boards, and subjects
    loadPublicGrades();
    loadPublicBoards();
    loadSubjects();

    // Check if package was passed from dashboard
    if (Get.arguments != null && Get.arguments is PackageModel) {
      selectedPackageModel.value = Get.arguments as PackageModel;
      // Set available types from the selected package
      availablePackageTypes.value = selectedPackageModel.value!.types;
    } else {
      // Load all public packages if no specific package selected
      loadPublicPackages();
    }
  }

  void _setPreselects({String? gradeId, String? subjectId}) {
    final g = (gradeId ?? '').trim();
    final s = (subjectId ?? '').trim();
    _preselectGradeId.value = g;
    _preselectSubjectId.value = s;
  }

  void _applyPreselectsIfPossible() {
    if (_preselectGradeId.value.isNotEmpty && selectedGradeModel.value == null) {
      final g = publicGrades.firstWhereOrNull(
        (e) => e.id == _preselectGradeId.value,
      );
      if (g != null) selectedGradeModel.value = g;
    }

    if (_preselectSubjectId.value.isNotEmpty && selectedSubjectModels.isEmpty) {
      final s = publicSubjects.firstWhereOrNull(
        (e) => e.id == _preselectSubjectId.value,
      );
      if (s != null) {
        selectedSubjectModels.assignAll([s]);
        selectedSubjects.assignAll([s.id]);
      }
    }
  }

  Future<void> loadPublicGrades() async {
    try {
      isLoadingGrades.value = true;
      gradesError.value = '';

      final grades = await _dataService.fetchPublicGrades();
      publicGrades.value = grades;
      _applyPreselectsIfPossible();
    } catch (e) {
      gradesError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingGrades.value = false;
    }
  }

  Future<void> loadPublicBoards() async {
    try {
      isLoadingBoards.value = true;
      boardsError.value = '';

      final boards = await _dataService.fetchPublicBoards();
      publicBoards.value = boards;
    } catch (e) {
      boardsError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingBoards.value = false;
    }
  }

  Future<void> loadSubjects() async {
    try {
      isLoadingSubjects.value = true;
      subjectsError.value = '';

      final result = await _dataService.fetchSubjects(limit: 100);
      if (result['success'] == true) {
        publicSubjects.value = result['subjects'] as List<SubjectModel>;
        _applyPreselectsIfPossible();
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      subjectsError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingSubjects.value = false;
    }
  }

  Future<void> loadPublicPackages() async {
    try {
      isLoadingPackages.value = true;
      packagesError.value = '';

      final packages = await _packageService.getPublicPackages();
      publicPackages.value = packages.where((p) => p.isActive).toList();

      // Extract all unique package types
      final Set<String> typesSet = {};
      for (var package in publicPackages) {
        typesSet.addAll(package.types);
      }
      availablePackageTypes.value = typesSet.toList();
    } catch (e) {
      packagesError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingPackages.value = false;
    }
  }

  // Get display name for package type
  String getPackageTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'genius':
        return 'GENIUS';
      case 'challenger':
        return 'CHALLENGER';
      case 'slow-learner':
      case 'slow_learner':
        return 'SLOW LEARNER';
      case 'revision':
        return 'REVISION';
      case 'revision-test':
      case 'revision_test':
        return 'REVISION TEST';
      case 'live-coaching':
      case 'lecture-class':
      case 'lecture_class':
        return 'LECTURE CLASS';
      default:
        return type.toUpperCase();
    }
  }

  // Get icon for package type
  IconData getPackageTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'genius':
        return Icons.lightbulb_rounded;
      case 'challenger':
        return Icons.emoji_events_rounded;
      case 'slow-learner':
      case 'slow_learner':
        return Icons.favorite_rounded;
      case 'revision':
        return Icons.refresh_rounded;
      case 'revision-test':
      case 'revision_test':
        return Icons.quiz_rounded;
      case 'live-coaching':
      case 'lecture-class':
      case 'lecture_class':
        return Icons.school_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  // Get color for package type
  Color getPackageTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'genius':
        return const Color(0xFF8B5CF6);
      case 'challenger':
        return const Color(0xFF10B981);
      case 'slow-learner':
      case 'slow_learner':
        return const Color(0xFFEF4444);
      case 'revision':
        return const Color(0xFF8B5CF6);
      case 'revision-test':
      case 'revision_test':
        return const Color(0xFF06B6D4);
      case 'live-coaching':
      case 'lecture-class':
      case 'lecture_class':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  // Get subtitle for package type
  String getPackageTypeSubtitle(String type) {
    switch (type.toLowerCase()) {
      case 'genius':
        return 'Advanced Learning';
      case 'challenger':
        return 'Standard Learning';
      case 'slow-learner':
      case 'slow_learner':
        return 'Personalized Pace';
      case 'revision':
        return 'Exam Preparation';
      case 'revision-test':
      case 'revision_test':
        return 'Test Practice';
      case 'live-coaching':
      case 'lecture-class':
      case 'lecture_class':
        return 'Live Sessions';
      default:
        return 'Learning Package';
    }
  }

  // Get description for package type
  String getPackageTypeDescription(String type) {
    switch (type.toLowerCase()) {
      case 'genius':
        return 'For high achievers seeking excellence';
      case 'challenger':
        return 'Balanced curriculum for steady progress';
      case 'slow-learner':
      case 'slow_learner':
        return 'Patient guidance at your own speed';
      case 'revision':
        return 'Final exam focused revision';
      case 'revision-test':
      case 'revision_test':
        return 'Mock tests and assessments';
      case 'live-coaching':
      case 'lecture-class':
      case 'lecture_class':
        return 'Interactive live classroom';
      default:
        return 'Comprehensive learning experience';
    }
  }

  void selectGrade(GradeModel grade) {
    selectedGradeModel.value = grade;
  }

  void selectPackage(String package) {
    selectedPackage.value = package;

    // Check if the selected package model is a competitive exam
    final isCompetitiveExam =
        selectedPackageModel.value?.isCompetitiveExam ?? false;

    if (isCompetitiveExam) {
      // Skip board selection for competitive exams, go directly to subject selection
      Get.toNamed('/subject-selection');
    } else {
      // Navigate to board selection for regular packages
      Get.toNamed('/board-selection');
    }
  }

  void selectBoard(BoardModel board) {
    selectedBoardModel.value = board;
    selectedBoard.value = board.name;
    // Navigate to subject selection
    Get.toNamed('/subject-selection');
  }

  void toggleSubject(SubjectModel subject) {
    final subjectName = subject.name;
    if (selectedSubjects.contains(subjectName)) {
      selectedSubjects.remove(subjectName);
      selectedSubjectModels.removeWhere((s) => s.name == subjectName);
      selectedChapters.remove(subjectName);
    } else {
      selectedSubjects.add(subjectName);
      selectedSubjectModels.add(subject);
      selectedChapters[subjectName] = [];
    }
    // Load chapters when subjects change
    if (selectedSubjectModels.isNotEmpty) {
      loadChapters();
    }
  }

  bool isSubjectSelected(SubjectModel subject) {
    return selectedSubjects.contains(subject.name);
  }

  Future<void> loadChapters() async {
    try {
      isLoadingChapters.value = true;
      chaptersError.value = '';

      // Get subject IDs from selected subjects
      final subjectIds = selectedSubjectModels
          .map((subject) => subject.id)
          .toList();

      if (subjectIds.isEmpty) {
        subjectChapters.value = [];
        return;
      }

      final chapters = await _dataService.fetchChaptersForSubjects(subjectIds);
      subjectChapters.value = chapters;
    } catch (e) {
      chaptersError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingChapters.value = false;
    }
  }

  List<ChapterModel> getChaptersForSubject(String subjectName) {
    final subjectChapter = subjectChapters.firstWhereOrNull(
      (sc) => sc.subject == subjectName,
    );
    return subjectChapter?.chapters ?? [];
  }

  void toggleChapter(String subjectName, String chapterId) {
    if (!selectedChapters.containsKey(subjectName)) {
      selectedChapters[subjectName] = [];
    }

    if (selectedChapters[subjectName]!.contains(chapterId)) {
      selectedChapters[subjectName]!.remove(chapterId);
    } else {
      selectedChapters[subjectName]!.add(chapterId);
    }
    selectedChapters.refresh();
  }

  void selectAllChaptersForSubject(String subjectName) {
    final chapters = getChaptersForSubject(subjectName);
    selectedChapters[subjectName] = chapters.map((c) => c.id).toList();
    selectedChapters.refresh();
  }

  void selectAllChaptersForAllSubjects() {
    for (var subject in selectedSubjectModels) {
      final chapters = getChaptersForSubject(subject.name);
      selectedChapters[subject.name] = chapters.map((c) => c.id).toList();
    }
    selectedChapters.refresh();
  }

  bool isChapterSelected(String subjectName, String chapterId) {
    return selectedChapters[subjectName]?.contains(chapterId) ?? false;
  }

  int getSelectedChapterCount(String subjectName) {
    return selectedChapters[subjectName]?.length ?? 0;
  }

  int getTotalSelectedChapters() {
    return selectedChapters.values.fold(0, (sum, list) => sum + list.length);
  }

  double getSubjectPrice(String subjectName) {
    final selectedChapterIds = selectedChapters[subjectName] ?? [];
    final chapters = getChaptersForSubject(subjectName);

    double total = 0;
    for (var chapterId in selectedChapterIds) {
      final chapter = chapters.firstWhereOrNull((c) => c.id == chapterId);
      if (chapter != null) {
        total += chapter.price;
      }
    }
    return total;
  }

  double getTotalPrice() {
    double total = 0;
    for (var subjectName in selectedChapters.keys) {
      total += getSubjectPrice(subjectName);
    }
    return total;
  }

  double getDiscountedPrice() {
    final total = getTotalPrice();
    final chapters = getTotalSelectedChapters();

    // Apply bulk discounts
    if (chapters >= 50) {
      return total * 0.70; // 30% off
    } else if (chapters >= 30) {
      return total * 0.80; // 20% off
    } else if (chapters >= 15) {
      return total * 0.90; // 10% off
    }
    return total;
  }

  double getFinalPayableAmount() {
    final bulkDiscounted = getDiscountedPrice();
    final hasCoupon = couponDiscount.value > 0 &&
        couponFinalAmount.value > 0 &&
        couponFinalAmount.value <= bulkDiscounted;
    return hasCoupon ? couponFinalAmount.value : bulkDiscounted;
  }

  Future<void> applyCoupon() async {
    final code = couponCode.value.trim();
    if (code.isEmpty) {
      couponMessage.value = 'Enter a coupon code';
      return;
    }

    try {
      isApplyingCoupon.value = true;
      couponMessage.value = '';
      final amount = getDiscountedPrice();
      final res = await _couponService.validate(code: code, amount: amount);
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        couponDiscount.value =
            ((data['discountAmount'] ?? 0) as num).toDouble();
        couponFinalAmount.value = ((data['finalAmount'] ?? amount) as num).toDouble();
        couponMessage.value =
            'Coupon applied: -₹${couponDiscount.value.toStringAsFixed(0)}';
      } else {
        couponDiscount.value = 0;
        couponFinalAmount.value = 0;
        couponMessage.value = (res['message'] ?? 'Invalid coupon').toString();
      }
    } catch (e) {
      couponDiscount.value = 0;
      couponFinalAmount.value = 0;
      couponMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  void clearCoupon() {
    couponCode.value = '';
    couponDiscount.value = 0;
    couponFinalAmount.value = 0;
    couponMessage.value = '';
  }

  double getSavings() {
    return getTotalPrice() - getDiscountedPrice();
  }

  void resetSelection() {
    selectedGradeModel.value = null;
    selectedPackage.value = '';
    selectedBoard.value = '';
    selectedSubjects.clear();
    selectedSubjectModels.clear();
    selectedChapters.clear();
  }
}
