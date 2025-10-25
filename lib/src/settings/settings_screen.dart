import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import 'settings_manager.dart';

/// Displays the various settings that can be customized by the user.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Selection
            Text(context.tr.systemTheme, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Watch((_) {
              final themeMode = get<SettingsManager>().themeMode;

              return DropdownButton<ThemeMode>(
                value: themeMode,
                onChanged: get<SettingsManager>().updateThemeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(context.tr.systemTheme),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(context.tr.lightTheme),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(context.tr.darkTheme),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            // Language Selection
            Text(context.tr.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Watch((_) {
              final currentLanguage = get<SettingsManager>().language;

              return DropdownButton<String>(
                value: currentLanguage,
                onChanged: (String? newLanguage) {
                  if (newLanguage != null) {
                    get<SettingsManager>().updateLanguage(newLanguage);
                  }
                },
                items: [
                  DropdownMenuItem(value: 'en', child: Text(context.tr.english)),
                  DropdownMenuItem(value: 'pt', child: Text(context.tr.portuguese)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
