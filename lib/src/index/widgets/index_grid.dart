import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared/extensions.dart';
import '../../shared/models/async_state.dart';
import '../../shared/models/entry.dart';
import '../../shared/services/service_locator.dart';
import '../../shared/widgets/error_banner.dart';
import '../index_manager.dart';
import 'index_card.dart';
import 'index_tile.dart';
import 'loading_card.dart';
import 'loading_tile.dart';
import 'new_card.dart';
import 'new_tile.dart';

/// Width below which entries are rendered as a vertical list of tiles
/// instead of a grid of cards.
const _listBreakpoint = 600.0;

class IndexGrid extends StatefulWidget {
  const IndexGrid({super.key});

  @override
  State<IndexGrid> createState() => _IndexGridState();
}

class _IndexGridState extends State<IndexGrid> {
  bool _hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    final manager = get<IndexManager>();

    return SignalBuilder(
      builder: (context) => switch (manager.loadState) {
        AppAsyncFailure(:final message) => Align(
          alignment: Alignment.topCenter,
          child: ErrorBanner(message: message, onRetry: manager.loadEntries),
        ),
        AppAsyncSuccess() when manager.shouldShowEmpty => const EmptyWidget(),
        final state => _buildEntries(
          manager,
          manager.gridEntries.value,
          isLoading: state is! AppAsyncSuccess,
        ),
      },
    );
  }

  Widget _buildEntries(
    IndexManager manager,
    List<Entry> entries, {
    required bool isLoading,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < _listBreakpoint) {
          return _buildList(manager, entries, isLoading);
        }
        return _buildGrid(manager, entries, width, isLoading);
      },
    );
  }

  Widget _buildGrid(
    IndexManager manager,
    List<Entry> entries,
    double width,
    bool isLoading,
  ) {
    final crossAxisCount = switch (width) {
      < 900 => 3,
      < 1200 => 4,
      _ => 4,
    };
    final cards = _cardList(manager, entries, isLoading);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildList(IndexManager manager, List<Entry> entries, bool isLoading) {
    final tiles = _tileList(manager, entries, isLoading);

    return ListView.separated(
      itemCount: tiles.length,
      itemBuilder: (context, index) => tiles[index],
      separatorBuilder: (_, _) => const Divider(height: 1),
    );
  }

  List<Widget> _cardList(IndexManager manager, List<Entry> entries, bool isLoading) {
    if (isLoading) {
      return List.generate(4, (index) => const LoadingCard());
    }

    final add = manager.showAddCard
        ? <Widget>[NewCard(manager.searchController.text)]
        : <Widget>[];
    final found = entries.map<Widget>((e) => IndexCard(e)).toList();

    return [...found, ...add];
  }

  List<Widget> _tileList(IndexManager manager, List<Entry> entries, bool isLoading) {
    if (isLoading) {
      return List.generate(6, (index) => const LoadingTile());
    }

    final add = manager.showAddCard
        ? <Widget>[NewTile(manager.searchController.text)]
        : <Widget>[];
    final found = entries.map<Widget>((e) => IndexTile(e)).toList();

    return [...found, ...add];
  }

  Future<void> _loadEntriesIfAuthenticated() async {
    // Wait for authentication to be ready
    await Future.delayed(const Duration(milliseconds: 100));

    if (FirebaseAuth.instance.currentUser != null && !_hasLoaded) {
      final manager = get<IndexManager>();
      await manager.loadEntries();
      _hasLoaded = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEntriesIfAuthenticated();
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.tr.noEntriesFound,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
