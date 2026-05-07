import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/data/models/chapter_content_model.dart';
import 'package:najahapp/app/data/models/chapter_resource_model.dart';
import 'package:najahapp/app/data/models/exercise_model.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/routes/app_pages.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:device_info_plus/device_info_plus.dart';

class VideoPlayerController extends GetxController {
  // Use the app-wide singleton so the Dio connection pool is shared
  final DataService _dataService = Get.find<DataService>();
  final ApiService _apiService = Get.find<ApiService>();
  StorageService? _storage;

  // ── Live Premiere + Polls (web ContentTestPage parity) ─────────────────────
  static const Duration _livePremiereWindow = Duration(hours: 3);
  final isLockedBySchedule = false.obs;
  final timeRemainingUntilLiveSeconds = RxnInt();
  final isPremiere = false.obs;
  final premiereMuted = true.obs;

  final activePoll = Rxn<Map<String, dynamic>>();
  final pollResult = Rxn<Map<String, dynamic>>(); // { selectedIndex, isCorrect }
  final pollAnswers = <String, Map<String, dynamic>>{}.obs;
  final shownPollKeys = <String>{}.obs;

  Timer? _scheduleTicker;
  Timer? _premiereSyncTicker;
  Timer? _pollTicker;
  Timer? _pollDismissTimer;

  // AI voice playback
  final AudioPlayer _aiAudioPlayer = AudioPlayer();
  final isAiSpeaking = false.obs;

  // Gemini-style Voice Assistant (voice -> AI -> voice)
  final isVoiceAssistantProcessing = false.obs;
  final lastVoiceTranscript = ''.obs;

  // Chapter and package data
  final chapterData = Rx<Map<String, dynamic>>({});
  final chapterId = ''.obs;
  final subscriptionId = ''.obs; // For marking video as complete
  final subjectName = ''.obs;
  final packageName = ''.obs;
  final grade = ''.obs;
  final board = ''.obs;

  // Content and Resources
  final chapterContents = <ChapterContentModel>[].obs;
  final chapterResources = <ChapterResourceModel>[].obs;
  final currentContent = Rx<ChapterContentModel?>(null);
  final isLoadingContent = false.obs;
  final isLoadingResources = false.obs;

  // Video player
  vp.VideoPlayerController? videoController;
  ChewieController? chewieController;
  YoutubePlayerController? youtubeController;
  final isYoutubeVideo = false.obs;
  final isVideoInitialized = false.obs;
  final isVideoLoading = true.obs; // starts true → spinner shows immediately
  final videoErrorMessage = ''.obs;
  final isPlaying = false.obs;
  final currentPosition = Duration.zero.obs;
  final totalDuration = Duration.zero.obs;
  final isLoading = false.obs;
  final isFullScreen = false.obs;
  final isEmulator = false.obs;

  // Document viewer
  final selectedDocument = Rx<Map<String, dynamic>?>(null);
  final currentPage = 1.obs;
  final totalPages = 0.obs;
  final isDocumentSyncEnabled = true.obs;
  final documents = <Map<String, dynamic>>[].obs;

  // Exercise
  final exercises = <ExerciseModel>[].obs;
  final currentExercise = Rx<ExerciseModel?>(null);
  final exerciseData = Rx<Map<String, dynamic>?>(null);
  final isExerciseAvailable = false.obs;
  final isLoadingExercises = false.obs;
  final exerciseAnswer = ''.obs;
  final isSubmittingExercise = false.obs;
  final exerciseSubmitted = false.obs;
  final submittedAt = Rx<DateTime?>(null);
  final viewMode = 'documents'.obs; // 'documents' or 'exercise'
  final exerciseScore = 0.obs;
  final totalExerciseQuestions = 0.obs;

  // Assessment
  final assessmentData = Rx<Map<String, dynamic>?>(null);
  final isAssessmentAvailable = false.obs;
  /// True only after the student has essentially finished the video
  /// (we mark completion at 95% watch progress).
  final isVideoCompleted = false.obs;
  final showAssessmentDialog = false.obs;
  final currentQuestionIndex = 0.obs;
  final assessmentAnswers =
      <int, int>{}.obs; // question index -> selected option
  final isSubmittingAssessment = false.obs;
  final hasStartedAssessment = false.obs; // Track if user clicked start

  // Downloads
  final isDownloadingVideo = false.obs;
  final isDownloadingDocument = false.obs;
  final videoDownloadProgress = 0.0.obs;
  final documentDownloadProgress = 0.0.obs;
  final downloadingResourceIds = <String>{}.obs;
  final resourceDownloadProgress = <String, double>{}.obs;

  // AI Chat Assistant
  final chatMessages = <Map<String, dynamic>>[].obs;
  final isSendingMessage = false.obs;
  final chatInputController = TextEditingController();
  final chatScrollController = ScrollController();
  final isLoadingChatHistory = false.obs;

  // Voice Input
  late stt.SpeechToText speechToText;
  final isListening = false.obs;
  final speechEnabled = false.obs;

  // ── Rating / Feedback ──────────────────────────────────────────────────────
  /// Star rating the student is hovering / selected (1-5)
  final selectedRating = 0.obs;

  /// Whether the student has already submitted a rating for this content
  final hasRated = false.obs;

  /// Previously submitted rating value (0 = no rating yet)
  final existingRating = 0.obs;
  final isSubmittingRating = false.obs;
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _detectEmulator();
    // StorageService may not be registered in some deep-link / test contexts.
    if (Get.isRegistered<StorageService>()) {
      _storage = Get.find<StorageService>();
    }
    _loadArguments();
    _initializeVideo();
    _loadDocuments();
    _loadAssessment(); // reads from chapterData synchronously
    // Defer speech init so it never blocks the page load or platform channel.
    // Speech recognition is only needed when the user taps the mic button.
    Future.delayed(const Duration(seconds: 3), _initializeSpeech);
  }

  Future<void> _detectEmulator() async {
    try {
      if (!Platform.isAndroid) {
        isEmulator.value = false;
        return;
      }
      final info = await DeviceInfoPlugin().androidInfo;
      isEmulator.value = !(info.isPhysicalDevice ?? true);
    } catch (_) {
      // Default to "not emulator" so real devices keep working.
      isEmulator.value = false;
    }
  }

  void _loadArguments() {
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      chapterData.value = args['chapter'] ?? {};
      chapterId.value =
          chapterData.value['_id'] ?? chapterData.value['chapterId'] ?? '';
      subscriptionId.value = args['subscriptionId'] ?? '';
      subjectName.value = args['subject'] ?? '';
      packageName.value = args['packageName'] ?? '';
      grade.value = args['grade'] ?? '';
      board.value = args['board'] ?? '';

      // Load content and resources from API
      if (chapterId.value.isNotEmpty) {
        // Persist last chapter for AI chat history screens.
        _storage?.saveString('lastChapterId', chapterId.value);
        _loadChapterContents();
        _loadChapterResources();
      }
    }
  }

  Future<void> _loadChapterContents() async {
    try {
      isLoadingContent.value = true;
      chapterContents.value = await _dataService.fetchChapterContents(
        chapterId.value,
      );

      print('📚 Loaded ${chapterContents.length} chapter contents');

      if (chapterContents.isNotEmpty) {
        currentContent.value = chapterContents.first;
        print('📖 Current content: ${currentContent.value!.title}');
        print('🔍 Assessment in content: ${currentContent.value!.assessment}');

        // Load persisted AI chat history for this chapter (best-effort).
        _loadAiChatHistoryForCurrentContent();

        // Release the loading gate immediately so the page renders,
        // then kick off video init in the background.
        isLoadingContent.value = false;

        // Live scheduling / premiere / polls (web parity)
        _setupSchedulePremiereAndPolls(currentContent.value!);

        // Initialize video with first content (non-blocking)
        if (!isLockedBySchedule.value) {
          _initializeVideoFromContent(currentContent.value!);
        }
        // Load assessment for this content
        _loadAssessmentFromContent();
        // Load exercises
        _loadExercise();
        // Load existing rating if available
        _loadMyRating();
      }
    } catch (e) {
      print('Error loading chapter contents: $e');
      Get.snackbar(
        'Error',
        'Failed to load chapter content',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingContent.value = false;
    }
  }

  void _setupSchedulePremiereAndPolls(ChapterContentModel content) {
    _scheduleTicker?.cancel();
    _premiereSyncTicker?.cancel();
    _pollTicker?.cancel();
    _pollDismissTimer?.cancel();
    activePoll.value = null;
    pollResult.value = null;

    // restore persisted poll answers
    try {
      final raw = _storage?.getString('pollAnswers') ?? '';
      if (raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          pollAnswers
            ..clear()
            ..addAll(
              decoded.map(
                (k, v) => MapEntry(
                  k.toString(),
                  (v is Map) ? Map<String, dynamic>.from(v) : <String, dynamic>{},
                ),
              ),
            );
        }
      }
    } catch (_) {
      // ignore persistence errors
    }

    void checkSchedule() {
      final scheduledAt = content.scheduledAt;
      if (scheduledAt == null) {
        isLockedBySchedule.value = false;
        timeRemainingUntilLiveSeconds.value = null;
        isPremiere.value = false;
        return;
      }

      final now = DateTime.now();
      if (now.isBefore(scheduledAt)) {
        isLockedBySchedule.value = true;
        timeRemainingUntilLiveSeconds.value =
            scheduledAt.difference(now).inSeconds;
        isPremiere.value = false;
        return;
      }

      isLockedBySchedule.value = false;
      timeRemainingUntilLiveSeconds.value = null;

      final completedKey =
          'chapter_video_completed_${subscriptionId.value}_${chapterId.value}';
      final isFirstWatch = _storage?.getBool(completedKey) != true;

      final elapsed = now.difference(scheduledAt);
      final withinWindow =
          elapsed >= Duration.zero && elapsed <= _livePremiereWindow;
      isPremiere.value = isFirstWatch && withinWindow;
      premiereMuted.value = isPremiere.value;
    }

    checkSchedule();
    _scheduleTicker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final wasLocked = isLockedBySchedule.value;
      checkSchedule();
      if (wasLocked && !isLockedBySchedule.value) {
        await _initializeVideoFromContent(content);
      }
    });

    // Sync + polls while in premiere.
    _premiereSyncTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPremiere.value) return;
      _syncToLiveWallClock(content);
      _clampSeekingAhead(content);
    });

    _pollTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPremiere.value) return;
      _checkForLivePolls(content);
    });
  }

  int _liveOffsetSeconds(DateTime scheduledAt) {
    final diff = DateTime.now().difference(scheduledAt).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  void _syncToLiveWallClock(ChapterContentModel content) {
    final scheduledAt = content.scheduledAt;
    if (scheduledAt == null) return;
    final dur = totalDuration.value.inSeconds;
    if (dur <= 0) return;
    final live = _liveOffsetSeconds(scheduledAt).clamp(0, dur);
    final target = Duration(
      milliseconds: (1000 * (live - 0.25)).toInt().clamp(0, 1 << 31),
    );

    if (isYoutubeVideo.value && youtubeController != null) {
      final pos = youtubeController!.value.position;
      if ((pos - target).inSeconds.abs() > 2) {
        youtubeController!.seekTo(target);
      }
      if (premiereMuted.value) youtubeController!.mute();
    } else if (videoController != null && videoController!.value.isInitialized) {
      final pos = videoController!.value.position;
      if ((pos - target).inSeconds.abs() > 2) {
        videoController!.seekTo(target);
      }
      if (premiereMuted.value) {
        try {
          videoController!.setVolume(0);
        } catch (_) {}
      }
    }
  }

  String? _currentStudentId() {
    final u = _storage?.getUserData();
    final id = u?['_id']?.toString().trim();
    return (id == null || id.isEmpty) ? null : id;
  }

  String _aiChatContextForContent() => 'content_test';

  Future<void> _loadAiChatHistoryForCurrentContent() async {
    if (currentContent.value == null) return;
    if (!_apiService.hasToken) return;

    // Backend groups content chats by Chapter (targetId).
    final targetId = currentContent.value?.chapter.id;
    isLoadingChatHistory.value = true;
    try {
      final items = await _dataService.fetchAiChatHistory(
        context: _aiChatContextForContent(),
        targetId: (targetId != null && targetId.isNotEmpty) ? targetId : null,
      );

      final normalized = items.map((m) {
        final role = (m['role'] ?? '').toString();
        final content = (m['content'] ?? '').toString();
        final ts = m['timestamp']?.toString();
        final metadata =
            (m['metadata'] is Map) ? Map<String, dynamic>.from(m['metadata']) : null;
        return <String, dynamic>{
          'role': role,
          'content': content,
          if (ts != null && ts.isNotEmpty) 'timestamp': ts,
          if (metadata != null) 'metadata': metadata,
        };
      }).toList();

      if (normalized.isNotEmpty) {
        chatMessages.assignAll(normalized);
        _scrollToBottom();
      }
    } finally {
      isLoadingChatHistory.value = false;
    }
  }

  void _clampSeekingAhead(ChapterContentModel content) {
    final scheduledAt = content.scheduledAt;
    if (scheduledAt == null) return;
    final dur = totalDuration.value.inSeconds;
    if (dur <= 0) return;
    final live = _liveOffsetSeconds(scheduledAt).clamp(0, dur);
    final maxAllowed = Duration(
      milliseconds: (1000 * (live - 0.25)).toInt().clamp(0, 1 << 31),
    );

    if (isYoutubeVideo.value && youtubeController != null) {
      final pos = youtubeController!.value.position;
      if (pos > maxAllowed + const Duration(milliseconds: 200)) {
        youtubeController!.seekTo(maxAllowed);
      }
    } else if (videoController != null && videoController!.value.isInitialized) {
      final pos = videoController!.value.position;
      if (pos > maxAllowed + const Duration(milliseconds: 200)) {
        videoController!.seekTo(maxAllowed);
      }
    }
  }

  void _checkForLivePolls(ChapterContentModel content) {
    if (activePoll.value != null) return;
    final list = content.polls;
    if (list.isEmpty) return;

    final now = DateTime.now();
    for (final p in list) {
      final pKey = (p['_id'] ?? p['id'] ?? 't_${p['time']}').toString();
      if (shownPollKeys.contains(pKey)) continue;
      if (pollAnswers.containsKey(pKey)) continue;

      final timeRaw = p['time'];
      final start = (timeRaw is String) ? DateTime.tryParse(timeRaw) : null;
      if (start == null) continue;
      final durationSec = (p['duration'] as num?)?.toInt() ?? 15;
      final end = start.add(Duration(seconds: durationSec));

      if (now.isAfter(start) && now.isBefore(end)) {
        shownPollKeys.add(pKey);
        activePoll.value = Map<String, dynamic>.from(p);
        pollResult.value = null;

        final remainingMs =
            end.difference(now).inMilliseconds.clamp(500, 600000);
        _pollDismissTimer?.cancel();
        _pollDismissTimer = Timer(Duration(milliseconds: remainingMs), () {
          activePoll.value = null;
          pollResult.value = null;
        });
        return;
      }
    }
  }

  void answerActivePoll(int optIndex) {
    final poll = activePoll.value;
    if (poll == null) return;
    if (pollResult.value != null) return;

    final correct = (poll['correctAnswer'] as num?)?.toInt();
    final isCorrect = correct != null && optIndex == correct;
    pollResult.value = {'selectedIndex': optIndex, 'isCorrect': isCorrect};

    final pKey = (poll['_id'] ?? poll['id'] ?? 't_${poll['time']}').toString();
    pollAnswers[pKey] = {'selectedIndex': optIndex, 'isCorrect': isCorrect};
    pollAnswers.refresh();
    try {
      _storage?.saveString('pollAnswers', jsonEncode(pollAnswers));
    } catch (_) {}
  }

  Future<void> _loadChapterResources() async {
    try {
      isLoadingResources.value = true;
      chapterResources.value = await _dataService.fetchChapterResources(
        chapterId.value,
      );

      // Convert to documents format for existing UI
      documents.value = chapterResources
          .map(
            (resource) => {
              // Normalize IDs so older UI comparisons work consistently.
              'id': resource.id,
              '_id': resource.id,
              'title': resource.title,
              'description': resource.description,
              'fileName': resource.fileName,
              'filePath': resource.filePath,
              'fileUrl': resource.fileUrl,
              'fileSize': resource.formattedFileSize,
              'mimeType': resource.mimeType,
              'icon': _getIconType(resource.mimeType),
              'pages': 1, // Add default pages
            },
          )
          .toList();

      if (documents.isNotEmpty) {
        selectDocument(documents.first);
      }
    } catch (e) {
      print('Error loading chapter resources: $e');
      // Don't show error snackbar for resources as it's not critical
    } finally {
      isLoadingResources.value = false;
    }
  }

  String _getIconType(String mimeType) {
    if (mimeType.contains('pdf')) return 'notes';
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return 'presentation';
    }
    if (mimeType.contains('document') || mimeType.contains('word')) {
      return 'book';
    }
    if (mimeType.contains('worksheet')) return 'worksheet';
    return 'notes';
  }

  Future<void> _initializeVideoFromContent(ChapterContentModel content) async {
    // Don't set isLoading here – the page is already visible at this point.
    // isVideoInitialized drives the loading indicator inside the video widget.
    isVideoLoading.value = true;
    videoErrorMessage.value = '';

    try {
      print('Content videoType: ${content.videoType}');
      print('Content videoUrl: ${content.videoUrl}');
      print('Content uploadedVideoPath: ${content.uploadedVideoPath}');

      // Check if it's a YouTube video
      if (content.videoType.toLowerCase() == 'youtube' &&
          content.videoUrl.isNotEmpty) {
        await _initializeYoutubeVideo(content.videoUrl);
      } else if (content.uploadedVideoPath.isNotEmpty) {
        await _initializeUploadedVideo(content.uploadedVideoPath);
      } else {
        throw Exception('No video URL available');
      }

    } on PlatformException catch (e) {
      isVideoInitialized.value = false;
      videoErrorMessage.value = e.message ?? 'Platform error';
      print('Platform Exception: ${e.code} - ${e.message}');
      print('Platform Exception Details: $e');
      Get.snackbar(
        'Video Error',
        'Platform error: ${e.message ?? "Unable to load video"}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
    } on TimeoutException catch (e) {
      isVideoInitialized.value = false;
      videoErrorMessage.value = 'Connection timeout';
      print('Timeout Exception: $e');
      Get.snackbar(
        'Connection Timeout',
        'Video took too long to load. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      isVideoInitialized.value = false;
      videoErrorMessage.value = e.toString();
      print('Error initializing video: $e');
      Get.snackbar(
        'Error',
        'Failed to load video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isVideoLoading.value = false;
    }

    // Listen to video position for document sync
    _startPositionListener();
  }

  Future<void> _initializeYoutubeVideo(String youtubeUrl) async {
    try {
      print('Initializing YouTube video: $youtubeUrl');
      videoErrorMessage.value = '';

      // Extract video ID from URL
      final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL: $youtubeUrl');
      }

      print('YouTube video ID: $videoId');

      // Use the embedded YouTube player directly – it is faster than going
      // through youtube_explode_dart (which requires an extra round-trip to
      // YouTube's API before we can even start buffering).
      // Initialize YouTube embedded controller
      youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: isPremiere.value,
          enableCaption: true,
          loop: false,
          forceHD: false,
          hideControls: isPremiere.value,
          controlsVisibleAtStart: !isPremiere.value,
        ),
      );

      // Add listener
      youtubeController!.addListener(() {
        if (youtubeController!.value.isReady) {
          isPlaying.value = youtubeController!.value.isPlaying;
          currentPosition.value = youtubeController!.value.position;
          totalDuration.value = youtubeController!.value.metaData.duration;
          _checkVideoCompletion();
        }
      });

      isYoutubeVideo.value = true;
      isVideoInitialized.value = true;
      print('YouTube video initialized successfully');
    } catch (e) {
      print('Error initializing YouTube video: $e');
      videoErrorMessage.value = e.toString();
      rethrow;
    }
  }

  Future<void> _initializeDirectStreamVideo(String streamUrl) async {
    try {
      print('Initializing direct stream video: $streamUrl');

      final uri = Uri.parse(streamUrl);

      videoController = vp.VideoPlayerController.networkUrl(uri);

      // Initialize Chewie controller with autoInitialize
      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        allowFullScreen: !isPremiere.value,
        allowMuting: true,
        showControls: !isPremiere.value,
        materialProgressColors: ChewieProgressColors(
          playedColor: Get.theme.primaryColor,
          handleColor: Get.theme.primaryColor,
          backgroundColor: Get.theme.primaryColor.withOpacity(0.3),
          bufferedColor: Get.theme.primaryColor.withOpacity(0.5),
        ),
        placeholder: Container(color: const Color(0xFF0A0E14)),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Error loading video',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Show the player widget immediately
      isYoutubeVideo.value = false;
      isVideoInitialized.value = true;
      videoErrorMessage.value = '';

      // Add listener – updates duration & play state once buffering starts
      videoController!.addListener(_videoListener);

      print('Direct stream video controller ready (buffering in background)');
    } catch (e) {
      print('Error initializing direct stream video: $e');
      videoErrorMessage.value = e.toString();
      rethrow;
    }
  }

  Future<void> _initializeUploadedVideo(String videoPath) async {
    try {
      // Clean up path
      String cleanPath = videoPath;
      if (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
      }

      final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
      final videoUrl = videoPath.startsWith('http') 
          ? videoPath 
          : '$baseUrl/$cleanPath';
      print('Initializing uploaded video: $videoUrl');
      videoErrorMessage.value = '';

      // Emulator workaround: goldfish MediaCodec can crash the emulator when
      // trying to decode some H.264 MP4 files (device disconnect). Avoid
      // embedded playback and offer external open instead.
      if (isEmulator.value) {
        isYoutubeVideo.value = false;
        isVideoInitialized.value = false;
        videoErrorMessage.value =
            'Video playback is not supported on Android emulator. Please use a real device or open the video externally.';
        return;
      }

      // Validate URL
      final uri = Uri.tryParse(videoUrl);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        throw Exception('Invalid video URL format: $videoUrl');
      }

      videoController = vp.VideoPlayerController.networkUrl(
        uri,
        httpHeaders: const {
          'Accept': 'video/*,*/*',
          'Connection': 'keep-alive',
        },
      );

      // Initialize Chewie with autoInitialize so we don't block the UI thread
      // or trigger emulator MediaCodec crashes on initialize().
      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        allowFullScreen: !isPremiere.value,
        allowMuting: true,
        showControls: !isPremiere.value,
        materialProgressColors: ChewieProgressColors(
          playedColor: Get.theme.primaryColor,
          handleColor: Get.theme.primaryColor,
          backgroundColor: Get.theme.primaryColor.withOpacity(0.3),
          bufferedColor: Get.theme.primaryColor.withOpacity(0.5),
        ),
        placeholder: Container(
          color: const Color(0xFF0A0E14),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Error loading video',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Listener updates play state & duration once buffering starts
      videoController!.addListener(_videoListener);

      // Show player widget immediately – Chewie handles its own loading state
      isYoutubeVideo.value = false;
      isVideoInitialized.value = true;
      videoErrorMessage.value = '';

      print('Uploaded video controller ready (buffering in background)');
    } catch (e) {
      print('Error initializing uploaded video: $e');
      videoErrorMessage.value = e.toString();
      rethrow;
    }
  }

  Future<void> retryVideo() async {
    final content = currentContent.value;
    if (content == null) return;
    await _initializeVideoFromContent(content);
  }

  void _initializeVideo() {
    // No-op: actual video loading happens in _loadChapterContents
    // via _initializeVideoFromContent after content is fetched.
  }

  void _videoListener() {
    if (videoController != null && videoController!.value.isInitialized) {
      isPlaying.value = videoController!.value.isPlaying;
      currentPosition.value = videoController!.value.position;

      // Update duration if it changed (important for direct streams)
      if (videoController!.value.duration != Duration.zero &&
          totalDuration.value != videoController!.value.duration) {
        totalDuration.value = videoController!.value.duration;
        print(
          '📹 Video duration updated: ${totalDuration.value.inSeconds} seconds',
        );
      }

      _checkVideoCompletion();
    }
  }

  void _loadDocuments() {
    documents.value =
        (chapterData.value['documents'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    if (documents.isNotEmpty) {
      selectDocument(documents.first);
    }
  }

  void _loadExercise() async {
    if (chapterId.value.isEmpty) return;

    try {
      isLoadingExercises.value = true;
      exercises.value = await _dataService.fetchChapterExercises(
        chapterId.value,
      );

      if (exercises.isNotEmpty) {
        currentExercise.value = exercises.first;
        isExerciseAvailable.value = true;
        totalExerciseQuestions.value =
            currentExercise.value?.questions.length ?? 0;
      } else {
        isExerciseAvailable.value = false;
      }
    } catch (e) {
      print('Error loading exercises: $e');
      isExerciseAvailable.value = false;
      // Don't show error snackbar as exercises might not be available for all chapters
    } finally {
      isLoadingExercises.value = false;
    }
  }

  void _startPositionListener() {
    // Check video position updates every second for sync
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        // Update position for regular video player
        if (videoController != null && videoController!.value.isInitialized) {
          currentPosition.value = videoController!.value.position;
          _checkDocumentSync();
          _checkVideoCompletion();
        }
        // Update position for YouTube player
        else if (youtubeController != null &&
            youtubeController!.value.isReady) {
          currentPosition.value = youtubeController!.value.position;
          totalDuration.value = youtubeController!.value.metaData.duration;
          _checkDocumentSync();
          _checkVideoCompletion();
        }
        _startPositionListener();
      }
    });
  }

  void _checkDocumentSync() {
    if (!isDocumentSyncEnabled.value || selectedDocument.value == null) return;

    final syncPoints = selectedDocument.value!['syncPoints'] as List<dynamic>?;
    if (syncPoints == null) return;

    final currentSeconds = currentPosition.value.inSeconds;

    for (var syncPoint in syncPoints) {
      final point = syncPoint as Map<String, dynamic>;
      final timeInSeconds = point['timeInSeconds'] as int;
      final page = point['page'] as int;

      // If we're within 1 second of a sync point, update the page
      if ((currentSeconds - timeInSeconds).abs() <= 1 &&
          currentPage.value != page) {
        currentPage.value = page;
        break;
      }
    }
  }

  void togglePlayPause() {
    if (videoController != null && videoController!.value.isInitialized) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
        isPlaying.value = false;
      } else {
        videoController!.play();
        isPlaying.value = true;
      }
    }
  }

  void seekTo(Duration position) {
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.seekTo(position);
      currentPosition.value = position;
    }
  }

  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;

    if (isFullScreen.value) {
      // Enter fullscreen - landscape mode
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Exit fullscreen - portrait mode
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  void selectDocument(Map<String, dynamic> document) {
    selectedDocument.value = document;
    totalPages.value = document['pages'] as int? ?? 0;
    currentPage.value = 1;
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  void toggleDocumentSync() {
    isDocumentSyncEnabled.value = !isDocumentSyncEnabled.value;
    if (isDocumentSyncEnabled.value) {
      Get.snackbar(
        'Document Sync',
        'Auto-scroll enabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Document Sync',
        'Auto-scroll disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void openDocumentInBrowser() {
    if (selectedDocument.value != null) {
      // In production, open URL in browser
      final docName =
          selectedDocument.value!['title'] as String? ??
          selectedDocument.value!['fileName'] as String? ??
          'Document';
      Get.snackbar(
        'Open in Browser',
        'Opening $docName in browser',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> downloadVideoForOffline() async {
    try {
      if (currentContent.value == null) {
        Get.snackbar(
          'Error',
          'No video available to download',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }

      final content = currentContent.value!;

      // Show disclaimer for YouTube videos
      if (content.videoType == 'youtube') {
        final shouldProceed = await Get.dialog<bool>(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Important Notice'),
              ],
            ),
            content: const Text(
              'Downloading YouTube videos may violate YouTube\'s Terms of Service. '
              'This feature is provided for educational purposes only. '
              'Please ensure you have the rights to download this content.\n\n'
              'Do you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Proceed'),
              ),
            ],
          ),
        );

        if (shouldProceed != true) return;
      }

      // Check if already downloading
      if (isDownloadingVideo.value) {
        Get.snackbar(
          'Already Downloading',
          'Please wait for the current download to complete',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isDownloadingVideo.value = true;
      videoDownloadProgress.value = 0.0;

      Get.snackbar(
        'Downloading',
        'Starting video download...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );

      // Request storage permission for Android
      if (Platform.isAndroid) {
        // Check Android version and request appropriate permissions
        // For Android 13+ (API 33+), we don't need storage permission for app-specific directory
        // For Android 10-12, request storage permission
        // For Android 9 and below, request storage permission

        bool hasPermission = false;

        if (await Permission.storage.isGranted) {
          hasPermission = true;
        } else if (await Permission.storage.isPermanentlyDenied) {
          // Permission permanently denied, show dialog to open settings
          final shouldOpenSettings = await Get.dialog<bool>(
            AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.settings, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Permission Required'),
                ],
              ),
              content: const Text(
                'Storage permission is required to download videos. '
                'Please enable it in app settings.\n\n'
                'Go to: Settings → Apps → Najah App → Permissions → Storage',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );

          if (shouldOpenSettings == true) {
            await openAppSettings();
          }

          isDownloadingVideo.value = false;
          return;
        } else {
          // Request permission
          final status = await Permission.storage.request();

          if (status.isGranted) {
            hasPermission = true;
          } else if (status.isDenied) {
            isDownloadingVideo.value = false;
            Get.snackbar(
              'Permission Denied',
              'Storage permission is required to download videos',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
              duration: const Duration(seconds: 3),
            );
            return;
          } else if (status.isPermanentlyDenied) {
            isDownloadingVideo.value = false;
            Get.snackbar(
              'Permission Denied',
              'Please enable storage permission in settings',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              duration: const Duration(seconds: 5),
            );
            return;
          }
        }

        if (!hasPermission) {
          isDownloadingVideo.value = false;
          Get.snackbar(
            'Permission Required',
            'Storage permission is needed to download videos',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
          return;
        }
      }

      // Get download directory
      final directory = await _getVideoDownloadDirectory();
      final sanitizedTitle = content.title.replaceAll(
        RegExp(r'[^\\w\\s-]'),
        '',
      );

      String filePath;

      if (content.videoType == 'youtube') {
        // Download YouTube video
        filePath = await _downloadYouTubeVideo(
          content,
          directory,
          sanitizedTitle,
        );
      } else {
        // Download regular video
        filePath = await _downloadRegularVideo(
          content,
          directory,
          sanitizedTitle,
        );
      }

      isDownloadingVideo.value = false;
      videoDownloadProgress.value = 1.0;

      // Save download info to storage
      await _saveDownloadedVideoInfo(content, filePath);

      Get.snackbar(
        'Download Complete',
        'Video is now available offline',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      isDownloadingVideo.value = false;
      videoDownloadProgress.value = 0.0;

      Get.snackbar(
        'Download Failed',
        'Failed to download video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<String> _downloadYouTubeVideo(
    ChapterContentModel content,
    Directory directory,
    String sanitizedTitle,
  ) async {
    try {
      // Extract video ID from URL
      final videoId = YoutubePlayer.convertUrlToId(content.videoUrl);

      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      // Initialize YouTube Explode
      final yt = YoutubeExplode();

      try {
        // Get video stream manifest
        final manifest = await yt.videos.streamsClient.getManifest(videoId);

        // Get the best muxed stream (video + audio combined)
        // This gives us a single file with both video and audio
        final streamInfo = manifest.muxed.withHighestBitrate();

        final fileName = '${content.id}_$sanitizedTitle.mp4';
        final filePath = '${directory.path}/$fileName';

        // Check if already downloaded
        final file = File(filePath);
        if (await file.exists()) {
          throw Exception('Video already downloaded');
        }

        // Get the stream
        final stream = yt.videos.streamsClient.get(streamInfo);

        // Download the video
        final output = file.openWrite();
        var bytesReceived = 0;
        final totalBytes = streamInfo.size.totalBytes;

        await for (final data in stream) {
          bytesReceived += data.length;
          output.add(data);

          // Update progress
          if (totalBytes > 0) {
            videoDownloadProgress.value = bytesReceived / totalBytes;
          }
        }

        await output.flush();
        await output.close();

        // Close YouTube Explode client
        yt.close();

        return filePath;
      } catch (e) {
        yt.close();
        rethrow;
      }
    } catch (e) {
      throw Exception('YouTube download failed: ${e.toString()}');
    }
  }

  Future<String> _downloadRegularVideo(
    ChapterContentModel content,
    Directory directory,
    String sanitizedTitle,
  ) async {
    final fileName = '${content.id}_$sanitizedTitle.mp4';
    final filePath = '${directory.path}/$fileName';

    // Check if already downloaded
    final file = File(filePath);
    if (await file.exists()) {
      throw Exception('Video already downloaded');
    }

    // Download video
    final dio = Dio();
    final videoUrl = '${ApiConstants.baseUrl}${content.videoUrl}';

    await dio.download(
      videoUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          videoDownloadProgress.value = received / total;
        }
      },
    );

    return filePath;
  }

  Future<Directory> _getVideoDownloadDirectory() async {
    Directory directory;

    if (Platform.isAndroid) {
      directory =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/NajahApp/Videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }
      return videoDir;
    } else {
      directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/Videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }
      return videoDir;
    }
  }

  Future<void> _saveDownloadedVideoInfo(
    ChapterContentModel content,
    String filePath,
  ) async {
    // In production, save this to a local database (Hive, SQLite, etc.)
    // For now, we'll use GetStorage or SharedPreferences

    final downloadData = {
      'id': content.id,
      'title': content.title,
      'subject': subjectName.value,
      'chapter': content.chapter.name,
      'grade': grade.value,
      'board': board.value,
      'duration': totalDuration.value.inSeconds,
      'thumbnail': '', // Thumbnail not available in model
      'filePath': filePath,
      'downloadedAt': DateTime.now().toIso8601String(),
      'videoType': content.videoType,
      'overview': content.overview,
      'watchProgress': 0.0,
      'watched': false,
      'timeWatched': 0,
      'lastWatchedAt': null,
      'notesCount': 0,
      'assessmentCompleted': false,
      'assessmentScore': null,
      'exerciseSubmitted': false,
    };

    // TODO: Save to local storage
    // Example with GetStorage:
    // final storage = GetStorage();
    // List downloads = storage.read('downloaded_videos') ?? [];
    // downloads.add(downloadData);
    // storage.write('downloaded_videos', downloads);

    print('Video downloaded: $downloadData');
  }

  void switchToExercise() {
    viewMode.value = 'exercise';
  }

  void switchToDocuments() {
    viewMode.value = 'documents';
  }

  void updateExerciseAnswer(String answer) {
    exerciseAnswer.value = answer;
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    if (currentExercise.value == null) return;
    if (exerciseSubmitted.value) return; // Don't allow changes after submission

    final question = currentExercise.value!.questions[questionIndex];
    question.selectedOptionIndex = optionIndex;

    // Trigger UI update
    currentExercise.refresh();
  }

  int get answeredQuestionsCount {
    if (currentExercise.value == null) return 0;
    return currentExercise.value!.questions.where((q) => q.isAnswered).length;
  }

  bool get allQuestionsAnswered {
    if (currentExercise.value == null) return false;
    return answeredQuestionsCount == currentExercise.value!.questions.length;
  }

  Future<void> submitExercise() async {
    if (currentExercise.value == null) return;

    if (!allQuestionsAnswered) {
      Get.snackbar(
        'Incomplete',
        'Please answer all questions before submitting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    isSubmittingExercise.value = true;

    try {
      int correctAnswers = 0;
      for (var question in currentExercise.value!.questions) {
        if (question.isCorrect) {
          correctAnswers++;
        }
      }

      exerciseScore.value = correctAnswers;
      totalExerciseQuestions.value = currentExercise.value!.questions.length;

      final percentage = totalExerciseQuestions.value > 0
          ? (correctAnswers / totalExerciseQuestions.value) * 100
          : 0.0;

      final response = await _dataService.recordExerciseSubmission(
        exerciseId: currentExercise.value!.id,
        chapterId: chapterId.value,
        obtainedMarks: correctAnswers,
        totalMarks: totalExerciseQuestions.value,
        percentage: percentage,
        subscriptionId: subscriptionId.value,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to submit exercise');
      }

      exerciseSubmitted.value = true;
      submittedAt.value = DateTime.now();

      Get.snackbar(
        'Exercise Submitted!',
        'Your exercise is marked as completed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Submission Failed',
        'Could not submit exercise: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSubmittingExercise.value = false;
    }
  }

  void resetExercise() {
    if (currentExercise.value == null) return;

    // Reset all answers
    for (var question in currentExercise.value!.questions) {
      question.selectedOptionIndex = null;
    }

    exerciseSubmitted.value = false;
    submittedAt.value = null;
    exerciseScore.value = 0;

    exercises.refresh();

    Get.snackbar(
      'Reset',
      'Exercise has been reset. You can try again!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> saveExerciseDraft() async {
    // Save draft without submitting
    // In production, save to local storage or API
    Get.snackbar(
      'Draft Saved',
      'Your answer has been saved',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> downloadDocumentForOffline() async {
    if (selectedDocument.value == null) return;

    final doc = selectedDocument.value!;
    final resourceId = (doc['_id'] ?? doc['id'] ?? '').toString();
    final fileName = (doc['fileName'] ?? doc['title'] ?? 'Document').toString();
    final fileUrl = (doc['fileUrl'] ?? doc['filePath'] ?? '').toString();

    if (resourceId.isEmpty || fileUrl.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'This document cannot be downloaded.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloadingDocument.value = true;
    documentDownloadProgress.value = 0.0;

    // Download without auto-opening (offline save).
    await downloadResource(
      resourceId,
      fileName,
      fileUrl,
      openAfterDownload: false,
      onProgress: (p) => documentDownloadProgress.value = p,
    );

    isDownloadingDocument.value = false;
  }

  // Assessment methods
  void _loadAssessment() {
    // Check if assessment is available for this chapter
    assessmentData.value =
        chapterData.value['assessment'] as Map<String, dynamic>?;
    isAssessmentAvailable.value = assessmentData.value != null;
    print('Chapter assessment loaded: ${isAssessmentAvailable.value}');
  }

  void _loadAssessmentFromContent() {
    // Check if assessment is available for the current content
    if (currentContent.value?.assessment != null) {
      assessmentData.value = currentContent.value!.assessment;
      isAssessmentAvailable.value = true;
      _hasShownAssessment = false; // Reset the flag for new content
      final questionsCount =
          (assessmentData.value?['questions'] as List?)?.length ?? 0;
      print(
        '✅ Assessment loaded for content: ${assessmentData.value?['title']} ($questionsCount questions)',
      );
      print('   isAssessmentAvailable: $isAssessmentAvailable');
    } else {
      assessmentData.value = null;
      isAssessmentAvailable.value = false;
      print('❌ No assessment available for this content');
    }
  }

  void _checkVideoCompletion() {
    // Check if video is near completion.
    // We mark "completed" at 95% (progress save), but auto-open the assessment
    // only when the video essentially ends (>= 99% or within ~2s of the end).
    if (totalDuration.value.inSeconds > 0) {
      final durSec = totalDuration.value.inSeconds;
      final posSec = currentPosition.value.inSeconds.clamp(0, durSec);
      final progress = posSec / durSec;
      final nearEndByProgress = progress >= 0.99;
      final nearEndBySeconds = (durSec - posSec) <= 2;

      print(
        'Video progress: ${(progress * 100).toStringAsFixed(1)}% - Assessment available: $isAssessmentAvailable - Already shown: $_hasShownAssessment',
      );

      // Mark video as complete at 95%
      if (progress >= 0.95 && !_hasMarkedVideoComplete) {
        _hasMarkedVideoComplete = true;
        isVideoCompleted.value = true;
        _markVideoComplete();
      }

      // Trigger assessment if available
      if ((nearEndByProgress || nearEndBySeconds) &&
          isAssessmentAvailable.value &&
          !showAssessmentDialog.value &&
          !_hasShownAssessment) {
        print(
          '🎯 Triggering assessment near end (${(progress * 100).toStringAsFixed(1)}%)',
        );
        _hasShownAssessment = true;
        _triggerChapterAssessment();
      }
    }
  }

  Future<void> _markVideoComplete() async {
    if (chapterId.value.isEmpty) {
      print('❌ Cannot mark video complete: Chapter ID is empty');
      return;
    }

    try {
      print('📹 Marking video as complete for chapter: ${chapterId.value}');

      final data = <String, dynamic>{};
      if (subscriptionId.value.isNotEmpty) {
        data['subscriptionId'] = subscriptionId.value;
      }

      final response = await _dataService.markVideoComplete(
        chapterId.value,
        data,
      );

      if (response['success'] == true) {
        print('✅ Video marked as complete successfully');
        Get.snackbar(
          'Progress Updated',
          'Video completion saved',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        // Load existing rating then prompt the user
        await _loadMyRating();
        _showRatingPrompt();

        // Persist completion (used for "first watch" premiere logic).
        final completedKey =
            'chapter_video_completed_${subscriptionId.value}_${chapterId.value}';
        try {
          await _storage?.saveBool(completedKey, true);
        } catch (_) {
          // ignore
        }
      } else {
        print('⚠️ Failed to mark video complete: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error marking video complete: $e');
    }
  }

  // ── Rating helpers ─────────────────────────────────────────────────────────

  /// Fetch the current student's existing rating for the active content.
  Future<void> _loadMyRating() async {
    try {
      final contentId = currentContent.value?.id;
      if (contentId == null || contentId.isEmpty) return;

      final response = await _apiService.get(
        '${ApiConstants.ratingsContent}/$contentId/mine',
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        final r = response.data['data'] as Map<String, dynamic>;
        existingRating.value = (r['rating'] as num?)?.toInt() ?? 0;
        hasRated.value = existingRating.value > 0;
        selectedRating.value = existingRating.value;
      }
    } catch (e) {
      print('❌ Error loading my rating: $e');
    }
  }

  /// Show the rating bottom sheet dialog.
  void _showRatingPrompt() {
    // Give a small delay so the completion snackbar doesn't overlap
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!isClosed) showVideoRatingDialog();
    });
  }

  /// Public — called from the view's "Rate this video" button as well.
  Future<void> loadMyRating() => _loadMyRating();

  /// Submit (or update) the rating for the currently playing content.
  Future<void> submitVideoRating({
    required int rating,
    String feedback = '',
  }) async {
    final contentId = currentContent.value?.id;
    if (contentId == null || contentId.isEmpty) {
      Get.snackbar('Error', 'Cannot identify the video');
      return;
    }
    if (rating < 1 || rating > 5) {
      Get.snackbar('Error', 'Please select a star rating before submitting');
      return;
    }

    isSubmittingRating.value = true;
    try {
      final response = await _apiService.post(
        '${ApiConstants.ratingsContent}/$contentId',
        data: {'rating': rating, 'feedback': feedback.trim()},
      );
      if (response.data['success'] == true) {
        existingRating.value = rating;
        hasRated.value = true;
        selectedRating.value = rating;
        Get.back(); // close dialog
        Get.snackbar(
          'Thank you! ⭐',
          'Your rating has been submitted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Failed to submit rating',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit rating');
    } finally {
      isSubmittingRating.value = false;
    }
  }

  /// Opens the rating dialog (called from the view's rate button too).
  void showVideoRatingDialog() {
    Get.dialog(const _VideoRatingDialog(), barrierDismissible: true);
  }
  // ──────────────────────────────────────────────────────────────────────────

  bool _hasShownAssessment = false;
  bool _hasMarkedVideoComplete =
      false; // Track if we've marked video as complete

  void _triggerChapterAssessment() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed && isAssessmentAvailable.value) {
        final completed = assessmentData.value?['completed'] as bool? ?? false;
        if (!completed) {
          openAssessmentAttempt();
        }
      }
    });
  }

  void openAssessmentAttempt() {
    final a = assessmentData.value;
    if (a == null) return;
    final assessmentId = (a['_id'] ?? '').toString();
    if (assessmentId.isEmpty) return;

    // Reuse the public assessment attempt flow (same submit endpoint on backend).
    Get.toNamed(
      Routes.PUBLIC_ASSESSMENT_ATTEMPT,
      arguments: {
        'assessment': a,
        'chapterId': chapterId.value,
        'subscriptionId': subscriptionId.value,
      },
    );
  }

  void startAssessment() {
    print('▶️  Starting assessment...');
    hasStartedAssessment.value = true;
    currentQuestionIndex.value = 0;
    assessmentAnswers.clear();
  }

  void selectAssessmentAnswer(int questionIndex, int optionIndex) {
    assessmentAnswers[questionIndex] = optionIndex;
  }

  void nextQuestion() {
    final questions = assessmentData.value?['questions'] as List?;
    if (questions != null &&
        currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  Future<void> submitAssessment() async {
    final questions = assessmentData.value?['questions'] as List?;
    final assessmentId = assessmentData.value?['_id'] as String?;

    if (questions == null || assessmentId == null) {
      Get.snackbar(
        'Error',
        'Assessment data not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Check if all questions are answered
    if (assessmentAnswers.length < questions.length) {
      Get.snackbar(
        'Incomplete',
        'Please answer all questions before submitting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Navigate to result page and start loading
    Get.toNamed('/assessment-result');
    isSubmittingAssessment.value = true;

    try {
      // Format answers for API
      final Map<String, dynamic> formattedAnswers = {};

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i] as Map<String, dynamic>;
        final questionId = question['_id'] as String;
        final selectedAnswer = assessmentAnswers[i];

        if (selectedAnswer != null) {
          // Check if it's multiple choice or single choice
          final questionType = question['type'] as String?;

          if (questionType == 'multiple' || questionType == 'multipleChoice') {
            // For multiple choice, send as array (if needed in future)
            formattedAnswers[questionId] = selectedAnswer.toString();
          } else {
            // For single choice, send as string
            formattedAnswers[questionId] = selectedAnswer.toString();
          }
        }
      }

      print('📤 Submitting assessment: $assessmentId');
      print('📝 Formatted answers: $formattedAnswers');

      // Submit to server
      final response = await _dataService.submitAssessment(
        assessmentId: assessmentId,
        answers: formattedAnswers,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final results = data['results'] as List;

        // Calculate correct answers from results
        int correctAnswers = 0;
        for (var result in results) {
          if (result['isCorrect'] == true) {
            correctAnswers++;
          }
        }

        final percentage = (data['percentage'] as num).toInt();
        final totalQuestions = questions.length;

        print('✅ Assessment submitted successfully');
        print('   Score: $percentage%');
        print('   Correct: $correctAnswers/$totalQuestions');

        // Update assessment data with server response
        if (assessmentData.value != null) {
          assessmentData.value!['completed'] = true;
          assessmentData.value!['score'] = percentage;
          assessmentData.value!['correctAnswers'] = correctAnswers;
          assessmentData.value!['totalQuestions'] = totalQuestions;
          assessmentData.value!['obtainedMarks'] = data['obtainedMarks'];
          assessmentData.value!['totalMarks'] = data['totalMarks'];
          assessmentData.value!['results'] = results;
          assessmentData.value!['attemptedAt'] = DateTime.now()
              .toIso8601String();
        }
      } else {
        // Fallback to local calculation if API fails
        print('⚠️  API submission failed, using local calculation');
        await _calculateScoreLocally(questions);
      }
    } catch (e) {
      print('❌ Error submitting assessment: $e');
      // Fallback to local calculation on error
      await _calculateScoreLocally(questions);
    } finally {
      isSubmittingAssessment.value = false;
    }
  }

  // Fallback local calculation if API fails
  Future<void> _calculateScoreLocally(List questions) async {
    await Future.delayed(const Duration(seconds: 1));

    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i] as Map<String, dynamic>;
      final selectedAnswer = assessmentAnswers[i];

      final options = question['options'] as List;
      if (selectedAnswer != null && selectedAnswer < options.length) {
        final selectedOption = options[selectedAnswer];
        final isCorrect = selectedOption is Map<String, dynamic>
            ? (selectedOption['isCorrect'] as bool? ?? false)
            : false;

        if (isCorrect) {
          correctAnswers++;
        }
      }
    }

    final score = (correctAnswers / questions.length * 100).round();

    if (assessmentData.value != null) {
      assessmentData.value!['completed'] = true;
      assessmentData.value!['score'] = score;
      assessmentData.value!['correctAnswers'] = correctAnswers;
      assessmentData.value!['totalQuestions'] = questions.length;
      assessmentData.value!['attemptedAt'] = DateTime.now().toIso8601String();
    }
  }

  void closeAssessmentDialog() {
    showAssessmentDialog.value = false;
  }

  void skipAssessment() {
    showAssessmentDialog.value = false;
    Get.snackbar(
      'Assessment Skipped',
      'You can take the assessment later from the chapter page',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // Resource Download and Open Methods
  Future<void> downloadAndOpenResource(Map<String, dynamic> resource) async {
    final resourceId = resource['_id'] as String;
    final fileName = resource['fileName'] as String;
    final fileUrl = resource['fileUrl'] as String?;
    final filePath = resource['filePath'] as String?;

    // Check if file is already downloaded
    final existingFile = await _getDownloadedFile(fileName);
    if (existingFile != null && await existingFile.exists()) {
      await _openFile(existingFile.path, fileName);
      return;
    }

    // Download the file
    await downloadResource(resourceId, fileName, fileUrl ?? filePath ?? '');
  }

  Future<void> downloadResource(
    String resourceId,
    String fileName,
    String fileUrl,
    {bool openAfterDownload = true, void Function(double progress)? onProgress}
  ) async {
    try {
      // Check if already downloading
      if (downloadingResourceIds.contains(resourceId)) {
        Get.snackbar(
          'Download in Progress',
          'This file is already being downloaded',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Request storage permission
      if (Platform.isAndroid) {
        bool hasPermission = false;

        if (await Permission.storage.isGranted) {
          hasPermission = true;
        } else if (await Permission.storage.isPermanentlyDenied) {
          // Permission permanently denied, show dialog to open settings
          final shouldOpenSettings = await Get.dialog<bool>(
            AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.settings, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Permission Required'),
                ],
              ),
              content: const Text(
                'Storage permission is required to download files. '
                'Please enable it in app settings.\n\n'
                'Go to: Settings → Apps → Najah App → Permissions → Storage',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );

          if (shouldOpenSettings == true) {
            await openAppSettings();
          }
          return;
        } else {
          // Request permission
          final status = await Permission.storage.request();

          if (status.isGranted) {
            hasPermission = true;
          } else if (status.isDenied) {
            Get.snackbar(
              'Permission Denied',
              'Storage permission is required to download files',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
              duration: const Duration(seconds: 3),
            );
            return;
          } else if (status.isPermanentlyDenied) {
            Get.snackbar(
              'Permission Denied',
              'Please enable storage permission in settings',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              duration: const Duration(seconds: 5),
            );
            return;
          }
        }

        if (!hasPermission) {
          Get.snackbar(
            'Permission Required',
            'Storage permission is needed to download files',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
          return;
        }
      }

      downloadingResourceIds.add(resourceId);
      resourceDownloadProgress[resourceId] = 0.0;

      // Get download directory
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';

      // Show downloading snackbar
      Get.snackbar(
        'Downloading',
        fileName,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );

      // Download using Dio
      final dio = Dio();
      final fullUrl = fileUrl.startsWith('http')
          ? fileUrl
          : '${ApiConstants.baseUrl}/$fileUrl';

      await dio.download(
        fullUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            resourceDownloadProgress[resourceId] = progress;
            if (onProgress != null) onProgress(progress);
          }
        },
      );

      downloadingResourceIds.remove(resourceId);
      resourceDownloadProgress.remove(resourceId);

      Get.snackbar(
        'Download Complete',
        fileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );

      if (openAfterDownload) {
        // Open the downloaded file
        await _openFile(filePath, fileName);
      }
    } catch (e) {
      downloadingResourceIds.remove(resourceId);
      resourceDownloadProgress.remove(resourceId);

      print('Error downloading resource: $e');
      Get.snackbar(
        'Download Failed',
        'Failed to download $fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Try to get external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Create NajahApp folder in Downloads
        final najahDir = Directory('${directory.path}/NajahApp/Resources');
        if (!await najahDir.exists()) {
          await najahDir.create(recursive: true);
        }
        return najahDir;
      }
    }
    // Fallback to application documents directory
    return await getApplicationDocumentsDirectory();
  }

  Future<File?> _getDownloadedFile(String fileName) async {
    try {
      final directory = await _getDownloadDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      print('Error checking for downloaded file: $e');
    }
    return null;
  }

  Future<void> _openFile(String filePath, String fileName) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        Get.snackbar(
          'Unable to Open',
          'No app found to open $fileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      Get.snackbar(
        'Error',
        'Failed to open $fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  bool isResourceDownloading(String resourceId) {
    return downloadingResourceIds.contains(resourceId);
  }

  double getResourceDownloadProgress(String resourceId) {
    return resourceDownloadProgress[resourceId] ?? 0.0;
  }

  // AI Chat Assistant Methods
  Future<void> sendChatMessage() async {
    final question = chatInputController.text.trim();

    if (question.isEmpty) return;
    if (currentContent.value == null) {
      Get.snackbar(
        'Error',
        'No content selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Add user message to chat
    chatMessages.add({
      'role': 'user',
      'content': question,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Persist user message (best-effort)
    _dataService.saveAiChatMessage(
      context: _aiChatContextForContent(),
      role: 'user',
      content: question,
      targetId: currentContent.value?.chapter.id,
    );

    // Clear input
    chatInputController.clear();

    // Scroll to bottom
    _scrollToBottom();

    // Show loading indicator
    isSendingMessage.value = true;

    try {
      // Convert chat history to API format
      final conversationHistory = chatMessages
          .where((msg) => msg['role'] != null && msg['content'] != null)
          .map(
            (msg) => {
              'role': msg['role'] as String,
              'content': msg['content'] as String,
            },
          )
          .toList();

      // Remove the last message (current question) from history for API call
      final historyForApi = conversationHistory
          .take(conversationHistory.length - 1)
          .toList()
          .cast<Map<String, String>>();

      print('🤖 Sending AI question: $question');
      print('📚 Content ID: ${currentContent.value!.id}');
      print('💬 History length: ${historyForApi.length}');

      final result = await _dataService.askAIQuestion(
        contentId: currentContent.value!.id,
        question: question,
        conversationHistory: historyForApi,
      );

      if (result['success'] == true) {
        final answer = result['data']['answer'] as String;
        final metadata = result['data']['metadata'] as Map<String, dynamic>?;
        final audioBase64 = result['data']['audio']?.toString();

        // Add AI response to chat
        chatMessages.add({
          'role': 'assistant',
          'content': answer,
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': metadata,
        });

        // Persist assistant message (best-effort)
        _dataService.saveAiChatMessage(
          context: _aiChatContextForContent(),
          role: 'assistant',
          content: answer,
          targetId: currentContent.value?.chapter.id,
          metadata: metadata,
        );

        // Scroll to bottom to show new message
        _scrollToBottom();

        // Auto-play AI voice if provided by backend
        if (audioBase64 != null && audioBase64.isNotEmpty) {
          try {
            isAiSpeaking.value = true;
            await _aiAudioPlayer.stop();
            final bytes = base64Decode(audioBase64);
            await _aiAudioPlayer.play(BytesSource(bytes));
          } catch (_) {
            // best-effort: ignore audio failures
          } finally {
            isAiSpeaking.value = false;
          }
        }
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to get AI response',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );

        // Remove the user message if AI failed
        chatMessages.removeLast();
      }
    } catch (e) {
      print('❌ Error sending chat message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );

      // Remove the user message if error occurred
      if (chatMessages.isNotEmpty && chatMessages.last['role'] == 'user') {
        chatMessages.removeLast();
      }
    } finally {
      isSendingMessage.value = false;
    }
  }

  void _scrollToBottom() {
    if (chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void clearChat() {
    chatMessages.clear();
    final studentId = _currentStudentId();
    if (studentId != null) {
      _dataService.clearAiChatHistory(
        context: _aiChatContextForContent(),
        studentId: studentId,
      );
    }
    Get.snackbar(
      'Chat Cleared',
      'Conversation history has been cleared',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Voice Input Methods
  Future<void> _initializeSpeech() async {
    if (isClosed) return; // controller may have been disposed by now
    try {
      speechToText = stt.SpeechToText();
      speechEnabled.value = await speechToText
          .initialize(
            onError: (error) {
              print('Speech recognition error: $error');
              isListening.value = false;
            },
            onStatus: (status) {
              if (status == 'notListening' || status == 'done') {
                isListening.value = false;
              }
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('[Speech] init timed out – mic will be unavailable');
              return false;
            },
          );
    } catch (e) {
      print('[Speech] init failed: $e');
      speechEnabled.value = false;
    }
  }

  Future<void> startListening() async {
    if (!speechEnabled.value) {
      Get.snackbar(
        'Not Available',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission Required',
        'Microphone permission is required for voice input',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (!isListening.value) {
      isListening.value = true;
      await speechToText.listen(
        onResult: (result) {
          chatInputController.text = result.recognizedWords;
        },
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      );
    }
  }

  /// "Gemini voice assistant" experience (web parity):
  /// - listen to user's voice
  /// - on final transcript: send AI chat message
  /// - auto-play backend provided audio (handled by [sendChatMessage])
  Future<void> startGeminiVoiceAssistant() async {
    if (!speechEnabled.value) {
      await startListening(); // will show snackbar
      return;
    }

    if (currentContent.value == null) {
      Get.snackbar(
        'Error',
        'No content selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Request microphone permission (same as normal voice input)
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission Required',
        'Microphone permission is required for voice assistant',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Stop any ongoing AI audio so the user can speak.
    try {
      await _aiAudioPlayer.stop();
    } catch (_) {
      // best-effort
    }

    if (isListening.value) return;
    isListening.value = true;
    lastVoiceTranscript.value = '';

    await speechToText.listen(
      onResult: (result) async {
        final text = result.recognizedWords.trim();
        lastVoiceTranscript.value = text;
        chatInputController.text = text;

        if (result.finalResult && text.isNotEmpty) {
          // Stop listening before we send to AI.
          await stopListening();
          isVoiceAssistantProcessing.value = true;
          try {
            await sendChatMessage();
          } finally {
            isVoiceAssistantProcessing.value = false;
          }
        }
      },
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> toggleGeminiVoiceAssistant() async {
    if (isListening.value) {
      await stopListening();
      return;
    }
    if (isVoiceAssistantProcessing.value) return;
    await startGeminiVoiceAssistant();
  }

  Future<void> stopListening() async {
    if (isListening.value) {
      await speechToText.stop();
      isListening.value = false;
    }
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  @override
  void onClose() {
    // Remove video listener
    videoController?.removeListener(_videoListener);

    // Dispose controllers
    youtubeController?.dispose();
    chewieController?.dispose();
    videoController?.dispose();
    chatInputController.dispose();
    chatScrollController.dispose();
    speechToText.cancel();
    _aiAudioPlayer.dispose();
    _scheduleTicker?.cancel();
    _premiereSyncTicker?.cancel();
    _pollTicker?.cancel();
    _pollDismissTimer?.cancel();

    // Reset orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.onClose();
  }
}

// ─── Rating Dialog ─────────────────────────────────────────────────────────────

class _VideoRatingDialog extends GetView<VideoPlayerController> {
  const _VideoRatingDialog();

  @override
  Widget build(BuildContext context) {
    // local state for the dialog
    final feedbackCtrl = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                controller.hasRated.value
                    ? 'Update Your Rating'
                    : 'Rate This Video',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.currentContent.value?.title ?? 'Video',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Star Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => controller.selectedRating.value = star,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        star <= controller.selectedRating.value
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: star <= controller.selectedRating.value
                            ? const Color(0xFFF59E0B)
                            : Colors.grey[400],
                        size: 44,
                      ),
                    ),
                  );
                }),
              ),

              // Label under stars
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Text(
                  _starLabel(controller.selectedRating.value),
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.selectedRating.value > 0
                        ? const Color(0xFFF59E0B)
                        : Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Feedback field
              TextField(
                controller: feedbackCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts (optional)…',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6A3DE8),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.isSubmittingRating.value
                          ? null
                          : () => controller.submitVideoRating(
                              rating: controller.selectedRating.value,
                              feedback: feedbackCtrl.text,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3DE8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isSubmittingRating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.hasRated.value
                                  ? 'Update Rating'
                                  : 'Submit Rating',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap a star to rate';
    }
  }
}
