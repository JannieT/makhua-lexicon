import 'package:flutter/material.dart';

import '../shared/extensions.dart';

/// Placeholder for the list screen
class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  static const routeName = '/list';

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.tr.navList, style: context.styles.headlineMedium));
  }
}
