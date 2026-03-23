// Models for the Self Assessment feature.

class ChapterRef {
  final String id;
  final String name;

  ChapterRef({required this.id, required this.name});

  factory ChapterRef.fromJson(Map<String, dynamic> j) => ChapterRef(
    id: j['_id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
  );
}

/// Represents one self-assessment document (list card).
class SelfAssessmentModel {
  final String id;
  final String title;
  final String subscriptionId;
  final List<ChapterRef> chapterIds;
  final int numberOfQuestions;
  final int questionCount;
  final int attempts;
  final double? lastPercentage;
  final DateTime? lastCompletedAt;
  final DateTime createdAt;

  SelfAssessmentModel({
    required this.id,
    required this.title,
    required this.subscriptionId,
    required this.chapterIds,
    required this.numberOfQuestions,
    required this.questionCount,
    required this.attempts,
    this.lastPercentage,
    this.lastCompletedAt,
    required this.createdAt,
  });

  factory SelfAssessmentModel.fromJson(Map<String, dynamic> j) {
    final chapters = <ChapterRef>[];
    if (j['chapterIds'] is List) {
      for (final c in (j['chapterIds'] as List)) {
        if (c is Map<String, dynamic>) {
          chapters.add(ChapterRef.fromJson(c));
        }
      }
    }
    return SelfAssessmentModel(
      id: j['_id']?.toString() ?? '',
      title: j['title']?.toString() ?? 'Self Assessment',
      subscriptionId: j['subscription']?.toString() ?? '',
      chapterIds: chapters,
      numberOfQuestions: (j['numberOfQuestions'] as num?)?.toInt() ?? 0,
      questionCount: (j['questionCount'] as num?)?.toInt() ?? 0,
      attempts: (j['attempts'] as num?)?.toInt() ?? 0,
      lastPercentage: (j['lastPercentage'] as num?)?.toDouble(),
      lastCompletedAt: j['lastCompletedAt'] != null
          ? DateTime.tryParse(j['lastCompletedAt'].toString())
          : null,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Option for a question (no isCorrect – students don't see that).
class QuestionOption {
  final String text;
  QuestionOption({required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> j) =>
      QuestionOption(text: j['text']?.toString() ?? '');
}

/// A single question sent to the student for an attempt.
class SelfAssessmentQuestion {
  final String id;
  final String questionText;
  final String answerType; // 'single' | 'multiple'
  final List<QuestionOption> options;
  final int marks;
  final String? difficulty;
  final ChapterRef? chapter;

  SelfAssessmentQuestion({
    required this.id,
    required this.questionText,
    required this.answerType,
    required this.options,
    required this.marks,
    this.difficulty,
    this.chapter,
  });

  factory SelfAssessmentQuestion.fromJson(Map<String, dynamic> j) {
    final opts = <QuestionOption>[];
    if (j['options'] is List) {
      for (final o in (j['options'] as List)) {
        if (o is Map<String, dynamic>) {
          opts.add(QuestionOption.fromJson(o));
        }
      }
    }

    ChapterRef? chapterRef;
    if (j['chapter'] is Map<String, dynamic>) {
      chapterRef = ChapterRef.fromJson(j['chapter'] as Map<String, dynamic>);
    }

    return SelfAssessmentQuestion(
      id: j['_id']?.toString() ?? '',
      questionText: j['questionText']?.toString() ?? '',
      answerType: j['answerType']?.toString() ?? 'single',
      options: opts,
      marks: (j['marks'] as num?)?.toInt() ?? 1,
      difficulty: j['difficulty']?.toString(),
      chapter: chapterRef,
    );
  }
}

/// Full self-assessment detail (with questions) returned by GET /self-assessments/:id.
class SelfAssessmentDetail {
  final String id;
  final String title;
  final String subscriptionId;
  final int numberOfQuestions;
  final List<SelfAssessmentQuestion> questions;
  final DateTime createdAt;

  SelfAssessmentDetail({
    required this.id,
    required this.title,
    required this.subscriptionId,
    required this.numberOfQuestions,
    required this.questions,
    required this.createdAt,
  });

  factory SelfAssessmentDetail.fromJson(Map<String, dynamic> j) {
    final qs = <SelfAssessmentQuestion>[];
    if (j['questions'] is List) {
      for (final q in (j['questions'] as List)) {
        if (q is Map<String, dynamic>) {
          qs.add(SelfAssessmentQuestion.fromJson(q));
        }
      }
    }
    return SelfAssessmentDetail(
      id: j['_id']?.toString() ?? '',
      title: j['title']?.toString() ?? 'Self Assessment',
      subscriptionId: j['subscription']?.toString() ?? '',
      numberOfQuestions: (j['numberOfQuestions'] as num?)?.toInt() ?? 0,
      questions: qs,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Per-question result after submission.
class QuestionResult {
  final String questionId;
  final String questionText;
  final bool isCorrect;
  final int obtainedMarks;
  final String explanation;

  QuestionResult({
    required this.questionId,
    required this.questionText,
    required this.isCorrect,
    required this.obtainedMarks,
    required this.explanation,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> j) => QuestionResult(
    questionId: j['questionId']?.toString() ?? '',
    questionText: j['questionText']?.toString() ?? '',
    isCorrect: j['isCorrect'] == true,
    obtainedMarks: (j['obtainedMarks'] as num?)?.toInt() ?? 0,
    explanation: j['explanation']?.toString() ?? '',
  );
}

/// Full result returned after POST /self-assessments/:id/submit.
class SelfAssessmentSubmitResult {
  final String selfAssessmentId;
  final double obtainedMarks;
  final double totalMarks;
  final double percentage;
  final List<QuestionResult> results;

  SelfAssessmentSubmitResult({
    required this.selfAssessmentId,
    required this.obtainedMarks,
    required this.totalMarks,
    required this.percentage,
    required this.results,
  });

  factory SelfAssessmentSubmitResult.fromJson(Map<String, dynamic> j) {
    final rs = <QuestionResult>[];
    if (j['results'] is List) {
      for (final r in (j['results'] as List)) {
        if (r is Map<String, dynamic>) {
          rs.add(QuestionResult.fromJson(r));
        }
      }
    }
    return SelfAssessmentSubmitResult(
      selfAssessmentId: j['selfAssessmentId']?.toString() ?? '',
      obtainedMarks: (j['obtainedMarks'] as num?)?.toDouble() ?? 0,
      totalMarks: (j['totalMarks'] as num?)?.toDouble() ?? 0,
      percentage: (j['percentage'] as num?)?.toDouble() ?? 0,
      results: rs,
    );
  }
}
