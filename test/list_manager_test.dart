import 'package:flutter_test/flutter_test.dart';
import 'package:makhua_lexicon/src/list/list_manager.dart';
import 'package:makhua_lexicon/src/shared/models/async_state.dart';
import 'package:makhua_lexicon/src/shared/models/entry.dart';

import 'doubles/fake_database_service.dart';

List<String> _headwords(AppAsyncState<List<Entry>> state) => switch (state) {
  AppAsyncSuccess(:final data) => data.map((e) => e.headword).toList(),
  _ => fail('expected success, got $state'),
};

void main() {
  late FakeDatabaseService db;
  late ListManager manager;

  setUp(() {
    db = FakeDatabaseService();
    manager = ListManager(db);
  });

  test('sorts headwords ignoring case and accents', () async {
    db.stored = ['nyuwo', 'Ápa', 'apa', 'mwana', 'aqa'].map(fakeEntry).toList();

    await manager.loadEntries();

    expect(_headwords(manager.visibleState.value), [
      'apa',
      'Ápa',
      'aqa',
      'mwana',
      'nyuwo',
    ]);
  });

  test('filters by first letter and toggles back to all', () async {
    db.stored = ['apa', 'ékuma', 'epheyo', 'mwana'].map(fakeEntry).toList();
    await manager.loadEntries();

    manager.selectLetter('E');
    expect(_headwords(manager.visibleState.value), ['ékuma', 'epheyo']);

    manager.selectLetter('E');
    expect(manager.letter, isNull);
    expect(_headwords(manager.visibleState.value), hasLength(4));
  });

  test('available letters only include letters with headwords', () async {
    db.stored = ['apa', 'Mwana', "'nlopwana"].map(fakeEntry).toList();

    await manager.loadEntries();

    expect(manager.availableLetters.value, {'A', 'M', ''});
  });

  test('first load failure is a failure', () async {
    db.fail = true;

    await manager.loadEntries();

    expect(manager.visibleState.value, isA<AppAsyncFailure<List<Entry>>>());
  });

  test('failed refresh keeps previously loaded entries', () async {
    db.stored = [fakeEntry('apa')];
    await manager.loadEntries();

    db.fail = true;
    await manager.loadEntries();

    expect(_headwords(manager.visibleState.value), ['apa']);
  });
}
