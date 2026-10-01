import 'package:makhua_lexicon/src/shared/models/entry.dart';
import 'package:makhua_lexicon/src/shared/services/database_service.dart';

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

Entry fakeEntry(String headword) {
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
