/// Aggregates [GET /progress/me] payload — same shape as eduai-frontend progress service.
class StudentProgressStats {
  const StudentProgressStats({
    required this.completedChapters,
    required this.totalChapters,
    required this.chapterAssessmentsCount,
    required this.selfAssessmentsCount,
    required this.mocktestAttemptsCount,
    required this.averageScorePercent,
    required this.chapterVideoProgressPercent,
  });

  final int completedChapters;
  final int totalChapters;

  /// Chapter content assessments (with at least one attempt).
  final int chapterAssessmentsCount;

  final int selfAssessmentsCount;
  final int mocktestAttemptsCount;

  /// Rounded 0–100 from chapter + self + mock percentages.
  final int averageScorePercent;

  /// Share of chapters with video completed (0–100).
  final double chapterVideoProgressPercent;

  /// Total "quiz-like" activities (aligns with web analytics use).
  int get totalQuizLikeAttempts =>
      chapterAssessmentsCount + selfAssessmentsCount + mocktestAttemptsCount;

  static StudentProgressStats empty() => const StudentProgressStats(
        completedChapters: 0,
        totalChapters: 0,
        chapterAssessmentsCount: 0,
        selfAssessmentsCount: 0,
        mocktestAttemptsCount: 0,
        averageScorePercent: 0,
        chapterVideoProgressPercent: 0,
      );

  /// Parse backend `data` object from `/api/progress/me`.
  static StudentProgressStats fromProgressPayload(Map<String, dynamic> data) {
    final packages = data['packages'] as List<dynamic>? ?? [];
    final mocktests = data['mocktests'] as List<dynamic>? ?? [];

    int totalChapters = 0;
    int completedChapters = 0;
    int chapterAssessmentsCount = 0;
    int selfAssessmentsCount = 0;
    double scoreSum = 0;
    int scoreCount = 0;

    for (final package in packages) {
      final chapters = package['chapters'] as List<dynamic>? ?? [];
      for (final chapter in chapters) {
        totalChapters++;
        if (chapter['videoCompleted'] == true) {
          completedChapters++;
        }
        final assessment = chapter['assessment'];
        if (assessment != null && ((assessment['attempts'] ?? 0) as num) > 0) {
          chapterAssessmentsCount++;
          scoreSum += ((assessment['percentage'] ?? 0) as num).toDouble();
          scoreCount++;
        }
      }
      final selfList = package['selfAssessments'] as List<dynamic>? ?? [];
      for (final s in selfList) {
        selfAssessmentsCount++;
        scoreSum += ((s['percentage'] ?? 0) as num).toDouble();
        scoreCount++;
      }
    }

    final mocktestAttemptsCount = mocktests.length;
    for (final m in mocktests) {
      scoreSum += ((m['percentage'] ?? 0) as num).toDouble();
      scoreCount++;
    }

    final avg = scoreCount > 0 ? (scoreSum / scoreCount).round().clamp(0, 100) : 0;
    final videoPct = totalChapters > 0
        ? (completedChapters / totalChapters) * 100.0
        : 0.0;

    return StudentProgressStats(
      completedChapters: completedChapters,
      totalChapters: totalChapters,
      chapterAssessmentsCount: chapterAssessmentsCount,
      selfAssessmentsCount: selfAssessmentsCount,
      mocktestAttemptsCount: mocktestAttemptsCount,
      averageScorePercent: avg,
      chapterVideoProgressPercent: videoPct,
    );
  }
}
