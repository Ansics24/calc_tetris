/// SQL statements for the entity `GameMode`.
abstract final class GameModeSql {
  static const String tableName = 'game_mode';

  /// Executed when the database is opened. Does nothing for an existing table.
  static const String createTable =
      '''
CREATE TABLE IF NOT EXISTS $tableName (
  name TEXT PRIMARY KEY,
  highscore INTEGER NOT NULL,
  achieved_at TEXT NOT NULL
)''';

  /// Update scripts for changes of the entity, to be executed in order when
  /// the database is opened. There are none yet, as the database is at v1.0.0.
  static const List<String> updates = [];
}
