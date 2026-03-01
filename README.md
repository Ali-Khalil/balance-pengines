# Penguin Balance

Deterministic Flutter puzzle game where players place weighted penguin pieces on fixed board slots to keep torque balanced.

## Features

- Integer-only torque math (`Σ weight × distance`)
- Solo level mode with predefined levels
- Deterministic AI mode (no randomness)
- State-driven board tilt + wobble animation
- Pseudo-3D board and piece styling
- `go_router` navigation with Home / Solo / VS AI

## Structure

```text
lib/
 ├── core/
 │    ├── balance_logic.dart
 │    ├── ai_engine.dart
 │    ├── game_state.dart
 │
 ├── models/
 │    ├── piece.dart
 │    ├── slot.dart
 │    ├── level.dart
 │
 ├── ui/
 │    ├── board_widget.dart
 │    ├── piece_widget.dart
 │    ├── game_screen.dart
 │    ├── home_screen.dart
 │
 └── main.dart
```

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```
