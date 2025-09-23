import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../settings/settings_screen.dart';
import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import '../shared/services/store_service.dart';
import '../shared/widgets/environment_label.dart';
import 'filter_bar.dart';
import 'index_grid.dart';

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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _signOut(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(SettingsView.routeName);
            },
          ),
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

  Future<void> _signOut(BuildContext context) async {
    final store = get<StoreService>();
    await store.clearCredentials();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    context.go('/signin');
  }
}
