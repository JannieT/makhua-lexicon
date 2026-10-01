import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../export/widgets/export_button.dart';
import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import 'list_manager.dart';
import 'widgets/headword_list.dart';
import 'widgets/letter_filter_bar.dart';

/// All headwords in alphabetical order, filterable by first letter
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  static const routeName = '/list';

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.isLargeWidth ? 28.0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: LetterFilterBar()),
              // Export relies on a browser download, so it is only available on web
              if (kIsWeb) ...[const SizedBox(width: 16), const ExportButton()],
            ],
          ),
          const SizedBox(height: 8),
          const Expanded(child: HeadwordList()),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load here, before the children subscribe: writing the state from a child's
    // initState would notify the filter bar mid-build and abort the load
    get<ListManager>().loadEntries();
  }
}
