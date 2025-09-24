import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../index/index_manager.dart';
import '../shared/models/entry.dart';
import '../shared/models/flags.dart';
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

  // Getters
  Entry? get entry => _entry.value;
  bool get isDirty => _isDirty.value;
  List<Flag> get selectedFlags => _selectedFlags.value;
  String? get error => _errorSignal.value;
  TextEditingController get definitionController => _definitionController;
  TextEditingController get exampleSentenceController => _exampleSentenceController;

  EntryManager(this._storeService, this._indexManager) {
    _definitionController = TextEditingController();
    _exampleSentenceController = TextEditingController();

    // Listen to text changes to update dirty state
    _definitionController.addListener(_onTextChanged);
    _exampleSentenceController.addListener(_onTextChanged);
  }

  void dispose() {
    _definitionController.dispose();
    _exampleSentenceController.dispose();
  }

  /// Initialize the manager with an entry
  void initializeEntry(String? entryId) {
    final found = _indexManager.getEntry(entryId);
    if (found == null) {
      _entry.value = null;
      return;
    }

    _entry.value = found;
    _definitionController.text = found.definition;
    _exampleSentenceController.text = found.exampleSentence ?? '';
    _selectedFlags.value = found.flags.map((n) => Flag.fromNumber(n)).toList();
    _isDirty.value = false;
    _errorSignal.value = null;
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

  /// Save the current entry
  Future<bool> saveEntry() async {
    if (_entry.value == null) return false;

    try {
      _errorSignal.value = null;

      final entry = _entry.value!;
      final updatedEntry = entry.copyWith(
        definition: _definitionController.text,
        exampleSentence: _exampleSentenceController.text,
        flags: _selectedFlags.value.map((f) => f.number).toList(),
        updatedAt: DateTime.now(),
        updatedBy: _storeService.email ?? '',
      );

      await _indexManager.updateEntry(updatedEntry);
      _isDirty.value = false;
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
    if (value == null || value.isEmpty) {
      return 'Definition is required';
    }
    return null;
  }

  /// Clear any error state
  void clearError() {
    _errorSignal.value = null;
  }

  void _onTextChanged() {
    if (_entry.value == null) return;

    _isDirty.value =
        _definitionController.text != _entry.value!.definition ||
        _exampleSentenceController.text != (_entry.value!.exampleSentence ?? '') ||
        _selectedFlags.value.map((f) => f.number).toList() != _entry.value!.flags;
  }
}
