import 'package:magic_blocks/persistence/database_service.dart';
import 'package:magic_blocks/persistence/model/game_mode.dart';
import 'package:magic_blocks/persistence/model/game_mode_name.dart';

/// Keeps the data only for the lifetime of the app.
class InMemoryDatabaseService implements DatabaseService {
  final Map<String, GameMode> _gameModes = {};

  @override
  Future<GameMode?> loadGameMode(GameModeName name) async =>
      _gameModes[name.value];

  @override
  Future<bool> saveHighscoreIfHigher(GameModeName name, int score) async {
    if (score < 0) {
      throw ArgumentError.value(score, 'score', 'must not be negative');
    }
    final stored = _gameModes[name.value];
    if (score == 0 || (stored != null && score <= stored.highscore)) {
      return false;
    }
    _gameModes[name.value] = GameMode(
      name: name.value,
      highscore: score,
      achievedAt: DateTime.now(),
    );
    return true;
  }
}
