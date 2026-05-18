import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/board_model.dart';
import 'package:najahapp/app/modules/packages/controllers/package_controller.dart';

class BoardSelectionView extends GetView<PackageController> {
  const BoardSelectionView({super.key});

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
                      const Text(
                        'Choose Your Board',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the education board for your curriculum',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBoardsGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
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
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0),
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
          'Select Board',
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
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.school_rounded, color: AppTheme.primaryColor, size: 24),
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
                    '$gradeText • $packageText',
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

  Widget _buildBoardsGrid() {
    return Obx(() {
      if (controller.isLoadingBoards.value) {
        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.white)));
      }

      if (controller.boardsError.value.isNotEmpty) {
        return SliverFillRemaining(child: _buildErrorState());
      }

      if (controller.publicBoards.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final board = controller.publicBoards[index];
              return _buildBoardCard(board);
            },
            childCount: controller.publicBoards.length,
          ),
        ),
      );
    });
  }

  Widget _buildBoardCard(BoardModel board) {
    final color = _getBoardColor(board.name);
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        controller.selectBoard(board);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: UIUtils.glossyDecoration(
          baseColor: Colors.white.withOpacity(0.05),
          borderRadius: 24,
          showBorder: true,
        ).copyWith(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(_getBoardIcon(board.name), color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              board.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Education Board',
              style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBoardColor(String name) {
    final n = name.toUpperCase();
    if (n.contains('CBSE')) return Colors.blueAccent;
    if (n.contains('ICSE')) return Colors.tealAccent;
    if (n.contains('STATE')) return Colors.orangeAccent;
    return AppTheme.primaryColor;
  }

  IconData _getBoardIcon(String name) {
    final n = name.toUpperCase();
    if (n.contains('CBSE')) return Icons.account_balance_rounded;
    if (n.contains('ICSE')) return Icons.menu_book_rounded;
    return Icons.school_rounded;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.redAccent.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Failed to load boards', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: controller.loadPublicBoards, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text('No boards available', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
