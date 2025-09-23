import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../qa/config.dart';
import '../extensions.dart';

class EnvironmentLabel extends StatelessWidget {
  const EnvironmentLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final isStaging = Config.database == DatabaseInstance.staging;

    // Show label conditionally:
    // - Always show in debug mode
    // - Only show staging in release mode (production should never show)
    final shouldShow = kDebugMode || isStaging;

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final label = isStaging
        ? context.tr.stagingEnvironment
        : context.tr.productionEnvironment;
    final color = isStaging ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
