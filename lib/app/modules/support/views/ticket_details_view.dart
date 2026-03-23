import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';
import 'package:intl/intl.dart';

class TicketDetailsView extends GetView<TicketController> {
  const TicketDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ticket ID from route parameter
    final ticketId = Get.parameters['id'] ?? '';

    // Load ticket details when view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTicketDetails(ticketId);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoadingDetails.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final ticket = controller.selectedTicket.value;
              if (ticket == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ticket not found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTicketInfo(ticket),
                  const SizedBox(height: 16),
                  _buildResponsesSection(ticket),
                  const SizedBox(height: 100),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final ticket = controller.selectedTicket.value;
        if (ticket == null || controller.isLoadingDetails.value) {
          return const SizedBox.shrink();
        }
        return _buildReplySection();
      }),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFEC4899),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 56,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ticket Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View and respond to your ticket',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfo(Ticket ticket) {
    final statusColor = _getStatusColor(ticket.status);
    final priorityColor = _getPriorityColor(ticket.priority);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and priority
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.getStatusLabel(ticket.status),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: priorityColor),
                ),
                child: Text(
                  controller.getPriorityLabel(ticket.priority),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                ticket.ticketNumber,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category
          Row(
            children: [
              Icon(
                _getCategoryIcon(ticket.category),
                color: const Color(0xFFEC4899),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                controller.getCategoryLabel(ticket.category),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEC4899),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(ticket.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subject
          Text(
            ticket.subject,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              ticket.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesSection(Ticket ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Responses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${ticket.responses.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC4899),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (ticket.responses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No responses yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to respond',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...ticket.responses.map((response) => _buildResponseCard(response)),
      ],
    );
  }

  Widget _buildResponseCard(TicketResponse response) {
    final isStaff = response.isStaffResponse;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isStaff ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStaff ? Colors.blue[200]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isStaff
                    ? Colors.blue[700]
                    : const Color(0xFFEC4899),
                child: Icon(
                  isStaff ? Icons.support_agent_rounded : Icons.person_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.userName.isNotEmpty
                          ? response.userName
                          : response.userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isStaff ? Colors.blue[900] : Colors.grey[900],
                      ),
                    ),
                    Text(
                      isStaff ? 'Support Team' : 'You',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(response.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response.message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.responseController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Type your response...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
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
                    borderSide: const BorderSide(
                      color: Color(0xFFEC4899),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSubmittingResponse.value
                    ? null
                    : () => controller.submitResponse(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isSubmittingResponse.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFFF59E0B);
      case TicketStatus.inProgress:
        return const Color(0xFF3B82F6);
      case TicketStatus.resolved:
        return const Color(0xFF10B981);
      case TicketStatus.closed:
        return const Color(0xFF6B7280);
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return const Color(0xFF6B7280);
      case TicketPriority.medium:
        return const Color(0xFF3B82F6);
      case TicketPriority.high:
        return const Color(0xFFF59E0B);
      case TicketPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getCategoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.technical:
        return Icons.build_rounded;
      case TicketCategory.subjectRelated:
        return Icons.school_rounded;
      case TicketCategory.paymentRelated:
        return Icons.payment_rounded;
      case TicketCategory.contentIssue:
        return Icons.report_problem_rounded;
      case TicketCategory.featureRequest:
        return Icons.lightbulb_rounded;
      case TicketCategory.other:
        return Icons.help_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
