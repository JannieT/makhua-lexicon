import 'package:firebase_auth/firebase_auth.dart';

/// Thrown by [AuthService] with a message fit to show the user.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

/// Wraps Firebase Auth. Firebase persists the session itself, so no
/// credentials are ever stored locally.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Completes once Firebase has restored any persisted session.
  Future<void> ready() => _auth.authStateChanges().first;

  bool get isSignedIn => _auth.currentUser != null;

  String? get email => _auth.currentUser?.email;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(switch (e.code) {
        'user-not-found' => 'User does not exist with the given email',
        'wrong-password' || 'invalid-credential' => 'Invalid email or password',
        _ => 'Something went wrong, please try again',
      });
    }
  }

  Future<void> signOut() => _auth.signOut();
}
