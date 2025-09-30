import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
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
        child: Watch((_) {
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
                  onPressed: manager.isExporting
                      ? null
                      : () => _downloadCsv(context, manager),
                  icon: manager.isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    manager.isExporting ? context.tr.exporting : context.tr.downloadCsv,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (manager.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          manager.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _downloadCsv(BuildContext context, ExportManager manager) async {
    try {
      await manager.exportToCsv();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Download started'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.exportError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
