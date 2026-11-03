import 'package:calc_tetris/screens/endless/endless_game.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:calc_tetris/screens/welcome/sky_background.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  test('listens for the game being over', () {
    expect(EndlessGame(), isA<GameOverListener>());
  });

  test('takes over the size of the game when it is resized', () {
    final game = EndlessGame();

    game.onGameResize(Vector2(400, 800));

    expect(game.size, Vector2(400, 800));
  });

  test('lays out its areas for the size it got', () {
    final game = EndlessGame();

    game.onGameResize(Vector2(400, 800));

    expect(game.gameDimensions.sizeHeader, Vector2(400, 200));
    expect(game.gameDimensions.sizeFooter, Vector2(400, 80));
  });

  test(
    'has the same sky background as the welcome screen, behind everything',
    () {
      final game = EndlessGame()..onGameResize(Vector2(400, 800));

      expect(game.background, isA<SkyBackground>());
      expect(game.background.size, Vector2(400, 800));
      expect(game.background.priority, lessThan(0));
    },
  );
}
