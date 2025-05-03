import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/models/entry.dart';

enum IndexFilter { search, latest, flag1, flag2, flag3 }

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

  final searchController = TextEditingController();
  void onSearch(String value) {
    _filter.value = value.isEmpty ? IndexFilter.latest : IndexFilter.search;
    gridEntries.value = getFilteredEntries();
  }

  Future<void> _loadEntries() async {
    final fresh = await Future.delayed(
      const Duration(seconds: 1),
      () => mockEntries,
    );
    _allEntries.clear();
    _allEntries.addAll(fresh);
    gridEntries.value = getFilteredEntries();
  }

  void resetSearch() {
    searchController.clear();
  }

  List<Entry> getFilteredEntries() {
    var filtered = _allEntries;
    var flag = 3;

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
        return filtered.take(3).toList();

      case IndexFilter.flag1:
        flag = 1;
        break;
      case IndexFilter.flag2:
        flag = 2;
        break;
      case IndexFilter.flag3:
        flag = 3;
        break;
    }

    return filtered.where((entry) => entry.flags.contains(flag)).toList();
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
    partOfSpeech: 'Interjeição',
    definition: 'Expressão de dor ou surpresa',
    exampleSentence: 'Ai! Meu dedo!',
    flags: [3],
    createdAt: DateTime.now().subtract(const Duration(days: 200)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
