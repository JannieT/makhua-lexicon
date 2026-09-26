import 'package:go_router/go_router.dart';

import '../shared/services/auth_service.dart';
import 'signin_screen.dart';

class AuthGuard {
  AuthGuard(this._auth);

  final AuthService _auth;

  Future<String?> redirect(GoRouterState state) async {
    final isAuthRoute = state.matchedLocation == SigninScreen.routeName;

    // Firebase restores a persisted session asynchronously, notably on web
    await _auth.ready();

    if (!_auth.isSignedIn && !isAuthRoute) return SigninScreen.routeName;
    if (_auth.isSignedIn && isAuthRoute) return '/';

    return null;
  }
}
