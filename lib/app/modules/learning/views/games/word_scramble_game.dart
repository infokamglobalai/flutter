import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/learning/controllers/brain_games_controller.dart';

class WordScrambleGame extends StatefulWidget {
  final Map<String, dynamic> game;

  const WordScrambleGame({super.key, required this.game});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  final controller = Get.find<BrainGamesController>();
  late Timer _timer;
  int _secondsElapsed = 0;
  final List<Map<String, String>> words = [
    {'word': 'FLUTTER', 'hint': 'A UI framework by Google'},
    {'word': 'MOBILE', 'hint': 'Type of phone'},
    {'word': 'CODING', 'hint': 'Writing programs'},
    {'word': 'DESIGN', 'hint': 'Planning visual appearance'},
    {'word': 'LEARNING', 'hint': 'Acquiring knowledge'},
    {'word': 'EDUCATION', 'hint': 'The process of learning'},
    {'word': 'KNOWLEDGE', 'hint': 'Information and skills'},
    {'word': 'CREATIVE', 'hint': 'Using imagination'},
    {'word': 'PUZZLE', 'hint': 'Brain teaser game'},
    {'word': 'CHALLENGE', 'hint': 'Difficult task'},
  ];

  late String currentWord;
  late String scrambledWord;
  late String hint;
  String userAnswer = '';
  int score = 0;
  int questionsAnswered = 0;
  final int totalQuestions = 10;
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    loadNextWord();
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

  void loadNextWord() {
    final random = Random();
    final wordData = words[random.nextInt(words.length)];
    currentWord = wordData['word']!;
    hint = wordData['hint']!;
    scrambledWord = scrambleWord(currentWord);
    userAnswer = '';
    showResult = false;
    isCorrect = false;
  }

  String scrambleWord(String word) {
    List<String> letters = word.split('');
    letters.shuffle();
    // Make sure it's actually scrambled
    if (letters.join() == word && word.length > 1) {
      return scrambleWord(word);
    }
    return letters.join();
  }

  void checkAnswer() {
    setState(() {
      showResult = true;
      isCorrect = userAnswer.toUpperCase() == currentWord;
      if (isCorrect) score++;
      questionsAnswered++;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (questionsAnswered < totalQuestions) {
        setState(() {
          loadNextWord();
        });
      } else {
        _showFinalScore();
      }
    });
  }

  void _showFinalScore() async {
    _timer.cancel();

    // Save game result
    await controller.saveGameResult(
      gameId: widget.game['id'],
      score: score * 10,
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
                color: Color(0xFF10B981),
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
                _secondsElapsed = 0;
                loadNextWord();
              });
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
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
                  Icons.lightbulb_outline,
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
                  const Text(
                    'Unscramble the word!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Scrambled word display
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                          scrambledWord,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lightbulb, size: 16, color: color),
                              const SizedBox(width: 8),
                              Text(
                                'Hint: $hint',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Input field
                  TextField(
                    enabled: !showResult,
                    onChanged: (value) {
                      setState(() {
                        userAnswer = value;
                      });
                    },
                    onSubmitted: (_) {
                      if (userAnswer.isNotEmpty && !showResult) {
                        checkAnswer();
                      }
                    },
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your answer',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: color, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: showResult || userAnswer.isEmpty
                        ? null
                        : checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Check Answer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  if (showResult) ...[
                    const SizedBox(height: 24),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isCorrect ? 'Correct!' : 'Wrong!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 8),
                            Text(
                              'The answer was: $currentWord',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[800],
                              ),
                            ),
                          ],
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
}
