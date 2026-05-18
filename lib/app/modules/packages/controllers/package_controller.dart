import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/data/models/package_model.dart';
import 'package:najahapp/app/data/models/grade_model.dart';
import 'package:najahapp/app/data/models/board_model.dart';
import 'package:najahapp/app/data/models/subject_model.dart';
import 'package:najahapp/app/data/models/chapter_model.dart';
import 'package:najahapp/app/data/services/package_service.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/data/services/coupon_service.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/modules/packages/views/ottu_payment_webview.dart';
import 'package:lottie/lottie.dart';

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

  // Selection state
  final Rx<GradeModel?> selectedGradeModel = Rx<GradeModel?>(null);
  final Rx<BoardModel?> selectedBoardModel = Rx<BoardModel?>(null);
  final selectedPackage = ''.obs;
  final selectedBoard = ''.obs;
  final RxList<String> selectedSubjectIds = <String>[].obs;
  final RxString paymentMode = 'full'.obs; // 'full' or 'installment'
  final RxBool isIndia = true.obs; // Default to true, can be updated based on IP/User profile
  
  List<SubjectModel> get selectedSubjectModels {
    final package = selectedPackageModel.value;
    if (package == null) return [];
    return package.subjects.where((s) => selectedSubjectIds.contains(s.id)).toList();
  }

  // Coupon
  final couponCode = ''.obs;
  final couponDiscount = 0.0.obs;
  final couponFinalAmount = 0.0.obs;
  final isApplyingCoupon = false.obs;
  final couponMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Reset state to avoid leakage from previous sessions
    selectedPackageModel.value = null;
    selectedSubjectIds.clear();
    paymentMode.value = 'full';
    clearCoupon();

    // Load initial data
    loadPublicPackages();

    // Check if package was passed from dashboard
    if (Get.arguments != null && Get.arguments is PackageModel) {
      selectedPackageModel.value = Get.arguments as PackageModel;
      availablePackageTypes.value = selectedPackageModel.value!.types;
      
      // If package-wise, select all subjects by default or based on requirements
      if (selectedPackageModel.value?.pricingType == 'package') {
        selectedSubjectIds.assignAll(
          selectedPackageModel.value!.subjects.map((s) => s.id).toList()
        );
      }
    }

    // Determine region dynamically
    _detectRegion();
  }

  void _detectRegion() {
    try {
      final userData = Get.find<StorageService>().getUserData();
      if (userData != null) {
        // Simple heuristic: if phone starts with +91 or no plus (India default)
        final phone = (userData['phone'] ?? '').toString();
        if (phone.startsWith('+91') || !phone.startsWith('+')) {
          isIndia.value = true;
        } else {
          isIndia.value = false;
        }
      }
    } catch (_) {
      isIndia.value = true; // Fallback
    }
  }

  Future<void> loadPublicPackages() async {
    try {
      isLoadingPackages.value = true;
      packagesError.value = '';

      final packages = await _packageService.getPublicPackages();
      publicPackages.value = packages.where((p) => p.isActive).toList();

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

  Future<void> loadPublicGrades() async {
    try {
      isLoadingGrades.value = true;
      gradesError.value = '';
      final grades = await _dataService.fetchPublicGrades();
      publicGrades.value = grades;
    } catch (e) {
      gradesError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingGrades.value = false;
    }
  }

  void selectBoard(BoardModel board) {
    selectedBoardModel.value = board;
    selectedBoard.value = board.name;
    // After board selection, usually go to subjects
    Get.toNamed('/subject-selection');
  }

  void selectGrade(GradeModel grade) {
    selectedGradeModel.value = grade;
    // Reset selections when grade changes
    selectedBoardModel.value = null;
    selectedBoard.value = '';
    selectedSubjectIds.clear();
  }

  void selectPackage(PackageModel package) {
    selectedPackageModel.value = package;
    selectedPackage.value = package.name;
    selectedSubjectIds.clear();
    paymentMode.value = 'full';
    clearCoupon();

    if (package.pricingType == 'package') {
      selectedSubjectIds.assignAll(package.subjects.map((s) => s.id).toList());
    }
    
    // In simplified flow, we go to package-selection directly
    Get.toNamed('/package-selection');
  }

  void toggleSubject(String subjectId) {
    HapticFeedback.lightImpact();
    final package = selectedPackageModel.value;
    if (package == null || package.pricingType != 'subject') return;

    if (selectedSubjectIds.contains(subjectId)) {
      if (selectedSubjectIds.length > package.minSubjectSelection) {
        selectedSubjectIds.remove(subjectId);
      } else {
        Get.snackbar(
          'Selection Error',
          'Minimum ${package.minSubjectSelection} subjects required',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      selectedSubjectIds.add(subjectId);
    }
    HapticFeedback.lightImpact();
    clearCoupon();
  }

  void togglePaymentMode(String mode) {
    HapticFeedback.selectionClick();
    paymentMode.value = mode;
    if (mode == 'installment') {
      clearCoupon();
    }
  }

  bool isSubjectSelected(String subjectId) {
    return selectedSubjectIds.contains(subjectId);
  }

  double calculateSubtotal() {
    final package = selectedPackageModel.value;
    if (package == null) return 0;

    if (package.pricingType == 'subject') {
      double total = 0;
      for (var subjectId in selectedSubjectIds) {
        final subjectPriceObj = package.subjectPrices.firstWhereOrNull(
          (sp) => sp.subjectId == subjectId
        );
        if (subjectPriceObj != null) {
          total += isIndia.value ? subjectPriceObj.price : subjectPriceObj.internationalPrice;
        }
      }
      return total;
    } else {
      return isIndia.value ? package.totalPrice : package.internationalPrice;
    }
  }

  double getTotalPrice() {
    final subtotal = calculateSubtotal();
    if (couponDiscount.value > 0) {
      return couponFinalAmount.value;
    }
    return subtotal;
  }

  double getInstallmentAmount() {
    final package = selectedPackageModel.value;
    if (package == null || package.installments == null || !package.installments!.enabled) {
      return 0;
    }
    return package.installments!.bookingAmount;
  }

  double getFinalPayableAmount() {
    if (paymentMode.value == 'installment') {
      return getInstallmentAmount();
    }
    return getTotalPrice();
  }

  double getSavings() {
    // For now returning 0, can be implemented if there's a strikethrough price
    return 0;
  }

  double getSubjectPrice(SubjectModel subject) {
    final package = selectedPackageModel.value;
    if (package == null) return 0;
    final sp = package.subjectPrices.firstWhereOrNull((p) => p.subjectId == subject.id);
    if (sp == null) return 0;
    return isIndia.value ? sp.price : sp.internationalPrice;
  }

  double getDiscountedPrice() {
    return getTotalPrice();
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
      final amount = calculateSubtotal();
      final res = await _couponService.validate(code: code, amount: amount);
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        couponDiscount.value = ((data['discountAmount'] ?? 0) as num).toDouble();
        couponFinalAmount.value = ((data['finalAmount'] ?? amount) as num).toDouble();
        couponMessage.value = 'Coupon applied: -${isIndia.value ? '₹' : '\$'}${couponDiscount.value.toStringAsFixed(0)}';
        HapticFeedback.mediumImpact();
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

  void resetSelection() {
    selectedPackageModel.value = null;
    selectedSubjectIds.clear();
    paymentMode.value = 'full';
    clearCoupon();
  }

  Future<void> initiateCheckout() async {
    final package = selectedPackageModel.value;
    if (package == null) return;

    if (package.pricingType == 'subject' && selectedSubjectIds.length < package.minSubjectSelection) {
      Get.snackbar(
        'Selection Error', 
        'Please select at least ${package.minSubjectSelection} subjects',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final packageTypeToUse = package.types.contains('genius') ? 'genius' : (package.types.isNotEmpty ? package.types.first : 'genius');
      final fallbackGrade = selectedGradeModel.value?.id ?? (package.grade?.id ?? (package.grades.isNotEmpty ? package.grades.first.id : ''));
      final fallbackBoard = selectedBoardModel.value?.id ?? (package.board?.id ?? '');

      final payload = {
        'packageId': package.id,
        'packageType': packageTypeToUse,
        'gradeId': fallbackGrade,
        'boardId': fallbackBoard,
        'subjectIds': package.pricingType == 'subject' ? selectedSubjectIds : [],
        'paymentMode': paymentMode.value,
        'couponCode': (paymentMode.value == 'full' && couponDiscount.value > 0) ? couponCode.value : null,
      };

      final res = await _packageService.initiatePayment(payload);
      Get.back(); // Close loading dialog

      if (res['success'] == true && res['checkout_url'] != null) {
        final String checkoutUrl = res['checkout_url'];
        final String sessionId = res['session_id'] ?? '';

        // Navigate to payment webview
        final result = await Get.to(() => OttuPaymentWebView(
          checkoutUrl: checkoutUrl,
          sessionId: sessionId,
        ));

        if (result == OttuPaymentResult.success) {
          await _showSuccessDialog();
          Get.offAllNamed('/dashboard'); // Go to dashboard on success
        } else if (result == OttuPaymentResult.failure) {
          Get.snackbar(
            'Payment Failed', 
            'Something went wrong with the payment. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception(res['message'] ?? 'Failed to get checkout URL');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error', 
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Legacy/Helper methods (keeping for compatibility if needed elsewhere)
  String getPackageTypeDisplayName(String type) => type.toUpperCase();
  IconData getPackageTypeIcon(String type) => Icons.book_rounded;
  Color getPackageTypeColor(String type) => const Color(0xFF6366F1);

  Future<void> _showSuccessDialog() async {
    HapticFeedback.heavyImpact();
    await Get.dialog(
      Stack(
        alignment: Alignment.center,
        children: [
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network(
                    'https://assets10.lottiefiles.com/packages/lf20_kz9pjcjt.json', // Success Checkmark
                    width: 150,
                    height: 150,
                    repeat: false,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your subscription is now active. You can start learning right away.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Start Learning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti Overlay
          IgnorePointer(
            child: Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_u4j3cx7p.json', // Confetti
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              repeat: false,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

