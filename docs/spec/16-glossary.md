# 16 – Glossary

[← Risks and Open Issues](15-risks-and-open-issues.md) · [Index](README.md)

| Term | Meaning |
| --- | --- |
| **AAB** | Android App Bundle – upload format for Google Play. |
| **ABI** | Application Binary Interface – CPU type of a phone (`arm64-v8a`, `armeabi-v7a`, `x86_64`). |
| **Accuracy** | Radius in metres around the GPS position within which the true position lies with ~68 % probability. |
| **ADR** | Architecture Decision Record – short document explaining one design decision. |
| **APK** | Android Package – installable app file. |
| **C4 model** | Architecture diagram levels: Context, Containers, Components, Code. |
| **Debug key** | Signing key Flutter/Android create automatically per computer; not for distribution. |
| **EXIF** | Exchangeable Image File Format – metadata inside JPEG files (date, GPS, camera). |
| **FileProvider** | Android mechanism to give another app (the camera) temporary access to a private file. |
| **Geocoding (reverse)** | Turning coordinates into a human-readable address. |
| **GDPR / DSGVO** | EU General Data Protection Regulation. |
| **GNSS / GPS** | Satellite positioning; on phones combined with Wi-Fi and cell data. |
| **Hot reload** | Flutter feature to inject code changes into the running app in about a second. |
| **IPA** | iOS App Store Package – installable iOS app archive. |
| **Isolate** | Dart's unit of concurrency; separate memory, used for heavy work off the UI. |
| **Last known position** | Position cached by the OS from an earlier fix; may be outdated. |
| **Lock record** | The one stored entry: photo + date/time + location + address. |
| **MoSCoW** | Prioritisation: Must, Should, Could, Won't. |
| **Proof photo** | The stamped JPEG produced by the app. |
| **Release key / keystore** | The developer's own signing key (`.jks`) that identifies all versions of the app. |
| **Share sheet** | The OS dialog listing apps that can receive shared content. |
| **Snack bar** | Short message at the bottom of the screen that disappears automatically. |
| **Stamp / info strip** | The dark band with white text drawn onto the bottom of the photo. |
| **STRIDE** | Threat categories: Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege. |
| **TestFlight** | Apple's beta distribution service for iOS apps. |
