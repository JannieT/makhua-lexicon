import 'package:flutter/material.dart';

import '../shared/extensions.dart';
import '../shared/models/flags.dart';

class FlagButton extends StatelessWidget {
  const FlagButton({super.key, required this.flag, this.isSelected = false, this.onTap});

  final Flag flag;
  final bool isSelected;
  final Function(Flag)? onTap;

  @override
  Widget build(BuildContext context) {
    final size = onTap == null ? 12.0 : 24.0;

    return GestureDetector(
      onTap: () => onTap?.call(flag),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(flag.color),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? context.colors.secondaryContainer : Colors.transparent,
            width: 5,
          ),
        ),
      ),
    );
  }
}
