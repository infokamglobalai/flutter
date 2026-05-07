import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/data/services/brain_games_storage_service.dart';
import '../views/game_play_view.dart';
import '../views/games/math_puzzle_game.dart';
import '../views/games/memory_match_game.dart';
import '../views/games/word_scramble_game.dart';
import '../views/games/general_quiz_game.dart';
import '../views/games/color_match_game.dart';
import '../views/games/pattern_recognition_game.dart';
import '../views/games/sequence_puzzle_game.dart';

class BrainGamesController extends GetxController {
  final BrainGamesStorageService _storageService =
      Get.find<BrainGamesStorageService>();
  final selectedCategory = Rx<String?>(null);
  final isLoading = false.obs;
  final availableGames = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadGames();
  }

  void loadGames() {
    availableGames.value = _generateGames(countPerEngine: 18); // 7 engines * 18 = 126 games
  }

  List<Map<String, dynamic>> _generateGames({required int countPerEngine}) {
    const difficulties = ['Easy', 'Medium', 'Hard'];

    int pseudoPlays(int seed) => 800 + (seed * 137) % 5200;
    double pseudoRating(int seed) => 4.1 + ((seed * 17) % 9) / 10.0; // 4.1 - 4.9

    Map<String, dynamic> mk({
      required String id,
      required String title,
      required String category,
      required String difficulty,
      required String description,
      required String icon,
      required int color,
      required String duration,
      required String type,
      required int seed,
    }) {
      return {
        'id': id,
        'title': title,
        'category': category,
        'difficulty': difficulty,
        'description': description,
        'icon': icon,
        'color': color,
        'plays': pseudoPlays(seed),
        'rating': double.parse(pseudoRating(seed).toStringAsFixed(1)),
        'duration': duration,
        'type': type,
      };
    }

    final games = <Map<String, dynamic>>[];
    int seed = 1;

    void addEngine({
      required String prefix,
      required String baseTitle,
      required String category,
      required String description,
      required String icon,
      required int color,
      required String type,
    }) {
      for (var i = 1; i <= countPerEngine; i++) {
        final d = difficulties[(i - 1) % difficulties.length];
        final num = i.toString().padLeft(3, '0');
        games.add(
          mk(
            id: '${prefix}_$num',
            title: '$baseTitle $i',
            category: category,
            difficulty: d,
            description: description,
            icon: icon,
            color: color,
            duration: d == 'Easy'
                ? '3 min'
                : d == 'Medium'
                    ? '6 min'
                    : '10 min',
            type: type,
            seed: seed++,
          ),
        );
      }
    }

    // Engines (all mapped to existing working game widgets)
    addEngine(
      prefix: 'math',
      baseTitle: 'Quick Math',
      category: 'Math & Logic',
      description: 'Solve arithmetic problems as fast as you can',
      icon: 'calculate',
      color: 0xFF6366F1,
      type: 'game',
    );
    addEngine(
      prefix: 'memory',
      baseTitle: 'Memory Match',
      category: 'Memory & Focus',
      description: 'Match pairs of cards to test your memory',
      icon: 'style',
      color: 0xFF10B981,
      type: 'game',
    );
    addEngine(
      prefix: 'word',
      baseTitle: 'Word Scramble',
      category: 'Word & Vocabulary',
      description: 'Unscramble letters to form words',
      icon: 'text_fields',
      color: 0xFFF59E0B,
      type: 'game',
    );
    addEngine(
      prefix: 'quiz',
      baseTitle: 'Knowledge Quiz',
      category: 'Trivia & Knowledge',
      description: 'Test your knowledge on various topics',
      icon: 'quiz',
      color: 0xFF14B8A6,
      type: 'quiz',
    );
    addEngine(
      prefix: 'reflex',
      baseTitle: 'Color Reflex',
      category: 'Speed & Reflexes',
      description: 'Test your reflexes by matching colors quickly',
      icon: 'speed',
      color: 0xFFEC4899,
      type: 'game',
    );
    addEngine(
      prefix: 'pattern',
      baseTitle: 'Pattern Detective',
      category: 'Visual & Spatial',
      description: 'Find the odd pattern in the grid',
      icon: 'grid_view',
      color: 0xFF8B5CF6,
      type: 'game',
    );
    addEngine(
      prefix: 'sequence',
      baseTitle: 'Sequence Solver',
      category: 'Strategy & Planning',
      description: 'Find patterns and complete sequences',
      icon: 'format_list_numbered',
      color: 0xFF059669,
      type: 'game',
    );

    return games;
  }

  List<Map<String, dynamic>> get filteredGames {
    if (selectedCategory.value == null || selectedCategory.value == 'All') {
      return availableGames;
    }
    return availableGames
        .where((game) => game['category'] == selectedCategory.value)
        .toList();
  }

  List<String> get categories {
    final cats = availableGames
        .map((g) => g['category'] as String)
        .toSet()
        .toList();
    cats.insert(0, 'All');
    return cats;
  }

  void setCategory(String? category) {
    if (category == 'All') {
      selectedCategory.value = null;
    } else {
      selectedCategory.value = category;
    }
  }

  void playGame(Map<String, dynamic> game) {
    Widget gameWidget;

    // Route to specific game implementation
    final id = (game['id'] ?? '').toString();
    if (id.startsWith('math_')) {
      gameWidget = MathPuzzleGame(game: game);
    } else if (id.startsWith('memory_')) {
      gameWidget = MemoryMatchGame(game: game);
    } else if (id.startsWith('word_')) {
      gameWidget = WordScrambleGame(game: game);
    } else if (id.startsWith('quiz_')) {
      gameWidget = GeneralQuizGame(game: game);
    } else if (id.startsWith('reflex_')) {
      gameWidget = ColorMatchGame(game: game);
    } else if (id.startsWith('pattern_')) {
      gameWidget = PatternRecognitionGame(game: game);
    } else if (id.startsWith('sequence_')) {
      gameWidget = SequencePuzzleGame(game: game);
    } else {
      // Unknown id: show placeholder, but this should be rare.
      gameWidget = GamePlayView(game: game);
    }

    Get.to(
      () => gameWidget,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  Map<String, dynamic> getUserStats() {
    final stats = _storageService.getStats();
    final badges = _storageService.getBadges();
    final streak = _storageService.getCurrentStreak();
    final rank = _storageService.getPlayerRank();
    final nextRank = _storageService.getNextRank();
    final progress = _storageService.getProgressToNextRank();

    return {
      'gamesPlayed': stats['totalGamesPlayed'] ?? 0,
      'totalScore': stats['totalScore'] ?? 0,
      'averageRating': 4.5, // Could be calculated from scores
      'streak': streak,
      'badges': badges.length,
      'rank': rank,
      'nextRank': nextRank,
      'progressToNext': progress,
    };
  }

  // Get game-specific stats
  Map<String, dynamic> getGameStats(String gameId) {
    final stats = _storageService.getStats();
    final perGame = stats['perGame'] as Map<String, dynamic>? ?? {};
    final gameStats = perGame[gameId] as Map<String, dynamic>? ?? {};

    return {
      'played': gameStats['played'] ?? 0,
      'bestScore': gameStats['bestScore'] ?? 0,
      'totalScore': gameStats['totalScore'] ?? 0,
      'averageScore': _storageService.getAverageScore(gameId),
    };
  }

  // Update game score after completion
  Future<void> saveGameResult({
    required String gameId,
    required int score,
    required int timeSpent,
    required String difficulty,
  }) async {
    await _storageService.saveGameScore(
      gameId: gameId,
      score: score,
      timeSpent: timeSpent,
      difficulty: difficulty,
    );

    // Trigger UI update
    update();
  }
}
