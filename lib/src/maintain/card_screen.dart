import 'package:flutter/material.dart';

import '../shared/models/entry.dart';
import '../shared/services/service_locator.dart';
import 'index_manager.dart';

class CardScreen extends StatelessWidget {
  final String? _entryId;
  const CardScreen(this._entryId, {super.key});

  @override
  Widget build(BuildContext context) {
    if (_entryId == null) {
      return const FourOhFour();
    }

    final manager = get<IndexManager>();
    final found = manager.getEntry(_entryId);
    if (found == null) {
      return const FourOhFour();
    }

    final Entry entry = found;

    return Scaffold(appBar: AppBar(title: Text(entry.headword)), body: Placeholder());
  }
}

class FourOhFour extends StatelessWidget {
  const FourOhFour({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Entry not found', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'The entry you are looking for does not exist or has been removed.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
