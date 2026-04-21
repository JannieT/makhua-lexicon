import 'dart:ui';

import 'package:flutter/material.dart';

import '../../shared/extensions.dart';

class LoadingTile extends StatelessWidget {
  const LoadingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _blurred(context, 'aneene', style: context.styles.titleLarge),
      subtitle: _blurred(
        context,
        'dono/donos; proprietario; senhor; chefe (de uma casa)',
        style: context.styles.bodyMedium,
      ),
    );
  }

  Widget _blurred(BuildContext context, String text, {TextStyle? style}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style?.copyWith(
          color: context.colors.onSurfaceVariant.withTransparency(0.4),
        ),
      ),
    );
  }
}
