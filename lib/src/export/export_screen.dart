import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/models/async_state.dart';
import '../shared/services/service_locator.dart';
import '../shared/widgets/error_banner.dart';
import 'export_manager.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  static const routeName = '/export';

  @override
  Widget build(BuildContext context) {
    // Only show export screen on web platform
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr.exportEntries)),
        body: const Center(child: Text('Export is only available on web platform')),
      );
    }

    final manager = get<ExportManager>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr.exportEntries)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SignalBuilder(builder: (context) {
          final state = manager.exportState;
          final isExporting = state is AppAsyncLoading<bool>;
          final error = switch (state) {
            AppAsyncFailure(:final message) => message,
            _ => null,
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr.exportDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: isExporting
                      ? null
                      : () => _downloadCsv(context, manager),
                  icon: isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    isExporting ? context.tr.exporting : context.tr.downloadCsv,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (error != null) ErrorBanner(message: error),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _downloadCsv(BuildContext context, ExportManager manager) async {
    final started = await manager.exportToCsv();
    if (!started || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started'), behavior: SnackBarBehavior.floating),
    );
  }
}
