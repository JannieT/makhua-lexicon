import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../edit/entry_screen.dart';
import '../export/export_screen.dart';
import '../index/index_screen.dart';
import '../list/list_screen.dart';
import '../settings/settings_screen.dart';
import '../users/auth_guard.dart';
import '../users/signin_screen.dart';
import 'services/auth_service.dart';
import 'services/service_locator.dart';
import 'widgets/app_shell.dart';

final authGuard = AuthGuard(get<AuthService>());

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter routes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  redirect: (context, state) async => await authGuard.redirect(state),
  routes: <RouteBase>[
    // Each branch keeps its own state and switching between them has no page transition
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
        return AppShell(navigationShell: shell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: IndexScreen.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const IndexScreen();
              },
              routes: [
                // Entry has its own app bar, so it pushes over the shell
                GoRoute(
                  path: 'entry/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    final entryId = state.pathParameters['id'];
                    return EntryScreen(entryId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: ListScreen.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const ListScreen();
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: SettingsView.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsView();
      },
    ),
    GoRoute(
      path: ExportScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const ExportScreen();
      },
    ),
    GoRoute(
      path: SigninScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const SigninScreen();
      },
    ),
  ],
);
