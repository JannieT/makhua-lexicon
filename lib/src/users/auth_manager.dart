import 'package:signals/signals.dart';

import '../shared/models/async_state.dart';
import '../shared/services/auth_service.dart';

class AuthManager {
  AuthManager(this._authService);

  final AuthService _authService;

  final _loginState = Signal<AppAsyncState<bool>>(const AppAsyncIdle());
  AppAsyncState<bool> get loginState => _loginState.value;

  /// The capitalised local part of the signed in user's email.
  String get userLabel {
    final name = _authService.email?.split('@').first;
    if (name == null || name.isEmpty) return 'User';
    return '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
  }

  Future<bool> login(String email, String password) async {
    _loginState.value = const AppAsyncLoading();
    try {
      await _authService.signIn(email: email, password: password);
      _loginState.value = const AppAsyncSuccess(true);
      return true;
    } on AuthException catch (e) {
      _loginState.value = AppAsyncFailure(e.message);
      return false;
    } catch (_) {
      _loginState.value = const AppAsyncFailure('Something went wrong, please try again');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    resetLoginState();
  }

  void resetLoginState() => _loginState.value = const AppAsyncIdle();
}
