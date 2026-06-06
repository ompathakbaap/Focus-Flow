# Focus Flow 🎯

A premium Pomodoro & deep work timer built with Flutter. Features custom `CustomPainter` animations, BLoC state management, Hive local persistence, and a hand-drawn animated stats dashboard.

## Tech Stack

- **State Management**: flutter_bloc + Equatable
- **Persistence**: Hive (local NoSQL)
- **Architecture**: BLoC pattern (event → state)
- **Animations**: CustomPainter, AnimationController, Hero transitions
- **Platform**: iOS + Android (portrait)

## Setup

```bash
# 1. Get dependencies
flutter pub get

# 2. Run the app
flutter run
```

> No API keys, no backend — runs 100% offline.

## Project Structure

```
lib/
├── main.dart                  # Entry point, Hive init, BLoC provider
├── theme/
│   └── app_theme.dart         # Color palette, ThemeData
├── models/
│   ├── session_model.dart     # Hive model
│   └── session_model.g.dart   # Generated adapter
├── bloc/
│   ├── timer_bloc.dart        # Business logic
│   ├── timer_event.dart       # Events
│   └── timer_state.dart       # States + SessionType enum
├── screens/
│   ├── timer_screen.dart      # Main timer UI
│   └── stats_screen.dart      # Weekly stats dashboard
└── widgets/
    ├── timer_painter.dart     # CustomPainter arc timer
    ├── pulse_ring.dart        # Animated pulse rings
    ├── stats_chart.dart       # Animated bar chart (CustomPainter)
    ├── session_type_selector.dart
    └── pomodoro_dots.dart
```

## Features

- Animated circular countdown timer with tick marks and glow effect
- Pulse ring animation when timer is running
- Smooth session type switching (Focus / Short Break / Long Break)
- Pomodoro dot tracker (4 dots per cycle)
- Session history persisted with Hive
- Weekly stats dashboard with animated bar chart
- Streak counter + total focus time
- Haptic feedback on pause/resume/complete
- Slide transition to stats screen
