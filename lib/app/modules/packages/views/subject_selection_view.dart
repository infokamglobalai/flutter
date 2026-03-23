import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/subject_model.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';

class SubjectSelectionView extends GetView<PackageController> {
  const SubjectSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Select Subjects'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (controller.selectedSubjectModels.isNotEmpty) {
                controller.selectAllChaptersForAllSubjects();
                Get.toNamed('/cart');
              }
            },
            child: const Text(
              'Buy',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choose Your Subjects',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      _buildSelectAllButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      '${controller.selectedSubjectModels.length} subjects selected',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSubjectsList(),
                ],
              ),
            ),
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
      child: Obx(() {
        // Build selection text based on whether board is selected
        final gradeText =
            controller.selectedGradeModel.value?.displayName ?? "Grade";
        final packageText = controller.selectedPackage.value.toUpperCase();
        final boardText = controller.selectedBoard.value;

        // For competitive exams, board might be empty
        final selectionText = boardText.isNotEmpty
            ? '$gradeText • $boardText • $packageText'
            : '$gradeText • $packageText';

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.list_alt_rounded,
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
                    'Your Selection',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectionText,
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
        );
      }),
    );
  }

  Widget _buildSelectAllButton() {
    return Obx(() {
      // Filter subjects by selected grade
      final filteredSubjects = controller.publicSubjects.where((subject) {
        if (controller.selectedGradeModel.value == null) return true;
        if (subject.grade == null) return true;
        return subject.grade!.id == controller.selectedGradeModel.value!.id;
      }).toList();

      if (filteredSubjects.isEmpty) return const SizedBox.shrink();

      final allSelected = filteredSubjects.every(
        (subject) => controller.isSubjectSelected(subject),
      );

      return OutlinedButton.icon(
        onPressed: () {
          if (allSelected) {
            // Deselect all
            for (var subject in filteredSubjects) {
              if (controller.isSubjectSelected(subject)) {
                controller.toggleSubject(subject);
              }
            }
          } else {
            // Select all
            for (var subject in filteredSubjects) {
              if (!controller.isSubjectSelected(subject)) {
                controller.toggleSubject(subject);
              }
            }
          }
        },
        icon: Icon(
          allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
          size: 18,
        ),
        label: Text(
          allSelected ? 'Deselect All' : 'Select All',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  Widget _buildSubjectsList() {
    return Obx(() {
      // Loading state
      if (controller.isLoadingSubjects.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Error state
      if (controller.subjectsError.value.isNotEmpty) {
        return Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load subjects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.subjectsError.value,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controller.loadSubjects,
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

      // Empty state
      if (controller.publicSubjects.isEmpty) {
        return Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No subjects available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }

      // Success state - Display subjects from API filtered by selected grade
      final filteredSubjects = controller.publicSubjects.where((subject) {
        // If no grade is selected, show all subjects
        if (controller.selectedGradeModel.value == null) return true;

        // If subject has no grade, show it for all grades
        if (subject.grade == null) return true;

        // Otherwise, only show subjects that match the selected grade
        return subject.grade!.id == controller.selectedGradeModel.value!.id;
      }).toList();

      // Show empty state if no subjects match the grade
      if (filteredSubjects.isEmpty) {
        return Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No subjects available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No subjects found for ${controller.selectedGradeModel.value?.displayName ?? "this grade"}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        children: filteredSubjects
            .map((subject) => _buildSubjectCard(subject: subject))
            .toList(),
      );
    });
  }

  Widget _buildSubjectCard({required SubjectModel subject}) {
    // Get icon based on subject name
    IconData icon;
    final nameLower = subject.name.toLowerCase();
    if (nameLower.contains('math')) {
      icon = Icons.calculate_rounded;
    } else if (nameLower.contains('physics')) {
      icon = Icons.science_rounded;
    } else if (nameLower.contains('chemistry')) {
      icon = Icons.science_rounded;
    } else if (nameLower.contains('biology')) {
      icon = Icons.biotech_rounded;
    } else if (nameLower.contains('english')) {
      icon = Icons.menu_book_rounded;
    } else if (nameLower.contains('social')) {
      icon = Icons.public_rounded;
    } else if (nameLower.contains('computer')) {
      icon = Icons.computer_rounded;
    } else if (nameLower.contains('hindi')) {
      icon = Icons.translate_rounded;
    } else if (nameLower.contains('sanskrit')) {
      icon = Icons.auto_stories_rounded;
    } else if (nameLower.contains('environment')) {
      icon = Icons.eco_rounded;
    } else if (nameLower.contains('science')) {
      icon = Icons.science_rounded;
    } else {
      icon = Icons.book_rounded;
    }

    // Get color based on subject name
    Color color;
    if (nameLower.contains('math')) {
      color = const Color(0xFF3B82F6); // Blue
    } else if (nameLower.contains('physics')) {
      color = const Color(0xFF10B981); // Green
    } else if (nameLower.contains('chemistry')) {
      color = const Color(0xFFF59E0B); // Amber
    } else if (nameLower.contains('biology')) {
      color = const Color(0xFF84CC16); // Lime
    } else if (nameLower.contains('english')) {
      color = const Color(0xFFEF4444); // Red
    } else if (nameLower.contains('social')) {
      color = const Color(0xFFF59E0B); // Amber
    } else if (nameLower.contains('computer')) {
      color = const Color(0xFF8B5CF6); // Purple
    } else if (nameLower.contains('hindi')) {
      color = const Color(0xFFEC4899); // Pink
    } else if (nameLower.contains('sanskrit')) {
      color = const Color(0xFF06B6D4); // Cyan
    } else if (nameLower.contains('environment')) {
      color = const Color(0xFF84CC16); // Lime
    } else if (nameLower.contains('science')) {
      color = const Color(0xFF10B981); // Green
    } else {
      color = const Color(0xFF6B7280); // Gray
    }

    return Obx(() {
      final isSelected = controller.isSubjectSelected(subject);

      return InkWell(
        onTap: () => controller.toggleSubject(subject),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [color, color.withOpacity(0.85)]
                  : [Colors.grey.shade100, Colors.grey.shade200],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 20 : 10,
                offset: Offset(0, isSelected ? 10 : 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles (only when selected)
              if (isSelected) ...[
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
              ],

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon badge with glass-morphism
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.25)
                            : color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withOpacity(0.4)
                              : color.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Subject details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Comprehensive curriculum',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Checkbox
                    Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_rounded : Icons.add_rounded,
                        color: isSelected ? color : Colors.grey[400],
                        size: 24,
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

  Widget _buildBottomBar() {
    return Obx(() {
      final selectedCount = controller.selectedSubjectModels.length;

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
                      '$selectedCount Subject${selectedCount != 1 ? 's' : ''} Selected',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confirm & Buy Now',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: selectedCount > 0
                    ? () {
                        controller.selectAllChaptersForAllSubjects();
                        Get.toNamed('/cart');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
