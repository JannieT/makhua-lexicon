import 'package:flutter/material.dart';

import '../../shared/extensions.dart';
import '../../shared/services/service_locator.dart';
import '../index_manager.dart';

class NewTile extends StatelessWidget {
  final String headword;
  const NewTile(this.headword, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(headword, style: context.styles.titleLarge),
      trailing: FilledButton(
        onPressed: () => _addNewEntry(context),
        child: Text(context.tr.add),
      ),
    );
  }

  Future<void> _addNewEntry(BuildContext context) async {
    final manager = get<IndexManager>();

    try {
      await manager.createEntry(headword);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.entryAddedToLexicon(headword)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.errorAddingEntry),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
