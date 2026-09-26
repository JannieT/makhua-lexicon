import 'package:makhua_lexicon/src/shared/services/auth_service.dart';

class FakeAuthService implements AuthService {
  @override
  String? email;

  /// When set, [signIn] throws it.
  Object? signInError;

  @override
  bool get isSignedIn => email != null;

  @override
  Future<void> ready() async {}

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (signInError != null) throw signInError!;
    this.email = email;
  }

  @override
  Future<void> signOut() async => email = null;
}
