# Bike Lock Proof

A small Flutter app for documenting where and when you locked your bike, e.g.
as evidence for your bicycle insurance after a theft.

- **One tap photo** – take a photo of the locked bike.
- **Date, time and location** – stamped visibly onto the photo *and* stored as
  EXIF metadata (GPS + timestamp). The street address is added when the phone
  can look it up (needs internet).
- **Always exactly one photo** – a new photo replaces the previous one. The old
  photo is only deleted after the new one has been saved successfully;
  cancelling the camera keeps the old photo.
- **Private** – photos are stored in the app's private storage, never in the
  gallery / Photos app.
- **Share** – send the photo plus a text with date, address, coordinates and a
  Google Maps link via any app (Messenger, e-mail, …).
- **English and German** – follows the phone's language, or pick one with the
  🌐 button in the top bar.

Technical details are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). The
full pre-implementation specification (requirements, use cases, architecture,
data model, test plan, decisions, with Mermaid diagrams) is in
[docs/spec/](docs/spec/README.md).

---

## Contents

1. [Requirements](#requirements)
2. [Running and debugging](#running-and-debugging)
3. [Building](#building)
4. [Sharing the app with friends](#sharing-the-app-with-friends)
5. [Signing the release build (Android)](#signing-the-release-build-android)
6. [Translations](#translations)
7. [Customising the app (icon, name, colours)](#customising-the-app-icon-name-colours)
8. [Project structure](#project-structure)
9. [Troubleshooting](#troubleshooting)

---

## Requirements

| What | Needed for |
| --- | --- |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart ≥ 3.13) | everything |
| Android SDK (via Android Studio or command-line tools) + Java 17 | Android builds |
| macOS + Xcode + CocoaPods | iOS builds (cannot be done on Linux/Windows) |
| A real phone | testing camera and GPS (emulators only fake them) |

Check your setup:

```sh
flutter doctor        # lists missing pieces; fix everything marked with ✗ for your platform
flutter --version
```

Install the Dart/Flutter packages once after cloning (and after every change to
`pubspec.yaml`):

```sh
flutter pub get
```

---

## Running and debugging

### Connect a phone

**Android**

1. On the phone: *Settings → About phone* → tap *Build number* 7 times to
   unlock developer options.
2. *Settings → System → Developer options* → enable **USB debugging**
   (optionally also **Wireless debugging**).
3. Plug in via USB and accept the "Allow USB debugging?" prompt.

**iPhone** (macOS only): connect via USB, trust the computer, enable
*Developer Mode* (*Settings → Privacy & Security*), and open
`ios/Runner.xcworkspace` in Xcode once to select your Apple ID as the
signing team (*Runner → Signing & Capabilities*).

Check that Flutter sees the device:

```sh
flutter devices
```

### Run in debug mode

```sh
flutter run                 # picks the only connected device
flutter run -d <device-id>  # pick a specific one (ids from `flutter devices`)
```

While `flutter run` is active, use these keys in the terminal:

| Key | Action |
| --- | --- |
| `r` | **Hot reload** – applies code changes in about a second, keeps app state |
| `R` | **Hot restart** – restarts the app, resets state |
| `d` | open **DevTools** in the browser (widget inspector, logs, performance, memory) |
| `p` | toggle layout guidelines on the device |
| `q` | quit |

Changes to native files (`AndroidManifest.xml`, `Info.plist`, Gradle files) or
newly added packages need a full stop (`q`) and a new `flutter run`.

### Debugging in an IDE

- **VS Code**: install the *Flutter* extension, open the project folder, press
  `F5`. Set breakpoints by clicking left of the line numbers; inspect
  variables in the *Run and Debug* side bar.
- **Android Studio / IntelliJ**: install the *Flutter* plugin, open the
  project, choose the device in the toolbar, click the bug icon.

### Logs

```sh
flutter logs                 # app output (print / debugPrint) of the running app
adb logcat | grep -i flutter # raw Android log, useful for native crashes
```

### Other run modes

```sh
flutter run --profile   # performance close to release, with DevTools profiling
flutter run --release   # exactly what users get; no hot reload, no debugger
```

### Code quality and tests

```sh
flutter analyze   # static analysis (lints from analysis_options.yaml)
dart format .     # format all Dart code
flutter test      # run unit/widget tests in test/
```

---

## Building

All output ends up in `build/` (ignored by git).

### Android

```sh
# One APK that runs on every phone (~48 MB)
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# Smaller APKs, one per CPU type (most modern phones need arm64-v8a);
# send your friends the arm64-v8a one
flutter build apk --release --split-per-abi
# → build/app/outputs/flutter-apk/app-arm64-v8a-release.apk, …

# App Bundle, only needed for uploading to Google Play
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

Install a built APK directly on a connected phone:

```sh
flutter install                # installs the last built APK
# or
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### iOS (macOS only)

```sh
flutter build ios --release    # builds the app; signing via Xcode
flutter build ipa              # archive for TestFlight / App Store
# → build/ios/ipa/*.ipa
```

### Version number

The version lives in `pubspec.yaml`:

```yaml
version: 1.0.0+1   # <name>+<build number>
```

**Increase the build number (`+1` → `+2`) for every version you hand out.**
Android refuses to install an update with the same or a lower build number.

---

## Sharing the app with friends

The app is not in any app store, so you distribute it yourself.

### Android – send the APK (easiest, free)

1. Set up a release key once, see
   [Signing the release build](#signing-the-release-build-android). (It works
   without one, but then you can't ship updates from another computer.)
2. Build it:
   ```sh
   flutter build apk --release
   ```
3. Send `build/app/outputs/flutter-apk/app-release.apk` to your friends via
   Signal/WhatsApp/Telegram (as a *file/document*, not as media), e-mail, or a
   cloud link (Nextcloud, Google Drive, Dropbox, …).
4. Your friends open the file on their phone. Android asks to allow
   **"Install unknown apps"** for the app they opened it with (e.g. Files or
   Chrome) – allow it, then tap *Install*. Google Play Protect may show a
   warning for apps it doesn't know; choose *Install anyway* / *More details →
   Install anyway*.

**Updates**: bump the version in `pubspec.yaml`, rebuild, send the new APK.
Installing it over the old one keeps the stored photo – **as long as both
APKs are signed with the same key**. If the key differs, Android refuses the
update and your friends would have to uninstall first (losing their photo).

Other Android options, if you want automatic update notifications:

- **[Firebase App Distribution](https://firebase.google.com/docs/app-distribution)**
  – free; you upload the APK, friends get an invite e-mail and a tester app
  that notifies them about new versions.
- **Google Play internal testing** – one-time 25 USD developer account; upload
  the `.aab` from `flutter build appbundle`, add up to 100 testers by e-mail,
  they install via the normal Play Store.

### iPhone – needs a Mac

Apple doesn't allow installing app files from chats. Options:

- **TestFlight** (recommended for friends): requires the
  [Apple Developer Program](https://developer.apple.com/programs/)
  (99 USD/year). Build with `flutter build ipa`, upload the `.ipa` with Apple's
  *Transporter* app or Xcode, add your friends as testers in
  [App Store Connect](https://appstoreconnect.apple.com). They install the
  *TestFlight* app and get your app from there. Builds expire after 90 days.
- **Free Apple ID**: you can only install on *your own* devices connected to
  your Mac (`flutter run --release`), and the app stops working after 7 days
  until you install it again. Not usable for friends.

---

## Signing the release build (Android)

Android identifies an app by its package name **and** its signing key. Without
the setup below, release builds are signed with the debug key that Flutter
created in `~/.android/debug.keystore` on *this* computer – fine for testing,
but a different computer means a different key and updates will fail to
install.

1. Create a key once (keep the passwords!):
   ```sh
   keytool -genkey -v -keystore ~/bike-lock-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias bikelock
   ```
2. Create `android/key.properties`:
   ```properties
   storePassword=<your store password>
   keyPassword=<your key password>
   keyAlias=bikelock
   storeFile=/home/<you>/bike-lock-release.jks
   ```
3. Build as usual (`flutter build apk --release`). `android/app/build.gradle.kts`
   picks up `key.properties` automatically and falls back to the debug key if
   the file is missing.

`key.properties` and `*.jks` are in `android/.gitignore` – **never commit them,
and back up the `.jks` file and passwords**. If you lose them you can't
publish updates to the installed app anymore.

Check which key an APK is signed with:

```sh
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

---

## Translations

The app follows the phone's system language. Supported: **English**
(default/fallback) and **German**. Users can override it with the
**language button** (translate icon) in the top bar: *System language*,
*English* or *Deutsch*. The choice is saved in the app's private
`settings.json` and kept after restarts and updates. It uses Flutter's built-in
[`gen-l10n`](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
tool with ARB files; the text stamped onto the photo and the shared text are
translated too.

| File | Purpose |
| --- | --- |
| `lib/l10n/app_en.arb` | English texts – the **template**, with a description for every text |
| `lib/l10n/app_de.arb` | German texts |
| `lib/l10n/app_localizations*.dart` | **generated** Dart code – don't edit by hand |
| `l10n.yaml` | `gen-l10n` configuration |
| `android/app/src/main/res/values*/strings.xml` | launcher name on Android |

### Change a text

Edit the ARB file(s), then run `flutter gen-l10n` (or simply `flutter run` /
`flutter build`, which do it automatically). Commit the regenerated
`app_localizations*.dart` files too.

### Add a new text

1. Add the key, English text and an `@key` description to `app_en.arb`.
   Values in `{braces}` are placeholders and must be listed under
   `placeholders`.
2. Add the same key to every other `app_<lang>.arb`.
3. Use it in code: `AppLocalizations.of(context).myKey` (or
   `l10n.myKey(value)` for texts with placeholders).

### Add a new language (e.g. French)

1. Copy `lib/l10n/app_de.arb` to `lib/l10n/app_fr.arb`, set
   `"@@locale": "fr"` and translate every value (keep keys and
   `{placeholders}` unchanged). Set `languageName` to `Français` – that's
   how it appears in the language menu.
2. Run `flutter gen-l10n` – French is now in
   `AppLocalizations.supportedLocales` and picked automatically on French
   phones.
3. Android launcher name: add
   `android/app/src/main/res/values-fr/strings.xml` with `app_name`.
4. iOS: add `<string>fr</string>` to `CFBundleLocalizations` in
   `ios/Runner/Info.plist`.

Check for texts you forgot to translate: every `flutter gen-l10n` (and every
build) writes `build/untranslated-messages.json`. It contains `{}` when
everything is translated, otherwise the missing keys per language. Missing
texts fall back to English in the app.

Test a language without changing the phone's language: use the language
button in the app. New languages appear in its menu automatically, labelled
with their `languageName` text.

**Not yet translated:** the iOS permission dialog texts in `Info.plist`
(needs `InfoPlist.strings` files added via Xcode).

---

## Customising the app (icon, name, colours)

### App icon

The icons are the Flutter default for now. The easiest way to replace them
on both platforms is the
[`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
package, which generates every required size from one picture.

1. Create a square PNG, **1024 × 1024 px**, e.g. `assets/icon/icon.png`.
   Keep the important part in the centre: Android crops icons into circles
   or rounded squares.
2. For Android's *adaptive* icons, also create a foreground image with a
   transparent background and the motif in the inner ~66 %, e.g.
   `assets/icon/icon_foreground.png`.
3. Add the tool and its configuration:
   ```sh
   flutter pub add --dev flutter_launcher_icons
   ```
   At the end of `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/icon.png"
     adaptive_icon_background: "#009688"     # or an image path
     adaptive_icon_foreground: "assets/icon/icon_foreground.png"
     remove_alpha_ios: true                   # the App Store rejects transparent icons
   ```
4. Generate the icons and rebuild:
   ```sh
   dart run flutter_launcher_icons
   flutter run
   ```
   This overwrites `android/app/src/main/res/mipmap-*/` and
   `ios/Runner/Assets.xcassets/AppIcon.appiconset/`; commit those files.

Doing it by hand instead: replace every `ic_launcher.png` in
`android/app/src/main/res/mipmap-*` (48, 72, 96, 144, 192 px), and on iOS
drag a 1024 px image into *Runner → Assets → AppIcon* in Xcode.

Android sometimes keeps showing the old icon: uninstall the app or restart
the launcher.

### App name

The name appears in several places; change all that apply:

| Where the name shows | File | Key |
| --- | --- | --- |
| Inside the app (top bar, task switcher) | `lib/l10n/app_en.arb`, `app_de.arb`, … | `appTitle` |
| Android home screen / app list | `android/app/src/main/res/values/strings.xml` (English/default) and `values-de/strings.xml` | `app_name` |
| iPhone home screen | `ios/Runner/Info.plist` | `CFBundleDisplayName` (and `CFBundleName`, max. 15 characters) |

Keep names short (≈ 12 characters) or the launcher truncates them under the
icon. Run `flutter gen-l10n` (or just `flutter run`) after editing ARB files.

**Package name / bundle ID** (`com.bikelock.bike_lock_doc`) is a different
thing: it's the app's technical identity, never shown to users. Only change
it **before** you share the app – phones treat a new ID as a completely
different app, so friends couldn't update and would lose their photo. If
needed: `applicationId` and `namespace` in `android/app/build.gradle.kts`,
the Kotlin folder path of `MainActivity.kt`, and `PRODUCT_BUNDLE_IDENTIFIER`
in Xcode (*Runner → Signing & Capabilities*).

### Colours and general styling

All styling is in **`lib/app_theme.dart`**.

**Main colour** – change one line:

```dart
const Color appSeedColor = Colors.teal;      // e.g. Colors.indigo, Colors.deepOrange
const Color appSeedColor = Color(0xFF2E7D32); // or any hex colour: 0xFF + RRGGBB
```

Material 3 derives a complete, matching palette from this seed – buttons, top
bar, cards, progress indicators – in both light and dark mode. Use hot reload
(`r`) while `flutter run` is active to try colours instantly.

**More control** – extend `_buildTheme` in the same file, e.g.:

```dart
return ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: appSeedColor,
    brightness: brightness,
    secondary: Colors.amber,            // override single palette colours
  ),
  appBarTheme: const AppBarTheme(centerTitle: true),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
  ),
  cardTheme: const CardThemeData(elevation: 0),
);
```

The [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/)
shows what a seed colour looks like and can export a full colour scheme.

**Light / dark mode** follows the system. To force one, set
`themeMode: ThemeMode.light` (or `.dark`) on the `MaterialApp` in
`lib/main.dart`.

**Custom font**:

1. Put the font files in `assets/fonts/`, e.g. `Inter-Regular.ttf` and
   `Inter-Bold.ttf`.
2. Register them in `pubspec.yaml` under `flutter:`:
   ```yaml
   fonts:
     - family: Inter
       fonts:
         - asset: assets/fonts/Inter-Regular.ttf
         - asset: assets/fonts/Inter-Bold.ttf
           weight: 700
   ```
3. Add `fontFamily: 'Inter'` to the `ThemeData` in `lib/app_theme.dart`.

**Text stamped on the photo** uses its own colours (white text on 55 % black)
so it stays readable on any photo. They're in `lib/photo_stamper.dart`
(`Colors.white`, `Colors.black.withValues(alpha: 0.55)`); the font size is
`shortSide * 0.035`.

**Splash screen** (shown for a moment while the app starts): white by
default. Change the background colour in
`android/app/src/main/res/drawable/launch_background.xml` (and
`drawable-v21/`) and in `ios/Runner/Base.lproj/LaunchScreen.storyboard`, or
use the [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash)
package, which works like `flutter_launcher_icons`.

---

## Project structure

```
lib/
  main.dart            UI: home screen, language menu, camera, location, sharing
  app_theme.dart       colours and styling (seed colour, light/dark theme)
  language_controller.dart  selected language, saved in settings.json
  photo_stamper.dart   draws the date/location strip, writes EXIF, encodes JPEG
  lock_record.dart     LockRecord model + LockStorage (keeps exactly one photo)
  l10n/                translations (app_<lang>.arb) + generated Dart code
test/
  widget_test.dart     unit tests for LockRecord and translations
  language_test.dart   widget test: language menu and saved choice
android/               Android project (permissions in app/src/main/AndroidManifest.xml)
ios/                   iOS project (permission texts in Runner/Info.plist)
docs/ARCHITECTURE.md   how the app works internally
docs/spec/             full software specification (16 documents)
pubspec.yaml           app version and dependencies
l10n.yaml              translation tool configuration
```

### Dependencies

| Package | Used for |
| --- | --- |
| `image_picker` | opening the system camera |
| `geolocator` | GPS position and location permission |
| `geocoding` | turning coordinates into a street address |
| `path_provider` | the app's private documents folder |
| `share_plus` | the system share sheet |
| `image` | JPEG encoding and EXIF metadata |
| `intl` | date formatting |
| `flutter_localizations` | translations (part of the Flutter SDK) |

Update them with `flutter pub upgrade` (within allowed versions) or
`flutter pub outdated` to see newer major versions.

---

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `flutter devices` doesn't list the phone | Re-plug, accept the USB debugging prompt, try another cable; run `adb devices`. |
| "Location unavailable" on the photo | Turn on location on the phone, allow the permission (*Settings → Apps → Bike Lock Proof → Permissions*), go outside for a GPS fix. |
| No street address, only coordinates | Address lookup needs internet; coordinates are always saved. |
| "App not installed" when updating | The new APK is signed with a different key or has a lower build number. See [Signing](#signing-the-release-build-android). |
| Build errors after changing packages | `flutter clean && flutter pub get`, then build again. |
| Gradle/Java errors | `flutter doctor -v`; Android builds need Java 17. |
