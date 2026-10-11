import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'l10n/app_localizations.dart';

/// The language the user picked in the app, or `null` to follow the system.
///
/// The choice is saved in `<app documents>/settings.json` so it survives
/// restarts. Listen to it (e.g. with [ValueListenableBuilder]) to rebuild the
/// [MaterialApp] with the new locale.
class LanguageController extends ValueNotifier<Locale?> {
  LanguageController() : super(null);

  static const _settingsFileName = 'settings.json';
  static const _languageKey = 'languageCode';

  Future<File> _file() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/$_settingsFileName');
  }

  /// Restores the saved choice. Unknown or unsupported values (e.g. a
  /// language that was removed in an update) fall back to the system.
  Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final code = json[_languageKey] as String?;
      value = AppLocalizations.supportedLocales
          .where((l) => l.languageCode == code)
          .firstOrNull;
    } catch (_) {
      value = null; // Corrupt settings: just follow the system language.
    }
  }

  /// Switches the app to [locale] (`null` = system language) and saves it.
  Future<void> select(Locale? locale) async {
    value = locale;
    try {
      await (await _file()).writeAsString(
        jsonEncode({_languageKey: locale?.languageCode}),
        flush: true,
      );
    } catch (_) {
      // Not saved: the choice still applies until the app is closed.
    }
  }
}
