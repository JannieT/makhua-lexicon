import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared/extensions.dart';
import '../../shared/services/service_locator.dart';
import '../../shared/widgets/flag_button.dart';
import '../index_manager.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = get<IndexManager>();

    return SignalBuilder(
      builder: (context) {
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

              // Filter picklist
              DropdownButton<IndexFilter>(
                value: manager.selectedFilterOption,
                hint: Text(context.tr.filter),
                onChanged: manager.selectFilter,
                underline: const SizedBox.shrink(),
                items: manager.filterOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: _FilterOptionLabel(option: option),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterOptionLabel extends StatelessWidget {
  const _FilterOptionLabel({required this.option});

  final IndexFilter option;

  @override
  Widget build(BuildContext context) {
    final flag = option.flag;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (flag != null) ...[FlagButton(flag: flag), const SizedBox(width: 8)],
        Text(flag == null ? context.tr.latest : context.flagLabel(flag)),
      ],
    );
  }
}
