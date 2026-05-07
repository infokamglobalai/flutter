import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentReportsView extends StatelessWidget {
  const StudentReportsView({super.key});

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppTheme.secondaryColor;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: c),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            icon: Icons.trending_up_rounded,
            title: 'My Progress',
            subtitle: 'Overall learning progress and stats',
            color: const Color(0xFF06B6D4),
            onTap: () => Get.toNamed(Routes.STUDENT_PROGRESS),
          ),
          const SizedBox(height: 10),
          _card(
            icon: Icons.history_rounded,
            title: 'Watch History',
            subtitle: 'Videos you watched recently',
            color: const Color(0xFF8B5CF6),
            onTap: () => Get.toNamed(Routes.WATCH_HISTORY),
          ),
          const SizedBox(height: 10),
          _card(
            icon: Icons.receipt_long_rounded,
            title: 'Payment History',
            subtitle: 'Your payments and invoices',
            color: const Color(0xFF10B981),
            onTap: () => Get.toNamed(Routes.PAYMENT_HISTORY),
          ),
          const SizedBox(height: 10),
          _card(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: 'Updates, reminders and alerts',
            color: const Color(0xFFF59E0B),
            onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),
          const SizedBox(height: 10),
          _card(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'AI Chat History',
            subtitle: 'Counsellor and chapter-wise AI messages',
            color: const Color(0xFF7C3AED),
            onTap: () => Get.toNamed(Routes.STUDENT_AI_CHAT_HISTORY),
          ),
          const SizedBox(height: 10),
          _card(
            icon: Icons.psychology_alt_rounded,
            title: 'AI Counsellor',
            subtitle: 'Personalized guidance and planning',
            color: const Color(0xFF2563EB),
            onTap: () => Get.toNamed(Routes.STUDENT_AI_COUNSELLOR),
          ),
        ],
      ),
    );
  }
}

