import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared/extensions.dart';
import '../../shared/models/async_state.dart';
import '../../shared/services/service_locator.dart';
import '../export_manager.dart';

/// Downloads all entries as a CSV file (web only)
class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = get<ExportManager>();

    return SignalBuilder(
      builder: (context) {
        final isExporting = manager.exportState is AppAsyncLoading<bool>;

        return ElevatedButton.icon(
          onPressed: isExporting ? null : () => _downloadCsv(context, manager),
          icon: isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(isExporting ? context.tr.exporting : context.tr.downloadCsv),
        );
      },
    );
  }

  Future<void> _downloadCsv(BuildContext context, ExportManager manager) async {
    final started = await manager.exportToCsv();
    if (!context.mounted) return;

    final message = switch (manager.exportState) {
      AppAsyncFailure(:final message) => message,
      _ => started ? 'Download started' : null,
    };
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
