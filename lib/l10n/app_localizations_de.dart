// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Fahrradschloss-Nachweis';

  @override
  String get dateTimePattern => 'dd.MM.yyyy HH:mm:ss';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get newPhoto => 'Neues Foto';

  @override
  String get share => 'Teilen';

  @override
  String get noPhotoYet => 'Noch kein Foto';

  @override
  String get emptyStateText =>
      'Fotografiere dein abgeschlossenes Fahrrad. Datum, Uhrzeit und Standort werden mitgespeichert. Jedes neue Foto ersetzt das vorherige.';

  @override
  String get gettingLocation => 'Standort wird ermittelt…';

  @override
  String get savingPhoto => 'Foto wird gespeichert…';

  @override
  String get dateTimeLabel => 'Datum & Uhrzeit';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get gpsLabel => 'GPS';

  @override
  String gpsLabelWithAccuracy(int meters) {
    return 'GPS (±$meters m)';
  }

  @override
  String get unknownLocation => 'Standort unbekannt';

  @override
  String get stampLocationUnavailable => 'Standort nicht verfügbar';

  @override
  String stampGps(String coordinates) {
    return 'GPS $coordinates';
  }

  @override
  String stampGpsWithAccuracy(String coordinates, int meters) {
    return 'GPS $coordinates  (±$meters m)';
  }

  @override
  String shareSubject(String dateTime) {
    return 'Fahrradschloss $dateTime';
  }

  @override
  String shareLockedOn(String dateTime) {
    return 'Fahrrad abgeschlossen am $dateTime';
  }

  @override
  String shareGps(String coordinates) {
    return 'GPS: $coordinates';
  }

  @override
  String shareGpsWithAccuracy(String coordinates, int meters) {
    return 'GPS: $coordinates (±$meters m)';
  }

  @override
  String errorCamera(String error) {
    return 'Kamera konnte nicht geöffnet werden: $error';
  }

  @override
  String get errorLocationServicesOff =>
      'Die Standortdienste sind ausgeschaltet.';

  @override
  String get errorLocationPermissionDenied =>
      'Standortzugriff wurde verweigert.';

  @override
  String get savedWithoutLocation =>
      'Foto gespeichert, aber der Standort konnte nicht ermittelt werden.';

  @override
  String errorSaving(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }
}
