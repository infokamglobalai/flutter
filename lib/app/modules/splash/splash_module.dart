import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/constants/app_constants.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  Future<void> _navigate() async {
    // 1.5 seconds splash display
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    String targetRoute = Routes.LOGIN;

    try {
      final storageService = Get.find<StorageService>();
      final onboardingCompleted = storageService.isOnboardingCompleted();

      if (!onboardingCompleted) {
        targetRoute = Routes.ONBOARDING;
      } else {
        final token = storageService.getString(AppConstants.storageKeyToken);
        if (token != null && token.isNotEmpty) {
          final userData = storageService.getUserData();
          final userRole = userData?['role']?.toString().toLowerCase();

          if (userRole == 'parent') {
            targetRoute = Routes.PARENT_DASHBOARD;
          } else {
            targetRoute = Routes.DASHBOARD;
          }
        } else {
          targetRoute = Routes.LOGIN;
        }
      }
    } catch (e) {
      debugPrint('Splash navigation error: $e');
      targetRoute = Routes.LOGIN;
    }

    if (!mounted) return;

    // Perform navigation with multiple fallbacks
    try {
      Get.offAllNamed(targetRoute);
    } catch (e) {
      debugPrint('Get.offAllNamed failed: $e');
      try {
        Navigator.of(context).pushReplacementNamed(targetRoute);
      } catch (e2) {
        debugPrint('Navigator fallback failed: $e2');
        Get.toNamed(targetRoute);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Learning Made Simple',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.92),
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentColor.withOpacity(0.95),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // No controller needed for splash screen
  }
}
