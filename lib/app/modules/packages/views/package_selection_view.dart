import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';
import 'package:najahapp/app/data/models/package_model.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class PackageSelectionView extends GetView<PackageController> {
  const PackageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Deep Navy
      body: Obx(() {
        final package = controller.selectedPackageModel.value;
        if (package == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(package),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPackageHeader(package),
                      if (package.pricingType == 'subject') _buildSubjectSelection(package),
                      _buildPaymentOptions(package),
                      _buildCouponSection(),
                      _buildPriceBreakdown(),
                      const SizedBox(height: 150), // Space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomCheckoutBar(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(PackageModel package) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0F172A),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (package.imageUrl.isNotEmpty)
              Hero(
                tag: 'package_${package.id}',
                child: Image.network(package.imageUrl, fit: BoxFit.cover),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                ),
                child: const Icon(Icons.school, size: 80, color: Colors.white54),
              ),
            // Glossy Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withOpacity(0.4),
                    const Color(0xFF0F172A).withOpacity(0),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageHeader(PackageModel package) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  package.isCompetitiveExam ? 'Competitive' : 'Academic',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.timer_outlined, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                '${package.validityDays} Days Validity',
                style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            package.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            package.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[400],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelection(PackageModel package) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Subjects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'Min ${package.minSubjectSelection} required',
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: package.subjects.length,
            itemBuilder: (context, index) {
              final subject = package.subjects[index];
              return Obx(() {
                final isSelected = controller.isSubjectSelected(subject.id);
                final priceObj = package.subjectPrices.firstWhereOrNull(
                  (sp) => sp.subjectId == subject.id
                );
                final price = controller.isIndia.value 
                    ? (priceObj?.price ?? 0) 
                    : (priceObj?.internationalPrice ?? 0);

                return InkWell(
                  onTap: () => controller.toggleSubject(subject.id),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: UIUtils.glossyDecoration(
                      baseColor: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.05),
                      borderRadius: 20,
                      showBorder: true,
                    ).copyWith(
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${controller.isIndia.value ? '₹' : '\$'}$price',
                                style: TextStyle(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions(PackageModel package) {
    final installments = package.installments;
    if (installments == null || !installments.enabled) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Strategy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
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
                  '${installments.count} flexible parts',
                  'installment',
                  Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String title, String subtitle, String mode, IconData icon) {
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
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 28,
              ),
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
                style: TextStyle(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promo Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    onChanged: (v) => controller.couponCode.value = v,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Enter Coupon',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => GestureDetector(
                onTap: controller.isApplyingCoupon.value ? null : () {
                  HapticFeedback.mediumImpact();
                  controller.applyCoupon();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: UIUtils.glossyDecoration(
                    baseColor: AppTheme.primaryColor,
                    borderRadius: 16,
                  ),
                  child: controller.isApplyingCoupon.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              )),
            ],
          ),
          Obx(() {
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
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: UIUtils.glossyDecoration(
          baseColor: Colors.white.withOpacity(0.03),
          borderRadius: 24,
          showBorder: true,
        ).copyWith(
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            _buildPriceRow('Subtotal', controller.calculateSubtotal()),
            if (controller.couponDiscount.value > 0)
              _buildPriceRow('Coupon Savings', -controller.couponDiscount.value, color: Colors.greenAccent),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white10),
            ),
            _buildPriceRow(
              controller.paymentMode.value == 'installment' ? 'Due Today' : 'Total Payable',
              controller.paymentMode.value == 'installment' 
                  ? controller.getInstallmentAmount() 
                  : controller.getTotalPrice(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: isBold ? Colors.white : Colors.grey[500],
            ),
          ),
          Text(
            '${amount < 0 ? '-' : ''}$symbol${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? (isBold ? Colors.white : Colors.white.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar() {
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
                  'AMOUNT PAYABLE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey),
                ),
                Obx(() {
                  final amount = controller.paymentMode.value == 'installment' 
                      ? controller.getInstallmentAmount() 
                      : controller.getTotalPrice();
                  final symbol = controller.isIndia.value ? '₹' : '\$';
                  return Text(
                    '$symbol${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                Get.toNamed(Routes.BOARD_SELECTION);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: UIUtils.glossyDecoration(
                  baseColor: AppTheme.primaryColor,
                  borderRadius: 20,
                ).copyWith(
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SELECT BOARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
