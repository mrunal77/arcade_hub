# 🕹️ Arcade Hub

A polished, fast, offline-first **multi-game retro-modern arcade application** built with Flutter. Arcade Hub features a unified game selection dashboard, high scores persistence, synthesized 8-bit audio effects, and reusable modular game engine architecture.

---

## 🎮 Included Games

| Game | Description | Controls |
| :--- | :--- | :--- |
| 🐍 **Snake** | Classic retro snake. Collect normal & golden food, avoid walls & self-collisions. | Arrow Keys / WASD / Touch D-Pad / Swipe |
| ❌⭕ **Tic-Tac-Toe** | Notebook paper styled game with hand-drawn ink X's & pencil O's. Play 2-Player or vs Easy/Hard Minimax AI. | Tap cell / Touch |
| 🧱 **Brick Breaker** | Smash multi-layered glowing neon bricks with real-time paddle physics, combos & particle explosions. | Drag paddle / Arrow Keys / A-D |
| 👾 **Space Shooter** | Galactic space defender with animated starfields, laser projectiles, alien formations & health tracking. | Drag ship / Arrow Keys / Space to Shoot |

---

## ✨ Features

- 📱 **Offline-First & Fast**: Fully functional offline without external server dependencies.
- 🎨 **Retro Arcade Theme**: Dark neon aesthetic with glowing cards, smooth canvas painters, and responsive UI layout.
- 🔊 **8-Bit Audio & Haptics**: Procedural sound synthesizers (move, score, power-up, hit, explosion, game over, win) with full mute/unmute settings and haptic feedback.
- 🏆 **High Score Persistence**: Automatic score tracking and leaderboard per game powered by `SharedPreferences`.
- 🕹️ **Dual Controls**: Touch screen (virtual D-Pad / action buttons / gestures) and full physical keyboard support (Arrows, WASD, Spacebar, ESC/P).

---

## 🏗️ Architecture

```text
ArcadeHub
├── Core
│   ├── GameEngine        # Base GameModule, input abstractions & lifecycle
│   ├── GameRegistry      # Catalog & metadata of all games
│   ├── ScoreManager      # High score persistence & leaderboard notifier
│   ├── AudioManager      # 8-bit sound effects & haptic engine
│   └── SettingsManager   # Audio & UI control preferences
│
├── Games
│   ├── Snake             # Grid movement, food spawning & collision logic
│   ├── TicTacToe         # Hand-drawn paper painters & Minimax solver
│   ├── BrickBreaker      # Paddle physics, ball trajectory & brick grid
│   └── SpaceShooter      # Starfield, enemy waves & laser projectiles
│
└── UI
    ├── HomeScreen        # Modern Arcade Hub selection dashboard
    ├── GameScreen        # Unified interactive game host with HUD
    ├── HighScoresScreen  # High scores leaderboard
    └── SettingsScreen    # Audio & controls options
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0.0 or higher)
- Android SDK / Emulator / Physical device

### Running Locally

```bash
# Clone repository
git clone https://github.com/mrunal77/arcade_hub.git
cd arcade_hub

# Install dependencies
flutter pub get

# Run on attached device or emulator
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing

Run static analysis and unit test suite:

```bash
flutter analyze
flutter test
```

---

## 📦 Releases

Download pre-built Android APK binaries directly from [GitHub Releases](https://github.com/mrunal77/arcade_hub/releases/tag/v1.0.0).

---

## 📜 License

Distributed under the MIT License.
