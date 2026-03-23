import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/brain_games_controller.dart';

class PatternRecognitionGame extends StatefulWidget {
  final Map<String, dynamic> game;

  const PatternRecognitionGame({super.key, required this.game});

  @override
  State<PatternRecognitionGame> createState() => _PatternRecognitionGameState();
}

class _PatternRecognitionGameState extends State<PatternRecognitionGame> {
  final BrainGamesController controller = Get.find<BrainGamesController>();
  final Random random = Random();

  int score = 0;
  int currentQuestion = 0;
  int totalQuestions = 10;
  bool gameStarted = false;
  int correctAnswers = 0;

  List<PatternItem> patterns = [];
  int? differentIndex;
  int? selectedIndex;
  bool showFeedback = false;

  Timer? gameTimer;
  DateTime? startTime;
  int elapsedSeconds = 0;

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
      currentQuestion = 0;
      score = 0;
      correctAnswers = 0;
    });
    generatePattern();
  }

  void generatePattern() {
    if (currentQuestion >= totalQuestions) {
      finishGame();
      return;
    }

    // Generate 9 patterns (3x3 grid)
    final baseShape = random.nextInt(3); // 0=circle, 1=square, 2=triangle
    final baseColor = Colors.primaries[random.nextInt(Colors.primaries.length)];
    final baseSize = 60.0 + random.nextInt(20);

    patterns = List.generate(9, (index) {
      return PatternItem(shape: baseShape, color: baseColor, size: baseSize);
    });

    // Make one pattern different
    differentIndex = random.nextInt(9);

    // Change one attribute of the different pattern
    final changeType = random.nextInt(3);
    switch (changeType) {
      case 0: // Change shape
        patterns[differentIndex!] = PatternItem(
          shape: (baseShape + 1) % 3,
          color: baseColor,
          size: baseSize,
        );
        break;
      case 1: // Change color
        Color differentColor;
        do {
          differentColor =
              Colors.primaries[random.nextInt(Colors.primaries.length)];
        } while (differentColor == baseColor);
        patterns[differentIndex!] = PatternItem(
          shape: baseShape,
          color: differentColor,
          size: baseSize,
        );
        break;
      case 2: // Change size
        patterns[differentIndex!] = PatternItem(
          shape: baseShape,
          color: baseColor,
          size: baseSize + 15,
        );
        break;
    }

    setState(() {
      selectedIndex = null;
      showFeedback = false;
    });
  }

  void onPatternTap(int index) {
    if (showFeedback) return;

    setState(() {
      selectedIndex = index;
      showFeedback = true;
    });

    final correct = index == differentIndex;
    if (correct) {
      score += 10;
      correctAnswers++;
    }

    Get.snackbar(
      correct ? '✓ Correct!' : '✗ Wrong!',
      correct
          ? 'Great observation! +10 points'
          : 'Try to spot the difference faster',
      backgroundColor: correct ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 1000),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          currentQuestion++;
        });
        generatePattern();
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
            Text('Correct: $correctAnswers / $totalQuestions'),
            Text('Time: ${totalTime}s'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: correctAnswers / totalQuestions,
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
                currentQuestion = 0;
                score = 0;
                correctAnswers = 0;
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
              Icons.grid_view_rounded,
              size: 100,
              color: Color(widget.game['color'] as int),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pattern Recognition',
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
                      'Look at the 3x3 grid of patterns',
                    ),
                    _buildInstructionItem(
                      '2',
                      'Find the ONE pattern that is different',
                    ),
                    _buildInstructionItem(
                      '3',
                      'It could differ in shape, color, or size',
                    ),
                    _buildInstructionItem(
                      '4',
                      'Tap on the different pattern to score points!',
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
        Container(
          padding: const EdgeInsets.all(16),
          color: Color(widget.game['color'] as int).withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Question',
                '${currentQuestion + 1}/$totalQuestions',
              ),
              _buildStatItem('Score', '$score'),
              _buildStatItem('Correct', '$correctAnswers'),
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
                    'Find the different pattern:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => onPatternTap(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: showFeedback && index == selectedIndex
                                  ? (index == differentIndex
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2))
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: showFeedback && index == differentIndex
                                    ? Colors.green
                                    : Colors.grey[300]!,
                                width: showFeedback && index == differentIndex
                                    ? 3
                                    : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _buildPattern(patterns[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPattern(PatternItem item) {
    switch (item.shape) {
      case 0: // Circle
        return Container(
          width: item.size,
          height: item.size,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        );
      case 1: // Square
        return Container(
          width: item.size,
          height: item.size,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case 2: // Triangle
        return CustomPaint(
          size: Size(item.size, item.size),
          painter: TrianglePainter(item.color),
        );
      default:
        return const SizedBox();
    }
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

class PatternItem {
  final int shape; // 0=circle, 1=square, 2=triangle
  final Color color;
  final double size;

  PatternItem({required this.shape, required this.color, required this.size});
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
