import 'package:magic_blocks/persistence/model/game_mode.dart';
import 'package:magic_blocks/persistence/model/game_mode_name.dart';
import 'package:test/test.dart';

void main() {
  test('the endless game has the stable name "endless"', () {
    expect(GameModeName.endless.value, 'endless');
  });

  test('every game mode name has a unique value', () {
    final values = GameModeName.values.map((n) => n.value).toList();

    expect(values.toSet(), hasLength(values.length));
  });

  test('finds the game mode name for a stored value', () {
    expect(GameModeName.fromValue('endless'), GameModeName.endless);
  });

  test('rejects an unknown stored value', () {
    expect(() => GameModeName.fromValue('unknown'), throwsArgumentError);
  });

  test('a game mode holds name, highscore and the time it was achieved', () {
    final achievedAt = DateTime(2026, 11, 17, 12, 30);

    final mode = GameMode(
      name: GameModeName.endless.value,
      highscore: 120,
      achievedAt: achievedAt,
    );

    expect(mode.name, 'endless');
    expect(mode.highscore, 120);
    expect(mode.achievedAt, achievedAt);
  });
}
