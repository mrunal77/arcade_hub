import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/game_engine.dart';
import '../../core/score_manager.dart';

enum EnemyType { scout, interceptor, cruiser, asteroid }

class SpaceEnemy {
  Offset position;
  final EnemyType type;
  int hp;
  final int maxHp;
  final double speed;
  final Size size;

  SpaceEnemy({
    required this.position,
    required this.type,
    required this.hp,
    required this.speed,
    required this.size,
  }) : maxHp = hp;

  bool get isDestroyed => hp <= 0;
}

class SpaceLaser {
  Offset position;
  final Offset velocity;
  final bool isPlayer;
  final Color color;

  SpaceLaser({
    required this.position,
    required this.velocity,
    required this.isPlayer,
    this.color = const Color(0xFF00E5FF),
  });
}

class Star {
  Offset position;
  double speed;
  double size;
  double alpha;

  Star({
    required this.position,
    required this.speed,
    required this.size,
    required this.alpha,
  });
}

class SpaceParticle {
  Offset position;
  Offset velocity;
  Color color;
  double life;

  SpaceParticle({
    required this.position,
    required this.velocity,
    required this.color,
    this.life = 1.0,
  });
}

class SpaceShooterGameModule extends GameModule {
  static const double worldWidth = 1.0;
  static const double worldHeight = 1.4;

  Offset playerPos = const Offset(0.5, 1.25);
  static const double playerWidth = 0.08;
  static const double playerHeight = 0.07;

  int health = 3;
  int wave = 1;

  List<SpaceLaser> lasers = [];
  List<SpaceEnemy> enemies = [];
  List<Star> stars = [];
  List<SpaceParticle> particles = [];

  Timer? _ticker;
  double _shootCooldown = 0.0;
  double _spawnCooldown = 0.0;
  final Random _rng = Random();

  SpaceShooterGameModule() : super(id: 'space_shooter', title: 'Space Shooter');

  @override
  void init() {
    highScore = ScoreManager.instance.getHighScore(id);
    _initStars();
    restartGame();
  }

  void _initStars() {
    stars.clear();
    for (int i = 0; i < 60; i++) {
      stars.add(
        Star(
          position: Offset(_rng.nextDouble(), _rng.nextDouble() * worldHeight),
          speed: 0.1 + _rng.nextDouble() * 0.4,
          size: 1.0 + _rng.nextDouble() * 2.5,
          alpha: 0.3 + _rng.nextDouble() * 0.7,
        ),
      );
    }
  }

  @override
  void restartGame() {
    score = 0;
    health = 3;
    wave = 1;
    isGameOver = false;
    isPaused = false;
    isStarted = false;
    playerPos = const Offset(0.5, 1.25);
    lasers.clear();
    enemies.clear();
    particles.clear();
    _shootCooldown = 0.0;
    _spawnCooldown = 0.0;
  }

  @override
  void startGame() {
    super.startGame();
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

    // Update Starfield
    for (final s in stars) {
      s.position = Offset(s.position.dx, s.position.dy + s.speed * dt);
      if (s.position.dy > worldHeight) {
        s.position = Offset(_rng.nextDouble(), 0.0);
      }
    }

    // Update Particles
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.position += p.velocity * dt;
      p.life -= dt * 2.5;
      if (p.life <= 0) particles.removeAt(i);
    }

    // Cooldowns & Auto Spawning
    _shootCooldown -= dt;
    _spawnCooldown -= dt;

    if (_spawnCooldown <= 0) {
      _spawnEnemy();
      _spawnCooldown = max(0.4, 1.4 - (score * 0.001));
    }

    // Auto Fire if holding fire button or in mobile mode
    if (_shootCooldown <= 0) {
      _fireLaser();
      _shootCooldown = 0.18;
    }

    // Update Lasers
    for (int i = lasers.length - 1; i >= 0; i--) {
      final laser = lasers[i];
      laser.position += laser.velocity * dt;

      if (laser.position.dy < 0 || laser.position.dy > worldHeight) {
        lasers.removeAt(i);
      }
    }

    // Update Enemies
    final playerRect = Rect.fromCenter(
      center: playerPos,
      width: playerWidth,
      height: playerHeight,
    );

    for (int i = enemies.length - 1; i >= 0; i--) {
      final enemy = enemies[i];
      enemy.position = Offset(enemy.position.dx, enemy.position.dy + enemy.speed * dt);

      // Enemy out of bounds
      if (enemy.position.dy > worldHeight + 0.1) {
        enemies.removeAt(i);
        continue;
      }

      final enemyRect = Rect.fromCenter(
        center: enemy.position,
        width: enemy.size.width,
        height: enemy.size.height,
      );

      // Check collision with Player
      if (enemyRect.overlaps(playerRect)) {
        health--;
        AudioManager.instance.play(SoundEffect.hit);
        _spawnExplosion(enemy.position, const Color(0xFFFF1744));
        enemies.removeAt(i);

        if (health <= 0) {
          _triggerGameOver();
          return;
        }
        continue;
      }

      // Check collision with Player Lasers
      for (int j = lasers.length - 1; j >= 0; j--) {
        final laser = lasers[j];
        if (!laser.isPlayer) continue;

        if (enemyRect.contains(laser.position)) {
          enemy.hp--;
          lasers.removeAt(j);
          AudioManager.instance.play(SoundEffect.hit);

          if (enemy.isDestroyed) {
            score += enemy.maxHp * 20;
            AudioManager.instance.play(SoundEffect.explosion);
            _spawnExplosion(enemy.position, const Color(0xFFFF9100));
            enemies.removeAt(i);
            break;
          }
        }
      }
    }
  }

  void _fireLaser() {
    lasers.add(
      SpaceLaser(
        position: Offset(playerPos.dx, playerPos.dy - playerHeight / 2),
        velocity: const Offset(0, -1.8),
        isPlayer: true,
        color: const Color(0xFF00E5FF),
      ),
    );
    AudioManager.instance.play(SoundEffect.laser);
  }

  void _spawnEnemy() {
    final r = _rng.nextDouble();
    EnemyType type = EnemyType.scout;
    int hp = 1;
    double speed = 0.45 + _rng.nextDouble() * 0.2;
    Size size = const Size(0.07, 0.07);

    if (r < 0.2) {
      type = EnemyType.cruiser;
      hp = 3;
      speed = 0.25;
      size = const Size(0.11, 0.10);
    } else if (r < 0.5) {
      type = EnemyType.interceptor;
      hp = 1;
      speed = 0.65;
      size = const Size(0.06, 0.06);
    }

    final spawnX = 0.05 + _rng.nextDouble() * 0.9;
    enemies.add(
      SpaceEnemy(
        position: Offset(spawnX, -0.05),
        type: type,
        hp: hp,
        speed: speed,
        size: size,
      ),
    );
  }

  void _spawnExplosion(Offset center, Color color) {
    for (int i = 0; i < 15; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 0.3 + _rng.nextDouble() * 0.6;
      particles.add(
        SpaceParticle(
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
      playerPos = Offset(
        input.touchPosition!.dx.clamp(playerWidth / 2, worldWidth - playerWidth / 2),
        input.touchPosition!.dy.clamp(0.2, worldHeight - playerHeight / 2),
      );
      return;
    }

    const moveStep = 0.035;
    double dx = playerPos.dx;
    double dy = playerPos.dy;

    switch (input.direction) {
      case GameDirection.left:
        dx -= moveStep;
        break;
      case GameDirection.right:
        dx += moveStep;
        break;
      case GameDirection.up:
        dy -= moveStep;
        break;
      case GameDirection.down:
        dy += moveStep;
        break;
      case GameDirection.none:
        break;
    }

    playerPos = Offset(
      dx.clamp(playerWidth / 2, worldWidth - playerWidth / 2),
      dy.clamp(0.2, worldHeight - playerHeight / 2),
    );

    if (input.action == GameAction.actionA && _shootCooldown <= 0) {
      _fireLaser();
      _shootCooldown = 0.15;
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
