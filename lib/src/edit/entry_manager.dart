import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../index/index_manager.dart';
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
  final _entry = signal<Entry?>(null);
  final _isDirty = signal<bool>(false);
  final _selectedFlags = signal<List<Flag>>([]);
  final _errorSignal = signal<String?>(null);

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
  Entry? get entry => _entry.value;
  bool get isDirty => _isDirty.value;
  List<Flag> get selectedFlags => _selectedFlags.value;
  String? get error => _errorSignal.value;
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
      _entry.value = null;
      return;
    }

    try {
      _errorSignal.value = null;
      final databaseService = get<DatabaseService>();
      final found = await databaseService.getEntry(entryId);

      if (found == null) {
        _entry.value = null;
        _errorSignal.value = 'Entry not found';
        return;
      }

      _entry.value = found;
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
    } catch (e) {
      log('Error fetching entry: $e');
      _errorSignal.value = 'Failed to load entry: $e';
      _entry.value = null;
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
    if (_entry.value == null) return false;

    try {
      _errorSignal.value = null;

      final updatedEntry = _entry.value!.copyWith(
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

      _entry.value = updatedEntry;
      return true;
    } catch (e) {
      log('Error updating entry: $e');
      _errorSignal.value = 'Failed to save entry: $e';
      return false;
    }
  }

  /// Delete the current entry
  Future<bool> deleteEntry() async {
    if (_entry.value == null) return false;

    try {
      _errorSignal.value = null;
      await _indexManager.deleteEntry(_entry.value!.id);
      return true;
    } catch (e) {
      log('Error deleting entry: $e');
      _errorSignal.value = 'Failed to delete entry: $e';
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

  /// Clear any error state
  void clearError() {
    _errorSignal.value = null;
  }

  void _onTextChanged() {
    if (_entry.value == null) return;

    final originalInflections = _entry.value!.inflectionsList;
    final originalPortugueseHeadwords = _entry.value!.portugueseHeadwordsList;
    final originalPortugueseDescription =
        _entry.value!.portugueseTranslation?.description ?? '';
    final originalEnglishHeadwords = _entry.value!.englishHeadwordsList;
    final originalEnglishDescription =
        _entry.value!.englishTranslation?.description ?? '';

    _isDirty.value =
        _definitionController.text != _entry.value!.definition ||
        _exampleSentenceController.text != (_entry.value!.exampleSentence ?? '') ||
        _inflections.value != originalInflections ||
        _portugueseDescriptionController.text != originalPortugueseDescription ||
        _portugueseHeadwords.value != originalPortugueseHeadwords ||
        _englishDescriptionController.text != originalEnglishDescription ||
        _englishHeadwords.value != originalEnglishHeadwords ||
        _selectedFlags.value.map((f) => f.number).toList() != _entry.value!.flags;
  }
}
