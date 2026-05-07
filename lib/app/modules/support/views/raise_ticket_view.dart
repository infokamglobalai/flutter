import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';
import 'package:file_picker/file_picker.dart';

class RaiseTicketView extends GetView<TicketController> {
  const RaiseTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Raise a Ticket'),
        backgroundColor: const Color(0xFFEC4899),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildCategorySelection(),
            const SizedBox(height: 20),
            _buildSubjectField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 20),
            _buildAttachmentsSection(),
            const SizedBox(height: 20),
            _buildHelpfulTips(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We\'re Here to Help!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Describe your issue and we\'ll get back to you soon',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          return Column(
            children: TicketCategory.values.map((category) {
              final isSelected = controller.selectedCategory.value == category;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => controller.selectedCategory.value = category,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEC4899).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFEC4899)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEC4899)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.getCategoryLabel(category),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFEC4899)
                                      : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.getCategoryDescription(category),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFFEC4899),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSubjectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.subjectController,
          decoration: InputDecoration(
            hintText: 'Brief summary of your issue',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.short_text_rounded, size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
              borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.descriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Please provide detailed information about your issue...',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
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
              borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments (optional)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Attach either up to 3 images OR 1 video.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final res = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: true,
                  );
                  if (res == null) return;
                  final paths =
                      res.files.map((f) => f.path).whereType<String>().toList();
                  controller.setImages(paths);
                },
                icon: const Icon(Icons.image_rounded),
                label: const Text('Pick images'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final res = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                    allowMultiple: false,
                  );
                  if (res == null) return;
                  final path = res.files.first.path;
                  if (path != null) controller.setVideo(path);
                },
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Pick video'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final imgs = controller.imagePaths;
          final vid = controller.videoPath.value;
          if (imgs.isEmpty && (vid == null || vid.isEmpty)) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Selected',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: controller.clearAttachments,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                if (vid != null && vid.isNotEmpty)
                  Text(
                    'Video: ${vid.split(RegExp(r"[\\\\/]")).last}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                if (imgs.isNotEmpty) ...[
                  Text(
                    'Images (${imgs.length}):',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: imgs
                        .take(3)
                        .map(
                          (p) => Chip(
                            label: Text(p.split(RegExp(r"[\\\\/]")).last),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHelpfulTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Helpful Tips',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('Be specific about the issue you\'re facing'),
          _buildTipItem('Include error messages if any'),
          _buildTipItem('Mention steps to reproduce the problem'),
          _buildTipItem('Add relevant details like device type, OS version'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : () => controller.submitTicket(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFFEC4899),
            disabledBackgroundColor: Colors.grey[300],
            elevation: 0,
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Submit Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
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
}
