<div align="center">
<img alt="Aadat Logo" src="https://github.com/user-attachments/assets/a59c32ed-1399-4e08-a10b-65f0f192f845" width="100" />


# Aadat — عادت

**the Urdu word for habit**

*A minimal habit tracker built on the principles of Atomic Habits.*  
*Black and white. No subscriptions. No noise.*  
*Just the list of things you said you'd do.*

![Flutter](https://img.shields.io/badge/Flutter-Framework-black?style=flat-square)
![SQLite](https://img.shields.io/badge/SQLite-Offline--First-black?style=flat-square)
![Android](https://img.shields.io/badge/Android-API%2026+-black?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-black?style=flat-square)

</div>

---

## Screenshots

> *(Replace with your actual screenshots)*

| Home | Stats | Profile | Widget |
|:----:|:-----:|:-------:|:------:|
| ![Home](screenshots/home.png) | ![Stats](screenshots/stats.png) | ![Profile](screenshots/profile.png) | ![Widget](screenshots/widget.png) |

---

## Features

### I — Core Tracking
- Check in habits with a single tap, undo instantly
- Custom frequency: daily or specific days of the week
- Archive or delete without losing history

### II — Streak Logic
| Mode | Behaviour |
|------|-----------|
| **Strict** | Miss a day — streak resets |
| **Grace** | One missed day allowed before chain breaks |

Best streak tracked independently from current streak.

### III — Habit Stacking
Group habits into a named stack — *"Morning Routine"* chains **Meditate + Read + Journal** as a single unit. Inspired directly by James Clear's habit stacking technique.

### IV — Habit Matrix
- Week-view grid of completion history across all habits
- Navigate between weeks with left/right arrows
- Visual chain — see streaks at a glance, identify exactly where you broke them

### V — Live Home Screen Widget
- Tap to check in directly from the home screen — no app open required
- Syncs on launch, check-in, edit, archive, and app resume
- White paper + black ink aesthetic, matches the app exactly
- Shows top habits with checkbox state and streak count

### VI — Profile & Stats
A 2×2 stats grid: Total Check-ins · Longest Streak · Days Tracked · Habits Created.  
Dark / Light theme toggle. Inline name editing.

---

## Design Philosophy

> *"You do not rise to the level of your goals.  
> You fall to the level of your systems."*  
> — James Clear, Atomic Habits

**Make it obvious** — Habits on your home screen via the widget, not buried in an app you have to remember to open.

**Make it satisfying** — Streak tracking and the habit matrix create a visual record worth protecting.

**Never miss twice** — Grace mode is built into the streak logic. One bad day doesn't erase your progress.

The black-and-white design is intentional. No gamification, no color-coded urgency, no notification spam. Moleskine notebook aesthetics: ink on paper.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| Database | SQLite via `sqflite` |
| State Management | Provider |
| Home Screen Widget | `home_widget` |
| Local Fonts | `google_fonts` |
| Launcher Icon | `flutter_launcher_icons` |

---

## Getting Started

**Prerequisites:** Flutter SDK ≥ 3.x · Android SDK API 26+

```bash
# Clone and run
git clone https://github.com/your-username/aadat.git
cd aadat
flutter pub get
flutter run
```

```bash
# Build release APK
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture

```
lib/
├── models/         habit.dart · habit_log.dart · habit_stack.dart
├── providers/      habit_provider.dart
├── services/       database_service.dart
├── screens/        home · stats · add_habit · profile · onboarding
└── widgets/        habit_card.dart

android/
└── app/src/main/
    ├── kotlin/     AadatWidgetProvider.kt
    └── res/layout/ widget_layout.xml
```

---

## License

MIT — open source, free forever.

---

<div align="center">

*Crafted with intention by* **Divyansh Khandal**

</div>
