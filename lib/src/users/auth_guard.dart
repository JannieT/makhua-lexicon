import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../shared/services/service_locator.dart';
import '../shared/services/store_service.dart';
import 'signin_screen.dart';

class AuthGuard {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> redirect(GoRouterState state) async {
    final isAuthRoute = state.matchedLocation == SigninScreen.routeName;
    final isAuthenticated = _auth.currentUser != null;

    // If not authenticated, try to auto-login with saved credentials
    if (!isAuthenticated) {
      final store = get<StoreService>();
      if (store.hasCredentials) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: store.email!,
            password: store.password!,
          );
          // Auto-login successful, user is now authenticated
          if (_auth.currentUser != null && isAuthRoute) {
            return '/';
          }
        } catch (e) {
          // Credentials no longer valid, clear them
          await store.clearCredentials();
        }
      }

      // Still not authenticated after auto-login attempt
      if (_auth.currentUser == null && !isAuthRoute) {
        return SigninScreen.routeName;
      }
    }

    if (isAuthenticated && isAuthRoute) {
      return '/';
    }

    return null;
  }
}
