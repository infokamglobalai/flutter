import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/qna_model.dart';
import '../controllers/mentor_chat_controller.dart';
import 'ask_doubt_view.dart';

class MentorChatView extends GetView<MentorChatController> {
  const MentorChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: controller.loadThreads,
        color: const Color(0xFF8B5CF6),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildStatsSection(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            _buildThreadsList(context),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AskDoubtView()),
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ask Doubt',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF8B5CF6),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.chat_bubble_outline,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('My Doubts',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Chat with your mentor',
                            style: TextStyle(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(() {
      final total = controller.threads.length;
      final pending = controller.pendingThreads.length;
      final answered = controller.answeredThreads.length;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _buildStat(Icons.question_answer, '$total', 'Chapters', const Color(0xFF8B5CF6))),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Expanded(child: _buildStat(Icons.schedule, '$pending', 'Pending', const Color(0xFFF59E0B))),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Expanded(child: _buildStat(Icons.check_circle, '$answered', 'Answered', const Color(0xFF10B981))),
          ],
        ),
      );
    });
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildThreadsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.threads.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          ),
        );
      }
      if (controller.threads.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 64, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(height: 24),
                const Text('No doubts yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                const SizedBox(height: 8),
                Text('Tap the button below to ask your first doubt',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildThreadCard(controller.threads[i]),
            ),
            childCount: controller.threads.length,
          ),
        ),
      );
    });
  }

  Widget _buildThreadCard(QnaThread thread) {
    final hasPending = thread.hasUnanswered;
    final statusColor = hasPending ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final lastItem = thread.lastItem;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => AskDoubtView(thread: thread)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(hasPending ? Icons.schedule : Icons.check_circle,
                            size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          hasPending ? 'Waiting' : 'Answered',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (lastItem != null)
                    Text(
                      timeago.format(lastItem.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.menu_book, size: 16, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      thread.chapter?.name ?? 'Chapter',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                  ),
                ],
              ),
              if (thread.packageName != null) ...[
                const SizedBox(height: 4),
                Text(thread.packageName!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
              if (lastItem != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        lastItem.isAnswered ? Icons.school : Icons.help_outline,
                        size: 16,
                        color: lastItem.isAnswered
                            ? const Color(0xFF10B981)
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lastItem.isAnswered
                              ? lastItem.answerText
                              : lastItem.questionText,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontStyle: lastItem.isAnswered
                                  ? FontStyle.normal
                                  : FontStyle.italic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCountChip(Icons.help_outline, '${thread.totalQuestions}', 'Questions', Colors.blueAccent),
                  const SizedBox(width: 8),
                  _buildCountChip(Icons.check_circle_outline, '${thread.answeredCount}', 'Answered', const Color(0xFF10B981)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountChip(IconData icon, String count, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text('$count $label',
            style: TextStyle(
                fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      ],
    );
  }
}
