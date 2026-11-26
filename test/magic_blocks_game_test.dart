import 'package:magic_blocks/audio/music_player.dart';
import 'package:magic_blocks/audio/sound_effect_player.dart';
import 'package:magic_blocks/audio/sound_files.dart';
import 'package:magic_blocks/block/solution_strategy_singlerun_result.dart';
import 'package:magic_blocks/magic_blocks_app.dart';
import 'package:magic_blocks/grid/grid.dart';
import 'package:magic_blocks/layout/footer/cannon_button.dart';
import 'package:magic_blocks/layout/header/confirm_button.dart';
import 'package:magic_blocks/layout/header/stop_button.dart';
import 'package:magic_blocks/persistence/database_service.dart';
import 'package:magic_blocks/persistence/in_memory_database_service.dart';
import 'package:magic_blocks/persistence/model/game_mode_name.dart';
import 'package:magic_blocks/screens/endless/endless_game.dart';
import 'package:magic_blocks/screens/stopgame/stop_game_dialog.dart';
import 'package:magic_blocks/screens/welcome/welcome_screen.dart';
import 'package:magic_blocks/magic_blocks_game.dart';
import 'package:magic_blocks/theme/welcome_palette.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/load_game_font.dart';
import 'support/recording_music_player.dart';
import 'support/recording_sound_effect_player.dart';
import 'support/test_grid.dart';

Future<MagicBlocksGame> _pumpGame(
  WidgetTester tester, {
  DatabaseService? databaseService,
  MusicPlayer? musicPlayer,
  SoundEffectPlayer? soundEffectPlayer,
}) async {
  final game = MagicBlocksGame(
    databaseService: databaseService,
    musicPlayer: musicPlayer,
    soundEffectPlayer: soundEffectPlayer,
  );
  await tester.pumpWidget(MagicBlocksApp(game: game));
  await tester.pump();
  await _settle(tester);
  // Text boxes redraw delayed; let those timers run out.
  await tester.pump(const Duration(seconds: 1));
  return game;
}

Future<void> _tapEndlessCard(WidgetTester tester) =>
    tester.tap(find.text('Endlosspiel'));

Future<void> _tapTutorialButton(WidgetTester tester) =>
    tester.tap(find.text('Tutorial'));

EndlessGame _endlessGame(MagicBlocksGame game) =>
    game.descendants().whereType<EndlessGame>().first;

StopGameDialog? _stopDialog(MagicBlocksGame game) =>
    game.descendants().whereType<StopGameDialog>().firstOrNull;

/// Lets the loading of images (e.g. the mascot) finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  // Images (e.g. mascot and trophy) are loaded one after another, so real time
  // has to pass between the frames.
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<MagicBlocksGame> _pumpEndlessGame(
  WidgetTester tester, {
  DatabaseService? databaseService,
}) async {
  final game = await _pumpGame(tester, databaseService: databaseService);
  await _tapEndlessCard(tester);
  await _settle(tester);
  return game;
}

Future<MagicBlocksGame> _pumpEndlessGameWith(
  WidgetTester tester,
  MusicPlayer musicPlayer,
) async {
  final game = await _pumpGame(tester, musicPlayer: musicPlayer);
  await _tapEndlessCard(tester);
  await _settle(tester);
  return game;
}

Future<void> _pressStop(WidgetTester tester, MagicBlocksGame game) async {
  game.descendants().whereType<StopButton>().first.press();
  await tester.pump();
}

void main() {
  setUpAll(loadGameFont);

  testWidgets('starts on the welcome route', (tester) async {
    final game = await _pumpGame(tester);

    expect(game.router.currentRoute.name, MagicBlocksGame.welcomeRoute);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('replaces the welcome route by the endless game route', (
    tester,
  ) async {
    final game = await _pumpGame(tester);

    await _tapEndlessCard(tester);
    await tester.pump();

    expect(game.router.currentRoute.name, MagicBlocksGame.endlessRoute);
    expect(find.byType(WelcomeScreen), findsNothing);
  });

  testWidgets('replaces the welcome route by the tutorial route', (
    tester,
  ) async {
    final game = await _pumpGame(tester);

    await _tapTutorialButton(tester);
    await tester.pump();
    // Text boxes redraw delayed; let those timers run out.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(game.router.currentRoute.name, MagicBlocksGame.tutorialRoute);
    expect(find.byType(WelcomeScreen), findsNothing);
  });

  group('footer of the endless game', () {
    testWidgets('shows the cannon power-up with none available', (
      tester,
    ) async {
      final game = await _pumpEndlessGame(tester);

      final buttons = game.descendants().whereType<CannonButton>();
      expect(buttons, hasLength(1));
      expect(buttons.single.count, 0);
      expect(buttons.single.badgeText, '0');
    });

    testWidgets('puts the button below the grid', (tester) async {
      final game = await _pumpEndlessGame(tester);

      final endless = _endlessGame(game);
      final button = game.descendants().whereType<CannonButton>().single;
      final footerTop =
          endless.gameDimensions.sizeHeader.y +
          endless.gameDimensions.sizeBlockBoard.y;
      expect(button.absolutePosition.y, greaterThanOrEqualTo(footerTop));
    });
  });

  group('sound of a solved equation in the endless game', () {
    Future<MagicBlocksGame> pumpWith(
      WidgetTester tester,
      RecordingSoundEffectPlayer sounds,
    ) async {
      final game = await _pumpGame(tester, soundEffectPlayer: sounds);
      await _tapEndlessCard(tester);
      await _settle(tester);
      await tester.pump(const Duration(seconds: 1));
      return game;
    }

    SolutionStrategySinglerunResult result(int points) =>
        SolutionStrategySinglerunResult(solvedBlocks: [], pointsEarned: points);

    testWidgets('rings the bell when an equation was solved', (tester) async {
      final sounds = RecordingSoundEffectPlayer();
      final game = await pumpWith(tester, sounds);

      game
          .descendants()
          .whereType<Grid>()
          .first
          .endlessController
          .onStrategyResult(
            result(6),
          );

      expect(sounds.played, [SoundFiles.solvedEquation]);
    });

    testWidgets('rings once for every solved result', (tester) async {
      final sounds = RecordingSoundEffectPlayer();
      final game = await pumpWith(tester, sounds);
      final controller = game
          .descendants()
          .whereType<Grid>()
          .first
          .endlessController;

      controller.onStrategyResult(result(6));
      controller.onStrategyResult(result(8));

      expect(sounds.played, hasLength(2));
    });

    testWidgets('is silent while nothing was solved', (tester) async {
      final sounds = RecordingSoundEffectPlayer();

      await pumpWith(tester, sounds);

      expect(sounds.played, isEmpty);
    });

    testWidgets('still counts the points when the audio is broken', (
      tester,
    ) async {
      final game = await pumpWith(
        tester,
        RecordingSoundEffectPlayer(failing: true),
      );

      game
          .descendants()
          .whereType<Grid>()
          .first
          .endlessController
          .onStrategyResult(
            result(6),
          );
      await tester.pump();

      expect(_endlessGame(game).scoreKeeper.total, 6);
    });
  });

  group('sound of placing a block in the endless game', () {
    testWidgets('plays when the block is placed with the OK button', (
      tester,
    ) async {
      final sounds = RecordingSoundEffectPlayer();
      final game = await _pumpGame(tester, soundEffectPlayer: sounds);
      await _tapEndlessCard(tester);
      await _settle(tester);
      await tester.pump(const Duration(seconds: 1));

      game.descendants().whereType<ConfirmButton>().first.press();

      expect(sounds.played, [SoundFiles.blockPlaced]);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('plays only once while the block is landing', (tester) async {
      final sounds = RecordingSoundEffectPlayer();
      final game = await _pumpGame(tester, soundEffectPlayer: sounds);
      await _tapEndlessCard(tester);
      await _settle(tester);
      await tester.pump(const Duration(seconds: 1));
      final button = game.descendants().whereType<ConfirmButton>().first;

      button.press();
      button.press();

      expect(sounds.played, [SoundFiles.blockPlaced]);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('is silent while the first block is still flying in', (
      tester,
    ) async {
      final sounds = RecordingSoundEffectPlayer();
      final game = await _pumpGame(tester, soundEffectPlayer: sounds);
      await _tapEndlessCard(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      game.descendants().whereType<ConfirmButton>().firstOrNull?.press();

      expect(sounds.played, isEmpty);
      await _settle(tester);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('welcome music', () {
    testWidgets('plays in a loop as soon as the welcome screen is there', (
      tester,
    ) async {
      final music = RecordingMusicPlayer();

      await _pumpGame(tester, musicPlayer: music);

      expect(music.played, [WelcomeScreen.musicFile]);
      expect(music.isSilent, isFalse);
    });

    testWidgets('stops when the endless game starts', (tester) async {
      final music = RecordingMusicPlayer();
      await _pumpGame(tester, musicPlayer: music);

      await _tapEndlessCard(tester);
      await _settle(tester);

      expect(music.isSilent, isTrue);
    });

    testWidgets('stops when the tutorial starts', (tester) async {
      final music = RecordingMusicPlayer();
      await _pumpGame(tester, musicPlayer: music);

      await _tapTutorialButton(tester);
      await _settle(tester);

      expect(music.isSilent, isTrue);
    });

    testWidgets('plays again after coming back to the welcome screen', (
      tester,
    ) async {
      final music = RecordingMusicPlayer();
      final game = await _pumpEndlessGameWith(tester, music);
      await _pressStop(tester, game);

      _stopDialog(game)!.yesButton.press();
      await _settle(tester);

      expect(music.played, hasLength(2));
      expect(music.isSilent, isFalse);
    });

    testWidgets('does not disturb the game when the audio is broken', (
      tester,
    ) async {
      final game = await _pumpGame(
        tester,
        musicPlayer: RecordingMusicPlayer(failing: true),
      );

      expect(find.byType(WelcomeScreen), findsOneWidget);
      await _tapEndlessCard(tester);
      await _settle(tester);

      expect(game.router.currentRoute.name, MagicBlocksGame.endlessRoute);
    });

    testWidgets('is silent when no music player is given', (tester) async {
      await _pumpGame(tester);

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
  });

  group('high score on the welcome screen', () {
    testWidgets('shows the stored high score of the endless game', (
      tester,
    ) async {
      final service = InMemoryDatabaseService();
      await service.saveHighscoreIfHigher(GameModeName.endless, 4711);

      await _pumpGame(tester, databaseService: service);

      expect(find.text('4.711'), findsOneWidget);
    });

    testWidgets('shows a new high score after coming back from the game', (
      tester,
    ) async {
      final service = InMemoryDatabaseService();
      final game = await _pumpEndlessGame(tester, databaseService: service);
      await service.saveHighscoreIfHigher(GameModeName.endless, 80);
      await _pressStop(tester, game);

      _stopDialog(game)!.yesButton.press();
      await _settle(tester);

      expect(find.text('80'), findsOneWidget);
    });
  });

  group('stopping the endless game', () {
    testWidgets('asks for confirmation when the stop button is pressed', (
      tester,
    ) async {
      final game = await _pumpEndlessGame(tester);
      expect(_stopDialog(game), isNull);

      await _pressStop(tester, game);

      expect(_stopDialog(game), isNotNull);
      expect(game.router.currentRoute.name, MagicBlocksGame.endlessRoute);
    });

    testWidgets('closes the question and goes on playing on Nein', (
      tester,
    ) async {
      final game = await _pumpEndlessGame(tester);
      await _pressStop(tester, game);

      _stopDialog(game)!.noButton.press();
      await tester.pump();

      expect(_stopDialog(game), isNull);
      expect(game.router.currentRoute.name, MagicBlocksGame.endlessRoute);
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

      expect(game.router.currentRoute.name, MagicBlocksGame.welcomeRoute);
      expect(game.descendants().whereType<EndlessGame>(), isEmpty);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('starts a fresh game after coming back', (tester) async {
      final game = await _pumpEndlessGame(tester);
      final firstGame = _endlessGame(game);
      await _pressStop(tester, game);
      _stopDialog(game)!.yesButton.press();
      await _settle(tester);

      await _tapEndlessCard(tester);
      await _settle(tester);

      expect(_endlessGame(game), isNot(same(firstGame)));
      expect(_stopDialog(game), isNull);
    });
  });

  group('confirming the current block', () {
    /// Grid positions of the single blocks that landed in the grid.
    List<Vector2> landedPositions(MagicBlocksGame game) {
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

    Future<void> pressConfirm(WidgetTester tester, MagicBlocksGame game) async {
      game.descendants().whereType<ConfirmButton>().first.press();
      // landing animation, then the strategy runs and the next block spawns
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    /// The grid cells the controlled block covers right now.
    Set<Vector2> coveredCells(Grid grid) {
      final start = grid.endlessController.currentBlockGridPosition!;
      return grid.endlessController.currentBlock!
          .getLocalSingleBlockPositions()
          .map((p) => Vector2(start.x + p.x * 1.0, start.y + p.y * 1.0))
          .toSet();
    }

    // A landed block may solve an equation right away and disappear, so the
    // landed cells can only be a subset of the cells the block covered.
    testWidgets('puts the block into the grid where it stands', (
      tester,
    ) async {
      final game = await _pumpGameWithArrivedBlock(tester);
      final grid = game.descendants().whereType<Grid>().first;
      final expected = coveredCells(grid);
      expect(landedPositions(game), isEmpty);

      await pressConfirm(tester, game);

      expect(expected.containsAll(landedPositions(game)), isTrue);
    });

    testWidgets('does not let the block fall down first', (tester) async {
      final game = await _pumpGameWithArrivedBlock(tester);
      final grid = game.descendants().whereType<Grid>().first;
      // the block may spawn at any border, so it can be blocked in one
      // direction
      final startY = grid.endlessController.currentBlockGridPosition!.y;
      grid.endlessController.onBlockDraggedDown();
      if (grid.endlessController.currentBlockGridPosition!.y == startY) {
        grid.endlessController.onBlockDraggedUp();
      }
      final expected = coveredCells(grid);
      expect(grid.endlessController.currentBlockGridPosition!.y, isNot(startY));

      await pressConfirm(tester, game);

      expect(expected.containsAll(landedPositions(game)), isTrue);
    });

    testWidgets('spawns the next block afterwards', (tester) async {
      final game = await _pumpGameWithArrivedBlock(tester);
      final controller = game
          .descendants()
          .whereType<Grid>()
          .first
          .endlessController;
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
Future<MagicBlocksGame> _pumpGameWithArrivedBlock(WidgetTester tester) async {
  final game = await _pumpEndlessGame(tester);
  await tester.pump(const Duration(seconds: 1));
  return game;
}
