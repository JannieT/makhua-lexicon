import 'package:flutter/material.dart';

import '../shared/extensions.dart';

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
                Expanded(
                  child: Text(headword, style: context.styles.titleLarge),
                ),
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
            FilledButton(onPressed: () {}, child: const Text('Add')),
          ],
        ),
      ),
    );
  }
}
