import 'package:calc_tetris/layout/header/stop_button.dart';
import 'package:calc_tetris/screens/endless/endless_game.dart';
import 'package:calc_tetris/screens/stopgame/stop_game_dialog.dart';
import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:calc_tetris/tetris_game.dart';
import 'package:calc_tetris/theme/game_palette.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

Future<TetrisGame> _pumpGame(WidgetTester tester) async {
  final game = TetrisGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  await tester.pump();
  // Text boxes redraw delayed; let those timers run out.
  await tester.pump(const Duration(seconds: 1));
  return game;
}

WelcomeScreen _welcomeScreen(TetrisGame game) =>
    game.descendants().whereType<WelcomeScreen>().first;

EndlessGame _endlessGame(TetrisGame game) =>
    game.descendants().whereType<EndlessGame>().first;

StopGameDialog? _stopDialog(TetrisGame game) =>
    game.descendants().whereType<StopGameDialog>().firstOrNull;

/// Lets the loading of the endless game (background image) finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 500)),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<TetrisGame> _pumpEndlessGame(WidgetTester tester) async {
  final game = await _pumpGame(tester);
  _welcomeScreen(game).cards.first.press();
  await _settle(tester);
  return game;
}

Future<void> _pressStop(WidgetTester tester, TetrisGame game) async {
  game.descendants().whereType<StopButton>().first.press();
  await tester.pump();
}

void main() {
  testWidgets('starts on the welcome route', (tester) async {
    final game = await _pumpGame(tester);

    expect(game.router.currentRoute.name, TetrisGame.welcomeRoute);
    expect(game.descendants().whereType<WelcomeScreen>(), hasLength(1));
  });

  testWidgets('replaces the welcome route by the endless game route', (
    tester,
  ) async {
    final game = await _pumpGame(tester);

    _welcomeScreen(game).cards.first.press();
    await tester.pump();

    expect(game.router.currentRoute.name, TetrisGame.endlessRoute);
    expect(game.descendants().whereType<WelcomeScreen>(), isEmpty);
  });

  group('stopping the endless game', () {
    testWidgets('asks for confirmation when the stop button is pressed', (
      tester,
    ) async {
      final game = await _pumpEndlessGame(tester);
      expect(_stopDialog(game), isNull);

      await _pressStop(tester, game);

      expect(_stopDialog(game), isNotNull);
      expect(game.router.currentRoute.name, TetrisGame.endlessRoute);
    });

    testWidgets('closes the question and goes on playing on Nein', (
      tester,
    ) async {
      final game = await _pumpEndlessGame(tester);
      await _pressStop(tester, game);

      _stopDialog(game)!.noButton.press();
      await tester.pump();

      expect(_stopDialog(game), isNull);
      expect(game.router.currentRoute.name, TetrisGame.endlessRoute);
    });

    testWidgets('can ask again after Nein', (tester) async {
      final game = await _pumpEndlessGame(tester);
      await _pressStop(tester, game);
      _stopDialog(game)!.noButton.press();
      await tester.pump();

      await _pressStop(tester, game);

      expect(_stopDialog(game), isNotNull);
    });

    testWidgets('navigates back to the welcome screen on Ja', (tester) async {
      final game = await _pumpEndlessGame(tester);
      await _pressStop(tester, game);

      _stopDialog(game)!.yesButton.press();
      await _settle(tester);

      expect(game.router.currentRoute.name, TetrisGame.welcomeRoute);
      expect(game.descendants().whereType<EndlessGame>(), isEmpty);
      expect(game.descendants().whereType<WelcomeScreen>(), hasLength(1));
    });

    testWidgets('starts a fresh game after coming back', (tester) async {
      final game = await _pumpEndlessGame(tester);
      final firstGame = _endlessGame(game);
      await _pressStop(tester, game);
      _stopDialog(game)!.yesButton.press();
      await _settle(tester);

      _welcomeScreen(game).cards.first.press();
      await _settle(tester);

      expect(_endlessGame(game), isNot(same(firstGame)));
      expect(_stopDialog(game), isNull);
    });
  });

  group('surrounding color', () {
    testWidgets('is the sky while on the welcome route', (tester) async {
      final game = await _pumpGame(tester);

      expect(game.surroundColors.value, [
        WelcomePalette.skyTop,
        WelcomePalette.skyBottom,
      ]);
    });

    testWidgets('is dark while playing the endless game', (tester) async {
      final game = await _pumpEndlessGame(tester);

      expect(game.surroundColors.value, [
        GamePalette.panelDeep,
        GamePalette.panelDeep,
      ]);
    });

    testWidgets('is the sky again after stopping the game', (tester) async {
      final game = await _pumpEndlessGame(tester);
      await _pressStop(tester, game);

      _stopDialog(game)!.yesButton.press();
      await _settle(tester);

      expect(game.surroundColors.value, [
        WelcomePalette.skyTop,
        WelcomePalette.skyBottom,
      ]);
    });
  });
}
