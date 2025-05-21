import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/models/entry.dart';
import '../shared/models/flags.dart';

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
  IndexManager() {
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
    final fresh = await Future.delayed(const Duration(seconds: 2), () => mockEntries);
    _allEntries.clear();
    _allEntries.addAll(fresh);
    gridEntries.value = getFilteredEntries();
    _isBusy.value = false;
  }

  void resetSearch() {
    searchController.clear();
  }

  void createEntry(String headword) {
    final now = DateTime.now();
    final id = Entry.getValidFirestoreId(headword);

    final entry = Entry(
      id: id,
      headword: headword,
      definition: '',
      flags: [1], // default flag
      createdAt: now,
      updatedAt: now,
    );

    _allEntries.add(entry);

    // Reset the filter to latest to show the new entry
    filter = IndexFilter.latest;
  }

  void updateEntry(Entry entry) {
    final index = _allEntries.indexWhere((e) => e.id == entry.id);
    if (index == -1) return;

    _allEntries[index] = entry;
    gridEntries.value = getFilteredEntries();
  }

  Future<void> deleteEntry(String id) async {
    // await FirebaseFirestore.instance.collection('entries').doc(id).delete();
    _allEntries.removeWhere((entry) => entry.id == id);
    gridEntries.value = getFilteredEntries();
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

final List<Entry> mockEntries = [
  Entry(
    id: 'casa',
    headword: 'casa',
    partOfSpeech: 'Substantivo',
    definition: 'Edifício onde as pessoas vivem',
    exampleSentence: 'A minha casa é grande e confortável.',
    flags: [1, 2],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Entry(
    id: 'correr',
    headword: 'correr',
    partOfSpeech: 'Verbo',
    definition: 'Mover-se rapidamente usando os pés',
    exampleSentence: 'Ele gosta de correr todas as manhãs.',
    flags: [],
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    updatedAt: DateTime.now().subtract(const Duration(days: 60)),
  ),
  Entry(
    id: 'bonito',
    headword: 'bonito',
    partOfSpeech: 'Adjetivo',
    definition: 'Que tem beleza, que agrada à vista',
    exampleSentence: 'O vestido é muito bonito.',
    flags: [3],
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now().subtract(const Duration(days: 200)),
  ),
  Entry(
    id: 'rapidamente',
    headword: 'rapidamente',
    partOfSpeech: 'Advérbio',
    definition: 'De modo rápido, com velocidade',
    exampleSentence: 'Ele terminou o trabalho rapidamente.',
    flags: [1, 2, 3],
    createdAt: DateTime.now().subtract(const Duration(days: 500)),
    updatedAt: DateTime.now().subtract(const Duration(days: 400)),
  ),
  Entry(
    id: 'ele',
    headword: 'ele',
    partOfSpeech: 'Pronome',
    definition: 'Pronome pessoal da terceira pessoa do singular',
    exampleSentence: 'Ele está estudando para o exame.',
    flags: [],
    createdAt: DateTime.now().subtract(const Duration(days: 700)),
    updatedAt: DateTime.now().subtract(const Duration(days: 600)),
  ),
  Entry(
    id: 'primeiro',
    headword: 'primeiro',
    partOfSpeech: 'Numeral',
    definition: 'Que ocupa a posição inicial em uma sequência',
    exampleSentence: 'Ele foi o primeiro a chegar.',
    flags: [2],
    createdAt: DateTime.now().subtract(const Duration(days: 730)),
    updatedAt: DateTime.now().subtract(const Duration(days: 700)),
  ),
  Entry(
    id: 'com',
    headword: 'com',
    partOfSpeech: 'Preposição',
    definition: 'Indica companhia, instrumento ou modo',
    exampleSentence: 'Vou viajar com meus amigos.',
    flags: [],
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now().subtract(const Duration(days: 100)),
  ),
  Entry(
    id: 'mas',
    headword: 'mas',
    partOfSpeech: 'Conjunção',
    definition: 'Indica oposição ou contraste',
    exampleSentence: 'Quero ir, mas estou cansado.',
    flags: [1],
    createdAt: DateTime.now().subtract(const Duration(days: 400)),
    updatedAt: DateTime.now().subtract(const Duration(days: 50)),
  ),
  Entry(
    id: 'ai',
    headword: 'ai',
    partOfSpeech: null,
    definition: 'Expressão de dor ou surpresa',
    exampleSentence: 'Ai! Meu dedo!',
    flags: [3],
    createdAt: DateTime.now().subtract(const Duration(days: 200)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
