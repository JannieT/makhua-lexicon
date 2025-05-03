import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import 'index_card.dart';
import 'index_manager.dart';

class IndexGrid extends StatelessWidget {
  const IndexGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = get<IndexManager>();

    return Watch((_) {
      final entries = manager.gridEntries.value;
      if (entries.isEmpty) {
        return Center(
          child: Text(
            context.tr.noEntriesFound,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the number of columns based on screen width
          final width = constraints.maxWidth;
          final crossAxisCount = width < 600 ? 2 : (width ~/ 300).clamp(2, 4);

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) => IndexCard(entries[index]),
          );
        },
      );
    });
  }
}
