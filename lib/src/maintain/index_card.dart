import 'package:flutter/material.dart';

import '../shared/models/entry.dart';

class IndexCard extends StatelessWidget {
  const IndexCard(this.entry, {super.key});
  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: [Text(entry.headword)]));
  }
}
