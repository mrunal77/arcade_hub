import 'package:flutter_test/flutter_test.dart';
import 'package:arcade_hub/core/game_engine.dart';
import 'package:arcade_hub/games/brick_breaker/brick_breaker_game.dart';
import 'package:arcade_hub/games/snake/snake_game.dart';
import 'package:arcade_hub/games/space_shooter/space_shooter_game.dart';
import 'package:arcade_hub/games/tictactoe/game_logic.dart';
import 'package:arcade_hub/games/tictactoe/tictactoe_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TicTacToe Tests', () {
    test('detects a winning row', () {
      final b = ['X', 'X', 'X', '', 'O', 'O', '', '', ''];
      expect(GameLogic.winningLine(b), [0, 1, 2]);
    });

    test('AI blocks an immediate loss', () {
      final b = ['X', 'X', '', '', 'O', '', '', '', ''];
      expect(GameLogic.bestMove(b, 'O', 'X'), 2);
    });

    test('TicTacToeGameModule resets and handles moves', () {
      final module = TicTacToeGameModule()..init();
      expect(module.board.every((cell) => cell.isEmpty), isTrue);
      module.tapCell(0);
      expect(module.board[0], 'X');
    });
  });

  group('Snake Tests', () {
    test('Snake initializes with 3 body segments', () {
      final module = SnakeGameModule()..init();
      expect(module.body.length, 3);
      expect(module.isGameOver, isFalse);
    });

    test('Snake changes direction on valid input', () {
      final module = SnakeGameModule()..init();
      expect(module.currentDirection, GameDirection.right);
      module.handleInput(const GameInput(direction: GameDirection.up));
      expect(module.currentDirection, GameDirection.right); // queued for step
    });
  });

  group('BrickBreaker Tests', () {
    test('BrickBreaker populates bricks on init', () {
      final module = BrickBreakerGameModule()..init();
      expect(module.bricks.isNotEmpty, isTrue);
      expect(module.lives, 3);
    });
  });

  group('SpaceShooter Tests', () {
    test('SpaceShooter initializes stars and player', () {
      final module = SpaceShooterGameModule()..init();
      expect(module.stars.length, 60);
      expect(module.health, 3);
    });
  });
}
