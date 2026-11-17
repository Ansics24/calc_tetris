import 'package:calc_tetris/persistence/model/game_mode.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';

/// The single entry point of the game for reading and writing persistent data.
abstract interface class DatabaseService {
  /// Returns the stored highscore of the game mode, or null if there is none.
  Future<GameMode?> loadGameMode(GameModeName name);

  /// Stores [score] as the highscore of the game mode, but only if it is
  /// higher than the stored one. A score of 0 is never stored. Returns true if
  /// the score was stored. Throws an [ArgumentError] for a negative [score].
  Future<bool> saveHighscoreIfHigher(GameModeName name, int score);
}
