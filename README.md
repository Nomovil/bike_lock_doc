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
7. [Project structure](#project-structure)
8. [Troubleshooting](#troubleshooting)

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
(default/fallback) and **German**. It uses Flutter's built-in
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
   `{placeholders}` unchanged).
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

Test a language without changing the phone's language: on Android 13+,
*Settings → System → Languages → App languages*; or temporarily set
`locale: const Locale('de')` on the `MaterialApp` in `lib/main.dart`.

**Not yet translated:** the iOS permission dialog texts in `Info.plist`
(needs `InfoPlist.strings` files added via Xcode).

---

## Project structure

```
lib/
  main.dart            UI: home screen, camera, location, sharing
  photo_stamper.dart   draws the date/location strip, writes EXIF, encodes JPEG
  lock_record.dart     LockRecord model + LockStorage (keeps exactly one photo)
  l10n/                translations (app_<lang>.arb) + generated Dart code
test/
  widget_test.dart     unit tests for LockRecord and translations
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
