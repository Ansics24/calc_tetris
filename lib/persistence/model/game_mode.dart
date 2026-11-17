/// The highscore reached in one game mode.
class GameMode {
  /// Stored value of a `GameModeName`.
  final String name;

  final int highscore;

  /// When the highscore was reached.
  final DateTime achievedAt;

  const GameMode({
    required this.name,
    required this.highscore,
    required this.achievedAt,
  });
}
