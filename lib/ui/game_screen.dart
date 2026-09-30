import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/audio_manager.dart';
import '../core/game_engine.dart';
import '../core/game_registry.dart';
import '../core/settings_manager.dart';
import '../games/brick_breaker/brick_breaker_game.dart';
import '../games/brick_breaker/brick_breaker_painter.dart';
import '../games/snake/snake_game.dart';
import '../games/snake/snake_painter.dart';
import '../games/space_shooter/space_shooter_game.dart';
import '../games/space_shooter/space_shooter_painter.dart';
import '../games/tictactoe/paper_painters.dart';
import '../games/tictactoe/tictactoe_game.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/touch_controls.dart';

class GameScreen extends StatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameModule gameModule;
  late GameInfo gameInfo;
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animController;
  late DateTime _lastFrameTime;

  void _onFrameTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastFrameTime).inMicroseconds / 1000000.0).clamp(0.001, 0.05);
    _lastFrameTime = now;
    gameModule.update(dt);
  }

  @override
  void initState() {
    super.initState();
    gameInfo = GameRegistry.getById(widget.gameId);

    // Instantiate game module
    switch (widget.gameId) {
      case 'snake':
        gameModule = SnakeGameModule();
        break;
      case 'tictactoe':
        gameModule = TicTacToeGameModule();
        break;
      case 'brick_breaker':
        gameModule = BrickBreakerGameModule();
        break;
      case 'space_shooter':
        gameModule = SpaceShooterGameModule();
        break;
      default:
        gameModule = SnakeGameModule();
    }

    gameModule.init();

    _lastFrameTime = DateTime.now();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(_onFrameTick)
      ..repeat();

    // Auto focus for keyboard inputs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animController.dispose();
    gameModule.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      gameModule.handleInput(const GameInput(direction: GameDirection.up));
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      gameModule.handleInput(const GameInput(direction: GameDirection.down));
    } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      gameModule.handleInput(const GameInput(direction: GameDirection.left));
    } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      gameModule.handleInput(const GameInput(direction: GameDirection.right));
    } else if (key == LogicalKeyboardKey.space) {
      if (!gameModule.isStarted) {
        gameModule.startGame();
      } else {
        gameModule.handleInput(const GameInput(action: GameAction.actionA));
      }
    } else if (key == LogicalKeyboardKey.keyP || key == LogicalKeyboardKey.escape) {
      gameModule.togglePause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0E15),
        body: SafeArea(
          child: Column(
            children: [
              // Top HUD Bar
              _buildTopHud(),

              // Game Play Canvas Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildGameBody(),

                      // Tap to Start overlay if not started
                      ValueListenableBuilder<bool>(
                        valueListenable: gameModule.isStartedNotifier,
                        builder: (context, isStarted, _) {
                          if (isStarted || gameModule.isGameOver) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: () {
                              gameModule.startGame();
                              AudioManager.instance.play(SoundEffect.tap);
                            },
                            child: Container(
                              color: Colors.black54,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E2C),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: gameInfo.primaryColor,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gameInfo.primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_circle_fill_rounded,
                                        size: 56,
                                        color: gameInfo.primaryColor,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'TAP OR PRESS SPACE TO START',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Game Over Overlay
                      ValueListenableBuilder<bool>(
                        valueListenable: gameModule.isGameOverNotifier,
                        builder: (context, isGameOver, _) {
                          if (!isGameOver) return const SizedBox.shrink();
                          return GameOverDialog(
                            title: 'GAME OVER',
                            score: gameModule.score,
                            highScore: gameModule.highScore,
                            primaryColor: gameInfo.primaryColor,
                            onRestart: () {
                              gameModule.restartGame();
                              gameModule.startGame();
                            },
                            onHome: () => Navigator.pop(context),
                          );
                        },
                      ),

                      // Pause Overlay
                      ValueListenableBuilder<bool>(
                        valueListenable: gameModule.isPausedNotifier,
                        builder: (context, isPaused, _) {
                          if (!isPaused || gameModule.isGameOver) return const SizedBox.shrink();
                          return Container(
                            color: Colors.black54,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2C),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: gameInfo.primaryColor),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'PAUSED',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () => gameModule.resumeGame(),
                                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                                      label: const Text('RESUME', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: gameInfo.primaryColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('EXIT TO MENU', style: TextStyle(color: Colors.white70)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Touch Controls Overlay
              if (widget.gameId != 'tictactoe')
                ValueListenableBuilder<bool>(
                  valueListenable: SettingsManager.instance.showTouchControlsNotifier,
                  builder: (context, showTouch, _) {
                    if (!showTouch) return const SizedBox.shrink();
                    return TouchControlsOverlay(
                      themeColor: gameInfo.primaryColor,
                      showActionButton: widget.gameId == 'space_shooter' || widget.gameId == 'brick_breaker',
                      actionLabel: widget.gameId == 'space_shooter' ? 'FIRE' : 'LAUNCH',
                      onInput: (input) {
                        if (!gameModule.isStarted) {
                          gameModule.startGame();
                        }
                        gameModule.handleInput(input);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF161722),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Icon(gameInfo.icon, color: gameInfo.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                gameInfo.title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Score display
              ValueListenableBuilder<int>(
                valueListenable: gameModule.scoreNotifier,
                builder: (context, score, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gameInfo.primaryColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'SCORE ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$score',
                          style: TextStyle(
                            color: gameInfo.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.pause_rounded, color: Colors.white),
                onPressed: () => gameModule.togglePause(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBody() {
    return Container(
      decoration: BoxDecoration(
        color: widget.gameId == 'tictactoe' ? paperColor : Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gameInfo.primaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            switch (widget.gameId) {
              case 'snake':
                return _buildSnakeBody();
              case 'tictactoe':
                return _buildTicTacToeBody();
              case 'brick_breaker':
                return _buildBrickBreakerBody();
              case 'space_shooter':
                return _buildSpaceShooterBody();
              default:
                return _buildSnakeBody();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSnakeBody() {
    final module = gameModule as SnakeGameModule;
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (!module.isStarted) module.startGame();
        if (details.delta.dy < -4) {
          module.handleInput(const GameInput(direction: GameDirection.up));
        } else if (details.delta.dy > 4) {
          module.handleInput(const GameInput(direction: GameDirection.down));
        }
      },
      onHorizontalDragUpdate: (details) {
        if (!module.isStarted) module.startGame();
        if (details.delta.dx < -4) {
          module.handleInput(const GameInput(direction: GameDirection.left));
        } else if (details.delta.dx > 4) {
          module.handleInput(const GameInput(direction: GameDirection.right));
        }
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: SnakePainter(
          game: module,
          animationValue: _animController.value,
        ),
      ),
    );
  }

  Widget _buildTicTacToeBody() {
    final module = gameModule as TicTacToeGameModule;
    return CustomPaint(
      painter: PaperPainter(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Mode Selector
              Wrap(
                spacing: 8,
                children: [
                  for (final m in TicTacToeMode.values)
                    ChoiceChip(
                      label: Text(
                        m == TicTacToeMode.friend
                            ? '2 Players'
                            : m == TicTacToeMode.easy
                                ? 'vs Easy'
                                : 'vs Hard',
                        style: const TextStyle(fontSize: 13),
                      ),
                      selected: module.mode == m,
                      onSelected: (_) {
                        setState(() => module.setMode(m));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Scoreboard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _scoreCell('X Wins', module.xWins, inkBlue),
                  _scoreCell('Draws', module.drawsCount, pencilGrey),
                  _scoreCell('O Wins', module.oWins, pencilRed),
                ],
              ),
              const SizedBox(height: 12),

              // Board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(builder: (context, c) {
                      final cell = c.maxWidth / 3;
                      return Stack(
                        children: [
                          Positioned.fill(child: CustomPaint(painter: GridPainter())),
                          GridView.count(
                            crossAxisCount: 3,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: List.generate(9, (i) {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() => module.tapCell(i));
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(cell * 0.2),
                                  child: module.board[i].isEmpty
                                      ? null
                                      : TweenAnimationBuilder<double>(
                                          key: ValueKey('${module.roundId}-$i-${module.board[i]}'),
                                          tween: Tween(begin: 0, end: 1),
                                          duration: const Duration(milliseconds: 380),
                                          builder: (_, v, __) => CustomPaint(
                                            painter: MarkPainter(module.board[i], v),
                                          ),
                                        ),
                                ),
                              );
                            }),
                          ),
                          if (module.winLine != null)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: TweenAnimationBuilder<double>(
                                  key: ValueKey('win-${module.roundId}'),
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 450),
                                  builder: (_, v, __) =>
                                      CustomPaint(painter: WinLinePainter(module.winLine!, v)),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              ElevatedButton.icon(
                onPressed: () => setState(() => module.restartGame()),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('NEW ROUND'),
                style: ElevatedButton.styleFrom(backgroundColor: inkBlue, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCell(String label, int val, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text('$val', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildBrickBreakerBody() {
    final module = gameModule as BrickBreakerGameModule;
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanUpdate: (details) {
          if (!module.isStarted) module.startGame();
          final normX = details.localPosition.dx / constraints.maxWidth;
          module.handleInput(GameInput(touchPosition: Offset(normX, 0)));
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: BrickBreakerPainter(game: module),
        ),
      );
    });
  }

  Widget _buildSpaceShooterBody() {
    final module = gameModule as SpaceShooterGameModule;
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanUpdate: (details) {
          if (!module.isStarted) module.startGame();
          final normX = details.localPosition.dx / constraints.maxWidth;
          final normY = (details.localPosition.dy / constraints.maxHeight) * SpaceShooterGameModule.worldHeight;
          module.handleInput(GameInput(touchPosition: Offset(normX, normY)));
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: SpaceShooterPainter(game: module),
        ),
      );
    });
  }
}
