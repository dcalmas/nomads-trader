import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/course_document.dart';
import 'package:flutter_app/app/view/doc_viewer/pdf_viewer_screen.dart';
import 'package:flutter_app/app/view/doc_viewer/webview_viewer_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Glassmorphism document tile widget
class CourseDocTile extends StatelessWidget {
  final CourseDocument document;
  final VoidCallback? onTap;

  const CourseDocTile({
    Key? key,
    required this.document,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? _openDocument,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.blue.withOpacity(0.2),
        highlightColor: Colors.blue.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Glassmorphism effect
            color: isDarkMode 
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.7),
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // File Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _getIconBackgroundColor().withOpacity(0.15),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconBackgroundColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Document Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: TextStyle(
                        fontFamily: 'medium',
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      document.type.displayName,
                      style: TextStyle(
                        fontFamily: 'regular',
                        fontSize: 11,
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Open Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _getIconBackgroundColor().withOpacity(0.15),
                ),
                child: Text(
                  'Open',
                  style: TextStyle(
                    fontFamily: 'medium',
                    fontSize: 12,
                    color: _getIconBackgroundColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon based on document type
  IconData _getIcon() {
    switch (document.type) {
      case DocumentType.pdf:
        return FontAwesomeIcons.filePdf;
      case DocumentType.word:
        return FontAwesomeIcons.fileWord;
      case DocumentType.excel:
        return FontAwesomeIcons.fileExcel;
      case DocumentType.powerpoint:
        return FontAwesomeIcons.filePowerpoint;
      case DocumentType.link:
        return Icons.link;
    }
  }

  /// Get icon background color based on document type
  Color _getIconBackgroundColor() {
    switch (document.type) {
      case DocumentType.pdf:
        return const Color(0xFFE53935);
      case DocumentType.word:
        return const Color(0xFF1E88E5);
      case DocumentType.excel:
        return const Color(0xFF43A047);
      case DocumentType.powerpoint:
        return const Color(0xFFFF7043);
      case DocumentType.link:
        return const Color(0xFF5C6BC0);
    }
  }

  /// Open the document in the appropriate viewer
  void _openDocument() {
    if (document.url.isEmpty) {
      Get.snackbar(
        'Error',
        'Document URL is empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (document.type == DocumentType.pdf) {
      // Open PDF in built-in PDF viewer
      Get.to(
        () => AppPdfViewer(
          url: document.url,
          title: document.title,
        ),
      );
    } else if (document.type.requiresWebView) {
      // Open Word, Excel, PowerPoint in WebView with Google Docs
      Get.to(
        () => AppWebViewViewer(
          url: document.url,
          title: document.title,
        ),
      );
    } else {
      // For links, open in external browser
      _openInBrowser();
    }
  }

  /// Open URL in external browser
  void _openInBrowser() async {
    if (document.url.isEmpty) return;
    
    final Uri uri = Uri.parse(document.url);
    if (uri.isScheme('http') || uri.isScheme('https')) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not open document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }
}
