import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/student_coaching_controller.dart';

class StudentCoachingView extends GetView<StudentCoachingController> {
  const StudentCoachingView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3FF),
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Decorative circle
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button row
                          Row(
                            children: [
                              GestureDetector(
                                onTap: Get.back,
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1-on-1 Coaching',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final accepted = controller.acceptedRequests.length;
                            final pending = controller.requests
                                .where(
                                  (r) => r['status']?.toString() == 'pending',
                                )
                                .length;
                            return Text(
                              accepted > 0
                                  ? '$accepted accepted • ${controller.sessions.length} session${controller.sessions.length == 1 ? '' : 's'} booked'
                                  : pending > 0
                                  ? '$pending request${pending == 1 ? '' : 's'} pending review'
                                  : 'Request personalised coaching from your mentor',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab Bar ─────────────────────────────────────────
            Container(
              color: const Color(0xFF5B21B6),
              child: const TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: 'Request'),
                  Tab(text: 'Slots'),
                  Tab(text: 'Sessions'),
                ],
              ),
            ),

            // ── Tab Content ─────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _RequestTab(controller: controller),
                  _SlotsTab(controller: controller),
                  _SessionsTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── REQUEST TAB ──────────────────────────────────────────────────────────────

class _RequestTab extends StatelessWidget {
  final StudentCoachingController controller;
  const _RequestTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      color: const Color(0xFF7C3AED),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFormCard(),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.requests.isEmpty) {
              return _emptyState(
                icon: Icons.school_outlined,
                title: 'No Requests Yet',
                subtitle: 'Submit your first coaching request above',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'My Requests (${controller.requests.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                ...controller.requests.map((req) => _buildRequestCard(req)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: const [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'New Coaching Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Subject *'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: controller.selectedSubjectId.value,
                    decoration: _inputDeco(
                      'Select your subject',
                      Icons.menu_book_outlined,
                    ),
                    isExpanded: true,
                    items: controller.subjects
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s['_id']?.toString(),
                            child: Text(s['name']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: controller.onSubjectChanged,
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel('Chapter (Optional)'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: controller.selectedChapterId.value,
                    decoration: _inputDeco(
                      'Select a chapter',
                      Icons.list_outlined,
                    ),
                    isExpanded: true,
                    items: controller.chapters.isEmpty
                        ? [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('— Select subject first —'),
                            ),
                          ]
                        : controller.chapters
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c['_id']?.toString(),
                                  child: Text(c['name']?.toString() ?? ''),
                                ),
                              )
                              .toList(),
                    onChanged: (v) => controller.selectedChapterId.value = v,
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel('What do you need help with? *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.requestMessageController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDeco(
                      'Describe your doubt or topic…',
                      Icons.edit_note,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel('Preferred Schedule'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.preferredScheduleController,
                    decoration: _inputDeco(
                      'e.g. Weekdays 5–7 PM',
                      Icons.schedule_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel('Contact Number'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.contactNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDeco(
                      'Your phone number',
                      Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFF7C3AED,
                        ).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isSubmitting.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Submitting…'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Request',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = req['status']?.toString() ?? 'pending';
    final Color statusColor;
    final IconData statusIcon;

    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_rounded;
    }

    final createdAt = req['createdAt'] as DateTime? ?? DateTime.now();
    final subject = req['subject']?.toString() ?? '';
    final chapter = req['chapter']?.toString() ?? '';
    final mentorName = req['mentorName']?.toString() ?? '';
    final board = req['board']?.toString() ?? '';
    final grade = req['grade']?.toString() ?? '';
    final response = req['response']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        chapter.isNotEmpty ? '$subject • $chapter' : subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
                if (mentorName.isNotEmpty || board.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (mentorName.isNotEmpty)
                        _chip(
                          Icons.person_outline,
                          mentorName,
                          const Color(0xFF7C3AED),
                        ),
                      if (board.isNotEmpty)
                        _chip(Icons.business_outlined, board, Colors.blue),
                      if (grade.isNotEmpty)
                        _chip(Icons.class_outlined, grade, Colors.teal),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  req['requestMessage']?.toString() ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (response.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.reply_rounded, size: 16, color: statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mentor\'s Response',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                response,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (status == 'accepted') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.green),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Go to the Slots tab to book a session',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SLOTS TAB ────────────────────────────────────────────────────────────────

class _SlotsTab extends StatelessWidget {
  final StudentCoachingController controller;
  const _SlotsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      color: const Color(0xFF7C3AED),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
          );
        }
        if (controller.availableSlots.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _emptyState(
                icon: Icons.event_available_outlined,
                title: 'No Slots Available',
                subtitle: controller.acceptedRequests.isEmpty
                    ? 'Your mentor will open slots once your request is accepted'
                    : 'Your mentor hasn\'t added any slots yet',
              ),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.availableSlots.length + 1,
          itemBuilder: (ctx, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${controller.availableSlots.length} slot${controller.availableSlots.length == 1 ? '' : 's'} available',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return _buildSlotCard(context, controller.availableSlots[i - 1]);
          },
        );
      }),
    );
  }

  Widget _buildSlotCard(BuildContext context, Map<String, dynamic> slot) {
    final date = slot['date'] as DateTime;
    final mentorName = slot['mentorName']?.toString() ?? 'Mentor';
    final start = slot['startTime']?.toString() ?? '';
    final end = slot['endTime']?.toString() ?? '';
    final isToday = _isToday(date);
    final isTomorrow = _isTomorrow(date);
    final dateLabel = isToday
        ? 'Today'
        : isTomorrow
        ? 'Tomorrow'
        : _formatDate(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      height: 1,
                    ),
                  ),
                  Text(
                    _monthShort(date),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mentorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? Colors.green[700] : Colors.grey[600],
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$start – $end',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmBooking(context, slot),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Book',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking(BuildContext context, Map<String, dynamic> slot) {
    final date = slot['date'] as DateTime;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.event_available, color: Color(0xFF7C3AED), size: 24),
            SizedBox(width: 10),
            Text('Confirm Booking'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogRow(
              Icons.person_outline,
              slot['mentorName']?.toString() ?? 'Mentor',
            ),
            const SizedBox(height: 8),
            _dialogRow(Icons.calendar_today_outlined, _formatDate(date)),
            const SizedBox(height: 8),
            _dialogRow(
              Icons.access_time_rounded,
              '${slot['startTime']} – ${slot['endTime']}',
            ),
            const SizedBox(height: 14),
            Text(
              'Booking this slot is permanent and cannot be undone once confirmed by your mentor.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.bookSlot(slot);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

// ─── SESSIONS TAB ─────────────────────────────────────────────────────────────

class _SessionsTab extends StatelessWidget {
  final StudentCoachingController controller;
  const _SessionsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      color: const Color(0xFF7C3AED),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
          );
        }
        if (controller.sessions.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _emptyState(
                icon: Icons.video_call_outlined,
                title: 'No Sessions Yet',
                subtitle: 'Book a slot from the Slots tab to get started',
              ),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sessions.length,
          itemBuilder: (ctx, i) =>
              _buildSessionCard(context, controller.sessions[i]),
        );
      }),
    );
  }

  Widget _buildSessionCard(BuildContext context, Map<String, dynamic> session) {
    final status = session['status']?.toString() ?? 'pending';
    final date = session['date'] as DateTime;
    final mentorName = session['mentorName']?.toString() ?? '';
    final subject = session['subject']?.toString() ?? '';
    final chapter = session['chapter']?.toString() ?? '';
    final board = session['board']?.toString() ?? '';
    final grade = session['grade']?.toString() ?? '';
    final meetingLink = session['meetingLink']?.toString() ?? '';
    final start = session['startTime']?.toString() ?? '';
    final end = session['endTime']?.toString() ?? '';
    final isUpcoming = date.isAfter(DateTime.now());

    final Color statusColor;
    final IconData statusIcon;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (isUpcoming && status != 'cancelled')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'UPCOMING',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(
                        0xFF7C3AED,
                      ).withValues(alpha: 0.12),
                      child: Text(
                        mentorName.isNotEmpty
                            ? mentorName[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatDate(date)} • $start – $end',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _infoRow(
                  Icons.menu_book_rounded,
                  chapter.isNotEmpty ? '$subject • $chapter' : subject,
                  const Color(0xFF7C3AED),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(
                        Icons.business_outlined,
                        board,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoRow(Icons.class_outlined, grade, Colors.teal),
                    ),
                  ],
                ),
                if (meetingLink.isNotEmpty && status == 'confirmed') ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: meetingLink));
                      Get.snackbar(
                        'Link Copied!',
                        'Meeting link copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        icon: const Icon(Icons.check, color: Colors.white),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Copy Meeting Link',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.copy_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (status == 'confirmed') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 14,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Meeting link will appear here once added',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                if (status == 'pending' && isUpcoming) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showCancelDialog(
                        context,
                        session['id']?.toString() ?? '',
                      ),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 16,
                      ),
                      label: const Text(
                        'Cancel Session',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String sessionId) {
    if (sessionId.isEmpty) return;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 10),
            Text('Cancel Session?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this session? This action cannot be undone and the slot will be freed.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Keep Session')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelSession(sessionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SHARED HELPERS ───────────────────────────────────────────────────────────

InputDecoration _inputDeco(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    prefixIcon: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
    ),
    filled: true,
    fillColor: const Color(0xFFF9F7FF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

Widget _fieldLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF374151),
    ),
  );
}

Widget _chip(IconData icon, String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget _emptyState({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 52, color: const Color(0xFF7C3AED)),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    ),
  );
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 7) return _formatDate(date);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

bool _isTomorrow(DateTime date) {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  return date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day;
}

String _monthShort(DateTime date) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return months[date.month - 1];
}
