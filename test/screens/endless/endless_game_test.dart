import 'package:magic_blocks/block/math/scoring/score_keeper.dart';
import 'package:magic_blocks/persistence/in_memory_database_service.dart';
import 'package:magic_blocks/persistence/model/game_mode_name.dart';
import 'package:magic_blocks/screens/endless/endless_game.dart';
import 'package:magic_blocks/screens/gameover/game_over_listener.dart';
import 'package:magic_blocks/screens/welcome/sky_background.dart';
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

  group('saving the score when the game is over', () {
    test('saves the reached score', () async {
      final service = InMemoryDatabaseService();
      final game = EndlessGame(
        databaseService: service,
        scoreKeeper: ScoreKeeper()..add(70),
      );

      game.onGameOver();

      final mode = await service.loadGameMode(GameModeName.endless);
      expect(mode!.highscore, 70);
    });

    test('keeps a higher stored highscore', () async {
      final service = InMemoryDatabaseService();
      await service.saveHighscoreIfHigher(GameModeName.endless, 200);
      final game = EndlessGame(
        databaseService: service,
        scoreKeeper: ScoreKeeper()..add(70),
      );

      game.onGameOver();

      final mode = await service.loadGameMode(GameModeName.endless);
      expect(mode!.highscore, 200);
    });

    test('saves nothing for a game without points', () async {
      final service = InMemoryDatabaseService();
      final game = EndlessGame(databaseService: service);

      game.onGameOver();

      expect(await service.loadGameMode(GameModeName.endless), isNull);
    });

    test('works without a given database service', () {
      final game = EndlessGame(scoreKeeper: ScoreKeeper()..add(70));

      expect(game.onGameOver, returnsNormally);
    });
  });
}
