import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/document_utils.dart';
import '../view/doc_viewer/pdf_viewer_screen.dart';
import '../view/doc_viewer/webview_viewer_screen.dart';

class CourseDocTile extends StatelessWidget {
  final String title;
  final String url;

  const CourseDocTile({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  void _handleOpen(BuildContext context) async {
    final type = DocumentUtils.getDocumentType(url);

    switch (type) {
      case DocumentType.pdf:
        Get.to(() => AppPdfViewer(url: url, title: title));
        break;
      case DocumentType.word:
      case DocumentType.excel:
      case DocumentType.powerpoint:
        Get.to(() => AppWebViewViewer(url: url, title: title));
        break;
      case DocumentType.generic:
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          Get.snackbar(
            'Error',
            'Could not open link',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = DocumentUtils.getDocumentType(url);
    final icon = DocumentUtils.getIconForType(type);
    final color = DocumentUtils.getColorForType(type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () => _handleOpen(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Glassmorphism base
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'medium',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type == DocumentType.generic ? 'External Link' : 'Document',
                          style: TextStyle(
                            fontFamily: 'regular',
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Open Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Open',
                      style: TextStyle(
                        fontFamily: 'semibold',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
