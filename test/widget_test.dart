import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:bike_lock_doc/l10n/app_localizations.dart';
import 'package:bike_lock_doc/lock_record.dart';

void main() {
  // In the app, the Material localisation delegates load this data.
  setUpAll(() => initializeDateFormatting());

  final en = lookupAppLocalizations(const Locale('en'));
  final de = lookupAppLocalizations(const Locale('de'));

  final record = LockRecord(
    photoPath: '/tmp/lock_photo_1.jpg',
    timestamp: DateTime(2026, 10, 10, 18, 30, 5),
    latitude: 52.520008,
    longitude: 13.404954,
    accuracy: 4.2,
    address: 'Alexanderplatz 1, 10178 Berlin',
  );

  test('LockRecord survives a JSON round trip', () {
    final copy = LockRecord.fromJson(record.toJson());

    expect(copy.photoPath, record.photoPath);
    expect(copy.timestamp, record.timestamp);
    expect(copy.latitude, record.latitude);
    expect(copy.longitude, record.longitude);
    expect(copy.accuracy, record.accuracy);
    expect(copy.address, record.address);
  });

  test('English share text', () {
    expect(record.formattedDateTime(en), '10.10.2026 18:30:05');
    expect(record.shareSubject(en), 'Bike lock 10.10.2026 18:30:05');
    expect(
      record.shareText(en),
      'Bike locked on 10.10.2026 18:30:05\n'
      'Alexanderplatz 1, 10178 Berlin\n'
      'GPS: 52.520008, 13.404954 (±4 m)\n'
      'https://maps.google.com/?q=52.520008,13.404954',
    );
  });

  test('German share text', () {
    expect(record.shareSubject(de), 'Fahrradschloss 10.10.2026 18:30:05');
    expect(
      record.shareText(de),
      startsWith('Fahrrad abgeschlossen am 10.10.2026 18:30:05\n'),
    );
  });

  test('LockRecord without location', () {
    final noLocation = LockRecord(
      photoPath: '/tmp/x.jpg',
      timestamp: DateTime(2026, 1, 1),
    );
    expect(noLocation.hasLocation, isFalse);
    expect(noLocation.coordinates, isNull);
    expect(noLocation.mapsUrl, isNull);
    expect(noLocation.shareText(en), contains('GPS: Unknown location'));
    expect(noLocation.shareText(de), contains('GPS: Standort unbekannt'));
  });

  test('German is supported', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('de')));
    expect(de.appTitle, 'Fahrradschloss-Nachweis');
  });
}
