import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/learning/controllers/brain_games_controller.dart';

class GeneralQuizGame extends StatefulWidget {
  final Map<String, dynamic> game;

  const GeneralQuizGame({super.key, required this.game});

  @override
  State<GeneralQuizGame> createState() => _GeneralQuizGameState();
}

class _GeneralQuizGameState extends State<GeneralQuizGame> {
  final controller = Get.find<BrainGamesController>();
  late Timer _timer;
  int _secondsElapsed = 0;
  int _score = 0;
  int _currentQuestion = 0;
  final int _totalQuestions = 10;

  late Map<String, dynamic> _currentQ;
  String? _selectedAnswer;
  bool _isAnswered = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Paris', 'Berlin', 'Madrid'],
      'answer': 'Paris',
      'category': 'Geography',
    },
    {
      'question': 'What is 7 × 8?',
      'options': ['54', '56', '58', '64'],
      'answer': '56',
      'category': 'Math',
    },
    {
      'question': 'Who wrote Romeo and Juliet?',
      'options': [
        'Charles Dickens',
        'William Shakespeare',
        'Jane Austen',
        'Mark Twain',
      ],
      'answer': 'William Shakespeare',
      'category': 'Literature',
    },
    {
      'question': 'What is the largest planet in our solar system?',
      'options': ['Earth', 'Mars', 'Jupiter', 'Saturn'],
      'answer': 'Jupiter',
      'category': 'Science',
    },
    {
      'question': 'What year did World War II end?',
      'options': ['1943', '1944', '1945', '1946'],
      'answer': '1945',
      'category': 'History',
    },
    {
      'question': 'What is the chemical symbol for gold?',
      'options': ['Go', 'Gd', 'Au', 'Ag'],
      'answer': 'Au',
      'category': 'Science',
    },
    {
      'question': 'How many continents are there?',
      'options': ['5', '6', '7', '8'],
      'answer': '7',
      'category': 'Geography',
    },
    {
      'question': 'What is the largest ocean on Earth?',
      'options': ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
      'answer': 'Pacific',
      'category': 'Geography',
    },
    {
      'question': 'Who painted the Mona Lisa?',
      'options': [
        'Vincent van Gogh',
        'Leonardo da Vinci',
        'Pablo Picasso',
        'Michelangelo',
      ],
      'answer': 'Leonardo da Vinci',
      'category': 'Art',
    },
    {
      'question': 'What is the speed of light?',
      'options': [
        '300,000 km/s',
        '150,000 km/s',
        '450,000 km/s',
        '200,000 km/s',
      ],
      'answer': '300,000 km/s',
      'category': 'Science',
    },
    {
      'question': 'What is the smallest prime number?',
      'options': ['0', '1', '2', '3'],
      'answer': '2',
      'category': 'Math',
    },
    {
      'question': 'In which country is the Great Pyramid of Giza?',
      'options': ['Egypt', 'Mexico', 'Peru', 'China'],
      'answer': 'Egypt',
      'category': 'Geography',
    },
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
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

  void _generateQuestion() {
    final random = Random();
    setState(() {
      _isAnswered = false;
      _selectedAnswer = null;
      _currentQ = _questions[random.nextInt(_questions.length)];
    });
  }

  void _checkAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;

      if (answer == _currentQ['answer']) {
        _score += 10;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_currentQuestion < _totalQuestions - 1) {
        setState(() {
          _currentQuestion++;
        });
        _generateQuestion();
      } else {
        _finishGame();
      }
    });
  }

  Future<void> _finishGame() async {
    _timer.cancel();

    await controller.saveGameResult(
      gameId: widget.game['id'],
      score: _score,
      timeSpent: _secondsElapsed,
      difficulty: widget.game['difficulty'],
    );

    _showResultDialog();
  }

  void _showResultDialog() {
    final percentage = (_score / (_totalQuestions * 10) * 100).toInt();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              percentage >= 70 ? Icons.emoji_events : Icons.sentiment_satisfied,
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
              'Your Score: $_score/${_totalQuestions * 10}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: $percentage%',
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
                _currentQuestion = 0;
                _score = 0;
                _secondsElapsed = 0;
                _isAnswered = false;
              });
              _generateQuestion();
              _startTimer();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.game['color'] as int);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game['title']),
        backgroundColor: color,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_secondsElapsed),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestion + 1}/$_totalQuestions',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Score: $_score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentQuestion + 1) / _totalQuestions,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _currentQ['category'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentQ['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Options
                    ...(_currentQ['options'] as List<String>).map((option) {
                      final isSelected = _selectedAnswer == option;
                      final isCorrect = option == _currentQ['answer'];

                      Color getColor() {
                        if (!_isAnswered) return Colors.white;
                        if (isSelected && isCorrect)
                          return Colors.green.shade50;
                        if (isSelected && !isCorrect) return Colors.red.shade50;
                        if (isCorrect) return Colors.green.shade50;
                        return Colors.grey.shade100;
                      }

                      Color getBorderColor() {
                        if (!_isAnswered) return Colors.grey.shade300;
                        if (isSelected && isCorrect) return Colors.green;
                        if (isSelected && !isCorrect) return Colors.red;
                        if (isCorrect) return Colors.green;
                        return Colors.grey.shade300;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _checkAnswer(option),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: getColor(),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: getBorderColor(),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_isAnswered && isCorrect)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  )
                                else if (_isAnswered &&
                                    isSelected &&
                                    !isCorrect)
                                  const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 24,
                                  )
                                else
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _isAnswered && isCorrect
                                          ? Colors.green.shade900
                                          : _isAnswered &&
                                                isSelected &&
                                                !isCorrect
                                          ? Colors.red.shade900
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
