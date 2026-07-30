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
    // Wait for splash animation + ensure all bindings are initialized
    await Future.delayed(const Duration(seconds: 3));

    // Wait until the navigator context is ready
    int retries = 0;
    while (Get.context == null && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      retries++;
    }

    // If widget was disposed before navigation (unlikely but safe), bail out
    if (!mounted) return;

    try {
      StorageService storageService;
      try {
        storageService = Get.find<StorageService>();
      } catch (_) {
        // If StorageService not yet registered, go to login
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // Check if onboarding is completed
      bool onboardingCompleted = false;
      try {
        onboardingCompleted = storageService.isOnboardingCompleted();
      } catch (_) {
        onboardingCompleted = false;
      }

      if (!onboardingCompleted) {
        Get.offAllNamed(Routes.ONBOARDING);
        return;
      }

      // Check if user is logged in
      final token = storageService.getString(AppConstants.storageKeyToken);

      if (token != null && token.isNotEmpty) {
        final userData = storageService.getUserData();
        final userRole = userData?['role'] as String?;

        if (userRole != null) {
          final role = userRole.toLowerCase();
          if (role == 'parent') {
            Get.offAllNamed(Routes.PARENT_DASHBOARD);
            return;
          }
          if (role == 'student') {
            Get.offAllNamed(Routes.DASHBOARD);
            return;
          }
        }
        // Unknown role or no role, go to dashboard as student
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      // Ultimate fallback — always navigate away from splash
      if (mounted) {
        Get.offAllNamed(Routes.LOGIN);
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
