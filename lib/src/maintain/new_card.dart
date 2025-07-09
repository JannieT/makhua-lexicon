import 'package:flutter/material.dart';

import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import 'index_manager.dart';

class NewCard extends StatelessWidget {
  final String headword;
  const NewCard(this.headword, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headword with flags
            Row(
              children: [
                Expanded(child: Text(headword, style: context.styles.titleLarge)),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const Spacer(),
            // Add a button to add a new word
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: () => _addNewEntry(context),
                  child: Text(context.tr.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewEntry(BuildContext context) async {
    final manager = get<IndexManager>();

    try {
      // Create a new entry with the headword
      await manager.createEntry(headword);

      // Show a snackbar to indicate success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.entryAddedToLexicon(headword)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error snackbar if something goes wrong
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
