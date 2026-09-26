/// Sealed variant state for an async operation (e.g. a manager action driven
/// by a `Signal<AppAsyncState<T>>`), used instead of separate loading/error
/// booleans so widgets can switch exhaustively over what's actually possible.
sealed class AppAsyncState<T> {
  const AppAsyncState();
}

class AppAsyncIdle<T> extends AppAsyncState<T> {
  const AppAsyncIdle();
}

class AppAsyncLoading<T> extends AppAsyncState<T> {
  const AppAsyncLoading();
}

class AppAsyncSuccess<T> extends AppAsyncState<T> {
  const AppAsyncSuccess(this.data);
  final T data;
}

class AppAsyncFailure<T> extends AppAsyncState<T> {
  const AppAsyncFailure(this.message);
  final String message;
}
