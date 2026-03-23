import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/learning/controllers/brain_games_controller.dart';

class MemoryMatchGame extends StatefulWidget {
  final Map<String, dynamic> game;

  const MemoryMatchGame({super.key, required this.game});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  final controller = Get.find<BrainGamesController>();
  late Timer _timer;
  int _secondsElapsed = 0;

  List<String> cardValues = [];
  List<bool> cardFlips = [];
  List<bool> cardMatched = [];
  int? firstCardIndex;
  int? secondCardIndex;
  int moves = 0;
  int matches = 0;
  bool canFlip = true;

  final List<String> emojis = [
    '🎮',
    '🎯',
    '🎨',
    '🎭',
    '🎪',
    '🎬',
    '🎵',
    '🎸',
    '⚽',
    '🏀',
    '🎾',
    '🏐',
    '🎳',
    '🎲',
    '♟️',
    '🎰',
  ];

  @override
  void initState() {
    super.initState();
    initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void initializeGame() {
    final selectedEmojis = (emojis.toList()..shuffle()).take(8).toList();
    cardValues = [...selectedEmojis, ...selectedEmojis]..shuffle();
    cardFlips = List.filled(16, false);
    cardMatched = List.filled(16, false);
    moves = 0;
    matches = 0;
    firstCardIndex = null;
    secondCardIndex = null;
    canFlip = true;
  }

  void onCardTap(int index) {
    if (!canFlip || cardFlips[index] || cardMatched[index]) return;

    setState(() {
      cardFlips[index] = true;

      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else if (secondCardIndex == null) {
        secondCardIndex = index;
        moves++;
        canFlip = false;

        // Check for match
        Future.delayed(const Duration(milliseconds: 1000), () {
          checkMatch();
        });
      }
    });
  }

  void checkMatch() {
    if (firstCardIndex != null && secondCardIndex != null) {
      if (cardValues[firstCardIndex!] == cardValues[secondCardIndex!]) {
        setState(() {
          cardMatched[firstCardIndex!] = true;
          cardMatched[secondCardIndex!] = true;
          matches++;

          if (matches == 8) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _showWinDialog();
            });
          }
        });
      } else {
        setState(() {
          cardFlips[firstCardIndex!] = false;
          cardFlips[secondCardIndex!] = false;
        });
      }

      setState(() {
        firstCardIndex = null;
        secondCardIndex = null;
        canFlip = true;
      });
    }
  }

  void _showWinDialog() async {
    _timer.cancel();

    // Calculate score: base 100 points, minus 2 per move, minus 1 per second
    int score = 100 - (moves * 2) - _secondsElapsed;
    if (score < 10) score = 10; // Minimum score

    // Save game result
    await controller.saveGameResult(
      gameId: widget.game['id'],
      score: score,
      timeSpent: _secondsElapsed,
      difficulty: widget.game['difficulty'],
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEC4899),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Moves: $moves',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${_formatTime(_secondsElapsed)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Back to Games'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {
                _secondsElapsed = 0;
                initializeGame();
              });
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.game['color'] as int);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: color,
        title: Text(
          widget.game['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.8)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  Icons.timer,
                  'Time: ${_formatTime(_secondsElapsed)}',
                  Colors.white,
                ),
                _buildStatChip(Icons.touch_app, 'Moves: $moves', Colors.white),
                _buildStatChip(Icons.check_circle, '$matches/8', Colors.white),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Match the pairs!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        return _buildCard(index, color);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        initializeGame();
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'New Game',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, Color color) {
    final isFlipped = cardFlips[index];
    final isMatched = cardMatched[index];

    return GestureDetector(
      onTap: () => onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isFlipped || isMatched
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isMatched ? Colors.green : color,
                    isMatched
                        ? Colors.green.shade700
                        : color.withValues(alpha: 0.8),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  (isFlipped || isMatched
                          ? (isMatched ? Colors.green : color)
                          : Colors.grey)
                      .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isFlipped || isMatched
              ? Text(cardValues[index], style: const TextStyle(fontSize: 36))
              : Icon(Icons.question_mark, size: 32, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
