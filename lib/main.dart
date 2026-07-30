import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:najahapp/app/core/bindings/initial_binding.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/routes/app_pages.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(exception: error, stack: stack),
      );
      return true; // prevent hard crash on some platforms
    };

    // Initialize Firebase (safely wrapped in try-catch)
    if (!kIsWeb) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint('Firebase initialization error: $e');
      }

      try {
        await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
      } catch (e) {
        debugPrint('FlutterDownloader initialization error: $e');
      }
    }

    // Initialize Storage Service
    await Get.putAsync(() => StorageService().init());

    runApp(const MyApp());
  }, (error, stack) {
    FlutterError.dumpErrorToConsole(
      FlutterErrorDetails(exception: error, stack: stack),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EduAiTutors',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Initial Binding
      initialBinding: InitialBinding(),

      // Routes
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // Default Transitions
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
