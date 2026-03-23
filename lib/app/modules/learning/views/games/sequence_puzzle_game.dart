import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/brain_games_controller.dart';

class SequencePuzzleGame extends StatefulWidget {
  final Map<String, dynamic> game;

  const SequencePuzzleGame({super.key, required this.game});

  @override
  State<SequencePuzzleGame> createState() => _SequencePuzzleGameState();
}

class _SequencePuzzleGameState extends State<SequencePuzzleGame> {
  final BrainGamesController controller = Get.find<BrainGamesController>();
  final Random random = Random();

  int score = 0;
  int currentPuzzle = 0;
  int totalPuzzles = 8;
  bool gameStarted = false;
  int correctAnswers = 0;

  List<int> sequence = [];
  int missingIndex = 0;
  int correctAnswer = 0;
  List<int> options = [];
  int? selectedOption;
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
      currentPuzzle = 0;
      score = 0;
      correctAnswers = 0;
    });
    generatePuzzle();
  }

  void generatePuzzle() {
    if (currentPuzzle >= totalPuzzles) {
      finishGame();
      return;
    }

    final puzzleType = random.nextInt(4);

    switch (puzzleType) {
      case 0: // Arithmetic sequence
        _generateArithmeticSequence();
        break;
      case 1: // Geometric sequence
        _generateGeometricSequence();
        break;
      case 2: // Fibonacci-like
        _generateFibonacciSequence();
        break;
      case 3: // Square/cube numbers
        _generatePowerSequence();
        break;
    }

    setState(() {
      selectedOption = null;
      showFeedback = false;
    });
  }

  void _generateArithmeticSequence() {
    final start = random.nextInt(20) + 1;
    final diff = random.nextInt(7) + 2;
    sequence = List.generate(6, (i) => start + i * diff);
    missingIndex = random.nextInt(4) + 1; // Not first or last
    correctAnswer = sequence[missingIndex];
    _generateOptions();
  }

  void _generateGeometricSequence() {
    final start = random.nextInt(5) + 2;
    final ratio = random.nextInt(2) + 2;
    sequence = List.generate(5, (i) => start * pow(ratio, i).toInt());
    missingIndex = random.nextInt(3) + 1;
    correctAnswer = sequence[missingIndex];
    _generateOptions();
  }

  void _generateFibonacciSequence() {
    final a = random.nextInt(5) + 1;
    final b = random.nextInt(5) + 1;
    sequence = [a, b];
    for (int i = 0; i < 4; i++) {
      sequence.add(
        sequence[sequence.length - 1] + sequence[sequence.length - 2],
      );
    }
    missingIndex = random.nextInt(4) + 1;
    correctAnswer = sequence[missingIndex];
    _generateOptions();
  }

  void _generatePowerSequence() {
    final power = random.nextBool() ? 2 : 3; // squares or cubes
    sequence = List.generate(5, (i) => pow(i + 1, power).toInt());
    missingIndex = random.nextInt(3) + 1;
    correctAnswer = sequence[missingIndex];
    _generateOptions();
  }

  void _generateOptions() {
    options = [correctAnswer];
    while (options.length < 4) {
      final offset = random.nextInt(20) - 10;
      final option = correctAnswer + offset;
      if (!options.contains(option) && option > 0) {
        options.add(option);
      }
    }
    options.shuffle();
  }

  void onOptionTap(int option) {
    if (showFeedback) return;

    setState(() {
      selectedOption = option;
      showFeedback = true;
    });

    final correct = option == correctAnswer;
    if (correct) {
      score += 12;
      correctAnswers++;
    }

    Get.snackbar(
      correct ? '✓ Correct!' : '✗ Wrong!',
      correct
          ? 'Excellent pattern recognition! +12 points'
          : 'The answer was $correctAnswer',
      backgroundColor: correct ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 1200),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          currentPuzzle++;
        });
        generatePuzzle();
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
            Text('Correct: $correctAnswers / $totalPuzzles'),
            Text('Time: ${totalTime}s'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: correctAnswers / totalPuzzles,
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
                currentPuzzle = 0;
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
              Icons.format_list_numbered_rounded,
              size: 100,
              color: Color(widget.game['color'] as int),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sequence Puzzles',
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
                    _buildInstructionItem('1', 'Look at the number sequence'),
                    _buildInstructionItem(
                      '2',
                      'Find the pattern (arithmetic, geometric, etc.)',
                    ),
                    _buildInstructionItem('3', 'Fill in the missing number'),
                    _buildInstructionItem(
                      '4',
                      'Master logical thinking and earn points!',
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
              _buildStatItem('Puzzle', '${currentPuzzle + 1}/$totalPuzzles'),
              _buildStatItem('Score', '$score'),
              _buildStatItem('Correct', '$correctAnswers'),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Find the missing number:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(sequence.length, (index) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: index == missingIndex
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: index == missingIndex
                                ? Colors.orange
                                : Colors.grey[300]!,
                            width: index == missingIndex ? 3 : 1,
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
                          child: Text(
                            index == missingIndex
                                ? '?'
                                : sequence[index].toString(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: index == missingIndex
                                  ? Colors.orange
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Choose the answer:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: options.map((option) {
                      final isSelected = selectedOption == option;
                      final isCorrect = option == correctAnswer;
                      final showCorrectHighlight = showFeedback && isCorrect;
                      final showIncorrectHighlight =
                          showFeedback && isSelected && !isCorrect;

                      return InkWell(
                        onTap: () => onOptionTap(option),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: showCorrectHighlight
                                ? Colors.green.withOpacity(0.2)
                                : showIncorrectHighlight
                                ? Colors.red.withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: showCorrectHighlight
                                  ? Colors.green
                                  : showIncorrectHighlight
                                  ? Colors.red
                                  : Colors.grey[300]!,
                              width:
                                  showCorrectHighlight || showIncorrectHighlight
                                  ? 3
                                  : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              option.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: showCorrectHighlight
                                    ? Colors.green
                                    : showIncorrectHighlight
                                    ? Colors.red
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
