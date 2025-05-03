import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'signin_screen.dart';

class AuthGuard {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? redirect(GoRouterState state) {
    final isAuthRoute = state.matchedLocation == SigninScreen.routeName;
    final isAuthenticated = _auth.currentUser != null;

    if (!isAuthenticated && !isAuthRoute) {
      return SigninScreen.routeName;
    }

    if (isAuthenticated && isAuthRoute) {
      return '/';
    }

    return null;
  }
}
