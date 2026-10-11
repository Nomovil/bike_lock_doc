# 07 – System Architecture

[← UI and UX Specification](06-ui-ux-specification.md) · [Index](README.md) · [Next: Data Model and Storage →](08-data-model-and-storage.md)

The architecture is described with the [C4 model](https://c4model.com/)
levels 1–3, plus a deployment view.

## 7.1 System context (C4 level 1)

```mermaid
flowchart TB
    User(["👤 Bike owner<br/><i>person</i>"])
    App["📱 Bike Lock Proof<br/><i>Flutter mobile app</i><br/>Takes, stamps, stores and shares one proof photo"]
    Camera["Camera app<br/><i>OS component</i>"]
    GNSS["Location service<br/><i>OS component (GPS, Wi-Fi, cell)</i>"]
    Geo["Geocoder<br/><i>OS service, online</i>"]
    Share["Share sheet<br/><i>OS component</i>"]
    Targets(["📨 E-mail, messengers, cloud<br/><i>external apps</i>"])

    User -- "uses" --> App
    App -- "intent / UIImagePicker" --> Camera
    App -- "position request" --> GNSS
    App -- "coordinates → address" --> Geo
    App -- "file + text" --> Share
    Share --> Targets
```

There is **no backend**. The only network traffic is the OS geocoder call
(FR-04) and whatever the user does in the share target.

## 7.2 Containers (C4 level 2)

```mermaid
flowchart TB
    subgraph Device["📱 User's phone"]
        subgraph AppC["Bike Lock Proof (Flutter app)"]
            UI["Presentation<br/><i>Flutter widgets</i>"]
            Domain["Domain & services<br/><i>Dart</i>"]
            Plugins["Platform plugins<br/><i>Kotlin / Swift via method channels</i>"]
        end
        FS[("Private app storage<br/><i>file system sandbox</i>")]
        OS["Android / iOS"]
    end

    UI --> Domain
    Domain --> Plugins
    Domain --> FS
    Plugins --> OS
```

## 7.3 Components (C4 level 3)

```mermaid
flowchart TB
    subgraph Presentation["Presentation – lib/main.dart"]
        App["BikeLockApp<br/>theme, root"]
        Home["HomePage / _HomePageState<br/>orchestrates the flows"]
        Empty["_EmptyState"]
        View["_RecordView"]
        Full["Full-screen viewer<br/>(route)"]
    end

    subgraph Domain["Domain & services"]
        Record["LockRecord<br/>lib/lock_record.dart<br/>model, formatting, JSON"]
        Storage["LockStorage<br/>lib/lock_record.dart<br/>single-record persistence"]
        Stamper["PhotoStamper<br/>lib/photo_stamper.dart<br/>strip drawing, EXIF, JPEG"]
        L10n["AppLocalizations<br/>lib/l10n/ (generated)<br/>all texts, en + de"]
    end

    subgraph Packages["Packages"]
        IP["image_picker"]
        GL["geolocator"]
        GC["geocoding"]
        PP["path_provider"]
        SP["share_plus"]
        IMG["image"]
        INTL["intl"]
    end

    App --> Home
    Home --> Empty
    Home --> View
    Home --> Full
    Home --> Storage
    Home --> Stamper
    Home --> IP
    Home --> GL
    Home --> GC
    Home --> SP
    View --> Record
    Storage --> Record
    Storage --> PP
    Stamper --> IMG
    Stamper --> INTL
    Record --> INTL
    Home --> L10n
    Record --> L10n
    Stamper --> L10n
```

### Component responsibilities

| Component | Responsibility | Must not |
| --- | --- | --- |
| `BikeLockApp` | `MaterialApp`, light/dark theme | contain logic |
| `_HomePageState` | UI state (`_record`, `_loading`, `_busyMessage`); orchestrates capture → locate → stamp → store; sharing | do file I/O or image processing itself |
| `LockRecord` | Immutable value object; derived display strings; JSON (de)serialisation | access files or plugins |
| `LockStorage` | Read/write the one record; enforce FR-08 | know about widgets |
| `PhotoStamper` | Pure function: bytes + metadata → stamped JPEG bytes | store files |

## 7.4 Layering rules

```mermaid
flowchart LR
    P["Presentation"] --> D["Domain & services"]
    D --> X["Packages / platform"]
    P --> X
    D -. "never" .-x P
```

- Domain code never imports Flutter widgets for UI purposes
  (`PhotoStamper` uses `dart:ui` and `TextPainter` only for off-screen
  drawing).
- Platform calls that are pure UI flow (camera, permission, share) are
  orchestrated by the presentation layer to keep the code small; extracting
  them into services is planned when a second screen appears (see ADR-05).

## 7.5 Technology stack

| Concern | Choice | Version (min) | Why |
| --- | --- | --- | --- |
| Framework | Flutter (stable) | 3.47 | single code base (C-1) |
| Language | Dart | 3.13 | null safety, records, null-aware elements |
| Camera | `image_picker` | 1.2 | system camera, no camera permission on Android, no gallery write (ADR-02) |
| Location | `geolocator` | 14.1 | permission handling + accuracy + timeouts |
| Address | `geocoding` | 5.0 | uses OS geocoder, no API key (ADR-06) |
| Storage path | `path_provider` | 2.1 | private documents directory |
| Sharing | `share_plus` | 13.3 | system share sheet, files + text |
| JPEG / EXIF | `image` | 4.10 | pure Dart encoder with EXIF write support (ADR-03) |
| Dates | `intl` | 0.20 | `DateFormat` |
| Translations | `flutter_localizations` + `gen-l10n` | SDK | official tooling, ARB files, type-safe generated API (NFR-61) |
| State | `StatefulWidget` | – | one screen, no library needed (ADR-05) |

## 7.6 Deployment view

```mermaid
flowchart LR
    subgraph DevPC["Developer PC"]
        SRC["Source (git)"] --> FL["flutter build"]
        KEY[("release key<br/>key.properties + .jks")] --> FL
    end
    FL --> APK["app-release.apk"]
    FL --> IPA["Runner.ipa<br/>(macOS only)"]
    APK -- "messenger / cloud link" --> AND["📱 Android phones"]
    APK -. "optional" .-> FAD["Firebase App Distribution"] -.-> AND
    IPA --> TF["TestFlight"] --> IOS["📱 iPhones"]
```

Details in [13 – Release and Distribution](13-release-and-distribution.md).

## 7.7 Threading model

```mermaid
flowchart LR
    subgraph Main["UI isolate"]
        A["Widget build / events"]
        B["Plugin calls (async)"]
        C["Decode + draw on Canvas<br/>(GPU-backed, async)"]
    end
    subgraph BG["Background isolate (compute)"]
        D["RGBA → JPEG encode<br/>+ EXIF write"]
    end
    subgraph Native["Platform threads"]
        E["Camera, GPS, geocoder, file I/O"]
    end
    A --> B --> E
    A --> C --> D
```

JPEG encoding of a 2560 px image takes about 1 s of CPU and therefore runs
in a background isolate (NFR-11).
