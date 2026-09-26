import 'package:flutter_test/flutter_test.dart';
import 'package:makhua_lexicon/src/shared/models/async_state.dart';
import 'package:makhua_lexicon/src/shared/services/auth_service.dart';
import 'package:makhua_lexicon/src/users/auth_manager.dart';

import 'doubles/fake_auth_service.dart';

void main() {
  late FakeAuthService authService;
  late AuthManager manager;

  setUp(() {
    authService = FakeAuthService();
    manager = AuthManager(authService);
  });

  test('successful login', () async {
    final success = await manager.login('geraldo@example.com', 'secret');

    expect(success, isTrue);
    expect(manager.loginState, isA<AppAsyncSuccess<bool>>());
    expect(manager.userLabel, 'Geraldo');
  });

  test('auth failure surfaces the service message', () async {
    authService.signInError = const AuthException('Invalid email or password');

    final success = await manager.login('geraldo@example.com', 'wrong');

    expect(success, isFalse);
    final state = manager.loginState as AppAsyncFailure<bool>;
    expect(state.message, 'Invalid email or password');
  });

  test('unexpected failure falls back to a generic message', () async {
    authService.signInError = Exception('offline');

    await manager.login('geraldo@example.com', 'secret');

    expect(manager.loginState, isA<AppAsyncFailure<bool>>());
  });

  test('sign out resets login state', () async {
    await manager.login('geraldo@example.com', 'secret');

    await manager.signOut();

    expect(authService.isSignedIn, isFalse);
    expect(manager.loginState, isA<AppAsyncIdle<bool>>());
    expect(manager.userLabel, 'User');
  });
}
