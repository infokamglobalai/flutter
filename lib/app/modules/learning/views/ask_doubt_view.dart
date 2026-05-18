import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/qna_model.dart';
import '../../../data/services/qna_service.dart';
import '../controllers/mentor_chat_controller.dart';
import 'dart:math' as math;

/// Per-chapter Q&A chat view.
/// Receives an optional [thread]. When null, shows subject/chapter picker first.
class AskDoubtView extends StatefulWidget {
  final QnaThread? thread;

  const AskDoubtView({super.key, this.thread});

  @override
  State<AskDoubtView> createState() => _AskDoubtViewState();
}

class _AskDoubtViewState extends State<AskDoubtView> {
  final MentorChatController _ctrl = Get.find<MentorChatController>();
  final QnaService _qnaService = QnaService();

  // State
  QnaThread? _thread;
  bool _isLoading = false;
  bool _isSending = false;
  Timer? _refreshTimer;

  // Controllers
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  // For 'new doubt' flow (when thread is null)
  Map<String, dynamic>? _selectedSubject;
  Map<String, dynamic>? _selectedChapter;

  // Cached chapter name — persists even after thread is set so AppBar never goes blank
  String _chapterName = 'Q&A Chat';

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
    if (_thread != null) {
      // Cache the chapter name immediately from the thread
      _chapterName = (_thread!.chapter?.name ?? '').isNotEmpty
          ? _thread!.chapter!.name
          : 'Q&A Chat';
      _startRefresh();
    } else {
      // New doubt — load subjects if not loaded
      if (_ctrl.subjects.isEmpty) _ctrl.loadSubscriptions();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _reload(silent: true),
    );
  }

  Future<void> _reload({bool silent = false}) async {
    if (_thread == null) return;
    if (!silent) setState(() => _isLoading = true);
    final result = await _qnaService.getQnaThread(
      chapterId: _thread!.chapter?.id ?? '',
      packageId: _thread!.packageSubscriptionId,
    );
    if (result['success'] == true && mounted) {
      setState(() {
        _thread = result['thread'] as QnaThread;
        _isLoading = false;
      });
      if (!silent) _scrollToBottom();
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    // New doubt flow — create first question
    if (_thread == null) {
      if (_selectedChapter == null) {
        Get.snackbar(
          'Error',
          'Please select a chapter first.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      setState(() => _isSending = true);
      // Snapshot the selected chapter before any async call
      final chapId = _selectedChapter!['_id'] as String;
      final chapPackageId = _selectedChapter!['subscriptionId'] as String;
      final chapName = _selectedChapter!['name']?.toString() ?? _chapterName;
      final created = await _ctrl.askQuestion(
        chapterId: chapId,
        questionText: text,
        overridePackageId: chapPackageId,
      );
      if (created != null && mounted) {
        _inputCtrl.clear();
        // Reload the thread from the server so chapter/package info is populated
        final reloaded = await _qnaService.getQnaThread(
          chapterId: chapId,
          packageId: chapPackageId,
        );
        final resolvedThread =
            (reloaded['success'] == true && reloaded['thread'] != null)
            ? reloaded['thread'] as QnaThread
            : created;
        setState(() {
          _isSending = false;
          _thread = resolvedThread;
          // Always use picker name as fallback if backend didn't populate chapter
          if ((_thread!.chapter?.name ?? '').isNotEmpty) {
            _chapterName = _thread!.chapter!.name;
          } else {
            _chapterName = chapName;
          }
          _startRefresh();
        });
        _scrollToBottom();
      } else {
        if (mounted) setState(() => _isSending = false);
      }
      return;
    }

    // Existing thread — add another question
    setState(() => _isSending = true);
    final result = await _qnaService.askQuestion(
      chapterId: _thread!.chapter?.id ?? '',
      packageId: _thread!.packageSubscriptionId,
      questionText: text,
    );
    if (result['success'] == true && mounted) {
      _inputCtrl.clear();
      setState(() {
        _thread = result['thread'] as QnaThread;
        _isSending = false;
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } else {
      if (mounted) setState(() => _isSending = false);
      Get.snackbar(
        'Error',
        result['message'] ?? 'Failed to send',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Container(
                decoration: UIUtils.glossyDecoration(
                  baseColor: const Color(0xFF8B5CF6),
                  borderRadius: 0,
                  showBorder: false,
                ),
              ),
              const Positioned(
                top: -30,
                right: -20,
                child: _AnimatedGlowBlob(color: Colors.white, size: 120),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          _thread != null
              ? ((_thread!.chapter?.name ?? '').isNotEmpty
                    ? _thread!.chapter!.name
                    : _chapterName)
              : (_chapterName != 'Q&A Chat' ? _chapterName : 'Ask a Doubt'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (_thread != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _reload();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_thread == null) _buildChapterPicker() else _buildThreadHeader(),
          Expanded(child: _buildBody()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── Chapter picker (new doubt flow) ──────────────────────────────────

  Widget _buildChapterPicker() {
    return Container(
      decoration: UIUtils.glossyDecoration(
        baseColor: Colors.white,
        borderRadius: 0,
        showBorder: false,
      ).copyWith(
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECT SUBJECT & CHAPTER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF64748B),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          // Subject dropdown
          Obx(
            () => Container(
              decoration: UIUtils.glassDecoration(borderRadius: 12).copyWith(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!, width: 1.2),
              ),
              child: _ctrl.subjects.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'Loading subjects...',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    )
                  : DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.book, color: Color(0xFF8B5CF6)),
                        border: InputBorder.none,
                        hintText: 'Choose a subject',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: _ctrl.subjects
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s['name']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedSubject = v;
                          _selectedChapter = null;
                        });
                        if (v != null) _ctrl.loadChapters(v['_id']);
                      },
                    ),
            ),
          ),
          // Chapter dropdown — only show after subject is picked
          if (_selectedSubject != null) ...[
            const SizedBox(height: 10),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _ctrl.chapters.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          'No chapters found for this subject',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedChapter,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.menu_book,
                            color: Color(0xFF8B5CF6),
                          ),
                          border: InputBorder.none,
                          hintText: 'Choose a chapter',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: _ctrl.chapters
                            .map(
                              (ch) => DropdownMenuItem(
                                value: ch,
                                child: Text(ch['name']?.toString() ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedChapter = v;
                            if (v != null)
                              _chapterName =
                                  v['name']?.toString() ?? _chapterName;
                          });
                          if (v != null) _ctrl.onChapterSelected(v);
                        },
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Thread header (existing thread) ──────────────────────────────────

  Widget _buildThreadHeader() {
    final t = _thread!;
    final displayName = (t.chapter?.name ?? '').isNotEmpty
        ? t.chapter!.name
        : _chapterName;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: UIUtils.glossyDecoration(
        baseColor: Colors.white,
        borderRadius: 0,
        showBorder: false,
      ).copyWith(
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, size: 16, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (t.packageName != null)
                  Text(
                    t.packageName!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: UIUtils.glassDecoration(borderRadius: 20).copyWith(
              color: t.hasUnanswered
                  ? Colors.orange.withValues(alpha: 0.12)
                  : Colors.green.withValues(alpha: 0.12),
            ),
            child: Text(
              t.hasUnanswered ? '${t.pendingCount} Pending' : 'All Answered',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: t.hasUnanswered ? Colors.orange[800] : Colors.green[800],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Chat body ────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading && _thread == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      );
    }

    if (_thread == null || _thread!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 52,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedChapter == null && _thread == null
                  ? 'Select a chapter and type your doubt below'
                  : 'Type your first question below!',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _thread!.items.length,
      itemBuilder: (ctx, i) => _buildQnaItem(_thread!.items[i]),
    );
  }

  Widget _buildQnaItem(QnaItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Student's question — right side (YOU)
          _buildBubble(
            text: item.questionText,
            isMe: true,
            senderLabel: 'You',
            avatarIcon: Icons.person,
            avatarColor: const Color(0xFF8B5CF6),
            time: item.createdAt,
          ),
          const SizedBox(height: 8),
          // Mentor answer — left side OR waiting widget
          if (item.isAnswered)
            _buildBubble(
              text: item.answerText,
              isMe: false,
              senderLabel: item.answeredBy?.fullName ?? 'Mentor',
              avatarIcon: Icons.school,
              avatarColor: const Color(0xFF10B981),
              time: item.answeredAt ?? item.createdAt,
            )
          else
            _buildWaiting(),
        ],
      ),
    );
  }

  Widget _buildBubble({
    required String text,
    required bool isMe,
    required String senderLabel,
    required IconData avatarIcon,
    required Color avatarColor,
    required DateTime time,
  }) {
    final bgColor = isMe ? const Color(0xFF8B5CF6) : Colors.white;
    final textColor = isMe ? Colors.white : const Color(0xFF1F2937);
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
                  maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: isMe
                    ? UIUtils.glossyDecoration(
                        baseColor: const Color(0xFF8B5CF6),
                        borderRadius: 20,
                      ).copyWith(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(4),
                        ),
                      )
                    : UIUtils.glassDecoration(borderRadius: 16).copyWith(
                        color: Colors.white,
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: isMe ? FontWeight.w500 : FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(time),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey[500],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.done_all_rounded,
                            size: 13,
                            color: Colors.white70,
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

  Widget _buildWaiting() {
    return Padding(
      padding: const EdgeInsets.only(left: 46),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: UIUtils.glassDecoration(borderRadius: 16).copyWith(
          color: Colors.orange[50],
          border: Border.all(color: Colors.orange[200]!, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, color: Colors.orange[700], size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Waiting for mentor reply...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Input bar ────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: UIUtils.glossyDecoration(
        baseColor: Colors.white,
        borderRadius: 0,
        showBorder: false,
      ).copyWith(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: UIUtils.glassDecoration(borderRadius: 24).copyWith(
                color: const Color(0xFFF1F5F9),
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
              ),
              child: TextField(
                controller: _inputCtrl,
                focusNode: _focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _thread == null
                      ? 'Type your doubt here...'
                      : 'Ask another question...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? Container(
                  width: 46,
                  height: 46,
                  decoration: UIUtils.glossyDecoration(
                    baseColor: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                    borderRadius: 24,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Container(
                  decoration: UIUtils.glossyDecoration(
                    baseColor: const Color(0xFF8B5CF6),
                    borderRadius: 24,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _send();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _AnimatedGlowBlob extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedGlowBlob({required this.color, required this.size});

  @override
  State<_AnimatedGlowBlob> createState() => _AnimatedGlowBlobState();
}

class _AnimatedGlowBlobState extends State<_AnimatedGlowBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(0.15),
                  widget.color.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
