import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/extensions.dart';
import '../../shared/models/entry.dart';
import '../../shared/models/flags.dart';
import '../../shared/widgets/flag_button.dart';

class IndexTile extends StatelessWidget {
  const IndexTile(this.entry, {super.key});
  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/entry/${entry.id}'),
      child: ListTile(
        title: Text(entry.headword, style: context.styles.titleLarge),
        subtitle: Text(entry.definition, style: context.styles.bodyMedium),
        trailing: entry.flags.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...entry.flags
                      .map<Widget>((number) {
                        final flag = Flag.fromNumber(number);
                        return FlagButton(flag: flag);
                      })
                      .intersperse(const SizedBox(width: 4)),
                ],
              )
            : null,
      ),
    );
  }
}
