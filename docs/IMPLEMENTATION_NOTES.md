# Penguin Balance — Implementation Notes

## 1) Your original request (what you asked for)

You requested a deterministic Flutter mobile puzzle game inspired by the penguin teeterboard toy, with:

- Integer-only torque logic (`Σ weight × distance`)
- No physics engine, no gravity simulation
- Solo levels + deterministic AI mode
- Smooth animations and pseudo-3D look
- Home / Solo / VS AI / Settings navigation
- Expandable architecture (`core/`, `models/`, `ui/`)
- Toy-like board feel and visible slot-based placement

You later clarified additional expectations:

- Toy-like board density (3 rows × 3 columns each side)
- Landscape-first gameplay experience
- More icon-driven game UI controls
- Local persistence for settings/progress
- Better docs for setup/testing/release workflow

---

## 2) How the current implementation maps to your request

### A) Deterministic game logic (implemented)

- `lib/core/balance_logic.dart`
  - Computes integer torque only
  - Uses tolerance-based balance condition
  - Maps torque to a clamped tilt angle for rendering

- `lib/core/ai_engine.dart`
  - Evaluates candidate placements deterministically
  - Chooses minimal `abs(torque)` result
  - Tie-breaks by smaller absolute distance

- `lib/core/game_state.dart`
  - Handles turn flow, piece placement, win/loss transitions
  - Supports solo and VS AI
  - Keeps logic separated from rendering widgets

### B) Toy-like board and pieces (implemented)

- `lib/models/slot.dart`
  - Board slots are generated as a toy-like layout with
    - 3 rows × 3 columns on the left side
    - 3 rows × 3 columns on the right side
  - Total 18 visible slots
  - Distances remain signed integer values for deterministic torque math

- `lib/models/piece.dart`
  - Three piece types are implemented:
    - Single penguin (weight 1)
    - Double penguin (weight 2)
    - Triple penguin (weight 3)

### C) UI, motion, pseudo-3D styling (implemented)

- `lib/ui/board_widget.dart`
  - Draws pseudo-3D board with gradients + shadows
  - Uses animated rotation (tilt) based on torque
  - Renders all slot markers and placed pieces

- `lib/ui/game_screen.dart`
  - Placement animation from tray toward selected slot
  - Confetti on win
  - Icon-driven actions (restart/home) and status indicators
  - Landscape-optimized gameplay composition

- `lib/ui/piece_widget.dart`
  - Animated piece cards with selection feedback

- `lib/ui/home_screen.dart`
  - Icon-driven entry buttons (Solo / VS AI / Settings)
  - Progress summary card

- `lib/ui/settings_screen.dart`
  - Persisted toggles with icons and continue flow

### D) Navigation, persistence, and app config (implemented)

- `lib/main.dart`
  - `go_router` routes for home/game/settings
  - Landscape orientation lock for gameplay-first UX

- `lib/core/app_storage.dart`
  - Local persistence through `shared_preferences`
  - Stores settings and progress stats

- `lib/core/app_config.dart`
  - Documents runtime permission policy

### E) Project quality and docs (implemented)

- `analysis_options.yaml` for linting
- `test/balance_logic_test.dart` for logic checks
- `README.md` now includes:
  - Local setup
  - Test/analyze commands
  - Production build guidance (Play Store/App Store workflow)

---

## 3) Libraries used and why

- `go_router`
  - Declarative screen routing

- `google_fonts`
  - Playful/clean typography styling

- `flutter_animate`
  - UI entrance and micro-motion polish

- `confetti`
  - Win feedback effect

- `shared_preferences`
  - Local key-value persistence for settings/progress

No physics engine is used.

---

## 4) Known practical constraints in this environment

In this container, Flutter SDK is not installed, so commands like:

- `flutter run`
- `flutter test`
- `flutter analyze`

cannot be executed here directly.

The source code and structure are prepared for normal Flutter local environments where those commands are available.

---

## 5) What you can adjust next (optional)

If you want an even closer toy replica, next steps can include:

- Replacing emoji penguins with custom PNG/SVG assets
- Adding board texture art assets
- Adding richer move history / undo
- Introducing level packs and difficulty progression metadata

