import 'package:flutter/material.dart';

enum DocumentType { pdf, word, excel, powerpoint, generic }

class DocumentUtils {
  static DocumentType getDocumentType(String url) {
    if (url.isEmpty) return DocumentType.generic;
    
    // Remove query parameters to get clean extension
    final cleanUrl = url.split('?').first.toLowerCase();
    
    if (cleanUrl.endsWith('.pdf')) {
      return DocumentType.pdf;
    } else if (cleanUrl.endsWith('.doc') || cleanUrl.endsWith('.docx')) {
      return DocumentType.word;
    } else if (cleanUrl.endsWith('.xls') || cleanUrl.endsWith('.xlsx')) {
      return DocumentType.excel;
    } else if (cleanUrl.endsWith('.ppt') || cleanUrl.endsWith('.pptx')) {
      return DocumentType.powerpoint;
    } else {
      return DocumentType.generic;
    }
  }

  static IconData getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.word:
        return Icons.description;
      case DocumentType.excel:
        return Icons.table_chart;
      case DocumentType.powerpoint:
        return Icons.slideshow;
      case DocumentType.generic:
        return Icons.link;
    }
  }

  static Color getColorForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Colors.red.shade400;
      case DocumentType.word:
        return Colors.blue.shade400;
      case DocumentType.excel:
        return Colors.green.shade400;
      case DocumentType.powerpoint:
        return Colors.orange.shade400;
      case DocumentType.generic:
        return Colors.grey.shade400;
    }
  }
}
