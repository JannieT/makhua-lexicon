import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared/extensions.dart';
import '../../shared/services/service_locator.dart';
import '../list_manager.dart';

class LetterFilterBar extends StatelessWidget {
  const LetterFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = get<ListManager>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SignalBuilder(
          builder: (context) {
            final available = manager.availableLetters.value;

            return Row(
              children: <Widget>[
                ChoiceChip(
                  label: Text(context.tr.all),
                  selected: manager.letter == null,
                  onSelected: (_) => manager.selectLetter(null),
                  showCheckmark: false,
                ),
                ...alphabet.map(
                  (letter) => ChoiceChip(
                    label: Text(letter),
                    selected: manager.letter == letter,
                    onSelected: available.contains(letter)
                        ? (_) => manager.selectLetter(letter)
                        : null,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ].intersperse(const SizedBox(width: 4)).toList(),
            );
          },
        ),
      ),
    );
  }
}
