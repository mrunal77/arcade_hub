class GameLogic {
  static const List<List<int>> lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  /// Returns the winning line (3 indexes) or null.
  static List<int>? winningLine(List<String> b) {
    for (final l in lines) {
      if (b[l[0]].isNotEmpty && b[l[0]] == b[l[1]] && b[l[1]] == b[l[2]]) {
        return l;
      }
    }
    return null;
  }

  static bool isFull(List<String> b) => !b.contains('');

  static List<int> emptyCells(List<String> b) => [
        for (int i = 0; i < b.length; i++)
          if (b[i].isEmpty) i
      ];

  /// Unbeatable move using minimax.
  static int bestMove(List<String> board, String ai, String human) {
    final b = List<String>.of(board);
    int bestScore = -1000;
    int move = -1;
    for (final i in emptyCells(b)) {
      b[i] = ai;
      final s = _minimax(b, false, ai, human, 1);
      b[i] = '';
      if (s > bestScore) {
        bestScore = s;
        move = i;
      }
    }
    return move;
  }

  static int _minimax(
      List<String> b, bool aiTurn, String ai, String human, int depth) {
    final w = winningLine(b);
    if (w != null) return b[w[0]] == ai ? 10 - depth : depth - 10;
    if (isFull(b)) return 0;

    int best = aiTurn ? -1000 : 1000;
    for (final i in emptyCells(b)) {
      b[i] = aiTurn ? ai : human;
      final s = _minimax(b, !aiTurn, ai, human, depth + 1);
      b[i] = '';
      best = aiTurn ? (s > best ? s : best) : (s < best ? s : best);
    }
    return best;
  }
}
