# 13 – Release and Distribution

[← Test Plan](12-test-plan.md) · [Index](README.md) · [Next: Architecture Decision Records →](14-architecture-decisions.md)

Step-by-step commands are in the [README](../../README.md#building); this
document defines the process.

## 13.1 Versioning

`pubspec.yaml` → `version: MAJOR.MINOR.PATCH+BUILD`

| Part | Increase when | Example |
| --- | --- | --- |
| MAJOR | stored data format changes incompatibly | `2.0.0` |
| MINOR | new feature | `1.1.0` |
| PATCH | bug fix | `1.0.1` |
| BUILD | **every** distributed build (Android `versionCode`) | `+7` |

Android refuses updates with an equal or lower `versionCode`; the build
number therefore only ever increases.

## 13.2 Branching and release flow

```mermaid
gitGraph
    commit id: "initial"
    branch feature/stamp
    checkout feature/stamp
    commit id: "photo stamping"
    checkout main
    merge feature/stamp
    branch feature/share
    checkout feature/share
    commit id: "sharing"
    checkout main
    merge feature/share
    commit id: "bump 1.0.0+1" tag: "v1.0.0"
    branch fix/geocode-timeout
    checkout fix/geocode-timeout
    commit id: "fix"
    checkout main
    merge fix/geocode-timeout
    commit id: "bump 1.0.1+2" tag: "v1.0.1"
```

- `main` is always releasable.
- Work happens on short-lived `feature/*` and `fix/*` branches.
- Releases are tagged `vMAJOR.MINOR.PATCH`.

## 13.3 Release pipeline

```mermaid
flowchart LR
    A["Bump version<br/>pubspec.yaml"] --> B["flutter analyze<br/>flutter test"]
    B --> C{"green?"}
    C -- "no" --> FIX["fix"] --> B
    C -- "yes" --> D["flutter build apk --release<br/>(signed with release key)"]
    D --> E["Manual test protocol<br/>(12-test-plan)"]
    E --> F{"exit criteria met?"}
    F -- "no" --> FIX
    F -- "yes" --> G["git tag vX.Y.Z"]
    G --> H["Distribute APK"]
    G --> I["iOS: flutter build ipa<br/>→ TestFlight"]
```

## 13.4 Signing

```mermaid
flowchart TD
    A["flutter build apk --release"] --> B{"android/key.properties<br/>exists?"}
    B -- "yes" --> C["Sign with release key<br/>(.jks, alias from file)"]
    B -- "no" --> D["Sign with debug key<br/>~/.android/debug.keystore"]
    C --> E["APK installable as update<br/>on all friends' phones"]
    D --> F["⚠️ Only updatable from<br/>this one computer"]
```

- The release keystore and `key.properties` are kept **outside git** and
  backed up (password manager + offline copy).
- Losing the key means friends must uninstall (losing their photo) before
  installing a newer version → risk R-05.

## 13.5 Distribution channels

| Channel | Platform | Cost | Effort | Auto-update notice | Chosen for 1.0 |
| --- | --- | --- | --- | --- | --- |
| APK via messenger / cloud link | Android | free | low | no | ✅ |
| Firebase App Distribution | Android, iOS | free | medium | yes | optional |
| Google Play internal testing | Android | 25 USD once | medium | yes (Play Store) | later |
| TestFlight | iOS | 99 USD / year | medium | yes | if iOS needed |
| Public app stores | both | as above | high | yes | ❌ out of scope |

## 13.6 Project plan (implementation)

```mermaid
gantt
    title Bike Lock Proof 1.0
    dateFormat  YYYY-MM-DD
    axisFormat  %d.%m.

    section Specification
    Vision, requirements          :done, s1, 2026-10-03, 2d
    Architecture, data, flows     :done, s2, after s1, 2d
    Test plan, review, approval   :done, s3, after s2, 2d

    section Implementation
    Project setup, dependencies   :i1, 2026-10-10, 1d
    Storage and model             :i2, 2026-10-10, 1d
    Capture, location, address    :i3, 2026-10-10, 1d
    Stamping and EXIF             :i4, 2026-10-10, 1d
    UI, share, full screen        :i5, 2026-10-10, 1d

    section Quality
    Unit tests, analysis          :q1, 2026-10-11, 1d
    Manual device tests           :q2, after q1, 1d

    section Release
    Docs, signing, APK            :r1, after q2, 1d
    Distribute to friends         :milestone, r2, after r1, 0d
```

## 13.7 Definition of Done

A change is done when:

- [ ] It implements the referenced requirement IDs.
- [ ] `flutter analyze` reports no issues; code is formatted.
- [ ] Unit tests added/updated where logic changed; all tests pass.
- [ ] Public classes/methods have doc comments.
- [ ] README / spec updated if behaviour or build steps changed.
- [ ] Tested on a real device for camera/GPS/share changes.
