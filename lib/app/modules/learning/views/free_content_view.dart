import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/learning/controllers/free_content_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class FreeContentView extends GetView<FreeContentController> {
  const FreeContentView({super.key});

  Future<void> _openUrl(String? url) async {
    final raw = (url ?? '').trim();
    if (raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _titleFor(Map<String, dynamic> item) {
    final title = (item['title'] ?? item['name'] ?? item['heading'])?.toString();
    if (title != null && title.trim().isNotEmpty) return title.trim();
    return 'Resource';
  }

  String _subtitleFor(Map<String, dynamic> item) {
    final type = (item['type'] ?? item['resourceType'] ?? item['category'])
        ?.toString()
        .trim();
    final desc = (item['description'] ?? item['desc'])?.toString().trim();
    if ((type ?? '').isNotEmpty && (desc ?? '').isNotEmpty) return '$type • $desc';
    if ((type ?? '').isNotEmpty) return type!;
    if ((desc ?? '').isNotEmpty) return desc!;
    return 'Free content';
  }

  String? _urlFor(Map<String, dynamic> item) {
    final candidates = [
      item['url'],
      item['link'],
      item['fileUrl'],
      item['videoUrl'],
      item['documentUrl'],
    ];
    for (final c in candidates) {
      final s = c?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Free Content'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.error.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final list = controller.resources;
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No free content available yet.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = list[index];
              final url = _urlFor(item);
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: url == null ? null : () => _openUrl(url),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titleFor(item),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _subtitleFor(item),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                          color: (url == null) ? Colors.grey[300] : Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

