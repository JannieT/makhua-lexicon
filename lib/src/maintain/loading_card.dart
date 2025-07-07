import 'dart:ui';

import 'package:flutter/material.dart';

import '../shared/extensions.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final grey = context.colors.onSurfaceVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headword with flags
            Row(
              children: [
                Expanded(child: _blurredBox(context, text: 'aneene')),
                ...[const SizedBox(width: 8), Wrap(spacing: 4, children: _dots(grey))],
              ],
            ),
            const SizedBox(height: 8),
            // Definition
            _blurredBox(
              context,
              text:
                  'dono/donos; proprietario; senhor; chefe (de uma casa); possuidor de uma coisa',
            ),
            const Spacer(),
            // Updated at
            _blurredBox(context, text: 'Updated: 2w ago'),
          ],
        ),
      ),
    );
  }

  Widget _blurredBox(BuildContext context, {required String text}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Text(
        text,
        style: context.styles.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant.withTransparency(0.4),
        ),
      ),
    );
  }

  List<Widget> _dots(Color grey) {
    // final dotCount = Random().nextInt(4);
    final dotCount = 0;
    return List.generate(
      dotCount,
      (index) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: grey, shape: BoxShape.circle),
      ),
    );
  }
}
