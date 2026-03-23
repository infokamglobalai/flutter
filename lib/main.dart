import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:najahapp/app/core/bindings/initial_binding.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Storage Service
  await Get.putAsync(() => StorageService().init());

  runApp(const MyApp());
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
      themeMode: ThemeMode.light,

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
