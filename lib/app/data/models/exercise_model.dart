class ExerciseModel {
  final String id;
  final String title;
  final ChapterInfo chapter;
  final List<QuestionModel> questions;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseModel({
    required this.id,
    required this.title,
    required this.chapter,
    required this.questions,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      chapter: ChapterInfo.fromJson(json['chapter'] ?? {}),
      questions:
          (json['questions'] as List?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'chapter': chapter.toJson(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChapterInfo {
  final String id;
  final String name;

  ChapterInfo({required this.id, required this.name});

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class QuestionModel {
  final String id;
  final String questionText;
  final String answerType;
  final List<OptionModel> options;
  int? selectedOptionIndex; // For storing user's answer

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.answerType,
    required this.options,
    this.selectedOptionIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      questionText: json['questionText'] ?? '',
      answerType: json['answerType'] ?? 'single',
      options:
          (json['options'] as List?)
              ?.map((o) => OptionModel.fromJson(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'questionText': questionText,
      'answerType': answerType,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }

  bool get isAnswered => selectedOptionIndex != null;

  bool get isCorrect {
    if (selectedOptionIndex == null) return false;
    return options[selectedOptionIndex!].isCorrect;
  }
}

class OptionModel {
  final String id;
  final String text;
  final bool isCorrect;

  OptionModel({required this.id, required this.text, required this.isCorrect});

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'text': text, 'isCorrect': isCorrect};
  }
}
