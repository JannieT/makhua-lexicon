import 'package:flutter/material.dart';

import '../../shared/extensions.dart';
import '../../shared/models/entry.dart';

class TagEditor extends StatefulWidget {
  final String? initialValue;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<List<String>>? onChanged;
  final bool enabled;

  const TagEditor({
    super.key,
    this.initialValue,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final List<String> _tags = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeTags();
    _focusNode.addListener(_onFocusChanged);
  }

  void _initializeTags() {
    _tags.addAll(Entry.parseCommaSeparatedString(widget.initialValue));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
      });
      _textController.clear();
      widget.onChanged?.call(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onChanged?.call(_tags);
  }

  String? _validate() {
    if (widget.validator != null) {
      return widget.validator!(_tags.join(','));
    }
    return null;
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chromeColor = _isFocused
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
    final chromeWidth = _isFocused ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 7),
              decoration: BoxDecoration(
                border: Border.all(color: chromeColor, width: chromeWidth),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags display
                  if (_tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) => _buildTag(tag)).toList(),
                      ),
                    ),
                  // Input field
                  TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? 'Add ${widget.label.toLowerCase()}...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (value) {
                      _addTag(value);
                    },
                    onChanged: (value) {
                      // Add tag when comma is entered
                      if (value.contains(',')) {
                        final parts = value.split(',');
                        for (final part in parts) {
                          _addTag(part);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            // Floating label
            Positioned(
              left: 12,
              top: _isFocused ? 1 : 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Text(
                  widget.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: chromeColor),
                ),
              ),
            ),
          ],
        ),
        if (widget.validator != null)
          Builder(
            builder: (context) {
              final error = _validate();
              if (error != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withTransparency(0.3),
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withTransparency(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
