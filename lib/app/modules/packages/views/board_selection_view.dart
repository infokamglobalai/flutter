import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/board_model.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';

class BoardSelectionView extends GetView<PackageController> {
  const BoardSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Select Board'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectionSummary(),
            const SizedBox(height: 24),
            Text(
              'Choose Your Board',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the education board for your curriculum',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoadingBoards.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (controller.boardsError.value.isNotEmpty) {
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
                          'Failed to load boards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.boardsError.value,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: controller.loadPublicBoards,
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
                if (controller.publicBoards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No boards available',
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

                // Success state - Display boards
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: controller.publicBoards.length,
                  itemBuilder: (context, index) {
                    final board = controller.publicBoards[index];
                    return _buildBoardCard(
                      board: board,
                      onTap: () => controller.selectBoard(board),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
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
                    '${controller.selectedGradeModel.value?.displayName ?? "Grade"} • ${controller.selectedPackage.value.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 16,
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

  Widget _buildBoardCard({
    required BoardModel board,
    required VoidCallback onTap,
  }) {
    // Get icon based on board name
    IconData icon;
    switch (board.name.toUpperCase()) {
      case 'CBSE':
        icon = Icons.school_rounded;
        break;
      case 'ICSE':
        icon = Icons.menu_book_rounded;
        break;
      case 'IGCSE':
      case 'IB':
        icon = Icons.public_rounded;
        break;
      case 'JEE':
      case 'NEET':
        icon = Icons.science_rounded;
        break;
      case 'STATE BOARD':
        icon = Icons.location_city_rounded;
        break;
      default:
        icon = Icons.more_horiz_rounded;
    }

    // Get color based on board name
    Color color;
    switch (board.name.toUpperCase()) {
      case 'CBSE':
        color = const Color(0xFF3B82F6); // Blue
        break;
      case 'ICSE':
        color = const Color(0xFF10B981); // Green
        break;
      case 'IGCSE':
      case 'IB':
        color = const Color(0xFF8B5CF6); // Purple
        break;
      case 'JEE':
        color = const Color(0xFFEF4444); // Red
        break;
      case 'NEET':
        color = const Color(0xFF06B6D4); // Cyan
        break;
      case 'STATE BOARD':
        color = const Color(0xFFF59E0B); // Amber
        break;
      default:
        color = const Color(0xFF6B7280); // Gray
    }

    // Get subtitle based on board name
    String subtitle;
    switch (board.name.toUpperCase()) {
      case 'CBSE':
        subtitle = 'Central Board';
        break;
      case 'ICSE':
        subtitle = 'Indian Council';
        break;
      case 'IGCSE':
      case 'IB':
        subtitle = 'International';
        break;
      case 'JEE':
        subtitle = 'Engineering';
        break;
      case 'NEET':
        subtitle = 'Medical';
        break;
      case 'STATE BOARD':
        subtitle = 'State Board';
        break;
      default:
        subtitle = 'Education Board';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.85)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
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

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon badge with glass-morphism
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    board.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
