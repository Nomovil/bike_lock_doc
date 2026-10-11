# 02 – Stakeholders and Personas

[← Vision and Scope](01-vision-and-scope.md) · [Index](README.md) · [Next: Functional Requirements →](03-functional-requirements.md)

## 2.1 Stakeholders

| Stakeholder | Interest | Influence |
| --- | --- | --- |
| **Bike owner** (primary user) | Fast, reliable proof; privacy | high |
| **Friends of the owner** (secondary users) | Same app, easy install without a store | medium |
| **Insurance company** (recipient) | Readable date, time, place; image not obviously edited | indirect |
| **Police** (recipient) | Location and time of theft for the report | indirect |
| **Developer / maintainer** | Small, understandable code base; easy builds | high |

```mermaid
  flowchart LR
      Owner(["Bike owner"]) -- "takes photo" --> App["Bike Lock Proof"]
      Friend(["Friend"]) -- "installs APK, uses" --> App
      App -- "shared photo + text" --> Insurer(["Insurance company"])
      App -- "shared photo + text" --> Police(["Police"])
      Dev(["Developer"]) -- "builds, distributes" --> App
```

## 2.2 Personas

### Persona A – Lena, daily commuter

- 34, rides an e-bike worth 3,500 € to the train station every day.
- Has a bike insurance policy that requires the bike to be locked to a fixed
  object.
- Phone: mid-range Android, often low battery, sometimes poor reception in the
  bike garage.
- **Needs**: one tap, no fiddling; must work in a hurry before the train
  leaves; doesn't want 250 bike photos per year in her gallery.
- **Quote**: *"I lock my bike, take a photo, and run."*

### Persona B – Jonas, weekend city tourer

- 27, parks in different, unfamiliar places in other cities.
- iPhone user.
- **Needs**: find out later *where* exactly he parked; send the location to a
  friend who picks up the bike.
- **Quote**: *"Where did I leave it again?"*

### Persona C – Mehmet, theft victim

- Comes back and the bike is gone.
- **Needs**: send evidence to the police and the insurer *immediately*,
  from the street, without explaining anything.
- **Quote**: *"I need proof that it was locked, now."*

## 2.3 User journey – daily lock (Lena)

```mermaid
journey
    title Lena locks her bike at the station
    section Arrive
      Lock bike to rack: 3: Lena
      Pull out phone: 3: Lena
    section Document
      Open Bike Lock Proof: 4: Lena
      Tap New photo: 5: Lena
      Take picture of lock and frame: 4: Lena
      Wait for location and saving: 3: Lena
      See stamped photo: 5: Lena
    section Leave
      Pocket phone, catch train: 5: Lena
```

## 2.4 User journey – theft (Mehmet)

```mermaid
journey
    title Mehmet finds his bike stolen
    section Discover
      Bike is gone: 1: Mehmet
      Open Bike Lock Proof: 3: Mehmet
      See photo with date, time and address: 5: Mehmet
    section Report
      Tap Share: 5: Mehmet
      Choose e-mail to insurer: 4: Mehmet
      Send to police via messenger: 4: Mehmet
```

## 2.5 Key insights from the personas

| Insight | Consequence in the spec |
| --- | --- |
| Users are in a hurry | Location lookup runs in parallel with the camera (FR-03, NFR-10). |
| Bad reception in garages | Address lookup is optional; coordinates are enough (FR-04, FR-13). |
| Gallery clutter is a real annoyance | Private storage only (FR-07, NFR-01). |
| Victims are stressed | Share is one tap, text is pre-filled (FR-12). |
| Insurer may doubt the photo | Information is burned into the image *and* stored as EXIF (FR-05, FR-06). |
