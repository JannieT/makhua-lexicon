import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';

import '../shared/models/entry.dart';
import '../shared/services/database_service.dart';
// Conditional imports to avoid web package on non-web platforms
import 'download_stub.dart' if (dart.library.html) 'download_web.dart' as download;
import 'export_service.dart';

class ExportManager {
  final DatabaseService _databaseService;

  ExportManager(this._databaseService);

  // State signals
  final _isExporting = signal<bool>(false);
  final _errorSignal = signal<String?>(null);

  // Getters
  bool get isExporting => _isExporting.value;
  String? get error => _errorSignal.value;

  /// Export all entries to CSV via direct browser download (web only)
  Future<void> exportToCsv() async {
    if (!kIsWeb) {
      _errorSignal.value = 'Export is only available on web platform';
      return;
    }

    try {
      _isExporting.value = true;
      _errorSignal.value = null;

      // Get all entries from database
      final entries = await _databaseService.getEntries();

      if (entries.isEmpty) {
        _errorSignal.value = 'No entries found to export';
        return;
      }

      // Sort entries by headword alphabetically
      final sortedEntries = List<Entry>.from(entries)
        ..sort((a, b) => a.headword.toLowerCase().compareTo(b.headword.toLowerCase()));

      // Convert to CSV
      final csvContent = ExportService.entriesToCsv(sortedEntries);

      // Trigger direct browser download
      await download.DownloadStub.triggerBrowserDownload(csvContent);
    } catch (e) {
      log('Error exporting entries: $e');
      _errorSignal.value = 'Failed to export entries: $e';
    } finally {
      _isExporting.value = false;
    }
  }

  /// Clear any error state
  void clearError() {
    _errorSignal.value = null;
  }
}
