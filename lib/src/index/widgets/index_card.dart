import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/extensions.dart';
import '../../shared/models/entry.dart';
import '../../shared/models/flags.dart';
import '../../shared/widgets/flag_button.dart';

class IndexCard extends StatelessWidget {
  const IndexCard(this.entry, {super.key});
  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.go('/entry/${entry.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headword with flags
              Row(
                children: [
                  Expanded(child: Text(entry.headword, style: context.styles.titleLarge)),
                  if (entry.flags.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    ...entry.flags
                        .map<Widget>((number) {
                          final flag = Flag.fromNumber(number);
                          return FlagButton(flag: flag);
                        })
                        .intersperse(const SizedBox(width: 4)),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Definition
              Text(entry.definition, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              // Updated at
              Text(
                context.tr.updatedAt(entry.updatedAt.toRelativeTimeString(context)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
