import 'package:flutter/material.dart';

import '../../shared/extensions.dart';
import '../../shared/models/entry.dart';

class EntryMetadata extends StatelessWidget {
  final Entry entry;

  const EntryMetadata({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final updatedAt = entry.updatedAt.toRelativeTimeString(context);
    final updatedBy = entry.updatedBy;

    return Text(
      context.tr.lastUpdated(updatedAt, updatedBy),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
