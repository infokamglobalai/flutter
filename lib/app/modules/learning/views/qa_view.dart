import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/qa_controller.dart';

class QAView extends GetView<QAController> {
  const QAView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildSearchModeToggle(),
          Expanded(child: _buildChatMessages()),
          _buildInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask Question',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'AI Learning Assistant',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: controller.clearChat,
          tooltip: 'Clear Chat',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Grade',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: controller.selectedGrade.value,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'All Grades',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          ...controller.availableGrades.map((grade) {
                            return DropdownMenuItem<String>(
                              value: grade,
                              child: Text(
                                grade,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) =>
                            controller.selectedGrade.value = value,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Subject',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: controller.selectedSubject.value,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'All Subjects',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          ...controller.availableSubjects.map((subject) {
                            return DropdownMenuItem<String>(
                              value: subject,
                              child: Text(
                                subject,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) =>
                            controller.selectedSubject.value = value,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchModeToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: _buildModeButton(
                'LMS Resources',
                Icons.school_rounded,
                'internal',
                controller.searchMode.value == 'internal',
              ),
            ),
            Expanded(
              child: _buildModeButton(
                'More Resources',
                Icons.public_rounded,
                'external',
                controller.searchMode.value == 'external',
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildModeButton(
    String label,
    IconData icon,
    String mode,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => controller.setSearchMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ask me anything!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'I can help you find answers from\nvideos and documents',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            controller.messages.length +
            (controller.isLoading.value || controller.isLoadingExternal.value
                ? 1
                : 0),
        itemBuilder: (context, index) {
          if (index == controller.messages.length) {
            return _buildTypingIndicator();
          }

          final message = controller.messages[index];
          return _buildMessageBubble(message);
        },
      );
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    final isError = message['isError'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isUser
                        ? null
                        : (isError ? Colors.red[50] : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isUser ? Colors.white : Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      if (!isUser && message['sources'] != null) ...[
                        const SizedBox(height: 16),
                        _buildSources(message['sources']),
                      ],
                      if (!isUser && message['externalSources'] != null) ...[
                        const SizedBox(height: 16),
                        _buildExternalSources(message['externalSources']),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeago.format(message['timestamp']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    if (!isUser && !isError) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => controller.speakAnswer(message['message']),
                        child: Obx(() {
                          return Icon(
                            controller.isSpeaking.value
                                ? Icons.volume_off
                                : Icons.volume_up,
                            size: 16,
                            color: AppTheme.primaryColor,
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSources(List<dynamic> sources) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          '📚 Related Resources:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...sources.map((source) => _buildSourceCard(source)).toList(),
      ],
    );
  }

  Widget _buildSourceCard(Map<String, dynamic> source) {
    final isVideo = source['type'] == 'video';

    return InkWell(
      onTap: () => controller.openResource(source),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isVideo
                      ? [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ]
                      : [Colors.red[400]!, Colors.red[600]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isVideo ? Icons.play_circle_filled : Icons.description_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source['title'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${source['subject']} • ${source['chapter']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isVideo
                        ? '⏱️ ${source['duration']}'
                        : '📄 ${source['pages']} pages',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalSources(List<dynamic> sources) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Row(
          children: [
            Icon(Icons.public_rounded, size: 16, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'External Resources:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sources.map((source) => _buildExternalSourceCard(source)).toList(),
      ],
    );
  }

  Widget _buildExternalSourceCard(Map<String, dynamic> source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: Colors.blue[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  source['source'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.open_in_new, size: 16, color: Colors.blue[600]),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(delay: 200),
                const SizedBox(width: 4),
                _buildDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({int delay = 0}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Obx(() {
              return IconButton(
                onPressed: controller.isListening.value
                    ? controller.stopListening
                    : controller.startListening,
                icon: Icon(
                  controller.isListening.value ? Icons.mic : Icons.mic_none,
                  color: controller.isListening.value
                      ? Colors.red
                      : AppTheme.primaryColor,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: controller.isListening.value
                      ? Colors.red[50]
                      : AppTheme.primaryColor.withOpacity(0.1),
                ),
              );
            }),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.questionController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => controller.askQuestion(value),
                decoration: InputDecoration(
                  hintText: 'Ask your question...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() {
              return IconButton(
                onPressed:
                    controller.isLoading.value ||
                        controller.isLoadingExternal.value
                    ? null
                    : () => controller.askQuestion(
                        controller.questionController.text,
                      ),
                icon:
                    controller.isLoading.value ||
                        controller.isLoadingExternal.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
