import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/modules/packages/views/ottu_payment_webview.dart';
import 'dart:async';
import 'dart:math' as math;

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final controller = Get.find<PackageController>();
  final dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Deep Navy
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          Obx(() {
            final hasSelection = controller.selectedSubjectIds.isNotEmpty;
            if (!hasSelection) return _buildEmptyCart();

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildAppBar(),
                      SliverToBoxAdapter(child: _buildPackageInfo()),
                      _buildSubjectsList(),
                      SliverToBoxAdapter(child: _buildDiscountInfo()),
                      SliverToBoxAdapter(child: _buildPriceSummary()),
                      const SliverToBoxAdapter(child: SizedBox(height: 140)),
                    ],
                  ),
                ),
                _buildCheckoutBar(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        title: Text('Your Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          ),
          const SizedBox(height: 32),
          const Text('Your cart is empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 12),
          Text('Choose subjects to build your package', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              decoration: UIUtils.glossyDecoration(baseColor: AppTheme.primaryColor, borderRadius: 20),
              child: const Text('Browse Subjects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: UIUtils.glossyDecoration(
        baseColor: AppTheme.primaryColor,
        borderRadius: 24,
      ),
      child: Stack(
        children: [
          const Positioned(right: -20, top: -20, child: _AnimatedGlowBlob(color: Colors.white, size: 100)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Custom Learning Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.selectedGradeModel.value?.displayName ?? "Grade"} • ${controller.selectedBoard.value}',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final subject = controller.selectedSubjectModels[index];
            final price = controller.getSubjectPrice(subject);
            final symbol = controller.isIndia.value ? '₹' : r'$';
            final color = _getSubjectColor(subject.name);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: UIUtils.glossyDecoration(
                baseColor: Colors.white.withOpacity(0.05),
                borderRadius: 20,
                showBorder: true,
              ).copyWith(border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                    child: Icon(_getSubjectIcon(subject.name), color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('Full Access', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('$symbol${price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            );
          },
          childCount: controller.selectedSubjectModels.length,
        ),
      ),
    );
  }

  Widget _buildDiscountInfo() {
    final savings = controller.getSavings();
    if (savings <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: UIUtils.glossyDecoration(baseColor: AppTheme.successColor, borderRadius: 20),
      child: Row(
        children: [
          const Icon(Icons.celebration_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bundle Discount Applied!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                Text('You save ${controller.isIndia.value ? '₹' : r'$'}${savings.toStringAsFixed(0)}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final subtotal = controller.calculateSubtotal();
    final savings = controller.getSavings();
    final total = controller.getFinalPayableAmount();
    final symbol = controller.isIndia.value ? '₹' : r'$';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '$symbol${subtotal.toStringAsFixed(0)}'),
          if (savings > 0) ...[
            const SizedBox(height: 16),
            _buildPriceRow('Bundle Discount', '-$symbol${savings.toStringAsFixed(0)}', color: AppTheme.successColor),
          ],
          const SizedBox(height: 24),
          _buildCouponSection(),
          if (controller.couponDiscount.value > 0) ...[
            const SizedBox(height: 16),
            _buildPriceRow('Coupon Applied', '-$symbol${controller.couponDiscount.value.toStringAsFixed(0)}', color: AppTheme.successColor),
          ],
          const Divider(height: 48, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              Text('$symbol${total.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 28, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  Widget _buildCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => controller.couponCode.value = v,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter Coupon',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => GestureDetector(
              onTap: controller.isApplyingCoupon.value ? null : controller.applyCoupon,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: UIUtils.glossyDecoration(baseColor: AppTheme.primaryColor, borderRadius: 16),
                child: controller.isApplyingCoupon.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            )),
          ],
        ),
        Obx(() {
          final msg = controller.couponMessage.value;
          if (msg.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: Text(msg, style: TextStyle(color: controller.couponDiscount.value > 0 ? AppTheme.successColor : Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 12)),
          );
        }),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF0F172A).withOpacity(0), const Color(0xFF0F172A).withOpacity(0.95), const Color(0xFF0F172A)],
          stops: const [0, 0.4, 1],
        ),
      ),
      child: GestureDetector(
        onTap: () => _createSubscription(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: UIUtils.glossyDecoration(baseColor: AppTheme.successColor, borderRadius: 20).copyWith(
            boxShadow: [BoxShadow(color: AppTheme.successColor.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))],
          ),
          child: const Center(
            child: Text('COMPLETE PURCHASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
          ),
        ),
      ),
    );
  }

  Future<void> _createSubscription() async {
    // Validation
    if (controller.selectedSubjectModels.isEmpty) {
      Get.snackbar('Error', 'Please select subjects', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Loading Dialog
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 24),
              Text('Securing Connection...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.none, fontSize: 16)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final isCompetitiveExam = controller.selectedPackageModel.value?.isCompetitiveExam ?? false;
      final boardId = isCompetitiveExam ? '' : (controller.selectedBoardModel.value?.id ?? '');

      final result = await dataService.initiateOttuPayment(
        packageId: controller.selectedPackageModel.value?.id ?? '',
        packageType: controller.selectedPackage.value,
        boardId: boardId,
        gradeId: controller.selectedGradeModel.value!.id,
        subjectIds: controller.selectedSubjectModels.map((s) => s.id).toList(),
        chapterIds: const [],
        couponCode: controller.couponCode.value.trim(),
      );

      Get.back(); // Close loading

      if (result['success'] == true) {
        final webResult = await Get.to(() => OttuPaymentWebView(checkoutUrl: result['checkoutUrl'], sessionId: result['sessionId']));
        if (webResult == OttuPaymentResult.success) {
          _showSuccessDialog();
        }
      } else {
        Get.snackbar('Error', result['message'] ?? 'Payment failed', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'System unavailable', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: UIUtils.glossyDecoration(baseColor: const Color(0xFF1E293B), borderRadius: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: AppTheme.successColor, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text('Payment Successful!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('Your learning journey begins now.', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  controller.resetSelection();
                  Get.offAllNamed('/');
                  Get.find<DashboardController>().loadUserSubscriptions();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: UIUtils.glossyDecoration(baseColor: AppTheme.primaryColor, borderRadius: 16),
                  child: const Center(child: Text('GO TO DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Color _getSubjectColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return Colors.blue;
    if (n.contains('physics')) return Colors.teal;
    if (n.contains('chemistry')) return Colors.orange;
    if (n.contains('biology')) return Colors.green;
    return AppTheme.primaryColor;
  }

  IconData _getSubjectIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return Icons.calculate_rounded;
    if (n.contains('physics')) return Icons.science_rounded;
    if (n.contains('chemistry')) return Icons.biotech_rounded;
    if (n.contains('biology')) return Icons.eco_rounded;
    return Icons.book_rounded;
  }
}

class _AnimatedGlowBlob extends StatefulWidget {
  final Color color;
  final double size;
  const _AnimatedGlowBlob({required this.color, required this.size});
  @override
  State<_AnimatedGlowBlob> createState() => _AnimatedGlowBlobState();
}

class _AnimatedGlowBlobState extends State<_AnimatedGlowBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(
        angle: _controller.value * 2 * math.pi,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [widget.color.withOpacity(0.15), widget.color.withOpacity(0)])),
        ),
      ),
    );
  }
}
