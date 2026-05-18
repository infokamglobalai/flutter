import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/packages/controllers/all_packages_controller.dart';
import 'package:najahapp/app/data/models/package_model.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'dart:math' as math;

class AllPackagesView extends GetView<AllPackagesController> {
  const AllPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Deep Navy
      body: Stack(
        children: [
          // Background Decorative Elements
          _buildBackgroundDecoration(),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              _buildContent(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        // Top right mesh glow
        Positioned(
          top: -150,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.primaryColor.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        // Bottom left mesh glow
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
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
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
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
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        centerTitle: false,
        title: const Text(
          'Learning Packages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0F172A),
                const Color(0xFF0F172A).withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState();
        }

        final regularPackages = controller.regularPackages;
        final competitivePackages = controller.competitivePackages;

        if (regularPackages.isEmpty && competitivePackages.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (regularPackages.isNotEmpty) ...[
                _buildSectionHeader('Academic Excellence', Icons.school_rounded, AppTheme.primaryColor),
                const SizedBox(height: 16),
                ...regularPackages.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPackageCard(entry.value, entry.key, AppTheme.primaryColor),
                )),
              ],
              
              if (competitivePackages.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('Competitive Edge', Icons.emoji_events_rounded, AppTheme.accentColor),
                const SizedBox(height: 16),
                ...competitivePackages.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPackageCard(entry.value, entry.key, AppTheme.accentColor),
                )),
              ],
              
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(PackageModel package, int index, Color baseColor) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(Routes.PACKAGE_SELECTION, arguments: package);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: UIUtils.glossyDecoration(
          baseColor: Colors.white.withOpacity(0.05),
          borderRadius: 24,
          showBorder: true,
        ).copyWith(
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle Inner Glow
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        baseColor.withOpacity(0.1),
                        baseColor.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon/Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: baseColor.withOpacity(0.2), width: 1),
                        image: package.imageUrl.isNotEmpty
                            ? DecorationImage(image: NetworkImage(package.imageUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: package.imageUrl.isEmpty
                          ? Icon(Icons.auto_stories_rounded, color: baseColor, size: 36)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            package.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildBadge(
                                '${package.validityDays} Days',
                                Icons.timer_outlined,
                                baseColor,
                              ),
                              const SizedBox(width: 8),
                              _buildBadge(
                                '${package.subjects.length} Subjects',
                                Icons.book_rounded,
                                baseColor,
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100, left: 32, right: 32),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.grey[600], size: 80),
            const SizedBox(height: 24),
            const Text(
              'No Packages Available',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Check back later for new programs.',
              style: TextStyle(fontSize: 15, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100, left: 24, right: 24),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Failed to load packages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.loadPackages(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
