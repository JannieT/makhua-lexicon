import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../index/index_manager.dart';
import '../shared/models/async_state.dart';
import '../shared/models/entry.dart';
import '../shared/models/flags.dart';
import '../shared/models/translation.dart';
import '../shared/services/database_service.dart';
import '../shared/services/service_locator.dart';
import '../shared/services/store_service.dart';

class EntryManager {
  final StoreService _storeService;
  final IndexManager _indexManager;

  // State signals
  /// Success with a null entry means the entry does not exist.
  final _entryState = Signal<AppAsyncState<Entry?>>(const AppAsyncIdle());
  final _saveState = Signal<AppAsyncState<bool>>(const AppAsyncIdle());
  final _deleteState = Signal<AppAsyncState<bool>>(const AppAsyncIdle());
  final _isDirty = signal<bool>(false);
  final _selectedFlags = signal<List<Flag>>([]);

  // Text controllers
  late final TextEditingController _definitionController;
  late final TextEditingController _exampleSentenceController;
  late final TextEditingController _portugueseDescriptionController;
  late final TextEditingController _englishDescriptionController;

  // Tag editor state
  final _inflections = signal<List<String>>([]);
  final _portugueseHeadwords = signal<List<String>>([]);
  final _englishHeadwords = signal<List<String>>([]);

  // Getters
  AppAsyncState<Entry?> get entryState => _entryState.value;
  AppAsyncState<bool> get saveState => _saveState.value;
  AppAsyncState<bool> get deleteState => _deleteState.value;
  Entry? get entry => switch (_entryState.value) {
    AppAsyncSuccess(:final data) => data,
    _ => null,
  };
  bool get isDirty => _isDirty.value;
  List<Flag> get selectedFlags => _selectedFlags.value;
  TextEditingController get definitionController => _definitionController;
  TextEditingController get exampleSentenceController => _exampleSentenceController;
  TextEditingController get portugueseDescriptionController =>
      _portugueseDescriptionController;
  TextEditingController get englishDescriptionController => _englishDescriptionController;
  List<String> get inflections => _inflections.value;
  List<String> get portugueseHeadwords => _portugueseHeadwords.value;
  List<String> get englishHeadwords => _englishHeadwords.value;

  EntryManager(this._storeService, this._indexManager) {
    _definitionController = TextEditingController();
    _exampleSentenceController = TextEditingController();
    _portugueseDescriptionController = TextEditingController();
    _englishDescriptionController = TextEditingController();

    // Listen to text changes to update dirty state
    _definitionController.addListener(_onTextChanged);
    _exampleSentenceController.addListener(_onTextChanged);
    _portugueseDescriptionController.addListener(_onTextChanged);
    _englishDescriptionController.addListener(_onTextChanged);
  }

  void dispose() {
    _definitionController.dispose();
    _exampleSentenceController.dispose();
    _portugueseDescriptionController.dispose();
    _englishDescriptionController.dispose();
  }

  /// Initialize the manager with an entry
  Future<void> initializeEntry(String? entryId) async {
    if (entryId == null) {
      _entryState.value = const AppAsyncIdle();
      return;
    }

    _entryState.value = const AppAsyncLoading();
    try {
      final databaseService = get<DatabaseService>();
      final found = await databaseService.getEntry(entryId);

      if (found == null) {
        _entryState.value = const AppAsyncSuccess(null);
        return;
      }

      _definitionController.text = found.definition;
      _exampleSentenceController.text = found.exampleSentence ?? '';
      _selectedFlags.value = found.flags.map((n) => Flag.fromNumber(n)).toList();

      // Initialize inflections from comma-separated string
      _inflections.value = found.inflectionsList;

      // Initialize Portuguese translation
      _portugueseDescriptionController.text =
          found.portugueseTranslation?.description ?? '';
      _portugueseHeadwords.value = found.portugueseHeadwordsList;

      // Initialize English translation
      _englishDescriptionController.text = found.englishTranslation?.description ?? '';
      _englishHeadwords.value = found.englishHeadwordsList;

      _isDirty.value = false;
      _entryState.value = AppAsyncSuccess(found);
    } catch (e) {
      log('Error fetching entry: $e');
      _entryState.value = const AppAsyncFailure('Could not load entry');
    }
  }

  /// Toggle a flag selection
  void toggleFlag(Flag flag) {
    final flags = List<Flag>.from(_selectedFlags.value);
    final isSelected = flags.contains(flag);

    if (isSelected) {
      flags.remove(flag);
    } else {
      flags.add(flag);
    }

    _selectedFlags.value = flags;
    _isDirty.value = true;
  }

  /// Check if a flag is selected
  bool isFlagSelected(Flag flag) {
    return _selectedFlags.value.contains(flag);
  }

  /// Update inflections
  void updateInflections(List<String> inflections) {
    _inflections.value = inflections;
    _isDirty.value = true;
  }

  /// Update Portuguese headwords
  void updatePortugueseHeadwords(List<String> headwords) {
    _portugueseHeadwords.value = headwords;
    _isDirty.value = true;
  }

  /// Update English headwords
  void updateEnglishHeadwords(List<String> headwords) {
    _englishHeadwords.value = headwords;
    _isDirty.value = true;
  }

  /// Save the current entry
  Future<bool> saveEntry() async {
    final current = entry;
    if (current == null) return false;

    _saveState.value = const AppAsyncLoading();
    try {
      final updatedEntry = current.copyWith(
        definition: _definitionController.text,
        exampleSentence: _exampleSentenceController.text,
        inflections: _inflections.value.join(','),
        portugueseTranslation: Translation(
          headwords: _portugueseHeadwords.value.join(','),
          description: _portugueseDescriptionController.text,
        ),
        englishTranslation: Translation(
          headwords: _englishHeadwords.value.join(','),
          description: _englishDescriptionController.text,
        ),
        flags: _selectedFlags.value.map((f) => f.number).toList(),
        updatedAt: DateTime.now(),
        updatedBy: _storeService.email ?? '',
      );

      await _indexManager.updateEntry(updatedEntry);
      _isDirty.value = false;

      // Allow any reactive updates to complete before assigning
      await Future.delayed(Duration.zero);

      _entryState.value = AppAsyncSuccess(updatedEntry);
      _saveState.value = const AppAsyncSuccess(true);
      return true;
    } catch (e) {
      log('Error updating entry: $e');
      _saveState.value = const AppAsyncFailure('Could not save entry');
      return false;
    }
  }

  /// Delete the current entry
  Future<bool> deleteEntry() async {
    final current = entry;
    if (current == null) return false;

    _deleteState.value = const AppAsyncLoading();
    try {
      await _indexManager.deleteEntry(current.id);
      _deleteState.value = const AppAsyncSuccess(true);
      return true;
    } catch (e) {
      log('Error deleting entry: $e');
      _deleteState.value = const AppAsyncFailure('Could not delete entry');
      return false;
    }
  }

  /// Validate the current form data
  String? validateDefinition(String? value) {
    // if (value == null || value.isEmpty) {
    //   return 'Definition is required';
    // }
    return null;
  }

  void _onTextChanged() {
    final current = entry;
    if (current == null) return;

    final originalInflections = current.inflectionsList;
    final originalPortugueseHeadwords = current.portugueseHeadwordsList;
    final originalPortugueseDescription =
        current.portugueseTranslation?.description ?? '';
    final originalEnglishHeadwords = current.englishHeadwordsList;
    final originalEnglishDescription =
        current.englishTranslation?.description ?? '';

    _isDirty.value =
        _definitionController.text != current.definition ||
        _exampleSentenceController.text != (current.exampleSentence ?? '') ||
        _inflections.value != originalInflections ||
        _portugueseDescriptionController.text != originalPortugueseDescription ||
        _portugueseHeadwords.value != originalPortugueseHeadwords ||
        _englishDescriptionController.text != originalEnglishDescription ||
        _englishHeadwords.value != originalEnglishHeadwords ||
        _selectedFlags.value.map((f) => f.number).toList() != current.flags;
  }
}
