import 'dart:convert';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';

class BrainGamesStorageService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  static const String _keyGameProgress = 'brain_games_progress';
  static const String _keyGameScores = 'brain_games_scores';
  static const String _keyGameStats = 'brain_games_stats';
  static const String _keyBadges = 'brain_games_badges';
  static const String _keyAchievements = 'brain_games_achievements';
  static const String _keyStreak = 'brain_games_streak';
  static const String _keyLastPlayed = 'brain_games_last_played';

  // Save game score
  Future<void> saveGameScore({
    required String gameId,
    required int score,
    required int timeSpent,
    required String difficulty,
  }) async {
    final scores = getGameScores(gameId);

    final newScore = {
      'score': score,
      'timeSpent': timeSpent,
      'difficulty': difficulty,
      'timestamp': DateTime.now().toIso8601String(),
    };

    scores.add(newScore);

    // Keep only last 50 scores per game
    if (scores.length > 50) {
      scores.removeAt(0);
    }

    final allScores = _getAllScores();
    allScores[gameId] = scores;

    await _storage.saveString(_keyGameScores, json.encode(allScores));

    // Update stats
    await _updateStats(gameId, score, timeSpent);

    // Check for achievements
    await _checkAchievements(gameId, score);

    // Update streak
    await _updateStreak();
  }

  // Get game scores
  List<Map<String, dynamic>> getGameScores(String gameId) {
    final allScores = _getAllScores();
    final gameScores = allScores[gameId] as List<dynamic>?;

    if (gameScores == null) return [];

    return gameScores.map((s) => Map<String, dynamic>.from(s as Map)).toList();
  }

  Map<String, dynamic> _getAllScores() {
    final scoresStr = _storage.getString(_keyGameScores);
    if (scoresStr == null) return {};

    try {
      return Map<String, dynamic>.from(json.decode(scoresStr));
    } catch (e) {
      return {};
    }
  }

  // Get best score for a game
  int getBestScore(String gameId) {
    final scores = getGameScores(gameId);
    if (scores.isEmpty) return 0;

    return scores.map((s) => s['score'] as int).reduce((a, b) => a > b ? a : b);
  }

  // Get average score for a game
  double getAverageScore(String gameId) {
    final scores = getGameScores(gameId);
    if (scores.isEmpty) return 0;

    final total = scores.map((s) => s['score'] as int).reduce((a, b) => a + b);

    return total / scores.length;
  }

  // Update overall stats
  Future<void> _updateStats(String gameId, int score, int timeSpent) async {
    final stats = getStats();

    stats['totalGamesPlayed'] = (stats['totalGamesPlayed'] ?? 0) + 1;
    stats['totalScore'] = (stats['totalScore'] ?? 0) + score;
    stats['totalTimeSpent'] = (stats['totalTimeSpent'] ?? 0) + timeSpent;

    // Update per-game stats
    final gameStats = stats['perGame'] ?? {};
    final currentGameStats =
        gameStats[gameId] ?? {'played': 0, 'bestScore': 0, 'totalScore': 0};

    currentGameStats['played'] = (currentGameStats['played'] ?? 0) + 1;
    currentGameStats['totalScore'] =
        (currentGameStats['totalScore'] ?? 0) + score;

    if (score > (currentGameStats['bestScore'] ?? 0)) {
      currentGameStats['bestScore'] = score;
    }

    gameStats[gameId] = currentGameStats;
    stats['perGame'] = gameStats;

    await _storage.saveString(_keyGameStats, json.encode(stats));
  }

  // Get stats
  Map<String, dynamic> getStats() {
    final statsStr = _storage.getString(_keyGameStats);
    if (statsStr == null) {
      return {
        'totalGamesPlayed': 0,
        'totalScore': 0,
        'totalTimeSpent': 0,
        'perGame': {},
      };
    }

    try {
      return Map<String, dynamic>.from(json.decode(statsStr));
    } catch (e) {
      return {
        'totalGamesPlayed': 0,
        'totalScore': 0,
        'totalTimeSpent': 0,
        'perGame': {},
      };
    }
  }

  // Streak management
  Future<void> _updateStreak() async {
    final lastPlayedStr = _storage.getString(_keyLastPlayed);
    final now = DateTime.now();

    if (lastPlayedStr == null) {
      // First time playing
      await _storage.saveString(
        _keyStreak,
        json.encode({'count': 1, 'lastDate': now.toIso8601String()}),
      );
    } else {
      final lastPlayed = DateTime.parse(lastPlayedStr);
      final difference = now.difference(lastPlayed).inDays;

      final streakData = _getStreakData();

      if (difference == 0) {
        // Same day, no change
        return;
      } else if (difference == 1) {
        // Consecutive day, increment streak
        streakData['count'] = (streakData['count'] ?? 0) + 1;
      } else {
        // Streak broken, reset to 1
        streakData['count'] = 1;
      }

      streakData['lastDate'] = now.toIso8601String();
      await _storage.saveString(_keyStreak, json.encode(streakData));
    }

    await _storage.saveString(_keyLastPlayed, now.toIso8601String());
  }

  Map<String, dynamic> _getStreakData() {
    final streakStr = _storage.getString(_keyStreak);
    if (streakStr == null) {
      return {'count': 0, 'lastDate': DateTime.now().toIso8601String()};
    }

    try {
      return Map<String, dynamic>.from(json.decode(streakStr));
    } catch (e) {
      return {'count': 0, 'lastDate': DateTime.now().toIso8601String()};
    }
  }

  int getCurrentStreak() {
    final streakData = _getStreakData();
    return streakData['count'] ?? 0;
  }

  // Achievements
  Future<void> _checkAchievements(String gameId, int score) async {
    final achievements = getAchievements();
    final newAchievements = <Map<String, dynamic>>[];

    // Check various achievement conditions
    final stats = getStats();
    final totalGames = stats['totalGamesPlayed'] ?? 0;
    final totalScore = stats['totalScore'] ?? 0;
    final streak = getCurrentStreak();

    // First game achievement
    if (totalGames == 1 && !_hasAchievement(achievements, 'first_game')) {
      newAchievements.add({
        'id': 'first_game',
        'title': 'Getting Started',
        'description': 'Played your first brain game',
        'icon': 'emoji_events',
        'unlockedAt': DateTime.now().toIso8601String(),
      });
    }

    // Score achievements
    if (score >= 100 && !_hasAchievement(achievements, 'score_100')) {
      newAchievements.add({
        'id': 'score_100',
        'title': 'Century',
        'description': 'Scored 100 points in a single game',
        'icon': 'stars',
        'unlockedAt': DateTime.now().toIso8601String(),
      });
    }

    if (totalScore >= 1000 && !_hasAchievement(achievements, 'total_1000')) {
      newAchievements.add({
        'id': 'total_1000',
        'title': 'Point Collector',
        'description': 'Earned 1000 total points',
        'icon': 'workspace_premium',
        'unlockedAt': DateTime.now().toIso8601String(),
      });
    }

    // Streak achievements
    if (streak >= 7 && !_hasAchievement(achievements, 'streak_7')) {
      newAchievements.add({
        'id': 'streak_7',
        'title': 'Week Warrior',
        'description': 'Played for 7 consecutive days',
        'icon': 'local_fire_department',
        'unlockedAt': DateTime.now().toIso8601String(),
      });
    }

    // Game count achievements
    if (totalGames >= 10 && !_hasAchievement(achievements, 'games_10')) {
      newAchievements.add({
        'id': 'games_10',
        'title': 'Enthusiast',
        'description': 'Played 10 brain games',
        'icon': 'psychology',
        'unlockedAt': DateTime.now().toIso8601String(),
      });
    }

    if (newAchievements.isNotEmpty) {
      achievements.addAll(newAchievements);
      await _storage.saveString(_keyAchievements, json.encode(achievements));
    }
  }

  bool _hasAchievement(List<Map<String, dynamic>> achievements, String id) {
    return achievements.any((a) => a['id'] == id);
  }

  List<Map<String, dynamic>> getAchievements() {
    final achievementsStr = _storage.getString(_keyAchievements);
    if (achievementsStr == null) return [];

    try {
      final list = json.decode(achievementsStr) as List;
      return list.map((a) => Map<String, dynamic>.from(a)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get badges based on achievements
  List<Map<String, dynamic>> getBadges() {
    // No need to check achievements for badges as they're level-based
    final stats = getStats();
    final badges = <Map<String, dynamic>>[];

    // Level-based badges
    final totalGames = stats['totalGamesPlayed'] ?? 0;
    if (totalGames >= 1) {
      badges.add({'name': 'Beginner', 'icon': 'grade', 'color': 0xFF9CA3AF});
    }
    if (totalGames >= 10) {
      badges.add({'name': 'Enthusiast', 'icon': 'star', 'color': 0xFF3B82F6});
    }
    if (totalGames >= 25) {
      badges.add({'name': 'Advanced', 'icon': 'stars', 'color': 0xFF8B5CF6});
    }
    if (totalGames >= 50) {
      badges.add({
        'name': 'Expert',
        'icon': 'workspace_premium',
        'color': 0xFFF59E0B,
      });
    }
    if (totalGames >= 100) {
      badges.add({
        'name': 'Master',
        'icon': 'emoji_events',
        'color': 0xFFEF4444,
      });
    }

    return badges;
  }

  // Get player rank
  String getPlayerRank() {
    final stats = getStats();
    final totalGames = stats['totalGamesPlayed'] ?? 0;

    if (totalGames >= 100) return 'Master';
    if (totalGames >= 50) return 'Expert';
    if (totalGames >= 25) return 'Advanced';
    if (totalGames >= 10) return 'Enthusiast';
    if (totalGames >= 1) return 'Beginner';
    return 'Newcomer';
  }

  String getNextRank() {
    final rank = getPlayerRank();

    switch (rank) {
      case 'Newcomer':
        return 'Beginner';
      case 'Beginner':
        return 'Enthusiast';
      case 'Enthusiast':
        return 'Advanced';
      case 'Advanced':
        return 'Expert';
      case 'Expert':
        return 'Master';
      case 'Master':
        return 'Legend';
      default:
        return 'Beginner';
    }
  }

  double getProgressToNextRank() {
    final stats = getStats();
    final totalGames = stats['totalGamesPlayed'] ?? 0;

    if (totalGames >= 100) return 1.0; // Max rank
    if (totalGames >= 50) return (totalGames - 50) / 50.0;
    if (totalGames >= 25) return (totalGames - 25) / 25.0;
    if (totalGames >= 10) return (totalGames - 10) / 15.0;
    if (totalGames >= 1) return (totalGames - 1) / 9.0;
    return 0.0;
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    await _storage.remove(_keyGameProgress);
    await _storage.remove(_keyGameScores);
    await _storage.remove(_keyGameStats);
    await _storage.remove(_keyBadges);
    await _storage.remove(_keyAchievements);
    await _storage.remove(_keyStreak);
    await _storage.remove(_keyLastPlayed);
  }
}
