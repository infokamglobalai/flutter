import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/packages/controllers/all_packages_controller.dart';
import 'package:najahapp/app/data/models/package_model.dart';

class AllPackagesView extends GetView<AllPackagesController> {
  const AllPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'All Packages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey[800],
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load packages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error.value,
                    style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadPackages(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final regularPackages = controller.regularPackages;
        final competitivePackages = controller.competitivePackages;

        if (regularPackages.isEmpty && competitivePackages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppTheme.primaryColor,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Packages Available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Check back later for new learning packages',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Regular Packages Section
            if (regularPackages.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Academic Packages',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    '${regularPackages.length} package${regularPackages.length != 1 ? 's' : ''} available',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPackageCard(
                        context,
                        regularPackages[index],
                        index,
                      ),
                    );
                  }, childCount: regularPackages.length),
                ),
              ),
            ],

            // Competitive Exams Section
            if (competitivePackages.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    regularPackages.isNotEmpty ? 24 : 16,
                    16,
                    8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Competitive Exams',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    '${competitivePackages.length} program${competitivePackages.length != 1 ? 's' : ''} • JEE, NEET & more',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildCompetitivePackageCard(
                        context,
                        competitivePackages[index],
                        index,
                      ),
                    );
                  }, childCount: competitivePackages.length),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      }),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    PackageModel package,
    int index,
  ) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
    ];
    final color = colors[index % colors.length];
    final isExpanded = false.obs;

    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/package-selection', arguments: package);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Package Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          image: package.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(package.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: package.imageUrl.isEmpty
                            ? Icon(Icons.school_rounded, color: color, size: 36)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              package.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              maxLines: isExpanded.value ? null : 2,
                              overflow: isExpanded.value
                                  ? null
                                  : TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                    ],
                  ),
                ),
                // Expandable section
                if (package.description.length > 100)
                  InkWell(
                    onTap: () => isExpanded.value = !isExpanded.value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExpanded.value
                                ? 'Show Less'
                                : 'Read Full Description',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded.value
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: color,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitivePackageCard(
    BuildContext context,
    PackageModel package,
    int index,
  ) {
    final colors = [
      AppTheme.accentColor,
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
    ];
    final color = colors[index % colors.length];
    final isExpanded = false.obs;

    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/package-selection', arguments: package);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Package Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          image: package.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(package.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: package.imageUrl.isEmpty
                            ? Icon(
                                Icons.emoji_events_rounded,
                                color: color,
                                size: 36,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              package.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              maxLines: isExpanded.value ? null : 2,
                              overflow: isExpanded.value
                                  ? null
                                  : TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                    ],
                  ),
                ),
                // Expandable section
                if (package.description.length > 100)
                  InkWell(
                    onTap: () => isExpanded.value = !isExpanded.value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExpanded.value
                                ? 'Show Less'
                                : 'Read Full Description',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded.value
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: color,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
