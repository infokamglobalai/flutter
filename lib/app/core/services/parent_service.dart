import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/api_service.dart';

class ParentService {
  final ApiService _apiService = Get.find<ApiService>();

  /// GET /api/auth/me/students
  /// Returns list of linked students for the authenticated parent.
  Future<Map<String, dynamic>> getMyStudents() async {
    final response = await _apiService.get(ApiConstants.parentStudents);
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/referral
  /// Sends a referral invitation email to a friend on behalf of the authenticated parent.
  Future<Map<String, dynamic>> sendReferral({
    required String name,
    required String email,
    String? phone,
  }) async {
    final body = <String, dynamic>{'name': name, 'email': email};
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    final response = await _apiService.post(
      ApiConstants.sendReferral,
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/parent-resources/public
  /// Returns publicly available parent resources (videos and documents).
  Future<Map<String, dynamic>> getParentResources() async {
    final response = await _apiService.get(ApiConstants.parentResources);
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/auth/me/students/:studentId/progress
  /// Returns full learning progress for a specific student.
  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    final response = await _apiService.get(
      '${ApiConstants.parentStudents}/$studentId/progress',
    );
    return response.data as Map<String, dynamic>;
  }

  /// Compute aggregate stats from the progress payload returned by [getStudentProgress].
  static Map<String, dynamic> computeStats(Map<String, dynamic> progressData) {
    final packages = ((progressData['packages'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

    int videosWatched = 0;
    int totalVideos = 0;
    int assessmentsCompleted = 0;
    int totalAssessmentChapters = 0;
    int selfAssessmentsCompleted = 0;

    double scoreSum = 0;
    int scoreCount = 0;

    final List<Map<String, dynamic>> recentAssessments = [];

    for (final pkg in packages) {
      final chapters = ((pkg['chapters'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
      final selfAssessments = ((pkg['selfAssessments'] as List?) ?? [])
          .cast<Map<String, dynamic>>();

      totalVideos += chapters.length;

      for (final ch in chapters) {
        if (ch['videoCompleted'] == true) videosWatched++;

        final assessment = ch['assessment'] as Map<String, dynamic>?;
        totalAssessmentChapters++;
        if (assessment != null) {
          assessmentsCompleted++;
          final pct = (assessment['percentage'] as num?)?.toDouble() ?? 0.0;
          scoreSum += pct;
          scoreCount++;

          recentAssessments.add({
            'subject': ch['subjectName'] ?? 'Subject',
            'chapter': ch['chapterName'] ?? '',
            'score': (assessment['lastScore'] as num?)?.toInt() ?? 0,
            'percentage': pct,
            'totalMarks': (assessment['totalMarks'] as num?)?.toInt() ?? 0,
            'date': assessment['lastAttemptAt']?.toString() ?? '',
          });
        }
      }

      selfAssessmentsCompleted += selfAssessments.length;

      for (final sa in selfAssessments) {
        final pct = (sa['percentage'] as num?)?.toDouble() ?? 0.0;
        scoreSum += pct;
        scoreCount++;
        recentAssessments.add({
          'subject': 'Self Assessment',
          'chapter': sa['title'] ?? 'Test',
          'score': (sa['obtainedMarks'] as num?)?.toInt() ?? 0,
          'percentage': pct,
          'totalMarks': (sa['totalMarks'] as num?)?.toInt() ?? 0,
          'date': sa['completedAt']?.toString() ?? '',
        });
      }
    }

    final double avgScore = scoreCount > 0 ? scoreSum / scoreCount : 0.0;
    final String performance = avgScore >= 80
        ? 'excellent'
        : avgScore >= 60
        ? 'good'
        : 'needs-improvement';

    // Sort by date desc and take latest 5
    recentAssessments.sort((a, b) {
      if (a['date'].toString().isEmpty) return 1;
      if (b['date'].toString().isEmpty) return -1;
      return b['date'].toString().compareTo(a['date'].toString());
    });

    return {
      'videosWatched': videosWatched,
      'totalVideos': totalVideos,
      'assessmentsCompleted': assessmentsCompleted,
      'totalAssessmentChapters': totalAssessmentChapters,
      'selfAssessmentsCompleted': selfAssessmentsCompleted,
      'averageScore': avgScore.round(),
      'performance': performance,
      'recentAssessments': recentAssessments.take(5).toList(),
      'packages': packages,
    };
  }
}
