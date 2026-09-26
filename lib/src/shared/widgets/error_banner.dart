import 'package:flutter/material.dart';

import '../extensions.dart';

/// Inline display for an `AppAsyncFailure` message, with an optional retry.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final onColor = context.colors.onErrorContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: onColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.styles.bodyMedium?.copyWith(color: onColor),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: Icon(Icons.refresh, color: onColor),
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}
