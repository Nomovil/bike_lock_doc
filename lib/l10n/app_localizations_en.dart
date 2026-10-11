// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bike Lock Proof';

  @override
  String get dateTimePattern => 'dd.MM.yyyy HH:mm:ss';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get newPhoto => 'New photo';

  @override
  String get share => 'Share';

  @override
  String get noPhotoYet => 'No photo yet';

  @override
  String get emptyStateText =>
      'Take a photo of your locked bike. Date, time and location are saved with it. Each new photo replaces the previous one.';

  @override
  String get gettingLocation => 'Getting location…';

  @override
  String get savingPhoto => 'Saving photo…';

  @override
  String get dateTimeLabel => 'Date & time';

  @override
  String get addressLabel => 'Address';

  @override
  String get gpsLabel => 'GPS';

  @override
  String gpsLabelWithAccuracy(int meters) {
    return 'GPS (±$meters m)';
  }

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get stampLocationUnavailable => 'Location unavailable';

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
    return 'Bike lock $dateTime';
  }

  @override
  String shareLockedOn(String dateTime) {
    return 'Bike locked on $dateTime';
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
    return 'Could not open camera: $error';
  }

  @override
  String get errorLocationServicesOff => 'Location services are turned off.';

  @override
  String get errorLocationPermissionDenied => 'Location permission denied.';

  @override
  String get savedWithoutLocation =>
      'Photo saved, but the location could not be determined.';

  @override
  String errorSaving(String error) {
    return 'Saving failed: $error';
  }

  @override
  String get languageName => 'English';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get systemLanguage => 'System language';
}
