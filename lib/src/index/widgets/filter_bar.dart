import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared/extensions.dart';
import '../../shared/models/flags.dart';
import '../../shared/services/service_locator.dart';
import '../../shared/widgets/flag_button.dart';
import '../index_manager.dart';

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
            ...Flag.values
                .map<Widget>(
                  (flag) => FlagButton(
                    flag: flag,
                    isSelected: manager.filter.flagNumber == flag.number,
                    onTap: manager.setFilterFlag,
                  ),
                )
                .intersperse(const SizedBox(width: 8)),
          ],
        ),
      );
    });
  }
}
