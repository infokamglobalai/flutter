import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/ticket_service.dart';

enum TicketCategory {
  technical,
  subjectRelated,
  paymentRelated,
  contentIssue,
  featureRequest,
  other,
}

enum TicketStatus { open, inProgress, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

class Ticket {
  final String id;
  final String ticketNumber;
  final TicketCategory category;
  final String subject;
  final String description;
  final DateTime createdAt;
  final TicketStatus status;
  final TicketPriority priority;
  final List<TicketResponse> responses;
  final List<TicketAttachment> attachments;
  final Map<String, dynamic>? metadata;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.category,
    required this.subject,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.priority,
    this.responses = const [],
    this.attachments = const [],
    this.metadata,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return Ticket(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ticketNumber: (json['ticketNumber'] ?? '').toString(),
      category: TicketService.categoryFromApi(
        (json['category'] ?? 'other').toString(),
      ),
      subject: (json['subject'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: parseDate(json['createdAt']),
      status: TicketService.statusFromApi((json['status'] ?? 'open').toString()),
      priority:
          TicketService.priorityFromApi((json['priority'] ?? 'medium').toString()),
      responses:
          (json['responses'] as List<dynamic>?)
              ?.map((r) => TicketResponse.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((a) => TicketAttachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
      metadata: (json['metadata'] is Map)
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }
}

class TicketAttachment {
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;

  TicketAttachment({
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
  });

  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    return TicketAttachment(
      fileName: json['fileName']?.toString() ?? 'attachment',
      fileUrl: json['fileUrl']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
    );
  }
}

class TicketResponse {
  final String id;
  final String message;
  final DateTime createdAt;
  final bool isStaffResponse;
  final String userEmail;
  final String userName;

  TicketResponse({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.isStaffResponse,
    required this.userEmail,
    required this.userName,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    final userIdRaw = json['userId'];
    final userId = (userIdRaw is Map)
        ? Map<String, dynamic>.from(userIdRaw)
        : <String, dynamic>{};
    return TicketResponse(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      isStaffResponse: json['isStaffResponse'] as bool? ?? false,
      userEmail: (userId['email'] ?? '').toString(),
      userName: '${(userId['firstName'] ?? '').toString()} ${(userId['lastName'] ?? '').toString()}'
          .trim(),
    );
  }
}

class TicketController extends GetxController {
  final tickets = <Ticket>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final TicketService _ticketService = TicketService();

  // Ticket details
  final Rxn<Ticket> selectedTicket = Rxn<Ticket>();
  final isLoadingDetails = false.obs;
  final isSubmittingResponse = false.obs;

  // Form fields
  final selectedCategory = Rx<TicketCategory?>(null);
  late final TextEditingController subjectController;
  late final TextEditingController descriptionController;
  late final TextEditingController responseController;
  final imagePaths = <String>[].obs;
  final videoPath = RxnString();

  @override
  void onInit() {
    super.onInit();
    subjectController = TextEditingController();
    descriptionController = TextEditingController();
    responseController = TextEditingController();
    loadTickets();
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    responseController.dispose();
    super.onClose();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;

    try {
      final response = await _ticketService.getTickets(page: 1, limit: 100);

      if (response['success'] == true) {
        final ticketsData = response['data'] as List<dynamic>;
        tickets.value = ticketsData
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tickets: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getCategoryLabel(TicketCategory category) {
    switch (category) {
      case TicketCategory.technical:
        return 'Technical Issue';
      case TicketCategory.subjectRelated:
        return 'Subject Related';
      case TicketCategory.paymentRelated:
        return 'Payment Related';
      case TicketCategory.contentIssue:
        return 'Content Issue';
      case TicketCategory.featureRequest:
        return 'Feature Request';
      case TicketCategory.other:
        return 'Other';
    }
  }

  String getCategoryDescription(TicketCategory category) {
    switch (category) {
      case TicketCategory.technical:
        return 'App crashes, login issues, video problems';
      case TicketCategory.subjectRelated:
        return 'Questions about lessons, doubt clarification';
      case TicketCategory.paymentRelated:
        return 'Payment issues, subscription queries';
      case TicketCategory.contentIssue:
        return 'Errors in content, missing materials';
      case TicketCategory.featureRequest:
        return 'Suggest new features or improvements';
      case TicketCategory.other:
        return 'Any other concerns or feedback';
    }
  }

  String getStatusLabel(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  String getPriorityLabel(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  Future<void> submitTicket() async {
    if (selectedCategory.value == null) {
      Get.snackbar(
        'Required',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
      );
      return;
    }

    if (subjectController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter a subject',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please provide a description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final response = await _ticketService.createTicket(
        category: TicketService.categoryToApi(selectedCategory.value!),
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
        metadata: {},
        imagePaths: imagePaths.toList(),
        videoPath: videoPath.value,
      );

      if (response['success'] == true) {
        final ticketData = response['data'] as Map<String, dynamic>;
        final newTicket = Ticket.fromJson(ticketData);

        tickets.insert(0, newTicket);

        Get.back();
        Get.snackbar(
          'Success',
          'Your ticket has been submitted successfully. Ticket ID: ${newTicket.ticketNumber}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green[100],
        );

        // Reset form
        selectedCategory.value = null;
        subjectController.clear();
        descriptionController.clear();
        imagePaths.clear();
        videoPath.value = null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit ticket: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void setImages(List<String> paths) {
    videoPath.value = null; // enforce mutually exclusive
    imagePaths.assignAll(paths.take(3));
  }

  void setVideo(String path) {
    imagePaths.clear(); // enforce mutually exclusive
    videoPath.value = path;
  }

  void clearAttachments() {
    imagePaths.clear();
    videoPath.value = null;
  }

  // Statistics
  int get openTicketsCount =>
      tickets.where((t) => t.status == TicketStatus.open).length;

  int get inProgressTicketsCount =>
      tickets.where((t) => t.status == TicketStatus.inProgress).length;

  int get resolvedTicketsCount =>
      tickets.where((t) => t.status == TicketStatus.resolved).length;

  double get resolutionRate {
    if (tickets.isEmpty) return 0;
    return (resolvedTicketsCount +
            tickets.where((t) => t.status == TicketStatus.closed).length) /
        tickets.length *
        100;
  }

  // ==================== Ticket Details ====================

  Future<void> loadTicketDetails(String ticketId) async {
    isLoadingDetails.value = true;
    try {
      final response = await _ticketService.getTicketById(ticketId);

      if (response['success'] == true) {
        final ticketData = response['data'] as Map<String, dynamic>;
        selectedTicket.value = Ticket.fromJson(ticketData);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load ticket details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> submitResponse() async {
    final ticket = selectedTicket.value;
    if (ticket == null) return;

    if (responseController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter a response',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
      );
      return;
    }

    isSubmittingResponse.value = true;

    try {
      final response = await _ticketService.addTicketResponse(
        ticketId: ticket.id,
        message: responseController.text.trim(),
        isInternal: false,
      );

      if (response['success'] == true) {
        // Reload ticket details to show new response
        await loadTicketDetails(ticket.id);

        // Clear response field
        responseController.clear();

        Get.snackbar(
          'Success',
          'Response added successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green[100],
        );

        // Also update the ticket in the list if it exists
        final index = tickets.indexWhere((t) => t.id == ticket.id);
        if (index != -1 && selectedTicket.value != null) {
          tickets[index] = selectedTicket.value!;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add response: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSubmittingResponse.value = false;
    }
  }
}
