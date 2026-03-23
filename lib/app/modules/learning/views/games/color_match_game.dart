import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/brain_games_controller.dart';

class ColorMatchGame extends StatefulWidget {
  final Map<String, dynamic> game;

  const ColorMatchGame({super.key, required this.game});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  final BrainGamesController controller = Get.find<BrainGamesController>();
  final Random random = Random();

  int score = 0;
  int round = 1;
  int totalRounds = 10;
  bool gameStarted = false;
  bool showColors = false;
  bool waitingForInput = false;
  int correctMatches = 0;
  int incorrectMatches = 0;

  Color currentColor = Colors.blue;
  Color targetColor = Colors.blue;
  Timer? gameTimer;
  DateTime? startTime;
  int elapsedSeconds = 0;

  final List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    startGameTimer();
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          elapsedSeconds++;
        });
      }
    });
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      round = 1;
      score = 0;
      correctMatches = 0;
      incorrectMatches = 0;
    });
    playRound();
  }

  void playRound() {
    if (round > totalRounds) {
      finishGame();
      return;
    }

    setState(() {
      targetColor = colorList[random.nextInt(colorList.length)];
      showColors = false;
      waitingForInput = false;
    });

    // Show target color
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        showColors = true;
      });

      // Wait random time then show test color
      final waitTime = 1000 + random.nextInt(2000); // 1-3 seconds
      Future.delayed(Duration(milliseconds: waitTime), () {
        if (!mounted) return;
        setState(() {
          // 50% chance of matching color
          if (random.nextBool()) {
            currentColor = targetColor;
          } else {
            // Pick different color
            Color differentColor;
            do {
              differentColor = colorList[random.nextInt(colorList.length)];
            } while (differentColor == targetColor);
            currentColor = differentColor;
          }
          waitingForInput = true;
        });
      });
    });
  }

  void onUserResponse(bool userSaysMatch) {
    if (!waitingForInput) return;

    final actualMatch = currentColor == targetColor;
    final correct = userSaysMatch == actualMatch;

    setState(() {
      if (correct) {
        score += 10;
        correctMatches++;
      } else {
        incorrectMatches++;
      }
      waitingForInput = false;
      round++;
    });

    // Show feedback
    Get.snackbar(
      correct ? '✓ Correct!' : '✗ Wrong!',
      correct
          ? 'Great reflexes! +10 points'
          : 'Colors ${actualMatch ? "matched" : "didn\'t match"}',
      backgroundColor: correct ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 800),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        playRound();
      }
    });
  }

  void finishGame() {
    gameTimer?.cancel();
    final totalTime = DateTime.now().difference(startTime!).inSeconds;

    controller.saveGameResult(
      gameId: widget.game['id'],
      score: score,
      timeSpent: totalTime,
      difficulty: widget.game['difficulty'],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 28),
            SizedBox(width: 8),
            Text('Game Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Correct: $correctMatches / $totalRounds'),
            Text('Time: ${totalTime}s'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: correctMatches / totalRounds,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF10B981),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {
                score = 0;
                round = 1;
                correctMatches = 0;
                incorrectMatches = 0;
                elapsedSeconds = 0;
                startTime = DateTime.now();
              });
              startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game['title']),
        backgroundColor: Color(widget.game['color'] as int),
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⏱️ ${elapsedSeconds}s',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: !gameStarted ? _buildInstructions() : _buildGameArea(),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed_rounded,
              size: 100,
              color: Color(widget.game['color'] as int),
            ),
            const SizedBox(height: 24),
            const Text(
              'Color Match Challenge',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Play:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      '1',
                      'Remember the target color shown at the top',
                    ),
                    _buildInstructionItem(
                      '2',
                      'Wait for the test color to appear',
                    ),
                    _buildInstructionItem(
                      '3',
                      'Tap MATCH if colors are same, NO MATCH if different',
                    ),
                    _buildInstructionItem(
                      '4',
                      'Respond as quickly as possible for best score!',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Column(
      children: [
        // Score bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Color(widget.game['color'] as int).withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Round', '$round/$totalRounds'),
              _buildStatItem('Score', '$score'),
              _buildStatItem('Correct', '$correctMatches'),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Target Color:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: showColors ? targetColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Test Color:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: waitingForInput ? currentColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (waitingForInput) ...[
                    const Text(
                      'Do the colors match?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => onUserResponse(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'MATCH',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => onUserResponse(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'NO MATCH',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      'Wait for the test color...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF4444),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
