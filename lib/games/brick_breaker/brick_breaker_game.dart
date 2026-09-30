import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/game_engine.dart';
import '../../core/score_manager.dart';

class Brick {
  Rect rect;
  Color color;
  int hp;
  final int maxHp;
  final int scoreValue;

  Brick({
    required this.rect,
    required this.color,
    this.hp = 1,
    this.scoreValue = 15,
  }) : maxHp = hp;

  bool get isDestroyed => hp <= 0;
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double life; // 1.0 to 0.0
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    this.life = 1.0,
    this.size = 4.0,
  });
}

class BrickBreakerGameModule extends GameModule {
  // Normalized dimensions: width = 1.0, height = 1.3
  static const double worldWidth = 1.0;
  static const double worldHeight = 1.3;

  double paddleX = 0.5;
  double paddleWidth = 0.24;
  static const double paddleHeight = 0.03;
  static const double paddleY = 1.20;

  Offset ballPos = const Offset(0.5, 1.15);
  Offset ballVel = const Offset(0.35, -0.65);
  static const double ballRadius = 0.018;

  bool ballLaunched = false;
  int lives = 3;
  int level = 1;

  List<Brick> bricks = [];
  List<Particle> particles = [];

  Timer? _ticker;
  final Random _rng = Random();

  BrickBreakerGameModule() : super(id: 'brick_breaker', title: 'Brick Breaker');

  @override
  void init() {
    highScore = ScoreManager.instance.getHighScore(id);
    restartGame();
  }

  @override
  void restartGame() {
    score = 0;
    lives = 3;
    level = 1;
    isGameOver = false;
    isPaused = false;
    isStarted = false;
    paddleX = 0.5;
    paddleWidth = 0.24;
    particles.clear();
    _resetBall();
    _generateBricks();
  }

  void _resetBall() {
    ballLaunched = false;
    ballPos = Offset(paddleX, paddleY - ballRadius - 0.01);
    final angle = (-pi / 4) - (_rng.nextDouble() * pi / 2);
    final speed = 0.75 + (level * 0.05);
    ballVel = Offset(cos(angle) * speed, sin(angle) * speed);
  }

  void _generateBricks() {
    bricks.clear();
    const rows = 6;
    const cols = 7;
    const padding = 0.012;
    const topOffset = 0.12;

    const brickW = (worldWidth - (padding * (cols + 1))) / cols;
    const brickH = 0.045;

    final colors = [
      const Color(0xFFFF1744), // Red
      const Color(0xFFFF9100), // Orange
      const Color(0xFFFFD600), // Yellow
      const Color(0xFF00E676), // Green
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFFD500F9), // Purple
    ];

    for (int r = 0; r < rows; r++) {
      final color = colors[r % colors.length];
      final hp = r < 2 ? 2 : 1;
      for (int c = 0; c < cols; c++) {
        final x = padding + c * (brickW + padding);
        final y = topOffset + r * (brickH + padding);
        bricks.add(
          Brick(
            rect: Rect.fromLTWH(x, y, brickW, brickH),
            color: color,
            hp: hp,
            scoreValue: (rows - r) * 10,
          ),
        );
      }
    }
  }

  @override
  void startGame() {
    super.startGame();
    ballLaunched = true;
    _startLoop();
  }

  void _startLoop() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
      update(0.016);
    });
  }

  @override
  void update(double dt) {
    if (!isStarted || isPaused || isGameOver) return;

    if (!ballLaunched) {
      ballPos = Offset(paddleX, paddleY - ballRadius - 0.01);
      return;
    }

    // Update Particles
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.position += p.velocity * dt;
      p.life -= dt * 2.5;
      if (p.life <= 0) {
        particles.removeAt(i);
      }
    }

    // Move Ball
    ballPos += ballVel * dt;

    // Wall collision (Left / Right)
    if (ballPos.dx - ballRadius <= 0) {
      ballPos = Offset(ballRadius, ballPos.dy);
      ballVel = Offset(-ballVel.dx, ballVel.dy);
      AudioManager.instance.play(SoundEffect.tap);
    } else if (ballPos.dx + ballRadius >= worldWidth) {
      ballPos = Offset(worldWidth - ballRadius, ballPos.dy);
      ballVel = Offset(-ballVel.dx, ballVel.dy);
      AudioManager.instance.play(SoundEffect.tap);
    }

    // Wall collision (Top)
    if (ballPos.dy - ballRadius <= 0.06) {
      ballPos = Offset(ballPos.dx, 0.06 + ballRadius);
      ballVel = Offset(ballVel.dx, -ballVel.dy);
      AudioManager.instance.play(SoundEffect.tap);
    }

    // Bottom out (Lose Life)
    if (ballPos.dy - ballRadius > worldHeight) {
      lives--;
      AudioManager.instance.play(SoundEffect.hit);
      if (lives <= 0) {
        _triggerGameOver();
      } else {
        _resetBall();
      }
      return;
    }

    // Paddle Collision
    final paddleRect = Rect.fromLTWH(
      paddleX - paddleWidth / 2,
      paddleY,
      paddleWidth,
      paddleHeight,
    );

    final ballRect = Rect.fromCircle(center: ballPos, radius: ballRadius);

    if (paddleRect.overlaps(ballRect) && ballVel.dy > 0) {
      final hitFactor = (ballPos.dx - paddleX) / (paddleWidth / 2);
      final clampedFactor = hitFactor.clamp(-0.85, 0.85);

      final speed = sqrt(ballVel.dx * ballVel.dx + ballVel.dy * ballVel.dy);
      final angle = (clampedFactor * (pi / 3)) - (pi / 2); // Angle from top center

      ballVel = Offset(cos(angle) * speed, sin(angle) * speed);
      ballPos = Offset(ballPos.dx, paddleY - ballRadius - 0.005);
      AudioManager.instance.play(SoundEffect.move);
    }

    // Brick Collision
    for (int i = 0; i < bricks.length; i++) {
      final brick = bricks[i];
      if (brick.isDestroyed) continue;

      if (brick.rect.overlaps(ballRect)) {
        brick.hp--;
        score += brick.scoreValue;
        AudioManager.instance.play(SoundEffect.score);

        // Spawn particle explosion
        _spawnExplosion(brick.rect.center, brick.color);

        // Bounce angle
        final overlapLeft = (ballPos.dx + ballRadius) - brick.rect.left;
        final overlapRight = brick.rect.right - (ballPos.dx - ballRadius);
        final overlapTop = (ballPos.dy + ballRadius) - brick.rect.top;
        final overlapBottom = brick.rect.bottom - (ballPos.dy - ballRadius);

        final minOverlapX = min(overlapLeft, overlapRight);
        final minOverlapY = min(overlapTop, overlapBottom);

        if (minOverlapX < minOverlapY) {
          ballVel = Offset(-ballVel.dx, ballVel.dy);
        } else {
          ballVel = Offset(ballVel.dx, -ballVel.dy);
        }
        break;
      }
    }

    // Check Win Level condition
    if (bricks.every((b) => b.isDestroyed)) {
      level++;
      score += 200;
      AudioManager.instance.play(SoundEffect.win);
      _generateBricks();
      _resetBall();
    }
  }

  void _spawnExplosion(Offset center, Color color) {
    for (int i = 0; i < 12; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 0.2 + _rng.nextDouble() * 0.5;
      particles.add(
        Particle(
          position: center,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: color,
        ),
      );
    }
  }

  @override
  void handleInput(GameInput input) {
    if (input.touchPosition != null) {
      paddleX = input.touchPosition!.dx.clamp(paddleWidth / 2, worldWidth - paddleWidth / 2);
      if (!ballLaunched && isStarted) {
        ballLaunched = true;
      }
      return;
    }

    const speed = 0.045;
    switch (input.direction) {
      case GameDirection.left:
        paddleX = (paddleX - speed).clamp(paddleWidth / 2, worldWidth - paddleWidth / 2);
        break;
      case GameDirection.right:
        paddleX = (paddleX + speed).clamp(paddleWidth / 2, worldWidth - paddleWidth / 2);
        break;
      case GameDirection.up:
      case GameDirection.down:
      case GameDirection.none:
        break;
    }

    if (input.action == GameAction.actionA && !ballLaunched && isStarted) {
      ballLaunched = true;
    }
  }

  void _triggerGameOver() {
    isGameOver = true;
    _ticker?.cancel();
    AudioManager.instance.play(SoundEffect.gameOver);
    ScoreManager.instance.saveScore(id, score).then((isNewHigh) {
      if (isNewHigh) highScore = score;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
