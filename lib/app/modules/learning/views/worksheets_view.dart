import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/worksheets_controller.dart';
import '../../../data/models/worksheet_model.dart';

class WorksheetsView extends GetView<WorksheetsController> {
  const WorksheetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsSection(context),
                const SizedBox(height: 16),
                _buildFiltersSection(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildWorksheetsList(context),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFEF4444),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFEF4444),
                    const Color(0xFFEF4444).withValues(alpha: 0.9),
                    const Color(0xFFDC2626).withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            // Decorative elements
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Worksheets',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Practice exercises & worksheets',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Obx(() {
      final totalWorksheets = controller.totalWorksheets.value;
      final filteredCount = controller.worksheets.length;
      final hasFilters =
          controller.selectedGradeId.value != null ||
          controller.selectedSubjectId.value != null ||
          controller.selectedChapterId.value != null ||
          controller.selectedYear.value != null;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.description,
                    '$totalWorksheets',
                    'Total',
                    const Color(0xFFEF4444),
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatItem(
                    Icons.filter_list,
                    '$filteredCount',
                    'Showing',
                    const Color(0xFF6366F1),
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatItem(
                    Icons.calendar_today,
                    '3 Years',
                    'Archive',
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Active filters',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.clearFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Filter Worksheets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grade Filter
          Obx(
            () => _buildFilterDropdown(
              label: 'Grade',
              value: controller.selectedGradeId.value != null
                  ? controller.getGradeName(controller.selectedGradeId.value)
                  : null,
              items: controller.grades.map((g) => g['name']!).toList(),
              icon: Icons.school,
              onChanged: (value) {
                if (value == null) {
                  controller.setGradeFilter(null);
                } else {
                  final gradeId = controller.grades.firstWhereOrNull(
                    (g) => g['name'] == value,
                  )?['id'];
                  controller.setGradeFilter(gradeId);
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          // Subject Filter
          Obx(
            () => _buildFilterDropdown(
              label: 'Subject',
              value: controller.selectedSubjectId.value != null
                  ? controller.getSubjectName(
                      controller.selectedSubjectId.value,
                    )
                  : null,
              items: controller.subjects.map((s) => s['name']!).toList(),
              icon: Icons.book,
              onChanged: (value) {
                if (value == null) {
                  controller.setSubjectFilter(null);
                } else {
                  final subjectId = controller.subjects.firstWhereOrNull(
                    (s) => s['name'] == value,
                  )?['id'];
                  controller.setSubjectFilter(subjectId);
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          // Chapter Filter (only show if subject is selected)
          Obx(
            () => controller.chapters.isNotEmpty
                ? Column(
                    children: [
                      _buildFilterDropdown(
                        label: 'Chapter',
                        value: controller.selectedChapterId.value != null
                            ? controller.getChapterName(
                                controller.selectedChapterId.value,
                              )
                            : null,
                        items: controller.chapters
                            .map((c) => c['name']!)
                            .toList(),
                        icon: Icons.menu_book,
                        onChanged: (value) {
                          if (value == null) {
                            controller.setChapterFilter(null);
                          } else {
                            final chapterId = controller.chapters
                                .firstWhereOrNull(
                                  (c) => c['name'] == value,
                                )?['id'];
                            controller.setChapterFilter(chapterId);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // Year Filter
          Obx(
            () => _buildFilterDropdown(
              label: 'Academic Year',
              value: controller.selectedYear.value?.toString(),
              items: controller.years.map((y) => y.toString()).toList(),
              icon: Icons.calendar_today,
              onChanged: (value) {
                controller.setYearFilter(
                  value != null ? int.tryParse(value) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? const Color(0xFFEF4444) : Colors.grey[300]!,
          width: value != null ? 2 : 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: value != null ? const Color(0xFFEF4444) : Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintText: 'Select $label',
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildWorksheetsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.worksheets.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final worksheets = controller.worksheets;

      if (worksheets.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No worksheets found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final worksheet = worksheets[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildWorksheetCard(worksheet),
            );
          }, childCount: worksheets.length),
        ),
      );
    });
  }

  Widget _buildWorksheetCard(WorksheetModel worksheet) {
    // Determine difficulty based on file size or default to Medium
    final difficulty = worksheet.fileSize > 3000000
        ? 'Hard'
        : worksheet.fileSize > 1500000
        ? 'Medium'
        : 'Easy';
    final difficultyColor = controller.getDifficultyColor(difficulty);
    final addedDate = worksheet.createdAt;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.downloadWorksheet(worksheet),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worksheet.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(addedDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.school,
                    worksheet.grade.name,
                    const Color(0xFF6366F1),
                  ),
                  _buildInfoChip(
                    Icons.book,
                    worksheet.subject.name,
                    const Color(0xFF8B5CF6),
                  ),
                  _buildInfoChip(
                    Icons.calendar_today,
                    worksheet.academicYear.toString(),
                    const Color(0xFF10B981),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  Flexible(
                    child: _buildStatBadge(
                      Icons.insert_drive_file,
                      worksheet.mimeType.contains('pdf') ? 'PDF' : 'Document',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: _buildStatBadge(
                      Icons.book,
                      worksheet.chapter.name,
                      maxWidth: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 14,
                          color: difficultyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: difficultyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Download Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.downloadWorksheet(worksheet),
                  icon: const Icon(
                    Icons.download,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Download (${worksheet.formattedFileSize})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, {bool maxWidth = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        if (maxWidth)
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
