import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/models/entry.dart';
import '../shared/services/service_locator.dart';
import 'index_card.dart';
import 'index_manager.dart';
import 'loading_card.dart';
import 'new_card.dart';

class IndexGrid extends StatelessWidget {
  const IndexGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = get<IndexManager>();

    return Watch((_) {
      final entries = manager.gridEntries.value;
      if (manager.shouldShowEmpty) {
        return const EmptyWidget();
      }

      final cards = _cardList(entries);

      return LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the number of columns based on screen width
          final width = constraints.maxWidth;
          final crossAxisCount = switch (width) {
            < 400 => 1,
            < 600 => 2,
            < 900 => 3,
            < 1200 => 4,
            _ => 4,
          };

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) => cards[index],
          );
        },
      );
    });
  }

  List<Widget> _cardList(List<Entry> entries) {
    final manager = get<IndexManager>();

    if (manager.isBusy) {
      return List.generate(4, (index) => LoadingCard());
    }

    if (manager.searchController.text.isNotEmpty && entries.isEmpty) {
      return [NewCard(manager.searchController.text)];
    }

    return entries.map((e) => IndexCard(e)).toList();
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.tr.noEntriesFound,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
