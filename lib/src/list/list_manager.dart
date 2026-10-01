import 'package:signals/signals.dart';

import '../shared/models/async_state.dart';
import '../shared/models/entry.dart';
import '../shared/services/database_service.dart';

/// Letters offered by the list filter bar
const alphabet = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

class ListManager {
  ListManager(this._db);

  final DatabaseService _db;

  /// All entries in alphabetical order of their headword
  final _entriesState = Signal<AppAsyncState<List<Entry>>>(const AppAsyncIdle());
  AppAsyncState<List<Entry>> get entriesState => _entriesState.value;

  /// The letter headwords must start with, or null for all headwords
  final _letter = Signal<String?>(null);
  String? get letter => _letter.value;

  /// Selecting the current letter again clears the filter
  void selectLetter(String? value) => _letter.value = value == letter ? null : value;

  /// Entries filtered by the selected [letter]
  late final Computed<AppAsyncState<List<Entry>>> visibleState = computed(
    () => switch (_entriesState.value) {
      AppAsyncSuccess(:final data) when _letter.value != null => AppAsyncSuccess(
        data.where((e) => initialOf(e.headword) == _letter.value).toList(),
      ),
      final state => state,
    },
  );

  /// Letters that at least one headword starts with
  late final Computed<Set<String>> availableLetters = computed(
    () => switch (_entriesState.value) {
      AppAsyncSuccess(:final data) => data.map((e) => initialOf(e.headword)).toSet(),
      _ => const <String>{},
    },
  );

  Future<void> loadEntries() async {
    // Keep showing entries we already have while refreshing
    final hasEntries = _entriesState.value is AppAsyncSuccess;
    if (!hasEntries) _entriesState.value = const AppAsyncLoading();

    try {
      final entries = await _db.getEntries();
      _entriesState.value = AppAsyncSuccess(sortedByHeadword(entries));
    } catch (_) {
      if (!hasEntries) {
        _entriesState.value = const AppAsyncFailure('Could not load entries');
      }
    }
  }

  /// Sorts ignoring case and accents, so "ápa" sits between "apa" and "aqa"
  static List<Entry> sortedByHeadword(List<Entry> entries) {
    return List<Entry>.from(entries)..sort((a, b) {
      final byKey = _fold(a.headword).compareTo(_fold(b.headword));
      return byKey != 0 ? byKey : a.headword.compareTo(b.headword);
    });
  }

  /// The uppercase A–Z letter a headword is filed under, or '' if it has none
  static String initialOf(String headword) {
    final folded = _fold(headword.trim());
    if (folded.isEmpty) return '';
    final initial = folded[0].toUpperCase();
    return alphabet.contains(initial) ? initial : '';
  }

  static String _fold(String text) {
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString();
  }

  static const _accents = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', //
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };
}
