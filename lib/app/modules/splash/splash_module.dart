import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/constants/app_constants.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final storageService = Get.find<StorageService>();

      // Check if onboarding is completed
      final onboardingCompleted = storageService.isOnboardingCompleted();

      if (!onboardingCompleted) {
        // First time user, show onboarding
        Get.offAllNamed('/onboarding');
        return;
      }

      // Check if user is logged in
      final token = storageService.getString(AppConstants.storageKeyToken);

      if (token != null && token.isNotEmpty) {
        // User is logged in, check their role and redirect accordingly
        final userData = storageService.getUserData();
        final userRole = userData?['role'] as String?;

        if (userRole != null) {
          // Convert role to lowercase for case-insensitive comparison
          final role = userRole.toLowerCase();

          if (role == 'parent') {
            Get.offAllNamed('/parent-dashboard');
          } else if (role == 'mentor') {
            Get.offAllNamed('/mentor-dashboard');
          } else {
            // Default to student dashboard for 'student' role or any other role
            Get.offAllNamed('/dashboard');
          }
        } else {
          // No role found, default to student dashboard
          Get.offAllNamed('/dashboard');
        }
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      // Fallback to login if there's an error
      Get.offAllNamed('/login');
    }
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
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Logo with animation
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
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
              const SizedBox(height: 32),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Learning Made Simple',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  strokeWidth: 3,
                ),
              ),
            ],
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
