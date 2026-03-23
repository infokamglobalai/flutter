import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/data/models/self_assessment_model.dart';
import '../controllers/self_assessment_controller.dart';

class SelfAssessmentResultView extends GetView<SelfAssessmentController> {
  const SelfAssessmentResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        final result = controller.submitResult.value;
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(result),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildScoreCard(result),
                  const SizedBox(height: 24),
                  _buildStatsRow(result),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Answer Review'),
                  const SizedBox(height: 12),
                  ...result.results.asMap().entries.map(
                    (e) => _buildResultCard(e.key, e.value),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  SliverAppBar _buildAppBar(SelfAssessmentSubmitResult result) {
    final color = controller.scoreColor(result.percentage);
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: color,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: _goToList,
      ),
      title: const Text(
        'Result',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.75)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.scoreLabel(result.percentage),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.currentDetail.value?.title ?? 'Self Assessment',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(SelfAssessmentSubmitResult result) {
    final color = controller.scoreColor(result.percentage);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Score ring
            SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: result.percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${result.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        'Score',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${result.obtainedMarks.toStringAsFixed(0)} / ${result.totalMarks.toStringAsFixed(0)} marks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(SelfAssessmentSubmitResult result) {
    final correct = result.results.where((r) => r.isCorrect).length;
    final incorrect = result.results.length - correct;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statCard('Correct', '$correct', Colors.green),
          const SizedBox(width: 12),
          _statCard('Incorrect', '$incorrect', Colors.red),
          const SizedBox(width: 12),
          _statCard('Total', '${result.results.length}', AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildResultCard(int idx, QuestionResult r) {
    final color = r.isCorrect ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Theme(
          data: Get.theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Icon(
                r.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 22,
              ),
            ),
            title: Text(
              'Q${idx + 1}: ${r.questionText}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                r.isCorrect
                    ? '+${r.obtainedMarks} mark${r.obtainedMarks == 1 ? '' : 's'}'
                    : '0 marks',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              if (r.explanation.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.blue[400],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  r.isCorrect
                      ? 'Well done! You got this right.'
                      : 'Incorrect. Review this topic.',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // Re-attempt the same assessment
                if (controller.currentDetail.value != null) {
                  controller.loadAndAttempt(controller.currentDetail.value!.id);
                }
              },
              icon: const Icon(Icons.replay_rounded),
              label: const Text(
                'Retry This Assessment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _goToList,
              icon: const Icon(Icons.list_rounded),
              label: const Text(
                'Back to Assessments',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToList() {
    // Schedule after the current event-loop tick so the navigator is
    // guaranteed to be unlocked before we call popUntil.
    Future(() {
      Get.until((route) => route.settings.name == '/self-assessment-list');
    });
  }
}
