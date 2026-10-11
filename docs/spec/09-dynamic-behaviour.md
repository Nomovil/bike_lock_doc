# 09 – Dynamic Behaviour

[← Data Model and Storage](08-data-model-and-storage.md) · [Index](README.md) · [Next: Privacy, Permissions and Security →](10-privacy-permissions-security.md)

## 9.1 App start (UC-02)

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant H as HomePage
    participant S as LockStorage
    participant FS as File system

    U->>H: launch app
    H->>H: show spinner (_loading = true)
    H->>S: load()
    S->>FS: read bike_lock/lock_record.json
    alt file missing or unreadable
        FS-->>S: not found / parse error
        S-->>H: null
        H->>H: show empty state
    else file present
        FS-->>S: JSON
        S->>FS: photo file exists?
        alt photo missing
            S-->>H: null
            H->>H: show empty state
        else photo present
            S-->>H: LockRecord
            H->>H: show photo and details
        end
    end
```

## 9.2 Document locked bike – main flow (UC-01)

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant H as HomePage
    participant G as geolocator
    participant C as image_picker / camera
    participant GC as geocoding
    participant P as PhotoStamper
    participant I as Background isolate
    participant S as LockStorage

    U->>H: tap "New photo"
    H->>G: _getPosition() (not awaited yet)
    activate G
    H->>C: pickImage(camera, max 2560 px, q95)
    activate C
    C-->>U: system camera UI
    U->>C: take and confirm photo
    C-->>H: XFile (temp file)
    deactivate C
    H->>H: timestamp = now()
    H->>H: overlay "Getting location…"
    H->>G: await position
    G-->>H: Position (lat, lon, accuracy)
    deactivate G
    H->>GC: placemarkFromCoordinates (8 s timeout)
    GC-->>H: "Main St 1, 10115 Berlin"
    H->>H: overlay "Saving photo…"
    H->>P: stamp(bytes, timestamp, location, address)
    P->>P: decode, draw strip on Canvas, read RGBA
    P->>I: compute(_encodeJpeg)
    I-->>P: JPEG bytes with EXIF
    P-->>H: JPEG bytes
    H->>S: replace(bytes, metadata)
    S->>S: write photo, write JSON, delete old photos
    S-->>H: LockRecord
    H->>H: delete camera temp file
    H->>H: hide overlay, show new record
```

## 9.3 Location acquisition (`_getPosition`)

```mermaid
flowchart TD
    A(["start"]) --> B{"Location service<br/>enabled?"}
    B -- "no" --> M1["message: services off"] --> N(["return null"])
    B -- "yes" --> C{"checkPermission()"}
    C -- "denied" --> D["requestPermission()<br/>(OS dialog)"]
    D --> E{"result"}
    C -- "whileInUse / always" --> F
    E -- "granted" --> F["getCurrentPosition<br/>accuracy best, limit 30 s"]
    E -- "denied / deniedForever" --> M2["message: permission denied"] --> N
    C -- "deniedForever" --> M2
    F -- "fix" --> R(["return Position"])
    F -- "timeout" --> L["getLastKnownPosition()"]
    L -- "available" --> R
    L -- "none" --> N
    F -- "other error" --> N
```

## 9.4 Alternative flows of UC-01

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant H as HomePage
    participant C as Camera
    participant G as geolocator
    participant S as LockStorage

    U->>H: tap "New photo"
    H->>G: start location lookup
    H->>C: open camera

    alt user cancels camera
        C-->>H: null
        H-->>U: nothing changes (FR-09)
    else camera error
        C-->>H: exception
        H-->>U: "Could not open camera: …"
    else photo taken
        C-->>H: XFile
        H->>G: await position
        alt no location
            G-->>H: null
            H->>S: replace(... without location)
            S-->>H: LockRecord
            H-->>U: "Photo saved, but the location could not be determined."
        else stamping or storage fails
            H->>S: replace(...)
            S-->>H: exception
            H-->>U: "Saving failed: …" (previous photo kept)
        end
        H->>H: delete temp file (always)
    end
```

## 9.5 Share (UC-04)

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant H as HomePage
    participant SP as share_plus
    participant OS as System share sheet
    participant T as Target app

    U->>H: tap "Share"
    H->>H: compute button rect (iPad anchor)
    H->>SP: share(files: [photo.jpg], text: shareText, subject)
    SP->>OS: present sheet
    OS-->>U: list of targets
    alt user picks a target
        U->>OS: choose e-mail / messenger
        OS->>T: photo + text
        T-->>U: compose screen
    else user dismisses
        OS-->>SP: dismissed
    end
    SP-->>H: ShareResult
```

## 9.6 Home screen state machine

```mermaid
stateDiagram-v2
    [*] --> Loading
    Loading --> Empty: load() == null
    Loading --> Showing: load() == record

    state Capturing {
        [*] --> CameraOpen
        CameraOpen --> Locating: photo taken
        Locating --> Geocoding: position known
        Locating --> Stamping: no position
        Geocoding --> Stamping
        Stamping --> Storing
    }

    Empty --> Capturing: tap Take photo
    Showing --> Capturing: tap New photo
    Capturing --> Showing: stored
    Capturing --> Empty: cancelled or failed, no previous record
    Capturing --> Showing: cancelled or failed, previous record

    Showing --> FullScreen: tap photo
    FullScreen --> Showing: back
    Showing --> Sharing: tap Share
    Sharing --> Showing: sheet closed
```

## 9.7 Timing budget (UC-01, typical)

```mermaid
gantt
    title Time from tap to saved photo (typical, good GPS)
    dateFormat  ss
    axisFormat  %S s
    section Parallel
    Location lookup          :loc, 00, 4s
    section User
    Camera open and shoot    :cam, 00, 5s
    section App
    Geocoding                :geo, after cam, 1s
    Stamping and encoding    :enc, after geo, 2s
    Storing and cleanup      :sto, after enc, 1s
```

Because location runs in parallel with the camera, the user usually doesn't
wait for GPS at all (G-1, NFR-10).
