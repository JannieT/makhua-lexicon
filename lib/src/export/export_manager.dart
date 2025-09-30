import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:web/web.dart' as web;

import '../shared/models/entry.dart';
import '../shared/services/database_service.dart';
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
      await _triggerBrowserDownload(csvContent);
    } catch (e) {
      log('Error exporting entries: $e');
      _errorSignal.value = 'Failed to export entries: $e';
    } finally {
      _isExporting.value = false;
    }
  }

  /// Trigger direct browser download (web only)
  Future<void> _triggerBrowserDownload(String csvContent) async {
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

  /// Clear any error state
  void clearError() {
    _errorSignal.value = null;
  }
}
