# Architecture

How Bike Lock Proof works internally. For setup, building and sharing see the
[README](../README.md).

## Overview

The app is a single screen with three Dart files and no state-management
library:

| File | Responsibility |
| --- | --- |
| `lib/main.dart` | `HomePage`: UI, camera, location, address lookup, sharing |
| `lib/photo_stamper.dart` | `PhotoStamper`: draws the info strip onto the photo, writes EXIF, encodes JPEG |
| `lib/lock_record.dart` | `LockRecord` (data model) and `LockStorage` (keeps exactly one record on disk) |

## Taking a photo

`_HomePageState._takePhoto()` runs these steps:

```
tap "New photo"
  │
  ├─ start _getPosition()  ──────────────┐  (runs in parallel with the camera)
  │                                      │
  ├─ image_picker opens the system camera│
  │    cancelled → stop, old photo kept  │
  │                                      │
  ├─ timestamp = now                     │
  ├─ await position  ◄───────────────────┘  (null if denied / off / no fix in 30 s)
  ├─ _reverseGeocode(position)              (address, null if offline; 8 s timeout)
  ├─ PhotoStamper.stamp(...)                (info strip + EXIF → JPEG bytes)
  ├─ LockStorage.replace(...)               (write new photo + JSON, delete old photo)
  └─ delete the camera's temporary file
```

The location lookup starts *before* the camera opens so that a GPS fix is
usually ready once the photo has been taken. If location fails, the photo is
still saved and stamped "Location unavailable".

`image_picker` is limited to 2560 px on the long side to keep files small
enough for messengers.

## Stamping (`photo_stamper.dart`)

1. The camera JPEG is decoded with Flutter's own decoder
   (`ui.instantiateImageCodec`), which applies the EXIF orientation so the
   image is upright.
2. The image and a semi-transparent black strip with white text are drawn on a
   `Canvas`. Text uses Flutter's `TextPainter`, so any characters (umlauts,
   accents) render correctly. The font size is 3.5 % of the image's short side.
3. The result is read back as raw RGBA pixels.
4. In a background isolate (`compute`) the `image` package encodes it as a
   JPEG (quality 90) with EXIF tags:
   - `DateTime`, `DateTimeOriginal` – capture time
   - `ImageDescription` – the same text as the strip
   - GPS latitude/longitude – when known

The original camera EXIF data (camera model etc.) isn't copied over.

## Storage (`lock_record.dart`)

All data is in `<application documents>/bike_lock/`:

| File | Content |
| --- | --- |
| `lock_photo_<millis>.jpg` | the stamped photo |
| `lock_record.json` | `LockRecord` as JSON: photo path, ISO timestamp, latitude, longitude, accuracy, address |

`getApplicationDocumentsDirectory()` is private app storage:

- **Android**: `/data/data/com.bikelock.bike_lock_doc/app_flutter/` – no
  other app can read it and the media scanner doesn't index it, so the photo
  never appears in the gallery. It's deleted when the app is uninstalled.
- **iOS**: the app's sandboxed `Documents` folder – not part of the Photos
  library. It's included in device backups.

`LockStorage.replace()` makes sure there is always exactly one photo:

1. Write the new photo under a unique name (unique names stop Flutter's image
   cache from showing a stale image).
2. Write `lock_record.json` pointing to it.
3. Only then delete every other `lock_photo_*.jpg`.

If the app crashes between steps, at worst an extra old photo remains, and the
next `replace()` removes it. `load()` returns `null` if the JSON is broken or
its photo is missing, so the app shows the empty state.

## Sharing

`share_plus` opens the system share sheet with the JPEG file and a text
(`LockRecord.shareText`) with date/time, address, coordinates with accuracy and
a Google Maps link. On iPad, the share popover is anchored to the Share button
(`sharePositionOrigin`). Some target apps ignore the text when a file is
attached; the information is still on the photo and in its EXIF data.

## Permissions

| Platform | Permission | Where | Why |
| --- | --- | --- | --- |
| Android | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | `AndroidManifest.xml` | GPS position |
| Android | `INTERNET` | `AndroidManifest.xml` | address lookup (release builds don't add it automatically) |
| Android | camera | none needed | `image_picker` uses the system camera app via an intent |
| iOS | `NSCameraUsageDescription` | `Info.plist` | camera |
| iOS | `NSLocationWhenInUseUsageDescription` | `Info.plist` | GPS position |
| iOS | `NSPhotoLibraryUsageDescription` | `Info.plist` | listed in `image_picker`'s iOS setup; the app never reads or writes the library |

Location is requested at runtime the first time a photo is taken
(`Geolocator.requestPermission()`), and only while the app is in use.

## Tests

`test/widget_test.dart` covers the `LockRecord` JSON round trip and the text
formatting. Camera, GPS and file sharing depend on platform plugins and must
be tested on a real device.
