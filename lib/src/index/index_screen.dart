import 'package:flutter/material.dart';

import '../shared/extensions.dart';
import 'widgets/filter_bar.dart';
import 'widgets/index_grid.dart';

/// Placeholder for home screen
class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.isLargeWidth ? 28.0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FilterBar(),
          Expanded(child: IndexGrid()),
        ],
      ),
    );
  }
}
