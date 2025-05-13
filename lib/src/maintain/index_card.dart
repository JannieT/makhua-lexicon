import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/extensions.dart';
import '../shared/models/entry.dart';

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
                  Expanded(
                    child: Text(entry.headword, style: context.styles.titleLarge),
                  ),
                  if (entry.flags.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 4,
                      children:
                          entry.flags.map((flag) {
                            final color = switch (flag) {
                              1 => context.colors.primary,
                              2 => context.colors.secondary,
                              3 => context.colors.tertiary,
                              _ => context.colors.primary,
                            };
                            return Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Definition
              Text(
                entry.definition,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              // Updated at
              Text(
                context.tr.updatedAt(_formatDate(context, entry.updatedAt)),
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

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return context.tr.timeAgoMinutes(difference.inMinutes);
      }
      return context.tr.timeAgoHours(difference.inHours);
    }

    if (difference.inDays < 7) {
      return context.tr.timeAgoDays(difference.inDays);
    }

    if (difference.inDays < 30) {
      return context.tr.timeAgoWeeks(difference.inDays ~/ 7);
    }

    if (difference.inDays < 365) {
      return context.tr.timeAgoMonths(difference.inDays ~/ 30);
    }

    return context.tr.timeAgoYears(difference.inDays ~/ 365);
  }
}
