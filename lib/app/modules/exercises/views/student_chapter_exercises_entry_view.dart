import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentChapterExercisesEntryView extends StatefulWidget {
  const StudentChapterExercisesEntryView({super.key});

  @override
  State<StudentChapterExercisesEntryView> createState() =>
      _StudentChapterExercisesEntryViewState();
}

class _StudentChapterExercisesEntryViewState
    extends State<StudentChapterExercisesEntryView> {
  final DataService _data = DataService();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _go());
  }

  Future<void> _go() async {
    final chapterId = (Get.parameters['chapterId'] ?? '').toString().trim();
    if (chapterId.isEmpty) {
      setState(() => _error = 'Missing chapterId');
      return;
    }

    String chapterName = 'Chapter';
    try {
      final subs = await _data.fetchUserSubscriptions();
      for (final s in subs) {
        for (final ch in s.chapters) {
          if (ch.id == chapterId) {
            chapterName = ch.name.isEmpty ? chapterName : ch.name;
            break;
          }
        }
      }
    } catch (_) {
      // Best-effort only.
    }

    Get.offNamed(
      Routes.CHAPTER_EXERCISES,
      arguments: {'chapterId': chapterId, 'chapterName': chapterName},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!, textAlign: TextAlign.center)),
      );
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

