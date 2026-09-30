import 'dart:math';
import '../../core/audio_manager.dart';
import '../../core/game_engine.dart';
import '../../core/score_manager.dart';

enum FoodType { normal, golden, speed }

class Food {
  final Point<int> position;
  final FoodType type;
  final DateTime createdAt;

  Food(this.position, this.type) : createdAt = DateTime.now();

  int get scoreValue {
    switch (type) {
      case FoodType.normal:
        return 10;
      case FoodType.golden:
        return 35;
      case FoodType.speed:
        return 20;
    }
  }
}

class SnakeGameModule extends GameModule {
  static const int gridWidth = 20;
  static const int gridHeight = 25;

  List<Point<int>> body = [];
  GameDirection currentDirection = GameDirection.right;
  GameDirection _nextDirection = GameDirection.right;
  bool _directionChangedThisStep = false;

  Food? food;
  final Random _rng = Random();

  double _stepInterval = 130.0; // ms per step
  double _accumulator = 0.0;

  int movesCount = 0;

  SnakeGameModule() : super(id: 'snake', title: 'Snake');

  @override
  void init() {
    highScore = ScoreManager.instance.getHighScore(id);
    restartGame();
  }

  @override
  void restartGame() {
    score = 0;
    movesCount = 0;
    _stepInterval = 130.0;
    _accumulator = 0.0;
    currentDirection = GameDirection.right;
    _nextDirection = GameDirection.right;
    _directionChangedThisStep = false;
    isGameOver = false;
    isPaused = false;
    isStarted = false;

    const startX = gridWidth ~/ 2;
    const startY = gridHeight ~/ 2;
    body = [
      const Point(startX, startY),
      const Point(startX - 1, startY),
      const Point(startX - 2, startY),
    ];

    _spawnFood();
  }

  @override
  void startGame() {
    super.startGame();
    _accumulator = 0.0;
  }

  @override
  void update(double dt) {
    if (!isStarted || isPaused || isGameOver) return;

    _accumulator += dt * 1000.0;
    if (_accumulator >= _stepInterval) {
      _accumulator = 0.0;
      _step();
    }
  }

  void _step() {
    if (!isStarted || isPaused || isGameOver) return;

    currentDirection = _nextDirection;
    _directionChangedThisStep = false;

    final head = body.first;
    Point<int> newHead;

    switch (currentDirection) {
      case GameDirection.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case GameDirection.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case GameDirection.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case GameDirection.right:
        newHead = Point(head.x + 1, head.y);
        break;
      case GameDirection.none:
        return;
    }

    // Wall collision
    if (newHead.x < 0 ||
        newHead.x >= gridWidth ||
        newHead.y < 0 ||
        newHead.y >= gridHeight) {
      _triggerGameOver();
      return;
    }

    // Self collision
    if (body.contains(newHead)) {
      _triggerGameOver();
      return;
    }

    body.insert(0, newHead);
    movesCount++;

    // Food collision
    if (food != null && newHead == food!.position) {
      score += food!.scoreValue;
      AudioManager.instance.play(
          food!.type == FoodType.golden ? SoundEffect.powerUp : SoundEffect.score);

      if (_stepInterval > 65.0) {
        _stepInterval = max(65.0, 130.0 - (score * 0.7));
      }

      _spawnFood();
    } else {
      body.removeLast();
    }
  }

  void _spawnFood() {
    final emptyCells = <Point<int>>[];
    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridHeight; y++) {
        final p = Point(x, y);
        if (!body.contains(p)) {
          emptyCells.add(p);
        }
      }
    }

    if (emptyCells.isEmpty) return;

    final p = emptyCells[_rng.nextInt(emptyCells.length)];
    FoodType type = FoodType.normal;
    final r = _rng.nextDouble();
    if (r < 0.15) {
      type = FoodType.golden;
    } else if (r < 0.3) {
      type = FoodType.speed;
    }

    food = Food(p, type);
  }

  @override
  void handleInput(GameInput input) {
    if (input.direction == GameDirection.none) return;
    if (_directionChangedThisStep) return;

    final desired = input.direction;

    if (desired == GameDirection.up && currentDirection != GameDirection.down) {
      _nextDirection = GameDirection.up;
      _directionChangedThisStep = true;
    } else if (desired == GameDirection.down && currentDirection != GameDirection.up) {
      _nextDirection = GameDirection.down;
      _directionChangedThisStep = true;
    } else if (desired == GameDirection.left && currentDirection != GameDirection.right) {
      _nextDirection = GameDirection.left;
      _directionChangedThisStep = true;
    } else if (desired == GameDirection.right && currentDirection != GameDirection.left) {
      _nextDirection = GameDirection.right;
      _directionChangedThisStep = true;
    }
  }

  void _triggerGameOver() {
    isGameOver = true;
    AudioManager.instance.play(SoundEffect.gameOver);
    ScoreManager.instance.saveScore(id, score).then((isNewHigh) {
      if (isNewHigh) {
        highScore = score;
      }
    });
  }
}
