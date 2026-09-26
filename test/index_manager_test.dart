import 'package:flutter_test/flutter_test.dart';
import 'package:makhua_lexicon/src/index/index_manager.dart';
import 'package:makhua_lexicon/src/shared/models/async_state.dart';
import 'package:makhua_lexicon/src/shared/models/entry.dart';
import 'package:makhua_lexicon/src/shared/services/database_service.dart';

import 'doubles/fake_auth_service.dart';

class FakeDatabaseService implements DatabaseService {
  List<Entry> stored = [];
  bool fail = false;

  @override
  Future<List<Entry>> getEntries() async {
    if (fail) throw Exception('offline');
    return stored;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Entry _entry(String headword) {
  final now = DateTime(2026);
  return Entry(
    id: headword,
    headword: headword,
    definition: '',
    flags: [1],
    createdAt: now,
    updatedAt: now,
    updatedBy: '',
  );
}

void main() {
  late FakeDatabaseService db;
  late IndexManager manager;

  setUp(() {
    db = FakeDatabaseService();
    manager = IndexManager(FakeAuthService(), db);
  });

  tearDown(() => manager.dispose());

  test('load success exposes entries', () async {
    db.stored = [_entry('nyuwo')];

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
    db.stored = [_entry('nyuwo')];
    await manager.loadEntries();

    db.fail = true;
    await manager.loadEntries();

    expect(manager.loadState, isA<AppAsyncSuccess<bool>>());
    expect(manager.gridEntries.value, hasLength(1));
  });
}
