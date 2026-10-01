import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../settings/settings_screen.dart';
import '../../users/auth_manager.dart';
import '../extensions.dart';
import '../services/service_locator.dart';
import 'environment_label.dart';

/// Common scaffold and app bar for the top-level screens
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  /// Branch order matches the branches of the shell route in routes.dart
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.isLargeWidth
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(context.tr.appTitle),
                  SizedBox(width: 8),
                  const EnvironmentLabel(),
                ],
              )
            : SizedBox.shrink(),
        actions: [
          _NavButton(
            icon: Icons.grid_view,
            label: context.tr.navIndex,
            branch: 0,
            navigationShell: navigationShell,
          ),
          _NavButton(
            icon: Icons.list,
            label: context.tr.navList,
            branch: 1,
            navigationShell: navigationShell,
          ),
          _UserMenuButton(),
        ],
      ),
      body: navigationShell,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.branch,
    required this.navigationShell,
  });

  final IconData icon;
  final String label;
  final int branch;
  final StatefulNavigationShell navigationShell;

  bool get _selected => navigationShell.currentIndex == branch;

  @override
  Widget build(BuildContext context) {
    final color = _selected ? context.colors.primary : context.colors.onSurfaceVariant;
    final onPressed = _selected ? null : () => navigationShell.goBranch(branch);

    if (!context.isLargeWidth) {
      return IconButton(
        icon: Icon(icon, color: color),
        tooltip: label,
        onPressed: onPressed,
      );
    }

    return TextButton.icon(
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      onPressed: onPressed,
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
            Text(
              get<AuthManager>().userLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await get<AuthManager>().signOut();
    if (!context.mounted) return;
    context.go('/signin');
  }
}
