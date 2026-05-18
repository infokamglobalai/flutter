import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import '../controllers/brain_games_controller.dart';
import 'dart:math' as math;

class BrainGamesView extends GetView<BrainGamesController> {
  const BrainGamesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsSection(context),
                const SizedBox(height: 16),
                _buildCategoryFilter(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildGamesList(context),
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
              decoration: UIUtils.glossyDecoration(
                baseColor: const Color(0xFFEF4444),
                borderRadius: 0,
                showBorder: false,
              ),
            ),
            // Decorative elements
            const Positioned(
              top: -40,
              right: -30,
              child: _AnimatedGlowBlob(color: Colors.white, size: 160),
            ),
            const Positioned(
              bottom: -30,
              left: -40,
              child: _AnimatedGlowBlob(color: Colors.white, size: 120),
            ),
            // Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: UIUtils.glassDecoration(borderRadius: 16).copyWith(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
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
                          'Brain Games',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Puzzles, Quizzes & IQ Boosters',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
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
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.emoji_events_rounded, color: Colors.white),
              onPressed: () {
                Get.snackbar(
                  'Leaderboard',
                  'Coming soon!',
                  backgroundColor: const Color(0xFFEF4444),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
              tooltip: 'Leaderboard',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return GetBuilder<BrainGamesController>(
      builder: (ctrl) {
        final stats = ctrl.getUserStats();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: UIUtils.glossyDecoration(
            baseColor: Colors.white,
            borderRadius: 24,
            showBorder: true,
          ).copyWith(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: UIUtils.glossyDecoration(
                      baseColor: const Color(0xFFEF4444),
                      borderRadius: 14,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats['rank']} Player',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${(stats['progressToNext'] * 100).toInt()}% to ${stats['nextRank']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: UIUtils.glossyDecoration(
                      baseColor: Colors.orange[500]!,
                      borderRadius: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats['streak']} day streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      Icons.games_rounded,
                      '${stats['gamesPlayed']}',
                      'Games Played',
                      const Color(0xFF6366F1),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      Icons.stars_rounded,
                      '${stats['totalScore']}',
                      'Total Score',
                      const Color(0xFFF59E0B),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      Icons.military_tech_rounded,
                      '${stats['badges']}',
                      'Badges',
                      const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            return SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected =
                      (category == 'All' &&
                          controller.selectedCategory.value == null) ||
                      (controller.selectedCategory.value == category);

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < controller.categories.length - 1 ? 8 : 0,
                    ),
                    child: InkWell(
                      onTap: () => controller.setCategory(category),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: isSelected
                            ? UIUtils.glossyDecoration(
                                baseColor: const Color(0xFFEF4444),
                                borderRadius: 20,
                              )
                            : UIUtils.glassDecoration(borderRadius: 20).copyWith(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!, width: 1.5),
                              ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGamesList(BuildContext context) {
    return Obx(() {
      final games = controller.filteredGames;

      if (games.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.games_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No games found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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
            final game = games[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGameCard(game),
            );
          }, childCount: games.length),
        ),
      );
    });
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    final color = Color(game['color'] as int);

    // Check if game is fully implemented
    final isImplemented = _isGameImplemented(game['id']);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          controller.playGame(game);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: UIUtils.glossyDecoration(
            baseColor: Colors.white,
            borderRadius: 24,
            showBorder: true,
          ).copyWith(
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: UIUtils.glossyDecoration(
                  baseColor: color,
                  borderRadius: 18,
                ),
                child: Icon(
                  _getIconData(game['icon'] as String),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                            decoration: UIUtils.glassDecoration(borderRadius: 8).copyWith(
                              color: _getDifficultyColor(game['difficulty'] as String).withValues(alpha: 0.12),
                              border: Border.all(color: _getDifficultyColor(game['difficulty'] as String).withValues(alpha: 0.3), width: 1.2),
                            ),
                          child: Text(
                            game['difficulty'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: _getDifficultyColor(game['difficulty'] as String),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (!isImplemented) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      game['description'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game['duration'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${game['plays']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${game['rating']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: UIUtils.glassDecoration(borderRadius: 12).copyWith(
                  color: color.withValues(alpha: 0.08),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'grid_on':
        return Icons.grid_on_rounded;
      case 'auto_graph':
        return Icons.auto_graph_rounded;
      case 'style':
        return Icons.style_rounded;
      case 'pattern':
        return Icons.pattern_rounded;
      case 'text_fields':
        return Icons.text_fields_rounded;
      case 'grid_4x4':
        return Icons.grid_4x4_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'category':
        return Icons.category_rounded;
      case '3d_rotation':
        return Icons.threed_rotation_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'lightbulb':
        return Icons.lightbulb_rounded;
      case 'psychology_alt':
        return Icons.psychology_alt_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'flash_on':
        return Icons.flash_on_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'grid_view':
        return Icons.grid_view_rounded;
      case 'view_in_ar':
        return Icons.view_in_ar_rounded;
      case 'scatter_plot':
        return Icons.scatter_plot_rounded;
      case 'format_list_numbered':
        return Icons.format_list_numbered_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      default:
        return Icons.games_rounded;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  bool _isGameImplemented(String gameId) {
    // All generated IDs map to one of the working engines.
    return gameId.startsWith('math_') ||
        gameId.startsWith('memory_') ||
        gameId.startsWith('word_') ||
        gameId.startsWith('quiz_') ||
        gameId.startsWith('reflex_') ||
        gameId.startsWith('pattern_') ||
        gameId.startsWith('sequence_');
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
