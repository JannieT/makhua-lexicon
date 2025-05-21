import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/models/entry.dart';
import '../shared/models/flags.dart';
import '../shared/models/parts_of_speech.dart';
import '../shared/services/service_locator.dart';
import '../shared/widgets/not_found.dart';
import 'flag_button.dart';
import 'index_manager.dart';

class EntryScreen extends StatefulWidget {
  final String? _entryId;
  const EntryScreen(this._entryId, {super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _definitionController;
  late final TextEditingController _exampleSentenceController;
  Entry? _entry;
  final _isDirty = signal<bool>(false);
  final _selectedFlags = signal<List<Flag>>([]);
  final _selectedPartOfSpeech = signal<PartOfSpeech?>(null);

  @override
  Widget build(BuildContext context) {
    if (_entry == null) {
      return const NotFound();
    }

    final entry = _entry!;
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.headword),
        actions: [
          Watch((_) {
            if (!_isDirty.value) return const SizedBox.shrink();
            return TextButton(onPressed: _onSave, child: Text(context.tr.save));
          }),
          IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Flags section
              Text(context.tr.flags, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    Flag.values.map((flag) {
                      return Watch((_) {
                        final isSelected = _selectedFlags.value.contains(flag);
                        return FlagButton(
                          flag: flag,
                          isSelected: isSelected,
                          onTap: (flag) {
                            final flags = List<Flag>.from(_selectedFlags.value);
                            if (isSelected) {
                              flags.remove(flag);
                            } else {
                              flags.add(flag);
                            }
                            _selectedFlags.value = flags;
                            _isDirty.value = true;
                          },
                        );
                      });
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Editable fields
              TextFormField(
                controller: _definitionController,
                decoration: InputDecoration(
                  labelText: context.tr.definition,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr.definitionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Watch((_) {
                return DropdownButtonFormField<PartOfSpeech?>(
                  value: _selectedPartOfSpeech.value,
                  decoration: InputDecoration(
                    labelText: context.tr.partOfSpeech,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<PartOfSpeech?>(
                      value: null,
                      child: Text(context.tr.none),
                    ),
                    ...PartOfSpeech.values.map((pos) {
                      return DropdownMenuItem(
                        value: pos,
                        child: Text(switch (pos) {
                          PartOfSpeech.noun => context.tr.noun,
                          PartOfSpeech.verb => context.tr.verb,
                          PartOfSpeech.adjective => context.tr.adjective,
                          PartOfSpeech.adverb => context.tr.adverb,
                          PartOfSpeech.pronoun => context.tr.pronoun,
                          PartOfSpeech.preposition => context.tr.preposition,
                          PartOfSpeech.conjunction => context.tr.conjunction,
                          PartOfSpeech.interjection => context.tr.interjection,
                        }),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    _selectedPartOfSpeech.value = value;
                    _isDirty.value = true;
                  },
                );
              }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _exampleSentenceController,
                decoration: InputDecoration(
                  labelText: context.tr.exampleSentence,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTextChanged() {
    _isDirty.value =
        _definitionController.text != _entry?.definition ||
        _selectedPartOfSpeech.value?.name != _entry?.partOfSpeech ||
        _exampleSentenceController.text != _entry?.exampleSentence ||
        _selectedFlags.value.map((f) => f.number).toList() != _entry?.flags;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final entry = _entry!;

    final updatedEntry = Entry(
      id: entry.id,
      headword: entry.headword,
      definition: _definitionController.text,
      partOfSpeech: _selectedPartOfSpeech.value?.name,
      exampleSentence: _exampleSentenceController.text,
      flags: _selectedFlags.value.map((f) => f.number).toList(),
      createdAt: entry.createdAt,
      updatedAt: DateTime.now(),
    );

    final manager = get<IndexManager>();
    manager.updateEntry(updatedEntry);
    _isDirty.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr.changesSaved),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr.deleteEntry),
            content: Text(context.tr.deleteEntryConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr.cancel),
              ),
              TextButton(
                onPressed: () async {
                  // Pop the dialog to close it
                  Navigator.pop(context);

                  // Delete the entry
                  final manager = get<IndexManager>();
                  try {
                    await manager.deleteEntry(_entry!.id);
                    if (!context.mounted) return;

                    // Pop the entry screen to close it
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr.errorDeletingEntry),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(context.tr.delete),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();

    final manager = get<IndexManager>();
    final found = manager.getEntry(widget._entryId);
    if (found == null) return;

    _entry = found;
    _definitionController = TextEditingController(text: _entry?.definition);
    _exampleSentenceController = TextEditingController(text: _entry?.exampleSentence);
    _selectedFlags.value = _entry?.flags.map((n) => Flag.fromNumber(n)).toList() ?? [];
    _selectedPartOfSpeech.value =
        _entry?.partOfSpeech != null
            ? PartOfSpeech.values.firstWhere(
              (pos) => pos.name == _entry?.partOfSpeech,
              orElse: () => PartOfSpeech.noun,
            )
            : null;

    // Listen to changes in the text controllers
    _definitionController.addListener(_onTextChanged);
    _exampleSentenceController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _definitionController.dispose();
    _exampleSentenceController.dispose();
    super.dispose();
  }
}
