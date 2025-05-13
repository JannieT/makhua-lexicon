import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import 'index_manager.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = get<IndexManager>();

    return Watch((_) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Search text field
            Expanded(
              child: TextField(
                controller: manager.searchController,
                onChanged: manager.onSearch,
                decoration: InputDecoration(
                  hintText: context.tr.searchEntries,
                  border: InputBorder.none,
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Latest entries chip
            FilterChip(
              label: Text(context.tr.latest),
              selected: manager.filter == IndexFilter.latest,
              onSelected: (selected) => manager.filter = IndexFilter.latest,
              showCheckmark: false,
            ),
            const SizedBox(width: 8),

            // Flag color options
            Row(
              children: [
                _FlagColorOption(color: context.colors.primary, filter: IndexFilter.flag1),
                const SizedBox(width: 8),
                _FlagColorOption(color: context.colors.secondary, filter: IndexFilter.flag2),
                const SizedBox(width: 8),
                _FlagColorOption(color: context.colors.tertiary, filter: IndexFilter.flag3),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _FlagColorOption extends StatelessWidget {
  const _FlagColorOption({required this.color, required this.filter});

  final Color color;
  final IndexFilter filter;

  @override
  Widget build(BuildContext context) {
    final manager = get<IndexManager>();
    final isSelected = manager.filter == filter;

    return GestureDetector(
      onTap: () => manager.filter = filter,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? context.colors.secondaryContainer : Colors.transparent,
            width: 5,
          ),
        ),
      ),
    );
  }
}
