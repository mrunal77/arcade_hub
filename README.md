# Paper Tic Tac Toe (Flutter)

Notebook-paper styled Tic Tac Toe: ruled lines, red margin, hand-drawn grid,
animated ink X's, pencil O's and a marker strike-through for wins.

Modes: 2 Players, vs Easy computer, vs Hard (unbeatable minimax). Score tracking included.

## Run

```bash
cd paper_tictactoe
flutter create . --platforms=android,ios,web,linux   # generates platform folders (keeps lib/ and pubspec.yaml)
flutter pub get
flutter run
```

Build an APK:

```bash
flutter build apk --release
```

Run tests: `flutter test`
