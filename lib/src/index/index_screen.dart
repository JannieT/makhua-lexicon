import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../export/export_screen.dart';
import '../settings/settings_screen.dart';
import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import '../shared/services/store_service.dart';
import '../shared/widgets/environment_label.dart';
import 'widgets/filter_bar.dart';
import 'widgets/index_grid.dart';

/// Placeholder for home screen
class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(context.tr.appTitle),
            SizedBox(width: 8),
            const EnvironmentLabel(),
          ],
        ),
        actions: [
          // Only show export button on web platform
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                context.push(ExportScreen.routeName);
              },
            ),
          _UserMenuButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FilterBar(),
            Expanded(child: IndexGrid()),
          ],
        ),
      ),
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  const _UserMenuButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'preferences':
            context.push(SettingsView.routeName);
            break;
          case 'logout':
            await _signOut(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'preferences',
          child: Row(
            children: [Icon(Icons.settings), SizedBox(width: 8), Text('Preferences')],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Logout')]),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_userLabel, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String get _userLabel {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.split('@').first;

    if (email == null) return 'User';

    return email.isNotEmpty
        ? '${email[0].toUpperCase()}${email.substring(1).toLowerCase()}'
        : 'User';
  }

  Future<void> _signOut(BuildContext context) async {
    final store = get<StoreService>();
    await store.clearCredentials();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    context.go('/signin');
  }
}
