import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// App name shown in the app bar and the task switcher.
  ///
  /// In en, this message translates to:
  /// **'Bike Lock Proof'**
  String get appTitle;

  /// intl DateFormat pattern for the capture time, used on screen, on the photo and in the shared text. Keep it unambiguous (day before month, 24 h) – it is used as evidence.
  ///
  /// In en, this message translates to:
  /// **'dd.MM.yyyy HH:mm:ss'**
  String get dateTimePattern;

  /// Main button when no photo is stored yet.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// Main button when a photo is stored; the new photo replaces it.
  ///
  /// In en, this message translates to:
  /// **'New photo'**
  String get newPhoto;

  /// Button that opens the system share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Heading of the empty state.
  ///
  /// In en, this message translates to:
  /// **'No photo yet'**
  String get noPhotoYet;

  /// Explanation in the empty state.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your locked bike. Date, time and location are saved with it. Each new photo replaces the previous one.'**
  String get emptyStateText;

  /// Progress text while waiting for GPS.
  ///
  /// In en, this message translates to:
  /// **'Getting location…'**
  String get gettingLocation;

  /// Progress text while stamping and storing the photo.
  ///
  /// In en, this message translates to:
  /// **'Saving photo…'**
  String get savingPhoto;

  /// Label under the capture time in the details card.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateTimeLabel;

  /// Label under the street address in the details card.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// Label under the coordinates when the accuracy is unknown.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get gpsLabel;

  /// Label under the coordinates with the GPS accuracy radius.
  ///
  /// In en, this message translates to:
  /// **'GPS (±{meters} m)'**
  String gpsLabelWithAccuracy(int meters);

  /// Shown instead of coordinates when no location was recorded.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// Line stamped onto the photo when no location was recorded.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get stampLocationUnavailable;

  /// Line stamped onto the photo with the coordinates.
  ///
  /// In en, this message translates to:
  /// **'GPS {coordinates}'**
  String stampGps(String coordinates);

  /// Line stamped onto the photo with coordinates and accuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS {coordinates}  (±{meters} m)'**
  String stampGpsWithAccuracy(String coordinates, int meters);

  /// Subject when sharing (e.g. e-mail subject).
  ///
  /// In en, this message translates to:
  /// **'Bike lock {dateTime}'**
  String shareSubject(String dateTime);

  /// First line of the shared text.
  ///
  /// In en, this message translates to:
  /// **'Bike locked on {dateTime}'**
  String shareLockedOn(String dateTime);

  /// Coordinates line of the shared text.
  ///
  /// In en, this message translates to:
  /// **'GPS: {coordinates}'**
  String shareGps(String coordinates);

  /// Coordinates line of the shared text, with accuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS: {coordinates} (±{meters} m)'**
  String shareGpsWithAccuracy(String coordinates, int meters);

  /// Snack bar when the camera cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open camera: {error}'**
  String errorCamera(String error);

  /// Snack bar when the device location service is disabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off.'**
  String get errorLocationServicesOff;

  /// Snack bar when the user denied location access.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get errorLocationPermissionDenied;

  /// Snack bar after saving a photo without location.
  ///
  /// In en, this message translates to:
  /// **'Photo saved, but the location could not be determined.'**
  String get savedWithoutLocation;

  /// Snack bar when stamping or storing the photo failed.
  ///
  /// In en, this message translates to:
  /// **'Saving failed: {error}'**
  String errorSaving(String error);

  /// Name of this language, written in this language. Shown in the language menu.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// Tooltip of the language button in the app bar.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// Language menu entry to follow the phone's language.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
