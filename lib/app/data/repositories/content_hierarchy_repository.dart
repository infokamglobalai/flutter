import 'package:get/get.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/data/models/content_hierarchy_models.dart';

class ContentHierarchyRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Boards
  Future<List<BoardModel>> getBoards() async {
    try {
      final response = await _apiClient.get(ApiConstants.boards);
      final boards = (response.data['boards'] as List)
          .map((board) => BoardModel.fromJson(board))
          .toList();
      return boards;
    } catch (e) {
      rethrow;
    }
  }

  // Grades
  Future<List<GradeModel>> getGrades({required String boardId}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.grades,
        queryParameters: {'board_id': boardId},
      );
      final grades = (response.data['grades'] as List)
          .map((grade) => GradeModel.fromJson(grade))
          .toList();
      return grades;
    } catch (e) {
      rethrow;
    }
  }

  // Subjects
  Future<List<SubjectModel>> getSubjects({required String gradeId}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.subjects,
        queryParameters: {'grade_id': gradeId},
      );
      final subjects = (response.data['subjects'] as List)
          .map((subject) => SubjectModel.fromJson(subject))
          .toList();
      return subjects;
    } catch (e) {
      rethrow;
    }
  }

  // Chapters
  Future<List<ChapterModel>> getChapters({required String subjectId}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.chapters,
        queryParameters: {'subject_id': subjectId},
      );
      final chapters = (response.data['chapters'] as List)
          .map((chapter) => ChapterModel.fromJson(chapter))
          .toList();
      return chapters;
    } catch (e) {
      rethrow;
    }
  }

  Future<ChapterModel> getChapterDetail({required String chapterId}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.chapters}/$chapterId',
      );
      return ChapterModel.fromJson(response.data['chapter']);
    } catch (e) {
      rethrow;
    }
  }
}
