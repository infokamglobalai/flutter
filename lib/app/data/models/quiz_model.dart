class QuizModel {
  final String id;
  final String chapterId;
  final String title;
  final String description;
  final int timeLimit; // in minutes
  final int totalMarks;
  final int passingMarks;
  final List<QuestionModel> questions;
  final bool isActive;

  QuizModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.timeLimit,
    required this.totalMarks,
    required this.passingMarks,
    required this.questions,
    required this.isActive,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeLimit: json['time_limit'] ?? 30,
      totalMarks: json['total_marks'] ?? 0,
      passingMarks: json['passing_marks'] ?? 0,
      questions:
          (json['questions'] as List?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'title': title,
      'description': description,
      'time_limit': timeLimit,
      'total_marks': totalMarks,
      'passing_marks': passingMarks,
      'questions': questions.map((q) => q.toJson()).toList(),
      'is_active': isActive,
    };
  }
}

class QuestionModel {
  final String id;
  final String questionText;
  final String type; // mcq, true_false, descriptive
  final List<AnswerOptionModel> options;
  final int marks;
  final String? correctAnswer;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.type,
    required this.options,
    required this.marks,
    this.correctAnswer,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      questionText: json['question_text'] ?? '',
      type: json['type'] ?? 'mcq',
      options:
          (json['options'] as List?)
              ?.map((o) => AnswerOptionModel.fromJson(o))
              .toList() ??
          [],
      marks: json['marks'] ?? 1,
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'type': type,
      'options': options.map((o) => o.toJson()).toList(),
      'marks': marks,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class AnswerOptionModel {
  final String id;
  final String text;
  final bool isCorrect;

  AnswerOptionModel({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'is_correct': isCorrect};
  }
}

class QuizResultModel {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final int totalMarks;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final int timeTaken; // in seconds
  final bool isPassed;
  final DateTime submittedAt;
  final List<UserAnswerModel> userAnswers;

  QuizResultModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalMarks,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.timeTaken,
    required this.isPassed,
    required this.submittedAt,
    required this.userAnswers,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      quizId: json['quiz_id'] ?? '',
      score: json['score'] ?? 0,
      totalMarks: json['total_marks'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      wrongAnswers: json['wrong_answers'] ?? 0,
      skippedAnswers: json['skipped_answers'] ?? 0,
      timeTaken: json['time_taken'] ?? 0,
      isPassed: json['is_passed'] ?? false,
      submittedAt: DateTime.parse(
        json['submitted_at'] ?? DateTime.now().toIso8601String(),
      ),
      userAnswers:
          (json['user_answers'] as List?)
              ?.map((a) => UserAnswerModel.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'total_marks': totalMarks,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'skipped_answers': skippedAnswers,
      'time_taken': timeTaken,
      'is_passed': isPassed,
      'submitted_at': submittedAt.toIso8601String(),
      'user_answers': userAnswers.map((a) => a.toJson()).toList(),
    };
  }

  double get percentage => (score / totalMarks) * 100;
}

class UserAnswerModel {
  final String questionId;
  final String? selectedAnswer;
  final bool isCorrect;

  UserAnswerModel({
    required this.questionId,
    this.selectedAnswer,
    required this.isCorrect,
  });

  factory UserAnswerModel.fromJson(Map<String, dynamic> json) {
    return UserAnswerModel(
      questionId: json['question_id'] ?? '',
      selectedAnswer: json['selected_answer'],
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_answer': selectedAnswer,
      'is_correct': isCorrect,
    };
  }
}
