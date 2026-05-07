import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/chapter_model.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class ChapterSelectionView extends GetView<PackageController> {
  const ChapterSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Select Chapters'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              _showSummaryAndAddToCart();
            },
            child: const Text(
              'Add to Cart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSelectionSummary(),
          Expanded(
            child: Obx(() {
              // Loading chapters
              if (controller.isLoadingChapters.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading chapters...'),
                    ],
                  ),
                );
              }

              // Error loading chapters
              if (controller.chaptersError.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load chapters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.chaptersError.value,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.loadChapters,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // No subjects selected
              if (controller.selectedSubjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.subject_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No subjects selected',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.selectedSubjects.length,
                itemBuilder: (context, index) {
                  final subject = controller.selectedSubjects[index];
                  return _buildSubjectSection(subject);
                },
              );
            }),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSelectionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Package Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.selectedGradeModel.value?.displayName ?? "Grade"} • ${controller.selectedBoard.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSection(String subject) {
    // Get chapters from API
    final List<ChapterModel> chapters = controller.getChaptersForSubject(
      subject,
    );

    final subjectColor = _getSubjectColor(subject);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [subjectColor, subjectColor.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
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
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject header with glass-morphism
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final selectedCount = controller
                                .getSelectedChapterCount(subject);
                            final price = controller.getSubjectPrice(subject);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$selectedCount of ${chapters.length} selected',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (selectedCount > 0) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '₹${price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subjectColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    // Select All button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          controller.selectAllChaptersForSubject(subject);
                        },
                        child: Text(
                          'Select All',
                          style: TextStyle(
                            color: subjectColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Chapters list in white container
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chapters.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return Obx(() {
                      final isSelected = controller.isChapterSelected(
                        subject,
                        chapter.id,
                      );

                      return InkWell(
                        onTap: () {
                          controller.toggleChapter(subject, chapter.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? subjectColor.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: index == 0
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  )
                                : index == chapters.length - 1
                                ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Custom checkbox
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? subjectColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? subjectColor
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chapter.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? subjectColor
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.subject_rounded,
                                          size: 12,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            chapter.subjectName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Price badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? subjectColor
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '₹${chapter.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final totalChapters = controller.getTotalSelectedChapters();
      final totalPrice = controller.getTotalPrice();
      final discountedPrice = controller.getDiscountedPrice();
      final savings = controller.getSavings();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalChapters Chapter${totalChapters != 1 ? 's' : ''} Selected',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (savings > 0)
                      Row(
                        children: [
                          Text(
                            '₹${totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '₹${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    if (savings > 0)
                      Text(
                        'Save ₹${savings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: totalChapters > 0
                    ? () {
                        Get.toNamed(Routes.CART);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shopping_cart_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'View Cart',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
  }

  void _showSummaryAndAddToCart() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppTheme.primaryColor.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Package Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => Column(
                  children: [
                    _buildSummaryRow(
                      'Grade',
                      controller.selectedGradeModel.value?.displayName ??
                          'Grade',
                    ),
                    _buildSummaryRow(
                      'Package',
                      controller.selectedPackage.value.toUpperCase(),
                    ),
                    _buildSummaryRow('Board', controller.selectedBoard.value),
                    _buildSummaryRow(
                      'Subjects',
                      '${controller.selectedSubjects.length}',
                    ),
                    _buildSummaryRow(
                      'Chapters',
                      '${controller.getTotalSelectedChapters()}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Package added to cart successfully!',
                          backgroundColor: AppTheme.successColor,
                          colorText: Colors.white,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                        // Navigate back to dashboard or cart
                        Get.until((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
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
      case 'sanskrit':
        return const Color(0xFF06B6D4);
      case 'environmental science':
        return const Color(0xFF84CC16);
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
      case 'sanskrit':
        return Icons.auto_stories_rounded;
      case 'environmental science':
        return Icons.eco_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
