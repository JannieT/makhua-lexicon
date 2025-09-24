import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/models/flags.dart';
import '../shared/services/service_locator.dart';
import '../shared/widgets/environment_label.dart';
import '../shared/widgets/flag_button.dart';
import '../shared/widgets/not_found.dart';
import 'entry_manager.dart';

class EntryScreen extends StatefulWidget {
  final String? _entryId;
  const EntryScreen(this._entryId, {super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final EntryManager _manager;

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      if (_manager.entry == null) {
        return const NotFound();
      }

      final entry = _manager.entry!;
      return Scaffold(
        appBar: AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(entry.headword),
              SizedBox(width: 8),
              const EnvironmentLabel(),
            ],
          ),
          actions: [
            Watch((_) {
              if (!_manager.isDirty) return const SizedBox.shrink();
              return TextButton(onPressed: _onSave, child: Text(context.tr.save));
            }),
            IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Flags section
                    Text(
                      context.tr.flags,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: Flag.values.map((flag) {
                        return Watch((_) {
                          final isSelected = _manager.isFlagSelected(flag);
                          return FlagButton(
                            flag: flag,
                            isSelected: isSelected,
                            onTap: (flag) => _manager.toggleFlag(flag),
                          );
                        });
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Editable fields
                    TextFormField(
                      controller: _manager.definitionController,
                      decoration: InputDecoration(
                        labelText: context.tr.definition,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: _manager.validateDefinition,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _manager.exampleSentenceController,
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
          ),
        ),
      );
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _manager.saveEntry();

    if (!mounted) return;

    final feedback = success ? context.tr.changesSaved : context.tr.errorUpdatingEntry;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(feedback), behavior: SnackBarBehavior.floating),
    );
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              final success = await _manager.deleteEntry();
              if (!context.mounted) return;

              if (success) {
                // Pop the entry screen to close it
                Navigator.pop(context);
              } else {
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

  Future<void> _initializeEntry() async {
    await _manager.initializeEntry(widget._entryId);
  }

  @override
  void initState() {
    super.initState();
    _manager = get<EntryManager>();
    _initializeEntry();
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }
}
