import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared/extensions.dart';
import '../../shared/models/async_state.dart';
import '../../shared/models/entry.dart';
import '../../shared/services/service_locator.dart';
import '../../shared/widgets/error_banner.dart';
import '../list_manager.dart';

class HeadwordList extends StatefulWidget {
  const HeadwordList({super.key});

  @override
  State<HeadwordList> createState() => _HeadwordListState();
}

class _HeadwordListState extends State<HeadwordList> {
  late final ListManager _list;

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) => switch (_list.visibleState.value) {
        AppAsyncSuccess(:final data) when data.isEmpty => Center(
          child: Text(context.tr.noEntriesFound, style: context.styles.bodyLarge),
        ),
        AppAsyncSuccess(:final data) => _buildList(data),
        AppAsyncFailure(:final message) => Align(
          alignment: Alignment.topCenter,
          child: ErrorBanner(message: message, onRetry: _list.loadEntries),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildList(List<Entry> entries) {
    return ListView.separated(
      itemCount: entries.length,
      itemBuilder: (context, index) => ListTile(title: Text(entries[index].headword)),
      separatorBuilder: (_, _) => const Divider(height: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    _list = get<ListManager>();
  }
}
