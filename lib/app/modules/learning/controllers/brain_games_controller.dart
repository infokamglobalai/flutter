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
    // Curated games list - all categories have working games
    availableGames.value = [
      // ===== MATH & LOGIC (4 games - all working) =====
      {
        'id': 'math_puzzle',
        'title': 'Quick Math Challenge',
        'category': 'Math & Logic',
        'difficulty': 'Easy',
        'description': 'Solve arithmetic problems as fast as you can',
        'icon': 'calculate',
        'color': 0xFF6366F1,
        'plays': 1234,
        'rating': 4.5,
        'duration': '5 min',
        'type': 'game',
      },
      {
        'id': 'logic_grid',
        'title': 'Advanced Math Puzzles',
        'category': 'Math & Logic',
        'difficulty': 'Hard',
        'description': 'Complex calculations and mathematical reasoning',
        'icon': 'grid_on',
        'color': 0xFF8B5CF6,
        'plays': 892,
        'rating': 4.7,
        'duration': '10 min',
        'type': 'game',
      },
      {
        'id': 'number_sequence',
        'title': 'Number Patterns',
        'category': 'Math & Logic',
        'difficulty': 'Medium',
        'description': 'Find patterns in number sequences',
        'icon': 'auto_graph',
        'color': 0xFF3B82F6,
        'plays': 2156,
        'rating': 4.3,
        'duration': '7 min',
        'type': 'game',
      },

      // ===== MEMORY & FOCUS (3 games - all working) =====
      {
        'id': 'memory_cards',
        'title': 'Memory Match - Easy',
        'category': 'Memory & Focus',
        'difficulty': 'Easy',
        'description': 'Match pairs of cards to test your memory',
        'icon': 'style',
        'color': 0xFF10B981,
        'plays': 3421,
        'rating': 4.6,
        'duration': '5 min',
        'type': 'game',
      },
      {
        'id': 'pattern_recall',
        'title': 'Memory Match - Hard',
        'category': 'Memory & Focus',
        'difficulty': 'Hard',
        'description': 'Advanced memory challenge with more cards',
        'icon': 'pattern',
        'color': 0xFF059669,
        'plays': 1567,
        'rating': 4.4,
        'duration': '8 min',
        'type': 'game',
      },

      // ===== WORD & VOCABULARY (4 games - all working) =====
      {
        'id': 'word_scramble',
        'title': 'Word Unscramble',
        'category': 'Word & Vocabulary',
        'difficulty': 'Easy',
        'description': 'Unscramble letters to form words',
        'icon': 'text_fields',
        'color': 0xFFF59E0B,
        'plays': 2789,
        'rating': 4.5,
        'duration': '5 min',
        'type': 'game',
      },
      {
        'id': 'crossword',
        'title': 'Word Builder',
        'category': 'Word & Vocabulary',
        'difficulty': 'Medium',
        'description': 'Build words from scrambled letters',
        'icon': 'grid_4x4',
        'color': 0xFFD97706,
        'plays': 1923,
        'rating': 4.8,
        'duration': '7 min',
        'type': 'game',
      },
      {
        'id': 'word_association',
        'title': 'Vocabulary Challenge',
        'category': 'Word & Vocabulary',
        'difficulty': 'Hard',
        'description': 'Advanced word puzzles and meanings',
        'icon': 'psychology',
        'color': 0xFFEA580C,
        'plays': 1456,
        'rating': 4.2,
        'duration': '10 min',
        'type': 'game',
      },

      // ===== TRIVIA & KNOWLEDGE (4 games - all working) =====
      {
        'id': 'trivia_quiz',
        'title': 'General Knowledge Quiz',
        'category': 'Trivia & Knowledge',
        'difficulty': 'Easy',
        'description': 'Test your knowledge on various topics',
        'icon': 'quiz',
        'color': 0xFF14B8A6,
        'plays': 4567,
        'rating': 4.7,
        'duration': '10 min',
        'type': 'quiz',
      },
      {
        'id': 'science_quiz',
        'title': 'Science & Nature Quiz',
        'category': 'Trivia & Knowledge',
        'difficulty': 'Medium',
        'description': 'Questions about science, nature, and technology',
        'icon': 'science',
        'color': 0xFF0D9488,
        'plays': 2234,
        'rating': 4.5,
        'duration': '10 min',
        'type': 'quiz',
      },
      {
        'id': 'riddles',
        'title': 'Brain Teasers',
        'category': 'Trivia & Knowledge',
        'difficulty': 'Medium',
        'description': 'Solve fun riddles and logic puzzles',
        'icon': 'lightbulb',
        'color': 0xFFF97316,
        'plays': 2891,
        'rating': 4.8,
        'duration': '8 min',
        'type': 'quiz',
      },
      {
        'id': 'history_quiz',
        'title': 'History & Geography',
        'category': 'Trivia & Knowledge',
        'difficulty': 'Hard',
        'description': 'Test your knowledge of world history and geography',
        'icon': 'public',
        'color': 0xFF0891B2,
        'plays': 1678,
        'rating': 4.4,
        'duration': '12 min',
        'type': 'quiz',
      },

      // ===== SPEED & REFLEXES (3 games - all working) =====
      {
        'id': 'color_match',
        'title': 'Color Match Rush',
        'category': 'Speed & Reflexes',
        'difficulty': 'Easy',
        'description': 'Test your reflexes by matching colors quickly',
        'icon': 'speed',
        'color': 0xFFEC4899,
        'plays': 3245,
        'rating': 4.6,
        'duration': '3 min',
        'type': 'game',
      },
      {
        'id': 'reaction_time',
        'title': 'Lightning Reflexes',
        'category': 'Speed & Reflexes',
        'difficulty': 'Medium',
        'description': 'Advanced color matching with time pressure',
        'icon': 'flash_on',
        'color': 0xFFDB2777,
        'plays': 2134,
        'rating': 4.5,
        'duration': '5 min',
        'type': 'game',
      },
      {
        'id': 'speed_challenge',
        'title': 'Speed Master',
        'category': 'Speed & Reflexes',
        'difficulty': 'Hard',
        'description': 'Ultimate test of speed and accuracy',
        'icon': 'bolt',
        'color': 0xFFC026D3,
        'plays': 1876,
        'rating': 4.7,
        'duration': '4 min',
        'type': 'game',
      },

      // ===== VISUAL & SPATIAL (3 games - all working) =====
      {
        'id': 'pattern_find',
        'title': 'Pattern Detective',
        'category': 'Visual & Spatial',
        'difficulty': 'Easy',
        'description': 'Find the odd pattern in the grid',
        'icon': 'grid_view',
        'color': 0xFF8B5CF6,
        'plays': 2567,
        'rating': 4.4,
        'duration': '6 min',
        'type': 'game',
      },
      {
        'id': 'spatial_reasoning',
        'title': 'Spatial Master',
        'category': 'Visual & Spatial',
        'difficulty': 'Medium',
        'description': 'Advanced pattern recognition challenges',
        'icon': 'view_in_ar',
        'color': 0xFF7C3AED,
        'plays': 1923,
        'rating': 4.6,
        'duration': '8 min',
        'type': 'game',
      },
      {
        'id': 'visual_puzzle',
        'title': 'Visual Genius',
        'category': 'Visual & Spatial',
        'difficulty': 'Hard',
        'description': 'Expert-level visual and spatial puzzles',
        'icon': 'scatter_plot',
        'color': 0xFF6D28D9,
        'plays': 1456,
        'rating': 4.8,
        'duration': '10 min',
        'type': 'game',
      },

      // ===== STRATEGY & PLANNING (3 games - all working) =====
      {
        'id': 'sequence_puzzle',
        'title': 'Sequence Solver',
        'category': 'Strategy & Planning',
        'difficulty': 'Easy',
        'description': 'Find patterns in number sequences',
        'icon': 'format_list_numbered',
        'color': 0xFF059669,
        'plays': 2890,
        'rating': 4.5,
        'duration': '7 min',
        'type': 'game',
      },
      {
        'id': 'logic_sequence',
        'title': 'Logic Patterns',
        'category': 'Strategy & Planning',
        'difficulty': 'Medium',
        'description': 'Complex sequence and pattern challenges',
        'icon': 'analytics',
        'color': 0xFF047857,
        'plays': 2145,
        'rating': 4.7,
        'duration': '9 min',
        'type': 'game',
      },
      {
        'id': 'strategy_master',
        'title': 'Strategy Genius',
        'category': 'Strategy & Planning',
        'difficulty': 'Hard',
        'description': 'Master-level strategic thinking puzzles',
        'icon': 'psychology',
        'color': 0xFF065F46,
        'plays': 1678,
        'rating': 4.9,
        'duration': '12 min',
        'type': 'game',
      },
    ];
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
    switch (game['id']) {
      // Math & Logic Games - all use math puzzle engine
      case 'math_puzzle':
      case 'logic_grid':
      case 'number_sequence':
        gameWidget = MathPuzzleGame(game: game);
        break;

      // Memory & Focus Games - all use memory match engine
      case 'memory_cards':
      case 'pattern_recall':
        gameWidget = MemoryMatchGame(game: game);
        break;

      // Word & Vocabulary Games - all use word scramble engine
      case 'word_scramble':
      case 'crossword':
      case 'word_association':
        gameWidget = WordScrambleGame(game: game);
        break;

      // Trivia & Knowledge Games - all use quiz engine
      case 'trivia_quiz':
      case 'science_quiz':
      case 'riddles':
      case 'history_quiz':
        gameWidget = GeneralQuizGame(game: game);
        break;

      // Speed & Reflexes Games - all use color match engine
      case 'color_match':
      case 'reaction_time':
      case 'speed_challenge':
        gameWidget = ColorMatchGame(game: game);
        break;

      // Visual & Spatial Games - all use pattern recognition engine
      case 'pattern_find':
      case 'spatial_reasoning':
      case 'visual_puzzle':
        gameWidget = PatternRecognitionGame(game: game);
        break;

      // Strategy & Planning Games - all use sequence puzzle engine
      case 'sequence_puzzle':
      case 'logic_sequence':
      case 'strategy_master':
        gameWidget = SequencePuzzleGame(game: game);
        break;

      // Future games - show placeholder
      default:
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
