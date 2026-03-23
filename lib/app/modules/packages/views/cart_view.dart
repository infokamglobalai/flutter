import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/modules/packages/views/ottu_payment_webview.dart';
import 'dart:async';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final controller = Get.find<PackageController>();
  final dataService = DataService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.85),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Responsive values
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;

        final totalChapters = controller.getTotalSelectedChapters();

        if (totalChapters == 0) {
          final emptyIconSize = isSmallScreen ? 64.0 : 80.0;
          final emptyPadding = isSmallScreen ? 32.0 : 40.0;
          final emptyTitleSize = isSmallScreen ? 20.0 : 24.0;
          final emptySubtitleSize = isSmallScreen ? 14.0 : 15.0;
          final buttonPaddingH = isSmallScreen ? 24.0 : 32.0;
          final buttonPaddingV = isSmallScreen ? 14.0 : 16.0;

          return Center(
            child: Padding(
              padding: EdgeInsets.all(emptyPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 28.0 : 32.0),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: emptyIconSize,
                      color: AppTheme.primaryColor.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: emptyTitleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 10 : 12),
                  Text(
                    'Start building your learning package by\nadding chapters from your favorite subjects',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: emptySubtitleSize,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    label: Text(
                      'Browse Chapters',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonPaddingH,
                        vertical: buttonPaddingV,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : 16,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildPackageInfo(),
                    _buildChaptersList(),
                    _buildDiscountInfo(),
                    _buildPriceSummary(),
                    const SizedBox(height: 120), // Space for checkout button
                  ],
                ),
              ),
            ),
            _buildCheckoutButton(),
          ],
        );
      }),
    );
  }

  Widget _buildPackageInfo() {
    return Builder(
      builder: (context) {
        // Responsive values
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

        final marginH = isSmallScreen ? 12.0 : 16.0;
        final marginV = isSmallScreen ? 16.0 : 20.0;
        final cardPadding = isSmallScreen
            ? 20.0
            : (isMediumScreen ? 22.0 : 24.0);
        final borderRadius = isSmallScreen ? 20.0 : 24.0;
        final iconPadding = isSmallScreen ? 12.0 : 14.0;
        final iconSize = isSmallScreen ? 28.0 : 32.0;
        final titleFontSize = isSmallScreen
            ? 16.0
            : (isMediumScreen ? 17.0 : 18.0);
        final subtitleFontSize = isSmallScreen ? 13.0 : 14.0;
        final chipPaddingH = isSmallScreen ? 12.0 : 14.0;
        final chipPaddingV = isSmallScreen ? 7.0 : 8.0;
        final chipFontSize = isSmallScreen ? 12.0 : 13.0;

        return Container(
          margin: EdgeInsets.fromLTRB(marginH, marginV, marginH, marginH),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.85),
                AppTheme.secondaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: isSmallScreen ? 20 : 24,
                offset: Offset(0, isSmallScreen ? 10 : 12),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Obx(() {
            final isCompetitiveExam =
                controller.selectedPackageModel.value?.isCompetitiveExam ??
                false;
            final gradeText =
                controller.selectedGradeModel.value?.displayName ?? "Grade";
            final boardText = controller.selectedBoard.value;
            final infoText = isCompetitiveExam || boardText.isEmpty
                ? gradeText
                : '$gradeText • $boardText';
            final totalChapters = controller.getTotalSelectedChapters();

            return Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(iconPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 14 : 16,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Custom Learning Package',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 5 : 6),
                                Text(
                                  infoText,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      Row(
                        children: [
                          _buildInfoChip(
                            chipPaddingH,
                            chipPaddingV,
                            chipFontSize,
                            isSmallScreen,
                            Icons.book_rounded,
                            '${controller.selectedSubjects.length} Subject${controller.selectedSubjects.length != 1 ? 's' : ''}',
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 12),
                          _buildInfoChip(
                            chipPaddingH,
                            chipPaddingV,
                            chipFontSize,
                            isSmallScreen,
                            Icons.library_books_rounded,
                            '$totalChapters Chapter${totalChapters != 1 ? 's' : ''}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildInfoChip(
    double chipPaddingH,
    double chipPaddingV,
    double chipFontSize,
    bool isSmallScreen,
    IconData icon,
    String text,
  ) {
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final borderRadius = isSmallScreen ? 16.0 : 20.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: chipPaddingH,
        vertical: chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: AppTheme.primaryColor),
          SizedBox(width: isSmallScreen ? 5 : 6),
          Text(
            text,
            style: TextStyle(
              fontSize: chipFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Selected Chapters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...controller.selectedSubjects.asMap().entries.map((entry) {
              final index = entry.key;
              final subject = entry.value;
              final count = controller.getSelectedChapterCount(subject);
              final price = controller.getSubjectPrice(subject);

              // Skip subjects with 0 chapters selected
              if (count == 0) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: index == 0
                        ? BorderSide.none
                        : BorderSide(color: Colors.grey[100]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getSubjectColor(subject),
                            _getSubjectColor(subject).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _getSubjectColor(subject).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: _getSubjectColor(subject),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$count chapter${count != 1 ? 's' : ''} selected',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountInfo() {
    return Obx(() {
      final savings = controller.getSavings();
      final chapters = controller.getTotalSelectedChapters();

      if (savings <= 0) {
        return const SizedBox.shrink();
      }

      String discountText = '';
      String discountPercent = '';
      if (chapters >= 50) {
        discountText = 'Bulk Discount Applied!';
        discountPercent = '30%';
      } else if (chapters >= 30) {
        discountText = 'Bulk Discount Applied!';
        discountPercent = '20%';
      } else if (chapters >= 15) {
        discountText = 'Discount Applied!';
        discountPercent = '10%';
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.successColor,
              AppTheme.successColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.successColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.celebration_rounded,
                      color: AppTheme.successColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                discountPercent,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              discountText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You save ₹${savings.toStringAsFixed(0)} on this order',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildPriceSummary() {
    return Obx(() {
      final totalPrice = controller.getTotalPrice();
      final discountedPrice = controller.getDiscountedPrice();
      final savings = controller.getSavings();
      final chapters = controller.getTotalSelectedChapters();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Price Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPriceRow(
                    'Subtotal',
                    '₹${totalPrice.toStringAsFixed(0)}',
                    subtitle: '$chapters chapter${chapters != 1 ? 's' : ''}',
                  ),
                  if (savings > 0) ...[
                    const SizedBox(height: 16),
                    _buildPriceRow(
                      'Discount',
                      '- ₹${savings.toStringAsFixed(0)}',
                      color: AppTheme.successColor,
                      isDiscount: true,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.secondaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (savings > 0)
                              Text(
                                '₹${totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 2,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '₹${discountedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
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

  Widget _buildPriceRow(
    String label,
    String value, {
    Color? color,
    String? subtitle,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? const Color(0xFF1F2937),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDiscount ? 10 : 0,
            vertical: isDiscount ? 6 : 0,
          ),
          decoration: isDiscount
              ? BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isDiscount ? 16 : 17,
              fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${controller.getDiscountedPrice().toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${controller.getTotalSelectedChapters()} items',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _createSubscription(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppTheme.successColor,
                        AppTheme.successColor.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successColor.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Complete Purchase',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSubscription() async {
    // ── 1. Validate required selections ─────────────────────────────────────
    if (controller.selectedPackage.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a package',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final isCompetitiveExam =
        controller.selectedPackageModel.value?.isCompetitiveExam ?? false;

    if (!isCompetitiveExam && controller.selectedBoardModel.value == null) {
      Get.snackbar(
        'Error',
        'Please select a board',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (controller.selectedGradeModel.value == null) {
      Get.snackbar(
        'Error',
        'Please select a grade',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (controller.selectedSubjectModels.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one subject',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final List<String> allChapterIds = [];
    controller.selectedChapters.forEach((_, ids) => allChapterIds.addAll(ids));

    if (allChapterIds.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one chapter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // ── 2. Show loading while creating Ottu session ──────────────────────────
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Preparing secure payment...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final subjectIds = controller.selectedSubjectModels
          .map((s) => s.id)
          .toList();
      final boardId = isCompetitiveExam
          ? ''
          : (controller.selectedBoardModel.value?.id ?? '');

      // ── 3. Call backend – creates subscription + Ottu checkout session ──────
      final result = await dataService.initiateOttuPayment(
        packageId: controller.selectedPackageModel.value?.id ?? '',
        packageType: controller.selectedPackage.value,
        boardId: boardId,
        gradeId: controller.selectedGradeModel.value!.id,
        subjectIds: subjectIds,
        chapterIds: allChapterIds,
      );

      // Close loading dialog
      Get.back();

      if (result['success'] != true) {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to initiate payment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final String checkoutUrl = result['checkoutUrl'];
      final String sessionId = result['sessionId'];
      final String subscriptionId = result['subscriptionId'] as String;

      // ── 4. Open Ottu checkout WebView ────────────────────────────────────
      final webViewResult = await Get.to<OttuPaymentResult>(
        () =>
            OttuPaymentWebView(checkoutUrl: checkoutUrl, sessionId: sessionId),
        transition: Transition.rightToLeft,
      );

      // ── 5. Handle WebView result ─────────────────────────────────────────
      if (webViewResult == OttuPaymentResult.cancelled) {
        // Clean up the pending subscription silently
        dataService.cancelOttuPayment(subscriptionId);
        Get.snackbar(
          'Payment Cancelled',
          'You cancelled the payment. Your cart is still available.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.cancel, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      // Show verifying dialog (whether success redirect or unknown)
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Verifying payment...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Poll status (up to 5 attempts, 2s apart)
      Map<String, dynamic> statusResult = {'success': false};
      for (int attempt = 0; attempt < 5; attempt++) {
        await Future.delayed(const Duration(seconds: 2));
        statusResult = await dataService.getOttuPaymentStatus(sessionId);
        if (statusResult['success'] == true &&
            statusResult['paymentStatus'] == 'completed') {
          break;
        }
      }

      // Close verifying dialog
      Get.back();

      if (statusResult['success'] == true &&
          statusResult['paymentStatus'] == 'completed') {
        // ── 6. Payment succeeded ──────────────────────────────────────────
        _showSuccessDialog(
          subscriptionId: statusResult['subscriptionId']?.toString(),
        );
      } else if (webViewResult == OttuPaymentResult.failure ||
          statusResult['paymentStatus'] == 'failed') {
        // Clean up the failed pending subscription
        dataService.cancelOttuPayment(subscriptionId);
        Get.snackbar(
          'Payment Failed',
          'The payment could not be processed. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      } else {
        // Still pending – notify user
        Get.snackbar(
          'Payment Pending',
          'Your payment is being processed. You will be notified once confirmed.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.hourglass_top, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      // Close any open dialog
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _showSuccessDialog({
    String? subscriptionId,
    String? paymentId,
    String? orderId,
    String? signature,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Subscription Created!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your courses have been added to your account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (subscriptionId != null || paymentId != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (subscriptionId != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subscription ID:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Flexible(
                              child: Text(
                                subscriptionId,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (paymentId != null) ...[
                        if (subscriptionId != null) const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transaction ID:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Flexible(
                              child: Text(
                                paymentId,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (orderId != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ID:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Flexible(
                              child: Text(
                                orderId,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close success dialog
                    controller.resetSelection();
                    Get.until((route) => route.isFirst); // Go to dashboard

                    // Refresh dashboard subscriptions
                    try {
                      final dashboardController =
                          Get.find<DashboardController>();
                      dashboardController.loadUserSubscriptions();
                      dashboardController.loadDashboardData();
                    } catch (e) {
                      print('Dashboard controller not found: $e');
                    }

                    Get.snackbar(
                      'Success',
                      'Courses are now available in your dashboard',
                      backgroundColor: AppTheme.successColor,
                      colorText: Colors.white,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF3B82F6);
      case 'science':
        return const Color(0xFF10B981);
      case 'english':
        return const Color(0xFFEF4444);
      case 'social science':
        return const Color(0xFFF59E0B);
      case 'computer science':
        return const Color(0xFF8B5CF6);
      case 'hindi':
        return const Color(0xFFEC4899);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'english':
        return Icons.menu_book_rounded;
      case 'social science':
        return Icons.public_rounded;
      case 'computer science':
        return Icons.computer_rounded;
      case 'hindi':
        return Icons.translate_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
