// Stub implementation for non-web platforms
// This file is used when the web package is not available

import 'dart:developer';

/// Stub implementation for non-web platforms
class DownloadStub {
  /// Stub method that throws an error when called on non-web platforms
  static Future<void> triggerBrowserDownload(String csvContent) async {
    log('Browser download not supported on this platform');
    throw UnsupportedError('Browser download is only available on web platform');
  }
}
