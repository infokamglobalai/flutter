import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/learning/controllers/brain_games_controller.dart';

class MathPuzzleGame extends StatefulWidget {
  final Map<String, dynamic> game;

  const MathPuzzleGame({super.key, required this.game});

  @override
  State<MathPuzzleGame> createState() => _MathPuzzleGameState();
}

class _MathPuzzleGameState extends State<MathPuzzleGame> {
  final controller = Get.find<BrainGamesController>();
  late Timer _timer;
  int _secondsElapsed = 0;

  late int num1;
  late int num2;
  late String operation;
  late int correctAnswer;
  int? selectedAnswer;
  List<int> options = [];
  int score = 0;
  int questionsAnswered = 0;
  final int totalQuestions = 10;
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    generateQuestion();
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

  void generateQuestion() {
    final random = Random();
    final operations = ['+', '-', '×', '÷'];
    operation = operations[random.nextInt(operations.length)];

    switch (operation) {
      case '+':
        num1 = random.nextInt(50) + 1;
        num2 = random.nextInt(50) + 1;
        correctAnswer = num1 + num2;
        break;
      case '-':
        num1 = random.nextInt(50) + 20;
        num2 = random.nextInt(num1);
        correctAnswer = num1 - num2;
        break;
      case '×':
        num1 = random.nextInt(12) + 1;
        num2 = random.nextInt(12) + 1;
        correctAnswer = num1 * num2;
        break;
      case '÷':
        num2 = random.nextInt(10) + 2;
        correctAnswer = random.nextInt(15) + 1;
        num1 = num2 * correctAnswer;
        break;
    }

    generateOptions();
  }

  void generateOptions() {
    options.clear();
    options.add(correctAnswer);
    final random = Random();

    while (options.length < 4) {
      int wrongAnswer = correctAnswer + random.nextInt(20) - 10;
      if (wrongAnswer > 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle();
  }

  void checkAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == correctAnswer;
      if (isCorrect) score++;
      questionsAnswered++;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (questionsAnswered < totalQuestions) {
        setState(() {
          showResult = false;
          selectedAnswer = null;
          generateQuestion();
        });
      } else {
        _showFinalScore();
      }
    });
  }

  void _showFinalScore() async {
    _timer.cancel();

    // Save game result to storage
    await controller.saveGameResult(
      gameId: widget.game['id'],
      score: score * 10, // 10 points per correct answer
      timeSpent: _secondsElapsed,
      difficulty: widget.game['difficulty'],
    );

    final percentage = (score / totalQuestions * 100).round();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              percentage >= 70 ? Icons.emoji_events : Icons.thumb_up,
              size: 64,
              color: percentage >= 70 ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              percentage >= 70 ? 'Excellent!' : 'Good Try!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You scored',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '$score/$totalQuestions',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% Correct',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'Time: ${_formatTime(_secondsElapsed)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                score = 0;
                questionsAnswered = 0;
                showResult = false;
                selectedAnswer = null;
                _secondsElapsed = 0;
                generateQuestion();
              });
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
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
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_secondsElapsed),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$questionsAnswered/$totalQuestions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Score bar
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
                  Icons.emoji_events,
                  'Score: $score',
                  Colors.white,
                ),
                _buildStatChip(
                  Icons.flash_on,
                  'Question ${questionsAnswered + 1}',
                  Colors.white,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Question card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'What is',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$num1 $operation $num2',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '?',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Options
                  ...options.map((option) => _buildOptionButton(option, color)),

                  if (showResult) ...[
                    const SizedBox(height: 24),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isCorrect
                                ? 'Correct!'
                                : 'Wrong! Answer: $correctAnswer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildOptionButton(int option, Color color) {
    final isSelected = selectedAnswer == option;
    final isCorrectOption = option == correctAnswer;

    Color buttonColor = Colors.white;
    Color borderColor = Colors.grey[300]!;

    if (showResult && isSelected) {
      buttonColor = isCorrect ? Colors.green[50]! : Colors.red[50]!;
      borderColor = isCorrect ? Colors.green : Colors.red;
    } else if (showResult && isCorrectOption) {
      buttonColor = Colors.green[50]!;
      borderColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showResult ? null : () => checkAnswer(option),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                if (!showResult)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '$option',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: showResult && (isSelected || isCorrectOption)
                      ? (isCorrectOption ? Colors.green[800] : Colors.red[800])
                      : color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
