import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/layout/header/confirm_button.dart';
import 'package:calc_tetris/layout/header/stop_button.dart';
import 'package:calc_tetris/screens/endless/endless_game.dart';
import 'package:calc_tetris/screens/stopgame/stop_game_dialog.dart';
import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:calc_tetris/tetris_game.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

Future<TetrisGame> _pumpGame(WidgetTester tester) async {
  final game = TetrisGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  await _settle(tester);
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

/// Lets the loading of images (e.g. the mascot) finish.
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

  group('confirming the current block', () {
    /// Grid positions of the single blocks that landed in the grid.
    List<Vector2> landedPositions(TetrisGame game) {
      final content = game
          .descendants()
          .whereType<EndlessGame>()
          .first
          .gridContent;
      return [
        for (var x = 0; x < content.length; x++)
          for (var y = 0; y < content[x].length; y++)
            if (content[x][y] != null) Vector2(x * 1.0, y * 1.0),
      ];
    }

    Future<void> pressConfirm(WidgetTester tester, TetrisGame game) async {
      game.descendants().whereType<ConfirmButton>().first.press();
      // landing animation, then the strategy runs and the next block spawns
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('puts the block into the grid where it stands', (
      tester,
    ) async {
      final game = await _pumpGameWithArrivedBlock(tester);
      final controller = game.descendants().whereType<Grid>().first.controller;
      final start = controller.currentBlockGridPosition!;
      final block = controller.currentBlock!;
      final expected = block
          .getLocalSingleBlockPositions()
          .map((p) => Vector2(start.x + p.x * 1.0, start.y + p.y * 1.0))
          .toSet();
      expect(landedPositions(game), isEmpty);

      await pressConfirm(tester, game);

      expect(landedPositions(game).toSet(), expected);
    });

    testWidgets('does not let the block fall down first', (tester) async {
      final game = await _pumpGameWithArrivedBlock(tester);
      final controller = game.descendants().whereType<Grid>().first.controller;
      controller.moveBlockDown();
      final row = controller.currentBlockGridPosition!.y;

      await pressConfirm(tester, game);

      expect(row, 1);
      expect(landedPositions(game).every((p) => p.y == row), isTrue);
    });

    testWidgets('spawns the next block afterwards', (tester) async {
      final game = await _pumpGameWithArrivedBlock(tester);
      final controller = game.descendants().whereType<Grid>().first.controller;
      final first = controller.currentBlock;

      await pressConfirm(tester, game);

      expect(controller.currentBlock, isNotNull);
      expect(controller.currentBlock, isNot(same(first)));
    });

    testWidgets('ignores a second press while the block is landing', (
      tester,
    ) async {
      final game = await _pumpGameWithArrivedBlock(tester);
      final button = game.descendants().whereType<ConfirmButton>().first;

      button.press();
      button.press();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
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

    testWidgets('is the same sky while playing the endless game', (
      tester,
    ) async {
      final game = await _pumpEndlessGame(tester);

      expect(game.surroundColors.value, [
        WelcomePalette.skyTop,
        WelcomePalette.skyBottom,
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

/// Pumps the endless game and waits until the first block has flown in from
/// the preview, as it can not be used before.
Future<TetrisGame> _pumpGameWithArrivedBlock(WidgetTester tester) async {
  final game = await _pumpEndlessGame(tester);
  await tester.pump(const Duration(seconds: 1));
  return game;
}
