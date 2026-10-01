import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../export/widgets/export_button.dart';
import '../shared/extensions.dart';

/// Placeholder for the list screen
class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  static const routeName = '/list';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.isLargeWidth ? 28.0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Export relies on a browser download, so it is only available on web
          if (kIsWeb) const Align(alignment: Alignment.centerRight, child: ExportButton()),
          Expanded(
            child: Center(
              child: Text(context.tr.navList, style: context.styles.headlineMedium),
            ),
          ),
        ],
      ),
    );
  }
}
