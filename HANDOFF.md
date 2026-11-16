# Putting app – hand-off summary

Paste or attach this file in a new chat to continue the work. Code: GitHub `tiryqthomas/putting_physics` (branch `main`).

**Read first.** The original chat was compressed partway through. Decisions 1–31 and the exact layouts of the earliest screens were only partly kept. Anything marked *(unverified)* should be checked with Ti before it is built. Ti's own screenshots of the Tempo screen, the Landmarks screen and the zone tile are the reference for those three.

---

## 1. How Ti works

- **Ti makes every decision.** For each decision, give 2–4 options with a one-line consequence each, plus a recommendation. Show them visually (phone mock-ups) where possible. Keep a numbered decision log. Never build past an open decision.
- **Design rules** (from Ti's flow document):
  - Apple design principles and Liquid Glass. SF Pro font.
  - Black and white. The exceptions are the green slab on Feel and **orange for whatever is selected or active** (the fall line, the selected landmark). The text caret is white.
  - Simplest possible information and minimal words. No tips for anything that can be implied. Very formal copy.
  - Consistent spacing. Subtle animations, used only as interactive feedback.
  - A back path on every screen, unless the screen already implies one.
  - No scrolling unless necessary.
  - The app follows the phone's light or dark setting. Text contrast is 4.5:1 or better: captions at `#8e8e93` in dark mode and `#6c6c70` in light mode, and chevrons in light mode at `#6c6c70`.
- **Purpose.** The app is for practice only, not for use on the course. Values are estimates that ignore grain, wind and moisture.

## 2. App structure

- **Onboarding:** Welcome (app name and three features), then Handedness, then the Calibration hub with a skip option. If the user skips, the dashboard shows a "Calibration incomplete" banner.
- **Dashboard** ("Practice"):
  - **Top bar:** Slope reading and Metronome buttons on the left, Settings on the right.
  - **Banners:** a Resume banner (shown first) and the Calibration banner. They stack when both apply.
  - **Glass cards:** [Calibration, Lookup]; TESTS [Tempo, Feel]; PRACTICE [Zones, Random putts, Pace of play].
- **Handedness:** set during onboarding and changeable in Settings. Right-handed uses the right foot; left-handed uses the left foot. Every foot diagram follows this.
- **Settings:** Handedness, Units (feet or metres; the small unit stays cups). Phone cases for camera-bump calibration: "No case" is built in; tapping a case gives Redo or Delete; readings are hidden and applied automatically. Sound and Haptics are *(unconfirmed)*.

## 3. Screens and decisions

### Calibration
- The hub is a list: Stance, Landmarks, Tempo, Stimp, Pace, Distance. A "Calibrate all" option runs every step.
- **Stance.** A camera view. One button sets marker one, then marker two, then Restart or Save. Measured with AR, with manual entry as a fallback.
- **Landmarks (Ti's screenshot is the reference).**
  - Both soles are drawn as white outlines on black.
  - Each zone is a **vertical line**. The selected zone is a solid orange line with a dot at the top and a large dot handle at the bottom.
  - The other zones are dashed grey lines with ring handles. Some of them sit outside the foot.
  - The lines sit on the hitting-side foot, and the screen is mirrored for left-handed users.
  - 2–6 landmarks. The control for removing a landmark is still undecided (leaning towards a glass popover).
- **Zones** are vertical strips of the foot, and the user names them. For a right-handed user, Inside is the left-most strip, Center is the middle and Outside is the right-most. Left-handed is mirrored.
- **Zone tile (Ti's screenshot).** A small glass tile at the top right showing the sole outline with the active zone as a white strip, and the zone name beneath.
- **Tempo (Ti's screenshot).** Round glass − and + buttons on either side of a large BPM number, a "BPM" label, one pulsing dot below, a Sound capsule at the top right and a white Start button at the bottom.
- **Stimp.** A list of Stimp ranges, each with a short description of where you might find that green, plus "I know the Stimp", which asks for the value. The ranges were approved; the exact list is *(unverified)*. When the user averages uphill and downhill readings, use the harmonic mean (Brede).
- **Pace (Decision 44).** Mark the start with AR, walk 10 normal steps, then mark the end. The fallback is counting the paces.
- **Distance.**
  - The AR start point is set once and kept. The user then marks the shortest and longest putts.
  - The saved distance is the average of the shortest and longest, measured from the start.
  - Paces are the fallback (Decision 41: AR with a paces fallback).
  - Layout per Ti: the zone tile at the top right, **3 white dots** (one per mark, at the top or bottom), an undo button and a back button. **Ti did not want a Start / Shortest / Longest segmented control.** The exact layout is *(unverified)*: ask Ti or get a screenshot.

### Slope reading
- **Standalone use.** The phone lies face up on the green with its top toward the hole.
  - The ring sits in the centre of the screen, with its text below.
  - The ring only fills once the phone is still. After about 3 seconds the reading locks with a check animation and **no text**.
  - Back is at the top left. Redo and See reading are at the top right.
- **Face-up and face-down calibration** applies only to the phone-case calibration in Settings.
- **Hidden readings.** In Feel and Random putts the reading stays secret until the end.
- An earlier note had readings averaged over several attempts. The weighting rule for that is undecided.

### Feel test (landscape)
- The guess screen has a squishy 3D green slab, a ball that springs to show the slope, and thin bars with glass capsule handles.
- Slope range is ±6% in 0.5% steps.
- Prototype: `feel_test_guess_options.html` was published as a claude.ai artifact. It still contains dead code for slider styles A, C and D.

### Zones practice (Decisions 33–43)
- **Flow:** pick a zone (from a list), confirm the tempo (the app plays it, with the small zone diagram at the top right and its name beneath), confirm the Stimp (exact or a range), then take slope checkpoints at the ball and ahead of it.
  - The slope checkpoints are guided, with spacing that scales with distance.
  - The app backs out a flat-equivalent distance from them.
- **Distance:** marked with AR (shortest and longest from a fixed start).
- **Result:** the number shown with the conditions it came from (Decision 43 B: tempo, Stimp, shortest and longest).
- The Zones flow screen is a **checklist** (Decision 33 B).

### Random putts (untimed, a feedback tool)
- The user places a ball anywhere on the green and works everything out unaided, entering it as they go. This takes two screens (Decision 49).
- The slope is measured during the feel step and kept secret until the end.
- Misses are logged with **nine buttons** (short, long, left, right and combinations) (Decision 50).
- **Review:** a scatter of every putt (Decision 60).

### Pace of play (timed)
- It times the user's routine: finding the distance, finding the slope, reading, standing over the ball and putting.
- It is a separate dashboard entry from Random putts (Decision 51).
- **Logged decisions 52–62** (option letters kept from the log):
  - 52 A: a target time per putt
  - 53 C: presets and custom
  - 54 C: one total
  - 55 A: time and difference
  - 56 B: the user chooses the round length
  - 57 B: two rows
  - 58 A: average and count
  - 59 C: presets and custom
  - 60 A: scatter of every putt
  - 61 A: fixed spots with a count
  - 62 A: flat list
  - What some of these apply to *(unverified)*: ask Ti if it matters.
- **Rotate cue (72).** A full-screen phone that turns, with one line of text, shown before slope entry in landscape. The clock pauses during the cue and for **3 s** after the phone turns (75).
- **Leaving mid-round (73).** An alert with Stay, Leave and Discard round. Progress is saved, and the round resumes from the dashboard banner (70, 71).

### Lookup (Decisions 64–68, 76–78)
- **Form, in portrait:**
  - Stimp
  - Distance in feet or metres, with a unit chip that switches to paces when a pace length exists
  - Side slope % with R/L
  - Up/down % with U/D
- **Measure buttons:** a ruler opens Distance; a level icon on either slope row opens Slope reading, and one reading fills both slope fields.
- **Up/down from checkpoints (77).** The checkpoints give one net average grade: net rise divided by distance.
- **RECOMMENDATION:** a two-column table, `Zone | Center` and `Aim | 3.3 cups · 1.2 ft L`.
  - The flat equivalent is a small grey note at the bottom.
  - The label is **Aim**, not "Aimpoint", to avoid the commercial method's name.
- **Aim direction:** opposite the slope. A green falling right gives L.
- **No saved distance for a zone:** "Not enough data", with a link to Zones.
- **Saved distance at a different Stimp:** the result is scaled from the saved Stimp (70).

## 4. Physics model (Decision 65)

Source: Weber, "Green Speed Physics", USGA Green Section Record, March/April 1997. The PDF is in the old chat.

- Friction: `f = 0.983 / S` (S is the Stimp reading in feet).
- Deceleration on a grade: `c = g (f ± sinφ cosφ)`, with `g = 32.2 ft/s²`. Plus is uphill. The ball never stops downhill if `sinφ cosφ ≥ f` (about 10% at Stimp 10).
- Uphill and downhill Stimp: `0.983/(f ± sinφcosφ)`. Their harmonic mean gives the level Stimp exactly.
- **Roll target:** `D + clamp(0.1·D, 1, 2)` ft (76, 78). The accept window is 1–2 ft past the hole.
- **Zone speed:** `v0² = 2 g f L_saved`. This does not change with Stimp. The app picks the zone closest to the required `sqrt(2c·roll)`.
- **Aim offset:** `(a/c²)·[(v0²−vh²)/4 − (vh²/2)·ln(v0/vh)]`, with `a = g·side grade` and `vh² = v0² − 2cD`. When `vh = 0` this reduces to `s·D/(2f)`. It was checked against a numerical simulation to within 0.05 ft.
- **Flat equivalent:** `roll · (f ± sinφcosφ) / f`.
- **Cup:** 4.25 in, so feet = cups × 4.25 / 12. Cups and feet are always both shown.
- **Not yet checked on real putts.**

## 5. Build status

- **Stack:** SwiftUI, iOS 26 (real Liquid Glass), Swift 5 mode. The project uses Xcode 16+ synchronised folders, so new files are added automatically.
- **Built (core loop, Decision 80):**
  - Dashboard. Feel, Zones, Random putts and Pace of play are greyed out.
  - Slope reading (CoreMotion gravity, 3 s stillness lock).
  - Tempo.
  - Lookup, with the model in `Putting/Model/PuttingModel.swift`.
  - Settings (handedness and units).
  - A **stand-in** Calibration screen for typing zone distances, Stimp and pace length.
- **Not compiled yet.** It was written on Linux. Fix whatever Xcode errors Ti reports first.
- **Shortcuts to replace:**
  - Slope Measure takes one reading, not checkpoints.
  - There's no AR distance.
  - "Not enough data" links to Calibration.
  - Blank slope fields count as 0.
  - The bundle ID is `com.ti.putting`.
  - The app is named "Putting" (a placeholder) and has no icon.

## 6. Open items

1. Fix the first-build errors.
2. Distance screen layout: the 3 dots (top or bottom), undo placement and how a mark is placed.
3. The Landmarks remove-landmark control. Confirm Decision 79 (the lines follow handedness on every screen).
4. Build the next modules: Zones, Feel, Random putts, Pace of play, AR distance and pace calibration, then the real Calibration flows.
5. The app name and icon.
6. Check the model against real putts.
