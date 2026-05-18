import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/subject_model.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'dart:math' as math;

class SubjectSelectionView extends GetView<PackageController> {
  const SubjectSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Deep Navy
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelectionSummary(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Your Subjects',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          _buildSelectAllButton(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        '${controller.selectedSubjectModels.length} subjects selected',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      )),
                    ],
                  ),
                ),
              ),
              _buildSubjectsList(),
              SliverToBoxAdapter(
                child: Obx(() {
                  final package = controller.selectedPackageModel.value;
                  if (package == null) return const SizedBox.shrink();
                  
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(color: Colors.white10),
                      ),
                      _buildPaymentOptions(package),
                      _buildCouponSection(),
                      _buildPriceBreakdown(),
                      const SizedBox(height: 150),
                    ],
                  );
                }),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentColor.withOpacity(0.1),
                  AppTheme.accentColor.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.overlay),
            child: Container(
              color: Colors.white.withOpacity(0.05),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Select Subjects',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildSelectionSummary() {
    return Obx(() {
      final gradeText = controller.selectedGradeModel.value?.displayName ?? "Grade";
      final packageText = controller.selectedPackage.value.toUpperCase();
      final boardText = controller.selectedBoard.value;
      final selectionText = boardText.isNotEmpty ? '$gradeText • $boardText • $packageText' : '$gradeText • $packageText';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: UIUtils.glossyDecoration(
          baseColor: Colors.white.withOpacity(0.05),
          borderRadius: 24,
          showBorder: true,
        ).copyWith(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.list_alt_rounded, color: AppTheme.secondaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT SELECTION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[500],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectionText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSelectAllButton() {
    return Obx(() {
      final filteredSubjects = controller.publicSubjects.where((subject) {
        if (controller.selectedGradeModel.value == null) return true;
        if (subject.grade == null) return true;
        return subject.grade!.id == controller.selectedGradeModel.value!.id;
      }).toList();

      if (filteredSubjects.isEmpty) return const SizedBox.shrink();

      final allSelected = filteredSubjects.every((s) => controller.isSubjectSelected(s.id));

      return TextButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (allSelected) {
            for (var s in filteredSubjects) if (controller.isSubjectSelected(s.id)) controller.toggleSubject(s.id);
          } else {
            for (var s in filteredSubjects) if (!controller.isSubjectSelected(s.id)) controller.toggleSubject(s.id);
          }
        },
        icon: Icon(allSelected ? Icons.deselect_rounded : Icons.select_all_rounded, color: AppTheme.primaryColor, size: 18),
        label: Text(allSelected ? 'None' : 'All', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900)),
      );
    });
  }

  Widget _buildSubjectsList() {
    return Obx(() {
      if (controller.isLoadingSubjects.value) {
        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.white)));
      }

      final filteredSubjects = controller.publicSubjects.where((subject) {
        if (controller.selectedGradeModel.value == null) return true;
        if (subject.grade == null) return true;
        return subject.grade!.id == controller.selectedGradeModel.value!.id;
      }).toList();

      if (filteredSubjects.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildSubjectCard(filteredSubjects[index]),
            childCount: filteredSubjects.length,
          ),
        ),
      );
    });
  }

  Widget _buildSubjectCard(SubjectModel subject) {
    return Obx(() {
      final isSelected = controller.isSubjectSelected(subject.id);
      final color = _getSubjectColor(subject.name);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            if (controller.selectedPackageModel.value?.pricingType == 'package') {
              Get.snackbar(
                'Package Info',
                'All subjects are included in this package',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                colorText: Colors.white,
              );
              return;
            }
            HapticFeedback.lightImpact();
            controller.toggleSubject(subject.id);
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: UIUtils.glossyDecoration(
              baseColor: isSelected ? color : Colors.white.withOpacity(0.05),
              borderRadius: 24,
              showBorder: true,
            ).copyWith(
              border: Border.all(
                color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getSubjectIcon(subject.name), color: isSelected ? Colors.white : color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Comprehensive Module',
                          style: TextStyle(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final selectedCount = controller.selectedSubjectModels.length;
      final package = controller.selectedPackageModel.value;
      final isPackageWise = package?.pricingType == 'package';
      final canCheckout = isPackageWise || selectedCount >= (package?.minSubjectSelection ?? 1);

      return Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F172A).withOpacity(0),
              const Color(0xFF0F172A).withOpacity(0.95),
              const Color(0xFF0F172A),
            ],
            stops: const [0, 0.4, 1],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL PAYABLE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey),
                  ),
                  Text(
                    '${controller.isIndia.value ? '₹' : '\$'}${controller.getFinalPayableAmount().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: canCheckout ? () {
                  HapticFeedback.heavyImpact();
                  controller.initiateCheckout();
                } : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: UIUtils.glossyDecoration(
                    baseColor: canCheckout ? AppTheme.primaryColor : Colors.grey[800]!,
                    borderRadius: 20,
                  ).copyWith(
                    boxShadow: canCheckout 
                      ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 8))] 
                      : null,
                  ),
                  child: const Center(
                    child: Text(
                      'COMPLETE PURCHASE',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentOptions(dynamic package) {
    final installments = package.installments;
    if (installments == null || !installments.enabled) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Strategy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPaymentCard(
                  'Full Unlock',
                  'Instant access',
                  'full',
                  Icons.auto_awesome_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentCard(
                  'Installments',
                  'Flexible plan',
                  'installment',
                  Icons.account_balance_wallet_rounded,
                  showInstallmentBreakdown: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String title, String subtitle, String mode, IconData icon, {bool showInstallmentBreakdown = false}) {
    return Obx(() {
      final isSelected = controller.paymentMode.value == mode;
      final baseColor = isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.05);
      
      return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.togglePaymentMode(mode);
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: UIUtils.glossyDecoration(
            baseColor: baseColor,
            borderRadius: 20,
            showBorder: true,
          ).copyWith(
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppTheme.primaryColor, size: 28),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey[500]),
              ),
              if (showInstallmentBreakdown && isSelected) ...[
                const SizedBox(height: 12),
                _buildInstallmentBreakdown(controller.selectedPackageModel.value!),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInstallmentBreakdown(dynamic package) {
    final symbol = controller.isIndia.value ? '₹' : '\$';
    final bookingAmt = package.installments.bookingAmount;
    final total = controller.getTotalPrice();
    final remaining = math.max(0.0, total - bookingAmt);
    final count = package.installments.count;
    final perInstallment = count > 0 ? (remaining / count) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white24, height: 16),
        Text(
          'Next: $count × $symbol${perInstallment.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promo Code',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final isInstallment = controller.paymentMode.value == 'installment';
            return Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isInstallment ? 0.02 : 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      enabled: !isInstallment && controller.couponDiscount.value <= 0,
                      onChanged: (v) => controller.couponCode.value = v,
                      style: TextStyle(
                        color: isInstallment ? Colors.white30 : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: isInstallment ? 'NOT AVAILABLE' : 'Enter Coupon',
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: (isInstallment || controller.isApplyingCoupon.value) 
                      ? null 
                      : () => controller.applyCoupon(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: UIUtils.glossyDecoration(
                      baseColor: (isInstallment || controller.isApplyingCoupon.value) 
                          ? Colors.grey[800]! 
                          : AppTheme.primaryColor,
                      borderRadius: 16,
                    ),
                    child: controller.isApplyingCoupon.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            'Apply', 
                            style: TextStyle(
                              color: isInstallment ? Colors.white24 : Colors.white, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            if (controller.paymentMode.value == 'installment') {
              return const Padding(
                padding: EdgeInsets.only(top: 12, left: 4),
                child: Text(
                  '* Coupons are only available for one-time payments.',
                  style: TextStyle(fontSize: 11, color: Colors.amberAccent, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              );
            }
            if (controller.couponMessage.value.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Text(
                controller.couponMessage.value,
                style: TextStyle(
                  fontSize: 13,
                  color: controller.couponDiscount.value > 0 ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: UIUtils.glossyDecoration(
          baseColor: Colors.white.withOpacity(0.03),
          borderRadius: 24,
          showBorder: true,
        ),
        child: Column(
          children: [
            _buildPriceRow('Subtotal', controller.calculateSubtotal()),
            if (controller.couponDiscount.value > 0)
              _buildPriceRow('Savings', -controller.couponDiscount.value, color: Colors.greenAccent),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10)),
            _buildPriceRow(
              controller.paymentMode.value == 'installment' ? 'Due Today' : 'Total Payable',
              controller.getFinalPayableAmount(),
              isBold: true,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false, double fontSize = 14, Color? color}) {
    final symbol = controller.isIndia.value ? '₹' : '\$';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: isBold ? Colors.white : Colors.grey[500])),
        Text('${amount < 0 ? '-' : ''}$symbol${amount.abs().toStringAsFixed(2)}', style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: color ?? Colors.white)),
      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text('No subjects available', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(0.15),
                  widget.color.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
