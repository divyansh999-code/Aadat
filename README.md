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

| Home | Stats | Profile | Widget |
|:----:|:-----:|:-------:|:------:|
| <img src="https://github.com/user-attachments/assets/b2465991-6c55-4cc3-8df3-b7c2b05a092c" width="180" /> | <img src="https://github.com/user-attachments/assets/61088848-b046-40b1-acbb-d83802577443" width="180" /> | <img src="https://github.com/user-attachments/assets/e82c00d4-2487-48d8-85ed-f868856ebe42" width="180" /> | <img src="https://github.com/user-attachments/assets/9e263d68-f225-476f-a7de-4573ad27ef06" width="180" /> |

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

## Built By

**Divyansh Khandal** | AI Developer & Data Science Enthusiast.

[![GitHub](https://img.shields.io/badge/GitHub-divyansh999--code-181717?style=flat-square&logo=github)](https://github.com/divyansh999-code)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Divyansh%20Khandal-0A66C2?style=flat-square&logo=linkedin)](https://linkedin.com/in/divyansh-khandal-5b8b8b32b)

---

</div>
