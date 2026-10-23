import 'package:calc_tetris/screens/gameover/game_over_hint.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  test('tells the player in german that the game is over', () {
    expect(GameOverHint.message, 'Spiel vorbei!');
  });

  test('takes the size it is given', () {
    final hint = GameOverHint(size: Vector2(300, 600));

    expect(hint.size, Vector2(300, 600));
  });
}
