import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/dashboard/controllers/student_ai_chat_history_controller.dart';

class StudentAiChatHistoryView extends StatelessWidget {
  const StudentAiChatHistoryView({super.key});

  Widget _bubble(Map<String, dynamic> msg) {
    final role = (msg['role'] ?? '').toString();
    final isUser = role == 'user';
    final isCounsellor = role == 'counsellor';
    final content = (msg['content'] ?? '').toString();
    final ts = (msg['timestamp'] ?? '').toString();

    final bg = isUser
        ? AppTheme.primaryColor
        : (isCounsellor ? const Color(0xFF7C3AED) : const Color(0xFFF3F4F6));
    final fg = isUser || isCounsellor ? Colors.white : const Color(0xFF111827);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyle(color: fg, fontSize: 13, height: 1.35),
              ),
              if (ts.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ts,
                  style: TextStyle(
                    color: (isUser || isCounsellor)
                        ? Colors.white70
                        : Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyList({
    required bool isLoading,
    required List<Map<String, dynamic>> messages,
    required VoidCallback onRefresh,
    String? emptyText,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            emptyText ?? 'No chat history yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (_, i) => _bubble(messages[i]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StudentAiChatHistoryController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('AI Chat History'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Counsellor'),
              Tab(text: 'Subject/Chapter'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => c.refreshAll(),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            Obx(
              () => _historyList(
                isLoading: c.isLoadingCounsellor.value,
                messages: c.counsellorMessages.cast<Map<String, dynamic>>(),
                onRefresh: () => c.loadCounsellorHistory(),
                emptyText: 'No AI counsellor chat history found.',
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Obx(
                    () => TextField(
                      decoration: InputDecoration(
                        labelText: 'Chapter ID (for chapter-wise history)',
                        hintText: 'Paste chapterId here',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            await c.loadContentHistory();
                          },
                          icon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      controller: c.contentTargetController,
                      onChanged: (v) => c.setContentTargetId(v),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => _historyList(
                      isLoading: c.isLoadingContent.value,
                      messages: c.contentMessages.cast<Map<String, dynamic>>(),
                      onRefresh: () => c.loadContentHistory(),
                      emptyText:
                          c.contentTargetId.value.trim().isEmpty
                              ? 'Open any chapter once (or paste a chapterId) to see chapter-wise AI chat history.'
                              : 'No AI chat history found for this chapter.',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

