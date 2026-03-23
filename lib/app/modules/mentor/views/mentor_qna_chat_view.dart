import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/qna_model.dart';
import '../../../data/services/qna_service.dart';
import '../controllers/mentor_dashboard_controller.dart';

/// Full-screen real-time chat view for a mentor answering a student's Q&A thread.
/// Launched from [_buildQuestionsTab] in [MentorDashboardView].
class MentorQnaChatView extends StatefulWidget {
  final QnaThread thread;

  const MentorQnaChatView({super.key, required this.thread});

  @override
  State<MentorQnaChatView> createState() => _MentorQnaChatViewState();
}

class _MentorQnaChatViewState extends State<MentorQnaChatView> {
  final QnaService _qnaService = QnaService();
  final MentorDashboardController _ctrl = Get.find<MentorDashboardController>();

  late QnaThread _thread;
  bool _isLoading = false;
  Timer? _pollTimer;
  final ScrollController _scrollCtrl = ScrollController();

  // Per-item reply state: itemId -> controller / sending flag
  final Map<String, TextEditingController> _replyCtrl = {};
  final Map<String, bool> _sending = {};
  String? _activeReplyItemId; // which item's reply box is open

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
    _initReplyControllers();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(jump: true),
    );
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    for (final c in _replyCtrl.values) {
      c.dispose();
    }
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _initReplyControllers() {
    for (final item in _thread.items) {
      _replyCtrl.putIfAbsent(item.id, () => TextEditingController());
      _sending.putIfAbsent(item.id, () => false);
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _reload(silent: true),
    );
  }

  Future<void> _reload({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      // Re-fetch all mentor threads and find this one
      final result = await _qnaService.getMentorThreads();
      if (result['success'] == true && mounted) {
        final threads = result['threads'] as List<QnaThread>;
        final updated = threads.firstWhereOrNull((t) => t.id == _thread.id);
        if (updated != null) {
          setState(() {
            _thread = updated;
            _initReplyControllers();
          });
        }
      }
    } finally {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAnswer(String itemId) async {
    final ctrl = _replyCtrl[itemId];
    final text = ctrl?.text.trim() ?? '';
    if (text.isEmpty) return;

    setState(() => _sending[itemId] = true);

    final result = await _qnaService.answerItem(
      threadId: _thread.id,
      itemId: itemId,
      answerText: text,
    );

    if (mounted) {
      if (result['success'] == true) {
        final updated = result['thread'] as QnaThread;
        ctrl?.clear();
        setState(() {
          _thread = updated;
          _sending[itemId] = false;
          _activeReplyItemId = null;
          _initReplyControllers();
        });
        // Sync back to controller list
        _ctrl.updateQnaThread(updated);
        Future.delayed(
          const Duration(milliseconds: 150),
          () => _scrollToBottom(),
        );
      } else {
        setState(() => _sending[itemId] = false);
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to send answer',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _scrollToBottom({bool jump = false}) {
    if (_scrollCtrl.hasClients) {
      if (jump) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      } else {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pending = _thread.pendingCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _thread.chapter?.name ?? 'Q&A Thread',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              _thread.studentName ?? 'Student',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(pending),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(int pending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            child: const Icon(Icons.person, color: Color(0xFF8B5CF6), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _thread.studentName ?? 'Student',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${_thread.totalQuestions} question${_thread.totalQuestions != 1 ? 's' : ''}  •  ${_thread.answeredCount} answered',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (pending > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pending Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'All Answered',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _thread.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      );
    }

    if (_thread.items.isEmpty) {
      return const Center(child: Text('No questions yet.'));
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _thread.items.length,
      itemBuilder: (ctx, i) => _buildQnaPair(_thread.items[i]),
    );
  }

  Widget _buildQnaPair(QnaItem item) {
    final isReplyOpen = _activeReplyItemId == item.id;
    final isSending = _sending[item.id] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Student's question (right) ───────────────────────────────
          _buildBubble(
            text: item.questionText,
            senderLabel:
                item.askedBy?.fullName ?? _thread.studentName ?? 'Student',
            avatarIcon: Icons.person,
            avatarColor: const Color(0xFF8B5CF6),
            isMe: false,
            time: item.createdAt,
            bgColor: const Color(0xFFEDE9FE),
            textColor: const Color(0xFF1F2937),
          ),
          const SizedBox(height: 8),

          // ─── Mentor's answer (left) or reply box ─────────────────────
          if (item.isAnswered)
            _buildBubble(
              text: item.answerText,
              senderLabel: item.answeredBy?.fullName ?? 'You',
              avatarIcon: Icons.school,
              avatarColor: const Color(0xFF10B981),
              isMe: true,
              time: item.answeredAt ?? item.createdAt,
              bgColor: const Color(0xFF8B5CF6),
              textColor: Colors.white,
            )
          else ...[
            // "Tap to reply" chip
            if (!isReplyOpen)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => setState(() => _activeReplyItemId = item.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.reply, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Reply',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              _buildReplyBox(item.id, isSending),
          ],
        ],
      ),
    );
  }

  Widget _buildBubble({
    required String text,
    required String senderLabel,
    required IconData avatarIcon,
    required Color avatarColor,
    required bool isMe,
    required DateTime time,
    required Color bgColor,
    required Color textColor,
  }) {
    final crossAlign = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final mainAlign = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isMe ? 0 : 46,
            right: isMe ? 46 : 0,
            bottom: 3,
          ),
          child: Text(
            senderLabel,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ),
        Row(
          mainAxisAlignment: mainAlign,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 18,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Icon(avatarIcon, size: 18, color: avatarColor),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.74,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(time),
                          style: TextStyle(
                            color: isMe ? Colors.white60 : Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.done_all,
                            size: 13,
                            color: Colors.white60,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Icon(avatarIcon, size: 18, color: avatarColor),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildReplyBox(String itemId, bool isSending) {
    return Container(
      margin: const EdgeInsets.only(left: 46, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 16, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 6),
              const Text(
                'Your Answer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _activeReplyItemId = null),
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _replyCtrl[itemId],
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isSending ? null : () => _sendAnswer(itemId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                disabledBackgroundColor: const Color(
                  0xFF8B5CF6,
                ).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Send Answer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
