import 'dart:math';
import '../../core/audio_manager.dart';
import '../../core/game_engine.dart';
import '../../core/score_manager.dart';
import 'game_logic.dart';

enum TicTacToeMode { friend, easy, hard }

class TicTacToeGameModule extends GameModule {
  List<String> board = List.filled(9, '');
  String currentSymbol = 'X';
  TicTacToeMode mode = TicTacToeMode.friend;
  List<int>? winLine;
  bool draw = false;

  int xWins = 0;
  int oWins = 0;
  int drawsCount = 0;
  int roundId = 0;

  final Random _rng = Random();

  TicTacToeGameModule() : super(id: 'tictactoe', title: 'Tic-Tac-Toe');

  bool get isOver => winLine != null || draw;
  bool get isAiTurn => mode != TicTacToeMode.friend && currentSymbol == 'O';

  @override
  void init() {
    highScore = ScoreManager.instance.getHighScore(id);
    restartGame();
  }

  @override
  void restartGame() {
    board = List.filled(9, '');
    currentSymbol = 'X';
    winLine = null;
    draw = false;
    isGameOver = false;
    isPaused = false;
    isStarted = true;
    roundId++;
  }

  void resetScores() {
    xWins = 0;
    oWins = 0;
    drawsCount = 0;
    score = 0;
    restartGame();
  }

  void setMode(TicTacToeMode newMode) {
    mode = newMode;
    resetScores();
  }

  void tapCell(int index) {
    if (isOver || board[index].isNotEmpty || isAiTurn) return;
    placeMark(index);
  }

  void placeMark(int index) {
    board[index] = currentSymbol;
    AudioManager.instance.play(SoundEffect.tap);

    final w = GameLogic.winningLine(board);
    if (w != null) {
      winLine = w;
      isGameOver = true;
      if (currentSymbol == 'X') {
        xWins++;
        score += 10;
        AudioManager.instance.play(SoundEffect.win);
      } else {
        oWins++;
        AudioManager.instance.play(SoundEffect.gameOver);
      }
      ScoreManager.instance.saveScore(id, score).then((isNewHigh) {
        if (isNewHigh) highScore = score;
      });
    } else if (GameLogic.isFull(board)) {
      draw = true;
      drawsCount++;
      isGameOver = true;
      score += 2;
      AudioManager.instance.play(SoundEffect.score);
      ScoreManager.instance.saveScore(id, score).then((isNewHigh) {
        if (isNewHigh) highScore = score;
      });
    } else {
      currentSymbol = currentSymbol == 'X' ? 'O' : 'X';
    }

    if (!isOver && isAiTurn) {
      _scheduleAiMove();
    }
  }

  void _scheduleAiMove() {
    final currentRound = roundId;
    Future.delayed(const Duration(milliseconds: 550), () {
      if (currentRound != roundId || isOver) return;
      placeMark(_computeAiMove());
    });
  }

  int _computeAiMove() {
    final empty = GameLogic.emptyCells(board);
    if (empty.isEmpty) return 0;

    final isRandom = mode == TicTacToeMode.easy && _rng.nextDouble() < 0.6;
    if (isRandom) return empty[_rng.nextInt(empty.length)];
    return GameLogic.bestMove(board, 'O', 'X');
  }

  @override
  void update(double dt) {}

  @override
  void handleInput(GameInput input) {}
}
