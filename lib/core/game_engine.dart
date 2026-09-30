import 'package:flutter/material.dart';

/// Enum representing common directional and action inputs across all arcade games.
enum GameDirection { up, down, left, right, none }

enum GameAction { actionA, actionB, pause, restart }

class GameInput {
  final GameDirection direction;
  final GameAction? action;
  final Offset? touchPosition;

  const GameInput({
    this.direction = GameDirection.none,
    this.action,
    this.touchPosition,
  });
}

/// Abstract base class for all game modules in the Arcade Hub.
abstract class GameModule {
  final String id;
  final String title;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> highScoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isGameOverNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isStartedNotifier = ValueNotifier<bool>(false);

  GameModule({required this.id, required this.title});

  int get score => scoreNotifier.value;
  set score(int value) => scoreNotifier.value = value;

  int get highScore => highScoreNotifier.value;
  set highScore(int value) => highScoreNotifier.value = value;

  bool get isGameOver => isGameOverNotifier.value;
  set isGameOver(bool value) => isGameOverNotifier.value = value;

  bool get isPaused => isPausedNotifier.value;
  set isPaused(bool value) => isPausedNotifier.value = value;

  bool get isStarted => isStartedNotifier.value;
  set isStarted(bool value) => isStartedNotifier.value = value;

  /// Called when the game widget is initialized.
  void init();

  /// Called every frame tick for game loop updates (dt in seconds).
  void update(double dt);

  /// Handle touch or keyboard input events.
  void handleInput(GameInput input);

  /// Start or unpause the game.
  void startGame() {
    isStarted = true;
    isPaused = false;
    isGameOver = false;
  }

  /// Pause the game loop.
  void pauseGame() {
    if (isStarted && !isGameOver) {
      isPaused = true;
    }
  }

  /// Resume paused game.
  void resumeGame() {
    if (isStarted && !isGameOver) {
      isPaused = false;
    }
  }

  /// Toggle pause/resume.
  void togglePause() {
    if (isPaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  /// Reset the game to initial state for a new round.
  void restartGame();

  /// Clean up resources, timers, and listeners.
  void dispose() {
    scoreNotifier.dispose();
    highScoreNotifier.dispose();
    isGameOverNotifier.dispose();
    isPausedNotifier.dispose();
    isStartedNotifier.dispose();
  }
}
