import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:bike_lock_doc/language_controller.dart';
import 'package:bike_lock_doc/main.dart';

/// Points the app's documents directory at a temporary folder.
class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  late Directory docs;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('bike_lock_test_');
    PathProviderPlatform.instance = _FakePathProvider(docs.path);
  });

  tearDown(() => docs.deleteSync(recursive: true));

  // Real file I/O must run outside the fake-async test zone.
  Future<T> io<T>(WidgetTester tester, Future<T> Function() body) async =>
      (await tester.runAsync(body)) as T;

  Future<void> pumpApp(WidgetTester tester, LanguageController c) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(BikeLockApp(languageController: c));
    // Let the real storage read finish; the spinner never "settles".
    for (var i = 0; i < 50; i++) {
      await io(tester, () => Future.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, String entry) async {
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(find.text(entry).last);
    await tester.pumpAndSettle();
  }

  testWidgets('language menu switches the UI and remembers the choice', (
    tester,
  ) async {
    final controller = LanguageController();
    await pumpApp(tester, controller);
    expect(find.text('No photo yet'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);

    await pick(tester, 'Deutsch');
    expect(find.text('Noch kein Foto'), findsOneWidget);
    expect(find.text('Foto aufnehmen'), findsOneWidget);
    expect(find.text('Fahrradschloss-Nachweis'), findsOneWidget);

    // A fresh controller (= app restart) restores German from settings.json.
    await io(tester, () => Future.delayed(const Duration(milliseconds: 50)));
    final restarted = LanguageController();
    await io(tester, restarted.load);
    expect(restarted.value, const Locale('de'));

    await pick(tester, 'Systemsprache');
    expect(controller.value, isNull);
    expect(find.text('No photo yet'), findsOneWidget);
  });

  testWidgets('corrupt or unknown saved language falls back to system', (
    tester,
  ) async {
    final controller = LanguageController();
    await io(tester, () async {
      File('${docs.path}/settings.json')
          .writeAsStringSync('{"languageCode":"xx"}');
      await controller.load();
    });
    expect(controller.value, isNull);

    await io(tester, () async {
      File('${docs.path}/settings.json').writeAsStringSync('not json');
      await controller.load();
    });
    expect(controller.value, isNull);
  });
}
