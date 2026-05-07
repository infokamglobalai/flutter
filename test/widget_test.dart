// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'dart:ui' show Size;

import 'package:najahapp/main.dart';

void main() {
  testWidgets('App builds without DI crash', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    await Get.putAsync(() => StorageService().init());

    // Make the test viewport large enough to avoid layout overflows.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // App has a splash timer; let timers complete so the test doesn't fail
    // with "A Timer is still pending".
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // If the app fails to build, the test will throw before reaching here.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
