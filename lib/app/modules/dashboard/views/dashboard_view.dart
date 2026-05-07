import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'package:najahapp/app/data/models/package_model.dart';
import 'package:najahapp/app/data/models/subscription_model.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver {
  DashboardController get controller => Get.find<DashboardController>();
  final GlobalKey _subscriptionsKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerPageController = PageController();
  Timer? _bannerAutoTimer;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerAutoTimer?.cancel();
    _bannerPageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startBannerAutoSlide() {
    _bannerAutoTimer?.cancel();
    _bannerAutoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final items = controller.banners;
      if (items.isEmpty) return;
      _bannerIndex = (_bannerIndex + 1) % items.length;
      if (_bannerPageController.hasClients) {
        _bannerPageController.animateToPage(
          _bannerIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh subscriptions when app comes to foreground
      controller.loadUserSubscriptions();
      controller.loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final guest = controller.isGuestMode.value;
      final tab = controller.bottomNavIndex.value;

      return Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: guest
                      ? [
                          ..._buildGuestUserSections(context),
                          const SizedBox(height: 24),
                          _buildMarketingDocuments(context),
                          const SizedBox(height: 24),
                          _buildRegistrationForm(context),
                          const SizedBox(height: 32),
                        ]
                      : [
                          Obx(() {
                            if (!controller
                                .notificationPermissionGranted
                                .value) {
                              return _buildNotificationPermissionBanner(
                                context,
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          ..._buildSubscribedUserSections(context, tab),
                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            guest ? null : _buildBottomNavigationBar(context),
      );
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.bottomNavIndex.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  selectedIndex: selectedIndex,
                  color: AppTheme.primaryColor,
                ),
                _buildNavItem(
                  icon: Icons.school_rounded,
                  label: 'Learn',
                  index: 1,
                  selectedIndex: selectedIndex,
                  color: AppTheme.primaryColor,
                ),
                _buildNavItem(
                  icon: Icons.support_agent_rounded,
                  label: 'Support',
                  index: 2,
                  selectedIndex: selectedIndex,
                  color: AppTheme.primaryColor,
                ),
                _buildNavItem(
                  icon: Icons.analytics_rounded,
                  label: 'Activity',
                  index: 3,
                  selectedIndex: selectedIndex,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    required Color color,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.bottomNavIndex.value = index;
          HapticFeedback.lightImpact();
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top indicator line
              Container(
                height: 2,
                width: 24,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 8),
              // Icon
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[500],
                size: 22,
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[600],
                  letterSpacing: 0,
                  height: 1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSubscribedUserSections(
    BuildContext context,
    int selectedTab,
  ) {
    // Common sections shown on all tabs
    final commonSections = [
      _buildTopBannerSection(context),
      const SizedBox(height: 24),
    ];

    // Tab-specific content
    switch (selectedTab) {
      case 0: // Home
        return [
          ...commonSections,
          _buildQuickAccessSection(context),
          const SizedBox(height: 24),
          _buildSubscribedPackages(context),
          const SizedBox(height: 24),
          _buildPromotionalVideo(context),
          const SizedBox(height: 24),
          _buildMarketingVideos(context),
        ];

      case 1: // Learn
        return [
          ...commonSections,
          _buildSectionHeader('Learning & Practice'),
          const SizedBox(height: 16),
          _buildTestYourKnowledgeSection(context),
          const SizedBox(height: 16),
          _buildWorksheetsSection(context),
          const SizedBox(height: 16),
          _buildExercisesSection(context),
          const SizedBox(height: 16),
          _buildBrainGamesSection(context),
          const SizedBox(height: 16),
          _buildReportsSection(context),
          const SizedBox(height: 16),
          _buildFreeContentSection(context),
          const SizedBox(height: 24),
          _buildSubscribedPackages(context),
        ];

      case 2: // Support
        return [
          ...commonSections,
          _buildSectionHeader('Help & Support'),
          const SizedBox(height: 16),
          _buildMentorChatSection(context),
          const SizedBox(height: 16),
          _buildCoachingSection(context),
          const SizedBox(height: 16),
          _buildAskQuestionSection(context),
          const SizedBox(height: 16),
          _buildAiCounsellorSupportSection(context),
          const SizedBox(height: 16),
          _buildContactSupportSection(context),
        ];

      case 3: // Activity
        return [
          ...commonSections,
          _buildSectionHeader('Activity & Downloads'),
          const SizedBox(height: 16),
          _buildWatchHistorySection(context),
          const SizedBox(height: 16),
          _buildMyDownloadsSection(context),
        ];

      default:
        return commonSections;
    }
  }

  Widget _buildTopBannerSection(BuildContext context) {
    return Obx(() {
      final banners = controller.banners;
      if (banners.isEmpty) {
        return _buildWelcomeSection(context);
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final marginH = screenWidth < 360 ? 12.0 : 16.0;

      return Container(
        margin: EdgeInsets.fromLTRB(marginH, 16, marginH, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _bannerPageController,
                  onPageChanged: (i) => setState(() => _bannerIndex = i),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final b = banners[index];
                    return InkWell(
                      onTap: () => _handleBannerTap(b.linkType, b.internalRoute,
                          b.internalParams, b.externalUrl),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            b.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if ((b.title).trim().isNotEmpty ||
                              (b.description).trim().isNotEmpty)
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.62),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if ((b.title).trim().isNotEmpty)
                                      Text(
                                        b.title.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    if ((b.description).trim().isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        b.description.trim(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.92),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(banners.length, (i) {
                      final active = i == _bannerIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: active ? 18 : 6,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _handleBannerTap(
    String linkType,
    String internalRoute,
    Map<String, dynamic> internalParams,
    String externalUrl,
  ) async {
    final lt = linkType.toLowerCase().trim();
    if (lt == 'external') {
      final url = externalUrl.trim();
      if (url.isEmpty) return;
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (lt == 'internal') {
      final r = internalRoute.trim();
      if (r.isEmpty) return;
      Get.toNamed(r, arguments: internalParams);
      return;
    }
  }

  Widget _buildSectionHeader(String title) {
    IconData icon;
    Color iconColor;

    // Choose icon based on section title
    if (title.contains('Learning')) {
      icon = Icons.menu_book_rounded;
      iconColor = AppTheme.primaryColor;
    } else if (title.contains('Help') || title.contains('Support')) {
      icon = Icons.support_agent_rounded;
      iconColor = AppTheme.accentColor;
    } else if (title.contains('Activity') || title.contains('Downloads')) {
      icon = Icons.history_rounded;
      iconColor = AppTheme.secondaryColor;
    } else {
      icon = Icons.category_rounded;
      iconColor = AppTheme.primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGuestUserSections(BuildContext context) {
    return [
      _buildLogoSection(context),
      const SizedBox(height: 24),
      _buildPackagesCTA(context),
      const SizedBox(height: 24),
      _buildIntroductionSection(context),
      const SizedBox(height: 24),
      _buildTeachingMethodology(context),
      const SizedBox(height: 24),
      _buildPromotionalVideo(context),
      const SizedBox(height: 24),
      _buildMarketingVideos(context),
    ];
  }

  Widget _buildAppBar(BuildContext context) {
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final appBarHeight = isSmallScreen
        ? 100.0
        : (isMediumScreen ? 110.0 : 120.0);

    return SliverAppBar(
      expandedHeight: appBarHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Welcome back ',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  '👋',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Obx(() {
                              final profile = controller.studentProfile.value;
                              final displayName =
                                  profile?.fullName ?? 'Student';
                              return Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notification Icon with Badge
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
                              child: Icon(
                                Icons.notifications,
                                color: AppTheme.primaryColor,
                                size: isSmallScreen ? 22 : 24,
                              ),
                            ),
                          ),
                          // Notification badge
                          Obx(() {
                            final count = controller.notificationCount.value;
                            if (count == 0) return const SizedBox.shrink();

                            return Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    count > 9 ? '9+' : count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Profile Picture
                      Container(
                        width: isSmallScreen ? 44 : 48,
                        height: isSmallScreen ? 44 : 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => Get.toNamed(Routes.STUDENT_PROFILE),
                          borderRadius: BorderRadius.circular(24),
                          child: ClipOval(
                            child: Container(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                                size: isSmallScreen ? 22 : 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToSubscriptions() {
    final context = _subscriptionsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildWelcomeSection(BuildContext context) {
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final marginH = isSmallScreen ? 12.0 : 16.0;
    final marginV = isSmallScreen ? 16.0 : 20.0;
    final cardPadding = isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);
    final borderRadius = isSmallScreen ? 16.0 : 20.0;

    return Container(
      margin: EdgeInsets.fromLTRB(marginH, marginV, marginH, 0),
      height: isSmallScreen ? 200.0 : 220.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8B384), Color(0xFFD9A46F)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          // Content - Left Side
          Positioned(
            left: cardPadding,
            top: cardPadding,
            bottom: cardPadding,
            right: isSmallScreen ? 140 : 160,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learn anytime &\nanywhere',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22.0 : 26.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        'start learning new skill and\ngrowing your skill.',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11.0 : 12.0,
                          color: const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Arrow Button
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 0,
                    child: InkWell(
                      onTap: _scrollToSubscriptions,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: isSmallScreen ? 44 : 50,
                        height: isSmallScreen ? 44 : 50,
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/up_arrow.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ),
          // Woman Image - Right Side
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              child: Image.asset(
                'assets/images/women.png',
                width: isSmallScreen ? 140 : 160,
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestYourKnowledgeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.PUBLIC_ASSESSMENTS),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: AppTheme.secondaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Your Knowledge',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assessments from your learning',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorksheetsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.WORKSHEETS),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Worksheets',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Practice sheets & exercises',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.EXERCISES),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chapter-wise practice questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.STUDENT_REPORTS),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Color(0xFF06B6D4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Progress, history & results',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreeContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.FREE_CONTENT),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.play_lesson_rounded,
                    color: AppTheme.secondaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Free Content',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explore public videos and resources',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchHistorySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.WATCH_HISTORY),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Watch History & Reports',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track learning activities',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyDownloadsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.DOWNLOADS),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.download_for_offline_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Downloads',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Watch offline & track progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMentorChatSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.MENTOR_CHAT),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Doubts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ask questions to mentors',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoachingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.STUDENT_COACHING),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1-on-1 Coaching',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Request coaching and book mentor slots',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAskQuestionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.STUDENT_QNA_THREADS),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ask Question',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI-powered answers from courses',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiCounsellorSupportSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.STUDENT_AI_COUNSELLOR),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Counsellor',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Personalized guidance and planning',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrainGamesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.BRAIN_GAMES),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.games_rounded,
                    color: Colors.pink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quiz & Puzzle Games',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Puzzles, quizzes & boost IQ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSupportSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.MY_TICKETS),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Support',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submit & track support tickets',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribedPackages(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSubscriptions.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      }

      if (controller.subscriptionsError.value.isNotEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load subscriptions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.subscriptionsError.value,
                style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.loadUserSubscriptions(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      final subscriptions = controller.userSubscriptions;

      if (subscriptions.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                Icons.card_membership_outlined,
                color: AppTheme.primaryColor,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Subscriptions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Subscribe to a package to start learning',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // Group subscriptions by package
      final groupedSubscriptions = <String, List<SubscriptionModel>>{};
      for (final subscription in subscriptions) {
        final packageId = subscription.package.id;
        if (!groupedSubscriptions.containsKey(packageId)) {
          groupedSubscriptions[packageId] = [];
        }
        groupedSubscriptions[packageId]!.add(subscription);
      }

      return Padding(
        key: _subscriptionsKey,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main section header - matching reference
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Course',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: Colors.grey[700],
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display all subscriptions as horizontal list
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subscriptions.length,
                padding: const EdgeInsets.only(bottom: 8),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < subscriptions.length - 1 ? 12 : 0,
                    ),
                    child: _buildSubscriptionCard(
                      context,
                      subscriptions[index],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // View all course button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.toNamed(Routes.MY_SUBSCRIPTIONS),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  ),
                  child: const Text(
                    'View all course',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    SubscriptionModel subscription,
  ) {
    final color = const Color(0xFF06B6D4); // Cyan color for progress
    final progress = subscription.progress;
    final overallPercentage = (progress * 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed(Routes.SUBJECT_CHAPTER_DETAIL, arguments: subscription);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large image/placeholder area
              Container(
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: (subscription.package.imageUrl.isNotEmpty)
                      ? Image.network(
                          subscription.package.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              _getSubjectIcon(subscription.package.name),
                              size: 44,
                              color: Colors.grey[400],
                            ),
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            _getSubjectIcon(subscription.package.name),
                            size: 44,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      subscription.package.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Subtitle
                    Text(
                      '${subscription.grade.name} . ${subscription.board.name}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subscription.totalVideos.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.insert_drive_file_outlined,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subscription.totalAssessments.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Progress text
                    Text(
                      '$overallPercentage% Completed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
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

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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

  Widget _buildQuickAccessSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  icon: Icons.trending_up_rounded,
                  label: 'My progress',
                  color: const Color(0xFF06B6D4),
                  onTap: () => Get.toNamed(Routes.STUDENT_PROGRESS),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  icon: Icons.assignment_rounded,
                  label: 'Quiz',
                  color: const Color(0xFFE8B384),
                  onTap: () => Get.toNamed(Routes.BRAIN_GAMES),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  context,
                  icon: Icons.confirmation_number_rounded,
                  label: 'Tickets',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => Get.toNamed(Routes.MY_TICKETS),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final marginH = isSmallScreen ? 12.0 : 16.0;
    final marginV = isSmallScreen ? 16.0 : 20.0;
    final logoHeight = isSmallScreen ? 160.0 : (isMediumScreen ? 170.0 : 180.0);
    final borderRadius = isSmallScreen ? 16.0 : 20.0;

    return Container(
      margin: EdgeInsets.fromLTRB(marginH, marginV, marginH, 0),
      height: logoHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.9),
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: isSmallScreen ? 16 : 20,
            offset: Offset(0, isSmallScreen ? 6 : 8),
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
              width: isSmallScreen ? 100.0 : 120.0,
              height: isSmallScreen ? 100.0 : 120.0,
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
              width: isSmallScreen ? 80.0 : 100.0,
              height: isSmallScreen ? 80.0 : 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: AppTheme.primaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'EduAiTutors',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Powered by KICCPA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesCTA(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPackages.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      }

      if (controller.packagesError.value.isNotEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load packages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.packagesError.value,
                style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.loadPublicPackages(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      final packages = controller.publicPackages;

      // Filter packages
      final regularPackages = packages
          .where((p) => !p.isCompetitiveExam)
          .toList();
      final competitivePackages = packages
          .where((p) => p.isCompetitiveExam)
          .toList();

      if (packages.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: AppTheme.primaryColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No Packages Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new learning packages',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Regular Packages Section
          if (regularPackages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clean header design
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Packages',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Choose your perfect learning path',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${regularPackages.length} packages',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.ALL_PACKAGES),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 3x2 Grid Layout for packages
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: regularPackages.length > 6
                        ? 6
                        : regularPackages.length,
                    itemBuilder: (context, index) {
                      final package = regularPackages[index];
                      return _buildPublicPackageCard(context, package, index);
                    },
                  ),
                ],
              ),
            ),

          // Competitive Exams Section
          if (competitivePackages.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildCompetitiveExamsSection(context, competitivePackages),
          ],
        ],
      );
    });
  }

  Widget _buildCompetitiveExamsSection(
    BuildContext context,
    List<PackageModel> competitivePackages,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Competitive Exam',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Prepare for JEE, NEET & more...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${competitivePackages.length} Programs',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.ALL_PACKAGES),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Horizontal list of cards
          ...competitivePackages
              .take(2)
              .map(
                (package) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCompetitivePackageCard(context, package),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildCompetitivePackageCard(
    BuildContext context,
    PackageModel package,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed('/package-selection', arguments: package);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              // Image on left
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: package.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          package.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.orange[300],
                                size: 36,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.orange[300],
                          size: 36,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Title in center
              Expanded(
                child: Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Arrow on right
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPublicPackageCard(
    BuildContext context,
    PackageModel package,
    int index,
  ) {
    return Material(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image placeholder area
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: package.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            package.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.grey[100]);
                            },
                          ),
                        )
                      : null,
                ),
              ),

              // Package name section
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroductionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.groups_3_rounded,
              count: '1000+',
              label: 'Students',
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events_rounded,
              count: '95%',
              label: 'Success',
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.workspace_premium_rounded,
              count: 'Top',
              label: 'Rated',
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachingMethodology(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Our Approach',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildMethodologyCard(
                  'Personalized',
                  Icons.person_rounded,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodologyCard(
                  'Interactive',
                  Icons.touch_app_rounded,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMethodologyCard(
                  'Assessed',
                  Icons.assessment_rounded,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodologyCard(
                  'Collaborative',
                  Icons.family_restroom_rounded,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodologyCard(String title, IconData icon, Color color) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalVideo(BuildContext context) {
    final featuredVideos = [
      {
        'id': 1,
        'title': 'Welcome to EduAiTutors',
        'thumbnail': '/video-cover/welcometo-eduaitutors.png',
        'duration': '5:30',
        'embedUrl': 'https://www.youtube.com/embed/-c5r4FSRlh0',
      },
      {
        'id': 2,
        'title': 'Getting Started Guide',
        'thumbnail': '/video-cover/getting-starte-guide.png',
        'duration': '8:15',
        'embedUrl': 'https://www.youtube.com/embed/U92_mc4KEB0',
      },
      {
        'id': 3,
        'title': 'How to Use the Platform',
        'thumbnail': '/video-cover/how-to-use-the-platform.png',
        'duration': '6:45',
        'embedUrl': 'https://www.youtube.com/embed/8hly31xKli0',
      },
    ];

    final mediaBaseUrl = ApiConstants.baseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Videos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final crossAxisCount = c.maxWidth >= 700 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: featuredVideos.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 16 / 12,
                ),
                itemBuilder: (context, index) {
                  final v = featuredVideos[index];
                  final thumbPath = (v['thumbnail'] as String).trim();
                  final thumbUrl = thumbPath.startsWith('http')
                      ? thumbPath
                      : '$mediaBaseUrl$thumbPath';
                  final duration = (v['duration'] as String?) ?? '';
                  final embedUrl = (v['embedUrl'] as String?) ?? '';

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async => _openVideoUrl(embedUrl),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                thumbUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              // subtle dark overlay for readability
                              Container(color: Colors.black.withOpacity(0.18)),
                              // Title overlay (no white background)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    22,
                                    12,
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.75),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    v['title'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 30,
                                  ),
                                ),
                              ),
                              if (duration.isNotEmpty)
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      duration,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingVideos(BuildContext context) {
    final marketingVideos = [
      {
        'id': 1,
        'title': 'Teaching Excellence',
        'thumbnail': '/video-cover/teaching-excellence.png',
        'duration': '10:20',
        'embedUrl': 'https://www.youtube.com/embed/jL1M8e3NpVc',
      },
      {
        'id': 2,
        'title': 'Student Success Stories',
        'thumbnail': '/video-cover/student-success-stories.png',
        'duration': '12:45',
        'embedUrl': 'https://www.youtube.com/embed/bkJQOjaIGvk',
      },
      {
        'id': 3,
        'title': 'Why Choose EduAiTutors',
        'thumbnail': '/video-cover/why-choose-eduaitutors.png',
        'duration': '9:30',
        'embedUrl': 'https://www.youtube.com/embed/Nls9ox39dfQ',
      },
    ];

    final mediaBaseUrl = ApiConstants.baseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Marketing Videos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final crossAxisCount = c.maxWidth >= 700 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: marketingVideos.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 16 / 12,
                ),
                itemBuilder: (context, index) {
                  final v = marketingVideos[index];
                  final thumbPath = (v['thumbnail'] as String).trim();
                  final thumbUrl = thumbPath.startsWith('http')
                      ? thumbPath
                      : '$mediaBaseUrl$thumbPath';
                  final duration = (v['duration'] as String?) ?? '';
                  final embedUrl = (v['embedUrl'] as String?) ?? '';

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async => _openVideoUrl(embedUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              thumbUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.black.withOpacity(0.65),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v['title'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Watch Now',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (duration.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.18),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            duration,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 34,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openVideoUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final youtubeWatch = _youtubeWatchUrlFromEmbed(trimmed);
    final uri = Uri.tryParse(youtubeWatch ?? trimmed);
    if (uri == null) return;

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  String? _youtubeWatchUrlFromEmbed(String embedUrl) {
    try {
      final uri = Uri.parse(embedUrl);
      if (!uri.host.contains('youtube.com')) return null;
      final segments = uri.pathSegments;
      final embedIndex = segments.indexOf('embed');
      if (embedIndex == -1 || embedIndex + 1 >= segments.length) return null;
      final id = segments[embedIndex + 1];
      if (id.isEmpty) return null;
      return 'https://www.youtube.com/watch?v=$id';
    } catch (_) {
      return null;
    }
  }

  Widget _buildMarketingDocuments(BuildContext context) {
    final documents = [
      {
        'title': 'Catalog',
        'subtitle': '2025 Edition',
        'description': 'Complete course catalog',
        'icon': Icons.menu_book_rounded,
        'gradient': [
          AppTheme.primaryColor,
          AppTheme.primaryColor.withOpacity(0.7),
        ],
      },
      {
        'title': 'Success Report',
        'subtitle': 'Student Stories',
        'description': 'Achievement highlights',
        'icon': Icons.assessment_rounded,
        'gradient': [
          AppTheme.primaryColor,
          AppTheme.primaryColor.withOpacity(0.7),
        ],
      },
      {
        'title': 'Tuition Guide',
        'subtitle': 'Pricing Plans',
        'description': 'Fees & packages',
        'icon': Icons.payments_rounded,
        'gradient': [
          AppTheme.primaryColor,
          AppTheme.primaryColor.withOpacity(0.7),
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.folder_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Resources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: documents.length,
              padding: const EdgeInsets.only(bottom: 8),
              itemBuilder: (context, index) {
                final doc = documents[index];
                final gradient = doc['gradient'] as List<Color>;

                return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < documents.length - 1 ? 16 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.snackbar(
                          doc['title'] as String,
                          'Opening ${doc['title']}...',
                          backgroundColor: gradient[0],
                          colorText: Colors.white,
                          icon: Icon(
                            doc['icon'] as IconData,
                            color: Colors.white,
                          ),
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradient,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: gradient[0].withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
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
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      doc['icon'] as IconData,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        doc['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              doc['description'] as String,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_rounded,
                                              color: gradient[0],
                                              size: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final childNameController = TextEditingController();
    final gradeController = TextEditingController();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.app_registration_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register Your Interest',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Join hundreds of successful families',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: nameController,
            label: 'Parent Name',
            icon: Icons.person_rounded,
            hint: 'Enter your full name',
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: emailController,
            label: 'Email Address',
            icon: Icons.email_rounded,
            hint: 'your.email@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: phoneController,
            label: 'Phone Number',
            icon: Icons.phone_rounded,
            hint: '+1 (555) 000-0000',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: childNameController,
            label: 'Child\'s Name',
            icon: Icons.child_care_rounded,
            hint: 'Enter child\'s full name',
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: gradeController,
            label: 'Grade/Class',
            icon: Icons.school_rounded,
            hint: 'e.g., Grade 5',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Success',
                  'Thank you! We will contact you shortly.',
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: AppTheme.primaryColor,
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Submit Registration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationPermissionBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay updated with course updates, messages, and more',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () async {
                final granted = await controller
                    .requestNotificationPermission();
                if (granted) {
                  Get.snackbar(
                    'Success',
                    'Notifications enabled successfully!',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  'Enable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
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
