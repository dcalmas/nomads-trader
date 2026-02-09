/// Document model for course documents
class CourseDocument {
  final String url;
  final String title;
  final DocumentType type;

  CourseDocument({
    required this.url,
    required this.title,
    required this.type,
  });

  /// Create from JSON (API response)
  factory CourseDocument.fromJson(Map<String, dynamic> json) {
    final url = json['url'] ?? json['link'] ?? '';
    final title = json['title'] ?? json['name'] ?? _extractFileName(url);
    final type = DocumentType.fromUrl(url);
    
    return CourseDocument(
      url: url,
      title: title,
      type: type,
    );
  }

  /// Extract file name from URL
  static String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last.split('?').first;
      }
    } catch (_) {}
    return 'Document';
  }
}

/// Document type enumeration
enum DocumentType {
  pdf,
  word,
  excel,
  powerpoint,
  link;

  /// Detect document type from URL
  factory DocumentType.fromUrl(String url) {
    if (url.isEmpty) return DocumentType.link;
    
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      final extension = uri.pathSegments.last.split('?').first.split('.').last;
      
      if (extension == 'pdf' || path.endsWith('.pdf')) {
        return DocumentType.pdf;
      }
      if (extension == 'doc' || extension == 'docx' || path.endsWith('.doc') || path.endsWith('.docx')) {
        return DocumentType.word;
      }
      if (extension == 'xls' || extension == 'xlsx' || path.endsWith('.xls') || path.endsWith('.xlsx')) {
        return DocumentType.excel;
      }
      if (extension == 'ppt' || extension == 'pptx' || path.endsWith('.ppt') || path.endsWith('.pptx')) {
        return DocumentType.powerpoint;
      }
    } catch (_) {}
    
    return DocumentType.link;
  }

  /// Get display name for the document type
  String get displayName {
    switch (this) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.word:
        return 'WORD';
      case DocumentType.excel:
        return 'EXCEL';
      case DocumentType.powerpoint:
        return 'POWERPOINT';
      case DocumentType.link:
        return 'LINK';
    }
  }

  /// Check if this document type should be opened in WebView (Google Docs)
  bool get requiresWebView {
    switch (this) {
      case DocumentType.pdf:
        return false;
      case DocumentType.word:
      case DocumentType.excel:
      case DocumentType.powerpoint:
        return true;
      case DocumentType.link:
        return false;
    }
  }
}
