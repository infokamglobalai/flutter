import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/doubt_model.dart';
import '../controllers/mentor_chat_controller.dart';

class DoubtDetailView extends StatefulWidget {
  final Doubt doubt;

  const DoubtDetailView({super.key, required this.doubt});

  @override
  State<DoubtDetailView> createState() => _DoubtDetailViewState();
}

class _DoubtDetailViewState extends State<DoubtDetailView> {
  final MentorChatController controller = Get.find<MentorChatController>();
  final TextEditingController replyController = TextEditingController();
  final RxBool showReplyBox = false.obs;
  late Rx<Doubt> currentDoubt;

  @override
  void initState() {
    super.initState();
    currentDoubt = widget.doubt.obs;
    _loadDoubtDetails();
  }

  Future<void> _loadDoubtDetails() async {
    final details = await controller.getDoubtDetails(widget.doubt.id);
    if (details != null) {
      currentDoubt.value = details;
    }
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF8B5CF6),
        title: const Text(
          'Doubt Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final doubt = currentDoubt.value;
        
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF8B5CF6),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      controller.getStatusIcon(doubt.status),
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      controller.getStatusText(doubt.status),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                doubt.ticketNumber,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (doubt.metadata?['subjectName'] != null ||
                              doubt.metadata?['chapterName'] != null)
                            Row(
                              children: [
                                if (doubt.metadata?['subjectName'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      doubt.metadata!['subjectName'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                if (doubt.metadata?['chapterName'] != null) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      doubt.metadata!['chapterName'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text(
                            timeago.format(doubt.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Question Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doubt.user?.fullName ?? 'You',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const Text(
                                      'Student',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Question:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doubt.question,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              height: 1.5,
                            ),
                          ),
                          if (doubt.description.isNotEmpty &&
                              doubt.description != doubt.question) ...[
                            const SizedBox(height: 12),
                            Text(
                              doubt.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4B5563),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Responses Section
                    if (doubt.responses.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${doubt.responses.length} ${doubt.responses.length == 1 ? "Response" : "Responses"}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...doubt.responses.map((response) => _buildResponseCard(response)),
                    ] else if (doubt.isPending) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange[200]!,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.orange[700],
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Waiting for Response',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'A mentor will respond to your question soon',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Reply Section
            Obx(() => showReplyBox.value
                ? _buildReplyBox()
                : _buildReplyButton()),
          ],
        );
      }),
    );
  }

  Widget _buildResponseCard(DoubtResponse response) {
    final isStaff = response.isStaffResponse;
    final color = isStaff ? Colors.green : const Color(0xFF8B5CF6);
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: isStaff ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(
                  isStaff ? Icons.school : Icons.person,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.user?.fullName ?? (isStaff ? 'Mentor' : 'Student'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      timeago.format(response.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isStaff)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Mentor',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response.message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => showReplyBox.value = true,
        icon: const Icon(Icons.reply, color: Colors.white),
        label: const Text(
          'Add Reply',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildReplyBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Your Reply',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  showReplyBox.value = false;
                  replyController.clear();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: replyController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your reply...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () async {
                      if (replyController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please write a reply',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      await controller.addResponse(
                        currentDoubt.value.id,
                        replyController.text.trim(),
                      );

                      // Reload doubt details
                      await _loadDoubtDetails();
                      
                      showReplyBox.value = false;
                      replyController.clear();
                    },
              icon: const Icon(Icons.send, color: Colors.white),
              label: controller.isLoading.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Send Reply',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

