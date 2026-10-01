import 'package:flutter_test/flutter_test.dart';
import 'package:makhua_lexicon/src/index/index_manager.dart';
import 'package:makhua_lexicon/src/shared/models/async_state.dart';

import 'doubles/fake_auth_service.dart';
import 'doubles/fake_database_service.dart';

void main() {
  late FakeDatabaseService db;
  late IndexManager manager;

  setUp(() {
    db = FakeDatabaseService();
    manager = IndexManager(FakeAuthService(), db);
  });

  tearDown(() => manager.dispose());

  test('load success exposes entries', () async {
    db.stored = [fakeEntry('nyuwo')];

    await manager.loadEntries();

    expect(manager.loadState, isA<AppAsyncSuccess<bool>>());
    expect(manager.gridEntries.value, hasLength(1));
    expect(manager.shouldShowEmpty, isFalse);
  });

  test('first load failure is a failure, not an empty index', () async {
    db.fail = true;

    await manager.loadEntries();

    expect(manager.loadState, isA<AppAsyncFailure<bool>>());
    expect(manager.shouldShowEmpty, isFalse);
  });

  test('failed refresh keeps previously loaded entries', () async {
    db.stored = [fakeEntry('nyuwo')];
    await manager.loadEntries();

    db.fail = true;
    await manager.loadEntries();

    expect(manager.loadState, isA<AppAsyncSuccess<bool>>());
    expect(manager.gridEntries.value, hasLength(1));
  });
}
