import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../edit/entry_screen.dart';
import '../index/index_screen.dart';
import '../settings/settings_screen.dart';
import '../users/auth_guard.dart';
import '../users/signin_screen.dart';

final authGuard = AuthGuard();

final GoRouter routes = GoRouter(
  redirect: (context, state) async => await authGuard.redirect(state),
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const IndexScreen();
      },
      routes: [
        GoRoute(
          path: 'entry/:id',
          builder: (BuildContext context, GoRouterState state) {
            final entryId = state.pathParameters['id'];
            return EntryScreen(entryId);
          },
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
      path: SigninScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const SigninScreen();
      },
    ),
  ],
);
