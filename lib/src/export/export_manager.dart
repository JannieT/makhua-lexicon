import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';

import '../shared/models/async_state.dart';
import '../shared/models/entry.dart';
import '../shared/services/database_service.dart';
// Conditional imports to avoid web package on non-web platforms
import 'download_stub.dart' if (dart.library.html) 'download_web.dart' as download;
import 'export_service.dart';

class ExportManager {
  final DatabaseService _databaseService;

  ExportManager(this._databaseService);

  final _exportState = Signal<AppAsyncState<bool>>(const AppAsyncIdle());
  AppAsyncState<bool> get exportState => _exportState.value;

  /// Export all entries to CSV via direct browser download (web only).
  /// Returns whether the download was started.
  Future<bool> exportToCsv() async {
    if (!kIsWeb) {
      _exportState.value = const AppAsyncFailure(
        'Export is only available on web platform',
      );
      return false;
    }

    _exportState.value = const AppAsyncLoading();
    try {
      // Get all entries from database
      final entries = await _databaseService.getEntries();

      if (entries.isEmpty) {
        _exportState.value = const AppAsyncFailure('No entries found to export');
        return false;
      }

      // Sort entries by headword alphabetically
      final sortedEntries = List<Entry>.from(entries)
        ..sort((a, b) => a.headword.toLowerCase().compareTo(b.headword.toLowerCase()));

      // Convert to CSV
      final csvContent = ExportService.entriesToCsv(sortedEntries);

      // Trigger direct browser download
      await download.DownloadStub.triggerBrowserDownload(csvContent);
      _exportState.value = const AppAsyncSuccess(true);
      return true;
    } catch (e) {
      log('Error exporting entries: $e');
      _exportState.value = const AppAsyncFailure('Could not export entries');
      return false;
    }
  }
}
