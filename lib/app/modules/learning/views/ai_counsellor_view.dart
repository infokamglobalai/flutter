import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/learning/controllers/ai_counsellor_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class AiCounsellorView extends StatelessWidget {
  const AiCounsellorView({super.key});

  Widget _pageChip({
    required AiCounsellorController c,
    required String id,
    required String label,
    required IconData icon,
  }) {
    return Obx(() {
      final active = c.page.value == id;
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => c.page.value = id,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? Colors.white.withOpacity(0.85)
                  : Colors.white.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? AppTheme.primaryColor : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Map<String, dynamic> msg) {
    final role = (msg['role'] ?? '').toString();
    final isUser = role == 'user';
    final isCounsellor = role == 'counsellor';
    final content = (msg['content'] ?? '').toString();

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
          child: Text(
            content,
            style: TextStyle(color: fg, fontSize: 13, height: 1.35),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AiCounsellorController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Obx(() {
          final name = c.studentName.value.trim().isEmpty
              ? 'Student'
              : c.studentName.value.trim().split(' ').first;
          return Text('AI Counsellor • $name');
        }),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            final enabled = c.voiceOutputEnabled.value;
            return IconButton(
              onPressed: () {
                c.voiceOutputEnabled.value = !enabled;
                if (!c.voiceOutputEnabled.value) {
                  c.stopSpeaking();
                }
              },
              icon: Icon(enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
              tooltip: enabled ? 'Voice on' : 'Voice off',
            );
          }),
          IconButton(
            onPressed: () => Get.toNamed(Routes.STUDENT_AI_CHAT_HISTORY),
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top page chips (web parity: overview/analytics/chat/career/wellness/planner/voice)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              border: Border(
                bottom: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _pageChip(
                    c: c,
                    id: 'chat',
                    label: 'Chat',
                    icon: Icons.forum_rounded,
                  ),
                  const SizedBox(width: 10),
                  _pageChip(
                    c: c,
                    id: 'overview',
                    label: 'Overview',
                    icon: Icons.dashboard_rounded,
                  ),
                  const SizedBox(width: 10),
                  _pageChip(
                    c: c,
                    id: 'analytics',
                    label: 'Analytics',
                    icon: Icons.bar_chart_rounded,
                  ),
                  const SizedBox(width: 10),
                  _pageChip(
                    c: c,
                    id: 'career',
                    label: 'Career',
                    icon: Icons.school_rounded,
                  ),
                  const SizedBox(width: 10),
                  _pageChip(
                    c: c,
                    id: 'wellness',
                    label: 'Wellness',
                    icon: Icons.favorite_rounded,
                  ),
                  const SizedBox(width: 10),
                  _pageChip(
                    c: c,
                    id: 'study-planner',
                    label: 'Planner',
                    icon: Icons.calendar_month_rounded,
                  ),
                  const SizedBox(width: 10),
                  _pageChip(
                    c: c,
                    id: 'voice',
                    label: 'Voice',
                    icon: Icons.mic_rounded,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final p = c.page.value;
              if (p == 'overview' || p == 'analytics') {
                final a = c.analytics;
                final totalStudyHours =
                    (a['totalStudyHours'] ?? a['totalStudyTime'] ?? 0).toString();
                final engagementScore = (a['engagementScore'] ?? 0).toString();
                final focusScore = (a['focusScore'] ?? a['focus'] ?? 0).toString();
                final weeklyStreak = (a['weeklyStreak'] ?? 0).toString();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (p == 'overview') ...[
                      _statCard(
                        label: 'Total Study Time',
                        value: '$totalStudyHours h',
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        label: 'Weekly Streak',
                        value: weeklyStreak,
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        label: 'Engagement',
                        value: '$engagementScore%',
                        icon: Icons.bolt_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ] else ...[
                      _statCard(
                        label: 'Focus Score',
                        value: '$focusScore%',
                        icon: Icons.center_focus_strong_rounded,
                        color: const Color(0xFF7C3AED),
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        label: 'Engagement',
                        value: '$engagementScore%',
                        icon: Icons.bolt_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                    if (c.insights.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...c.insights.map((ins) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (ins['title'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                (ins['description'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                );
              }

              if (p == 'career' || p == 'wellness' || p == 'study-planner') {
                final rep = c.reports;
                final section = (p == 'career')
                    ? (rep['career'] as Map?)
                    : (p == 'wellness')
                        ? (rep['wellness'] as Map?)
                        : (rep['planner'] as Map?);
                final data = (section is Map) ? Map<String, dynamic>.from(section) : <String, dynamic>{};
                final title = p == 'career'
                    ? 'Career Guidance'
                    : p == 'wellness'
                        ? 'Mental Wellness'
                        : 'Study Planner';
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        (data['advice'] ??
                                data['status'] ??
                                data['matches'] ??
                                data['schedule'] ??
                                'No data available yet.')
                            .toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (p == 'voice') {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Obx(() {
                            final listening = c.isListening.value;
                            return Icon(
                              listening ? Icons.hearing_rounded : Icons.mic_rounded,
                              size: 56,
                              color: listening ? Colors.red : AppTheme.primaryColor,
                            );
                          }),
                        ),
                        const SizedBox(height: 18),
                        Obx(() {
                          final t = c.lastVoiceTranscript.value.trim();
                          final listening = c.isListening.value;
                          return Text(
                            listening
                                ? (t.isEmpty ? 'Listening…' : t)
                                : 'Tap to start a voice session',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                              height: 1.35,
                            ),
                          );
                        }),
                        const SizedBox(height: 18),
                        Obx(() {
                          final listening = c.isListening.value;
                          final busy = c.isTyping.value;
                          return SizedBox(
                            height: 54,
                            width: 220,
                            child: ElevatedButton.icon(
                              onPressed: busy ? null : c.toggleVoiceSession,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    listening ? Colors.red : AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Icon(listening ? Icons.stop_rounded : Icons.mic_rounded),
                              label: Text(busy ? 'Thinking…' : (listening ? 'Stop' : 'Start')),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }

              // Default: chat view
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: c.messages.length + (c.isTyping.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= c.messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Thinking…',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _bubble(c.messages[i]);
                },
              );
            }),
          ),
          Obx(() {
            if (!c.isListening.value) return const SizedBox.shrink();
            final t = c.lastVoiceTranscript.value.trim();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                border: Border(
                  top: BorderSide(color: Colors.red.withOpacity(0.15)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.isEmpty ? 'Listening…' : t,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            );
          }),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.inputController,
                      decoration: InputDecoration(
                        hintText: 'Ask your AI counsellor…',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => c.send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: Obx(() {
                      final disabled = c.isTyping.value;
                      return ElevatedButton(
                        onPressed: disabled ? null : c.toggleVoiceInput,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.isListening.value
                              ? Colors.red
                              : Colors.white,
                          foregroundColor: c.isListening.value
                              ? Colors.white
                              : AppTheme.primaryColor,
                          side: BorderSide(
                            color: c.isListening.value
                                ? Colors.red
                                : AppTheme.primaryColor.withOpacity(0.25),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: Icon(
                          c.isListening.value
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: () => c.send(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white),
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

