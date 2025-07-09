import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/models/entry.dart';
import '../shared/models/flags.dart';
import '../shared/services/database_service.dart';
import '../shared/services/store_service.dart';

enum IndexFilter {
  search,
  latest,
  isDraft,
  needsReviewOne,
  needsReviewTwo;

  int get flagNumber => switch (this) {
    isDraft => 1,
    needsReviewOne => 2,
    needsReviewTwo => 3,
    _ => 0,
  };
}

class IndexManager {
  final StoreService _store;
  final DatabaseService _db;

  IndexManager(this._store, this._db) {
    _loadEntries();
  }

  final _allEntries = <Entry>[];
  final gridEntries = signal<List<Entry>>(<Entry>[]);
  final selectedFlag = signal<int?>(null);

  final _filter = signal<IndexFilter>(IndexFilter.latest);
  IndexFilter get filter => _filter.value;
  set filter(IndexFilter value) {
    _filter.value = value;
    if (value != IndexFilter.search) {
      searchController.clear();
    }
    gridEntries.value = getFilteredEntries();
  }

  void setFilterFlag(Flag flag) {
    final newFilter = switch (flag) {
      Flag.isDraft => IndexFilter.isDraft,
      Flag.needsReviewOne => IndexFilter.needsReviewOne,
      Flag.needsReviewTwo => IndexFilter.needsReviewTwo,
    };
    filter = newFilter;
  }

  final searchController = TextEditingController();
  void onSearch(String value) {
    _filter.value = value.isEmpty ? IndexFilter.latest : IndexFilter.search;
    gridEntries.value = getFilteredEntries();
  }

  final _isBusy = signal<bool>(false);
  bool get isBusy => _isBusy.value;
  bool get shouldShowEmpty =>
      !isBusy && searchController.text.isEmpty && gridEntries.value.isEmpty;

  Future<void> _loadEntries() async {
    _isBusy.value = true;
    // final fresh = await Future.delayed(const Duration(seconds: 2), () => mockEntries);
    final fresh = await _db.getEntries();
    _allEntries.clear();
    _allEntries.addAll(fresh);
    gridEntries.value = getFilteredEntries();
    _isBusy.value = false;
  }

  void resetSearch() {
    searchController.clear();
  }

  Future<void> createEntry(String headword) async {
    final now = DateTime.now();
    final id = Entry.getValidFirestoreId(headword);

    final entry = Entry(
      id: id,
      headword: headword,
      definition: '',
      flags: [1], // default flag
      createdAt: now,
      updatedAt: now,
      updatedBy: _store.email ?? '',
    );

    _allEntries.add(entry);

    // Reset the filter to latest to show the new entry
    filter = IndexFilter.latest;

    // Save to database
    await _db.addEntry(entry);
  }

  Future<void> updateEntry(Entry entry) async {
    final index = _allEntries.indexWhere((e) => e.id == entry.id);
    if (index == -1) return;

    _allEntries[index] = entry;
    gridEntries.value = getFilteredEntries();

    // Update the database
    await _db.updateEntry(entry);
  }

  Future<void> deleteEntry(String id) async {
    _allEntries.removeWhere((entry) => entry.id == id);
    gridEntries.value = getFilteredEntries();

    // Delete from database
    await _db.deleteEntry(id);
  }

  List<Entry> getFilteredEntries() {
    var filtered = _allEntries;

    switch (filter) {
      case IndexFilter.search:
        // Filter by search text
        return filtered
            .where(
              (entry) => entry.headword.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
              // ) ||
              // entry.definition.toLowerCase().contains(
              //   searchController.text.toLowerCase(),
              // ),
            )
            .toList();

      // Filter by latest entries
      case IndexFilter.latest:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return filtered.take(20).toList();

      default:
        return filtered
            .where((entry) => entry.flags.contains(filter.flagNumber))
            .toList();
    }
  }

  Entry? getEntry(String? id) {
    try {
      return _allEntries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    searchController.dispose();
  }
}
