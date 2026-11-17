/// The game modes a highscore is kept for. [value] is what gets stored, so it
/// must never change for an existing mode.
enum GameModeName {
  endless('endless');

  final String value;

  const GameModeName(this.value);

  static GameModeName fromValue(String value) {
    for (final name in values) {
      if (name.value == value) {
        return name;
      }
    }
    throw ArgumentError.value(value, 'value', 'is not a known game mode');
  }
}
