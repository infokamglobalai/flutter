import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiCounsellorController extends GetxController {
  final DataService _data = Get.find<DataService>();

  final isLoading = false.obs;
  final isTyping = false.obs;
  final messages = <Map<String, dynamic>>[].obs;
  final inputController = TextEditingController();

  // Pages: home, overview, analytics, career, wellness, study-planner, voice
  final page = 'chat'.obs;

  // Profile + reports/analytics (mirrors web tabs, simplified UI)
  final studentName = 'Student'.obs;
  final studentExam = ''.obs;
  final analytics = <String, dynamic>{}.obs;
  final subjectPerformance = <Map<String, dynamic>>[].obs;
  final reports = <String, dynamic>{}.obs; // { career, wellness, planner }
  final insights = <Map<String, dynamic>>[].obs;

  final isListening = false.obs;
  final lastVoiceTranscript = ''.obs;
  late final stt.SpeechToText _speechToText;
  bool _speechReady = false;

  final isSpeaking = false.obs;
  final voiceOutputEnabled = true.obs;
  late final FlutterTts _tts;
  bool _ttsReady = false;

  String _systemPrompt = '';

  @override
  void onInit() {
    super.onInit();
    _speechToText = stt.SpeechToText();
    _tts = FlutterTts();
    _bootstrap();
  }

  @override
  void onClose() {
    if (isListening.value) {
      // Best-effort: stop any active session to avoid leaks.
      _speechToText.stop();
    }
    _tts.stop();
    inputController.dispose();
    super.onClose();
  }

  Future<void> _initTtsIfNeeded() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        isSpeaking.value = false;
      });
      _tts.setErrorHandler((_) {
        isSpeaking.value = false;
      });
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
  }

  Future<void> speakIfEnabled(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    if (!voiceOutputEnabled.value) return;
    await _initTtsIfNeeded();
    if (!_ttsReady) return;
    isSpeaking.value = true;
    await _tts.stop();
    await _tts.speak(t);
  }

  Future<void> stopSpeaking() async {
    isSpeaking.value = false;
    await _tts.stop();
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;
    try {
      final ok = await _speechToText.initialize(
        onStatus: (status) {
          // Some platforms emit "done"/"notListening"
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (_) {
          isListening.value = false;
        },
      );
      _speechReady = ok;
      return ok;
    } catch (_) {
      _speechReady = false;
      return false;
    }
  }

  Future<void> toggleVoiceInput() async {
    if (isTyping.value) return;

    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission required',
        'Microphone permission is required for voice input',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final ready = await _ensureSpeechReady();
    if (!ready) {
      Get.snackbar(
        'Voice unavailable',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    lastVoiceTranscript.value = '';
    isListening.value = true;
    await _speechToText.listen(
      listenMode: stt.ListenMode.confirmation,
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (words.isEmpty) return;
        lastVoiceTranscript.value = words;
        inputController.value = inputController.value.copyWith(
          text: words,
          selection: TextSelection.collapsed(offset: words.length),
          composing: TextRange.empty,
        );
      },
    );
  }

  Future<void> toggleVoiceSession() async {
    // Voice session: listen -> auto-send when final result arrives.
    if (isTyping.value) return;

    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission required',
        'Microphone permission is required for voice input',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final ready = await _ensureSpeechReady();
    if (!ready) {
      Get.snackbar(
        'Voice unavailable',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    lastVoiceTranscript.value = '';
    isListening.value = true;
    await _speechToText.listen(
      listenMode: stt.ListenMode.confirmation,
      onResult: (result) async {
        final words = result.recognizedWords.trim();
        if (words.isEmpty) return;
        lastVoiceTranscript.value = words;
        if (result.finalResult) {
          inputController.text = words;
          await _speechToText.stop();
          isListening.value = false;
          await send();
        }
      },
    );
  }

  Future<void> _bootstrap() async {
    isLoading.value = true;
    try {
      // Load counsellor chat history first
      final history = await _data.fetchAiChatHistory(context: 'counsellor');
      if (history.isNotEmpty) {
        messages.assignAll(history);
      }

      // Load counsellor data (analytics + system prompt)
      final res = await _data.fetchAiCounsellorData();
      if (res['success'] == true && res['data'] is Map) {
        final data = Map<String, dynamic>.from(res['data'] as Map);
        _systemPrompt = (data['systemPrompt'] ?? '').toString();

        final student = (data['student'] is Map)
            ? Map<String, dynamic>.from(data['student'] as Map)
            : <String, dynamic>{};
        studentName.value = (student['name'] ?? 'Student').toString();
        studentExam.value = (student['exam'] ?? '').toString();

        final a = (data['analytics'] is Map)
            ? Map<String, dynamic>.from(data['analytics'] as Map)
            : <String, dynamic>{};
        analytics.assignAll(a);

        final subjects = (data['subjects'] is List)
            ? (data['subjects'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];
        subjectPerformance.assignAll(subjects);

        // Simple insight: highlight weakest subject if any
        if (subjects.isNotEmpty) {
          subjects.sort((x, y) {
            final xs = double.tryParse((x['score'] ?? 0).toString()) ?? 0;
            final ys = double.tryParse((y['score'] ?? 0).toString()) ?? 0;
            return xs.compareTo(ys);
          });
          final worst = subjects.first;
          final worstScore =
              double.tryParse((worst['score'] ?? 0).toString()) ?? 0;
          if (worstScore < 60) {
            insights.assignAll([
              {
                'type': 'warning',
                'title': '${(worst['subject'] ?? 'Subject').toString()} needs focus',
                'description':
                    'Your score is ${worstScore.toStringAsFixed(0)}%. Consider revising recent chapters.',
              },
            ]);
          }
        }
      }

      final rep = await _data.fetchAiCounsellorReports();
      if (rep['success'] == true && rep['data'] is Map) {
        reports.assignAll(Map<String, dynamic>.from(rep['data'] as Map));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> send() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;
    if (isTyping.value) return;
    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
    }

    inputController.clear();

    final userMsg = <String, dynamic>{
      'role': 'user',
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
    };
    messages.add(userMsg);

    // Persist user message (best-effort)
    _data.saveAiChatMessage(
      context: 'counsellor',
      role: 'user',
      content: text,
    );

    isTyping.value = true;
    try {
      final historyForApi = messages
          .where((m) => m['role'] != null && m['content'] != null)
          .map((m) => {
                'role': (m['role'] == 'user') ? 'user' : 'assistant',
                'content': (m['content'] ?? '').toString(),
              })
          .toList()
          .cast<Map<String, String>>();

      // Remove current question from historyForApi (backend expects previous history)
      final convo = historyForApi.length > 1
          ? historyForApi.take(historyForApi.length - 1).toList()
          : <Map<String, String>>[];

      final res = await _data.chatWithAiCounsellor(
        question: text,
        conversationHistory: convo,
        systemPrompt: _systemPrompt,
      );

      if (res['success'] == true) {
        final data = res['data'];
        final answer = (data is Map ? data['answer'] : null)?.toString() ?? '';
        if (answer.isEmpty) {
          throw Exception('Empty AI response');
        }

        final aiMsg = <String, dynamic>{
          'role': 'counsellor',
          'content': answer,
          'timestamp': DateTime.now().toIso8601String(),
        };
        messages.add(aiMsg);

        _data.saveAiChatMessage(
          context: 'counsellor',
          role: 'counsellor',
          content: answer,
        );

        // Voice output (used by "Voice Session" + optional accessibility)
        await speakIfEnabled(answer);
      } else {
        throw Exception(res['message'] ?? 'Failed to get AI response');
      }
    } catch (e) {
      // Remove last user message on failure to keep thread clean
      if (messages.isNotEmpty && messages.last['role'] == 'user') {
        messages.removeLast();
      }
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isTyping.value = false;
    }
  }
}

