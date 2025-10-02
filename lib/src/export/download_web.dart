// Web-specific implementation using the web package
import 'dart:developer';

import 'package:web/web.dart' as web;

/// Web-specific implementation for browser downloads
class DownloadStub {
  /// Trigger browser download on web platform
  static Future<void> triggerBrowserDownload(String csvContent) async {
    try {
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'makhua_lexicon_export_$timestamp.csv';

      // Build data URL and trigger download
      final dataUrl = 'data:text/csv;charset=utf-8,${Uri.encodeComponent(csvContent)}';

      final anchor = web.HTMLAnchorElement()
        ..href = dataUrl
        ..download = filename;
      anchor.click();

      log('Browser download triggered for: $filename');
    } catch (e) {
      log('Error triggering browser download: $e');
      rethrow;
    }
  }
}
