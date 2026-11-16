# Putting

Putting-practice app for iPhone. SwiftUI, iOS 26, Liquid Glass.

## Run it on your iPhone

1. Open `Putting.xcodeproj` in Xcode 26.
2. Select the **Putting** target, then **Signing & Capabilities**, and choose your team (a free Apple ID works).
   If Xcode says the bundle identifier is taken, change `com.ti.putting` to something unique.
3. Connect your iPhone, select it as the run destination, and press **Run**.
4. On the phone, turn on **Developer Mode** (Settings → Privacy & Security) and trust the developer profile
   (Settings → General → VPN & Device Management) if asked.

The simulator has no motion sensor, so slope reading only works on a real phone.

## In this build (core loop)

- **Dashboard.** Grouped glass cards. Slope reading and Metronome in the top bar, Settings on the right.
  Feel, Zones, Random putts and Pace of play are shown dimmed until they are built.
- **Slope reading.** Phone face up, top toward the hole. The ring fills while the phone is still
  and the reading locks after 3 seconds with a check. Redo and See reading in the top right.
- **Tempo.** BPM with − and +, Sound, a pulsing dot, Start and Stop.
- **Lookup.** Stimp, distance (feet, metres or paces), side slope (R/L) and up/down (U/D),
  with Measure buttons that open Slope reading and fill both slope fields.
  Recommendation table: Zone and Aim. Flat equivalent as a note.
- **Calibration (stand-in).** Enter each zone's flat distance and Stimp, and your pace length, by hand.
- **Settings.** Handedness and units.

## Model

`Putting/Model/PuttingModel.swift`

- Friction from Stimp, Weber (1997): `f = 0.983 / S`
- Deceleration on a grade: `g (f ± sinφ cosφ)`
- Roll target: putt + 10% of the distance, at least 1 ft, at most 2 ft
- Each zone is one release speed, `v0² = 2 g f L` from its saved flat distance and Stimp
- Aim: `(a / c²) · [(v0² − vh²)/4 − (vh²/2) ln(v0/vh)]`, aimed opposite the fall of the slope

Not yet checked against real putts.
