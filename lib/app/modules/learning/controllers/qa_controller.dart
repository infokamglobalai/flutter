import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class QAController extends GetxController {
  final TextEditingController questionController = TextEditingController();

  // Chat messages
  final messages = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingExternal = false.obs;
  final isListening = false.obs;
  final isSpeaking = false.obs;

  // Search mode
  final searchMode = 'internal'.obs; // 'internal' or 'external'

  // Filter options
  final selectedGrade = Rxn<String>();
  final selectedSubject = Rxn<String>();
  final availableGrades = <String>[].obs;
  final availableSubjects = <String>[].obs;

  // Speech recognition and TTS
  late stt.SpeechToText speech;
  late FlutterTts flutterTts;
  final spokenText = ''.obs;

  // Scroll controller for chat
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    initializeSpeech();
    initializeTts();
    loadAvailableFilters();

    // Add welcome message
    messages.add({
      'type': 'bot',
      'message':
          'Hi! I\'m your AI learning assistant. Ask me anything about your subjects, and I\'ll help you find answers from our video library and documents. 📚',
      'timestamp': DateTime.now(),
    });
  }

  @override
  void onClose() {
    questionController.dispose();
    scrollController.dispose();
    flutterTts.stop();
    super.onClose();
  }

  void initializeSpeech() async {
    speech = stt.SpeechToText();
    await speech.initialize(
      onError: (error) {
        debugPrint('Speech recognition error: $error');
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
      },
    );
  }

  void initializeTts() async {
    flutterTts = FlutterTts();
    await flutterTts!.setLanguage('en-US');
    await flutterTts!.setSpeechRate(0.5);
    await flutterTts!.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
  }

  Future<void> loadAvailableFilters() async {
    // Mock data - Replace with actual API
    availableGrades.value = [
      'Grade 8',
      'Grade 9',
      'Grade 10',
      'Grade 11',
      'Grade 12',
    ];

    availableSubjects.value = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English',
      'Computer Science',
      'History',
      'Geography',
    ];
  }

  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty) return;

    // Add user message
    messages.add({
      'type': 'user',
      'message': question,
      'timestamp': DateTime.now(),
    });

    questionController.clear();
    scrollToBottom();

    if (searchMode.value == 'internal') {
      await searchInternalResources(question);
    } else {
      await searchExternalResources(question);
    }
  }

  Future<void> searchInternalResources(String question) async {
    try {
      isLoading.value = true;

      // Simulate AI processing - Replace with actual API
      await Future.delayed(const Duration(seconds: 2));

      // Mock response with video/document references
      final response = _generateInternalResponse(question);

      messages.add({
        'type': 'bot',
        'message': response['answer'],
        'sources': response['sources'],
        'timestamp': DateTime.now(),
      });

      scrollToBottom();
    } catch (e) {
      messages.add({
        'type': 'bot',
        'message':
            'Sorry, I encountered an error while searching. Please try again.',
        'timestamp': DateTime.now(),
        'isError': true,
      });
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _generateInternalResponse(String question) {
    // Mock AI response based on question keywords
    // In production, this would call your AI backend with vector search

    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('quadratic') ||
        lowerQuestion.contains('equation')) {
      return {
        'answer':
            'Based on your question about quadratic equations, I found relevant content in our library:\n\n'
            'Quadratic equations are polynomial equations of degree 2, typically in the form ax² + bx + c = 0. '
            'They can be solved using factoring, completing the square, or the quadratic formula.\n\n'
            'I found 3 videos and 2 documents that cover this topic in detail.',
        'sources': [
          {
            'type': 'video',
            'title': 'Introduction to Quadratic Equations',
            'chapter': 'Chapter 4: Quadratic Equations',
            'subject': 'Mathematics',
            'grade': selectedGrade.value ?? 'Grade 10',
            'duration': '30:45',
            'thumbnail': 'https://via.placeholder.com/150x100',
          },
          {
            'type': 'video',
            'title': 'Solving Quadratic Equations by Factoring',
            'chapter': 'Chapter 4: Quadratic Equations',
            'subject': 'Mathematics',
            'grade': selectedGrade.value ?? 'Grade 10',
            'duration': '25:30',
            'thumbnail': 'https://via.placeholder.com/150x100',
          },
          {
            'type': 'document',
            'title': 'Quadratic Equations Practice Problems',
            'chapter': 'Chapter 4: Quadratic Equations',
            'subject': 'Mathematics',
            'grade': selectedGrade.value ?? 'Grade 10',
            'pages': 15,
          },
        ],
      };
    } else if (lowerQuestion.contains('photosynthesis') ||
        lowerQuestion.contains('plant')) {
      return {
        'answer':
            'Here\'s what I found about photosynthesis:\n\n'
            'Photosynthesis is the process by which plants convert light energy into chemical energy. '
            'It occurs in chloroplasts and involves two main stages: light-dependent reactions and the Calvin cycle.\n\n'
            'Check out these resources for more details:',
        'sources': [
          {
            'type': 'video',
            'title': 'Photosynthesis - Complete Process',
            'chapter': 'Chapter 6: Life Processes',
            'subject': 'Biology',
            'grade': selectedGrade.value ?? 'Grade 10',
            'duration': '28:15',
            'thumbnail': 'https://via.placeholder.com/150x100',
          },
          {
            'type': 'document',
            'title': 'Photosynthesis Study Notes',
            'chapter': 'Chapter 6: Life Processes',
            'subject': 'Biology',
            'grade': selectedGrade.value ?? 'Grade 10',
            'pages': 10,
          },
        ],
      };
    } else {
      return {
        'answer':
            'I found some general resources that might help with your question:\n\n'
            'Based on the selected filters (${selectedGrade.value ?? "All Grades"}, ${selectedSubject.value ?? "All Subjects"}), '
            'here are relevant materials from our library.',
        'sources': [
          {
            'type': 'video',
            'title': 'General Concept Overview',
            'chapter': 'Multiple Chapters',
            'subject': selectedSubject.value ?? 'General',
            'grade': selectedGrade.value ?? 'Grade 10',
            'duration': '20:00',
            'thumbnail': 'https://via.placeholder.com/150x100',
          },
        ],
      };
    }
  }

  Future<void> searchExternalResources(String question) async {
    try {
      isLoadingExternal.value = true;

      // Simulate external AI API call (Gemini, ChatGPT, etc.)
      await Future.delayed(const Duration(seconds: 2));

      // Mock external AI response
      final response = _generateExternalResponse(question);

      messages.add({
        'type': 'bot',
        'message': response['answer'],
        'isExternal': true,
        'externalSources': response['externalSources'],
        'timestamp': DateTime.now(),
      });

      scrollToBottom();
    } catch (e) {
      messages.add({
        'type': 'bot',
        'message':
            'Sorry, I encountered an error while searching external resources. Please try again.',
        'timestamp': DateTime.now(),
        'isError': true,
      });
    } finally {
      isLoadingExternal.value = false;
    }
  }

  Map<String, dynamic> _generateExternalResponse(String question) {
    // Mock external AI response
    // In production, integrate with Gemini API or other AI services

    return {
      'answer':
          'Based on external knowledge sources:\n\n'
          'I\'ve searched across multiple educational platforms and found comprehensive information. '
          'Here are additional resources that complement our internal library:\n\n'
          '• Online tutorials and explanations\n'
          '• Interactive simulations\n'
          '• Practice exercises\n'
          '• Related YouTube videos\n\n'
          'Would you like me to provide more specific details?',
      'externalSources': [
        {
          'type': 'article',
          'title': 'Khan Academy - ${question}',
          'url': 'https://www.khanacademy.org',
          'source': 'Khan Academy',
        },
        {
          'type': 'video',
          'title': 'YouTube Educational Video',
          'url': 'https://www.youtube.com',
          'source': 'YouTube',
        },
        {
          'type': 'article',
          'title': 'Wikipedia Reference',
          'url': 'https://www.wikipedia.org',
          'source': 'Wikipedia',
        },
      ],
    };
  }

  Future<void> startListening() async {
    if (!speech.isAvailable) {
      Get.snackbar(
        'Error',
        'Speech recognition is not available on this device',
        backgroundColor: Colors.red[100],
      );
      return;
    }

    isListening.value = true;
    spokenText.value = '';

    await speech.listen(
      onResult: (result) {
        spokenText.value = result.recognizedWords;
        questionController.text = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
    isListening.value = false;

    // Automatically ask the question after stopping
    if (spokenText.value.isNotEmpty) {
      await askQuestion(spokenText.value);
    }
  }

  Future<void> speakAnswer(String text) async {
    if (isSpeaking.value) {
      await flutterTts.stop();
      isSpeaking.value = false;
      return;
    }

    isSpeaking.value = true;
    await flutterTts.speak(text);
  }

  void setSearchMode(String mode) {
    searchMode.value = mode;

    Get.snackbar(
      'Search Mode Changed',
      mode == 'internal'
          ? 'Searching within LMS resources'
          : 'Searching external resources via AI',
      backgroundColor: Colors.blue[100],
      duration: const Duration(seconds: 2),
    );
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    messages.clear();
    messages.add({
      'type': 'bot',
      'message': 'Chat cleared! How can I help you today?',
      'timestamp': DateTime.now(),
    });
  }

  void openResource(Map<String, dynamic> source) {
    // Navigate to video or document viewer
    Get.snackbar(
      'Opening Resource',
      'Opening: ${source['title']}',
      backgroundColor: Colors.green[100],
    );

    // TODO: Implement actual navigation
    // if (source['type'] == 'video') {
    //   Get.toNamed(Routes.VIDEO_PLAYER, arguments: source);
    // } else if (source['type'] == 'document') {
    //   Get.toNamed(Routes.DOCUMENT_VIEWER, arguments: source);
    // }
  }
}
