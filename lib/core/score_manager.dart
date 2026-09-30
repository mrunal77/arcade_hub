import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static ScoreManager? _instance;
  static ScoreManager get instance => _instance ??= ScoreManager._();

  ScoreManager._();

  SharedPreferences? _prefs;
  final Map<String, ValueNotifier<int>> _highScores = {};

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get high score for a specific game ID.
  int getHighScore(String gameId) {
    return _prefs?.getInt('highscore_$gameId') ?? 0;
  }

  /// Get a ValueNotifier for high score of a game ID.
  ValueNotifier<int> getHighScoreNotifier(String gameId) {
    if (!_highScores.containsKey(gameId)) {
      _highScores[gameId] = ValueNotifier<int>(getHighScore(gameId));
    }
    return _highScores[gameId]!;
  }

  /// Update high score if new score is higher. Returns true if high score was updated.
  Future<bool> saveScore(String gameId, int score) async {
    final currentHigh = getHighScore(gameId);
    if (score > currentHigh) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setInt('highscore_$gameId', score);
      if (_highScores.containsKey(gameId)) {
        _highScores[gameId]!.value = score;
      }
      return true;
    }
    return false;
  }

  /// Reset all high scores.
  Future<void> clearAllScores() async {
    _prefs ??= await SharedPreferences.getInstance();
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('highscore_')) {
        await _prefs?.remove(key);
      }
    }
    for (final notifier in _highScores.values) {
      notifier.value = 0;
    }
  }
}
