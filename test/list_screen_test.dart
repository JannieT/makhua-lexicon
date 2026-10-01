import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhua_lexicon/src/list/list_manager.dart';
import 'package:makhua_lexicon/src/list/list_screen.dart';
import 'package:makhua_lexicon/src/localization/app_localizations.dart';
import 'package:makhua_lexicon/src/shared/models/entry.dart';
import 'package:makhua_lexicon/src/shared/services/service_locator.dart';

import 'doubles/fake_database_service.dart';

/// Answers only when [respond] is called, like a real network request.
/// Create it inside the test body so its future completes in the test's fake async zone.
class SlowDatabaseService extends FakeDatabaseService {
  final _response = Completer<List<Entry>>();

  void respond(List<Entry> entries) => _response.complete(entries);

  @override
  Future<List<Entry>> getEntries() => _response.future;
}

void main() {
  tearDown(() => get.reset());

  testWidgets('shows headwords once the slow load completes', (tester) async {
    final db = SlowDatabaseService();
    get.registerSingleton<ListManager>(ListManager(db));

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: ListScreen()),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    db.respond([fakeEntry('mwana'), fakeEntry('apa')]);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('apa'), findsOneWidget);
    expect(find.text('mwana'), findsOneWidget);
  });
}
