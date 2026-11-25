import 'package:calc_tetris/audio/sound_effect_player.dart';
import 'package:calc_tetris/audio/sound_files.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:calc_tetris/layout/footer/power_up_found_animation.dart';
import 'package:calc_tetris/layout/header/confirm_button.dart';
import 'package:calc_tetris/layout/header/stop_button.dart';
import 'package:calc_tetris/persistence/in_memory_database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:calc_tetris/screens/stopgame/stop_game_dialog.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_game.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_message_overlay.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_script.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_step.dart';
import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:calc_tetris/tetris_game.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/recording_sound_effect_player.dart';
import '../../support/test_grid.dart';

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

Future<TetrisGame> _pumpTutorial(
  WidgetTester tester, {
  InMemoryDatabaseService? databaseService,
  SoundEffectPlayer? soundEffectPlayer,
}) async {
  final game = TetrisGame(
    databaseService: databaseService,
    soundEffectPlayer: soundEffectPlayer,
  );
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  await _settle(tester);
  await tester.pump(const Duration(seconds: 1));
  game
      .descendants()
      .whereType<WelcomeScreen>()
      .first
      .cards
      .first
      .secondaryButton!
      .press();
  await _settle(tester);
  return game;
}

TutorialGame _tutorial(TetrisGame game) =>
    game.descendants().whereType<TutorialGame>().first;

TutorialMessageOverlay? _overlay(TetrisGame game) =>
    game.descendants().whereType<TutorialMessageOverlay>().firstOrNull;

Grid? _grid(TetrisGame game) =>
    game.descendants().whereType<Grid>().firstOrNull;

/// Presses the button of the message that is shown.
Future<void> _continue(WidgetTester tester, TetrisGame game) async {
  _overlay(game)!.continueButton.press();
  await tester.pump();
  // the new board loads and the block flies in
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

/// Moves the controlled block step by step to [target] (rotating first).
void _steerBlock(Grid grid, PlayStep step, {bool toSolution = true}) {
  final controller = grid.endlessController;
  for (var i = 0; i < step.solutionRotations && toSolution; i++) {
    controller.currentBlock!.rotate();
  }
  if (!toSolution) {
    return;
  }
  final target = step.solutionPosition;
  // down first, so the block never has to cross the prepared blocks
  while (controller.currentBlockGridPosition!.y < target.y) {
    controller.onBlockDraggedDown();
  }
  while (controller.currentBlockGridPosition!.x < target.x) {
    controller.onBlockDraggedRight();
  }
  while (controller.currentBlockGridPosition!.x > target.x) {
    controller.onBlockDraggedLeft();
  }
}

Future<void> _place(WidgetTester tester, TetrisGame game) async {
  _grid(game)!.endlessController.placeCurrentBlock();
  await tester.pump();
  // landing animation, solving, removing the solved blocks, counting up the
  // score and the short pause before the next step
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
  // components added by the finished round get mounted
  await tester.pump(const Duration(milliseconds: 100));
}

/// Like [testWidgets], but lets the delayed redraw timers of text boxes run
/// out at the end.
void _tutorialTest(
  String description,
  Future<void> Function(WidgetTester) body,
) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });
}

void main() {
  final script = tutorialScript();

  _tutorialTest('starts with the first message and no board yet', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);

    expect(game.router.currentRoute.name, TetrisGame.tutorialRoute);
    expect(_overlay(game)!.messageText.text, (script[0] as MessageStep).text);
    expect(game.descendants().whereType<Grid>(), isEmpty);
  });

  _tutorialTest('shows the board and the hint after the first message', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);

    await _continue(tester, game);

    final step = script[1] as PlayStep;
    expect(_overlay(game), isNull);
    expect(_tutorial(game).hintText.text, step.hint);
    expect(_grid(game), isNotNull);
    final content = _tutorial(game).gridContent;
    expect(content[2][9], isNotNull); // the prepared equation
  });

  _tutorialTest('lets the block spawn where the script wants it', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);

    await _continue(tester, game);

    final step = script[1] as PlayStep;
    final position = _grid(game)!.endlessController.currentBlockGridPosition!;
    expect(position.x, step.spawnPosition.x);
    expect(position.y, step.spawnPosition.y);
  });

  _tutorialTest('shows the next message after the equation was solved', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);
    await _continue(tester, game);
    _steerBlock(_grid(game)!, script[1] as PlayStep);

    await _place(tester, game);

    expect(_overlay(game)!.messageText.text, (script[2] as MessageStep).text);
    expect(game.descendants().whereType<Grid>(), isEmpty);
  });

  _tutorialTest('waits with the next step until the score has counted up', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);
    await _continue(tester, game);
    final tutorial = _tutorial(game);

    tutorial.scoreKeeper.add(6);
    tutorial.onRoundFinished(6);
    await tester.pump(const Duration(milliseconds: 300));

    expect(tutorial.runner.current, isA<PlayStep>());
    expect(_overlay(game), isNull);
    expect(game.descendants().whereType<Grid>(), isNotEmpty);

    // the count up takes 1.2 seconds, then a short pause follows
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump(const Duration(milliseconds: 100));

    expect(_overlay(game)!.messageText.text, (script[2] as MessageStep).text);
  });

  _tutorialTest('does not wait when the round earned nothing', (tester) async {
    final game = await _pumpTutorial(tester);
    await _continue(tester, game);
    final tutorial = _tutorial(game);

    tutorial.onRoundFinished(0);

    expect(tutorial.runner.attempt, 1);
  });

  _tutorialTest('plays the placing sound when the OK button is pressed', (
    tester,
  ) async {
    final sounds = RecordingSoundEffectPlayer();
    final game = await _pumpTutorial(tester, soundEffectPlayer: sounds);
    await _continue(tester, game);

    game.descendants().whereType<ConfirmButton>().first.press();

    expect(sounds.played, [SoundFiles.blockPlaced]);
    // the block solves nothing, so the step starts over
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump(const Duration(milliseconds: 100));
  });

  _tutorialTest('plays the placing sound before the bell', (tester) async {
    final sounds = RecordingSoundEffectPlayer();
    final game = await _pumpTutorial(tester, soundEffectPlayer: sounds);
    await _continue(tester, game);
    _steerBlock(_grid(game)!, script[1] as PlayStep);

    game.descendants().whereType<ConfirmButton>().first.press();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(sounds.played, [SoundFiles.blockPlaced, SoundFiles.solvedEquation]);
  });

  _tutorialTest('does not break when the placing sound is broken', (
    tester,
  ) async {
    final game = await _pumpTutorial(
      tester,
      soundEffectPlayer: RecordingSoundEffectPlayer(failing: true),
    );
    await _continue(tester, game);
    _steerBlock(_grid(game)!, script[1] as PlayStep);

    game.descendants().whereType<ConfirmButton>().first.press();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(_tutorial(game).scoreKeeper.total, 6);
  });

  _tutorialTest('rings the bell when the equation was solved', (tester) async {
    final sounds = RecordingSoundEffectPlayer();
    final game = await _pumpTutorial(tester, soundEffectPlayer: sounds);
    await _continue(tester, game);
    expect(sounds.played, isEmpty);
    _steerBlock(_grid(game)!, script[1] as PlayStep);

    await _place(tester, game);

    expect(sounds.played, [SoundFiles.solvedEquation]);
  });

  _tutorialTest('is silent when the block solves nothing', (tester) async {
    final sounds = RecordingSoundEffectPlayer();
    final game = await _pumpTutorial(tester, soundEffectPlayer: sounds);
    await _continue(tester, game);

    await _place(tester, game); // right where it spawned

    expect(sounds.played, isEmpty);
  });

  _tutorialTest('does not break when the audio is broken', (tester) async {
    final game = await _pumpTutorial(
      tester,
      soundEffectPlayer: RecordingSoundEffectPlayer(failing: true),
    );
    await _continue(tester, game);
    _steerBlock(_grid(game)!, script[1] as PlayStep);

    await _place(tester, game);

    expect(_tutorial(game).scoreKeeper.total, 6);
    expect(_overlay(game)!.messageText.text, (script[2] as MessageStep).text);
  });

  _tutorialTest('counts the points of the solved equation in the tutorial', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);
    await _continue(tester, game);
    _steerBlock(_grid(game)!, script[1] as PlayStep);

    await _place(tester, game);

    expect(_tutorial(game).scoreKeeper.total, 6);
  });

  _tutorialTest('starts the step again when the block solves nothing', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);
    await _continue(tester, game);

    await _place(tester, game); // right where it spawned

    expect(_overlay(game), isNull);
    expect(
      (_tutorial(game).runner.current as PlayStep).hint,
      (script[1] as PlayStep).hint,
    );
    expect(_tutorial(game).runner.attempt, 1);
    expect(_tutorial(game).hintText.text, TutorialGame.retryNotice);
    expect(_tutorial(game).scoreKeeper.total, 0);
    // a fresh board with the prepared equation and a block ready to be moved
    final grid = _grid(game)!;
    expect(grid.endlessController.currentBlock, isNotNull);
    expect(_tutorial(game).gridContent[2][9], isNotNull);
  });

  _tutorialTest('can be solved after a failed attempt', (tester) async {
    final game = await _pumpTutorial(tester);
    await _continue(tester, game);
    await _place(tester, game);
    await tester.pump(const Duration(seconds: 1));
    _steerBlock(_grid(game)!, script[1] as PlayStep);

    await _place(tester, game);

    expect(_overlay(game)!.messageText.text, (script[2] as MessageStep).text);
  });

  _tutorialTest('does not touch the highscore, not even when stopped', (
    tester,
  ) async {
    final service = InMemoryDatabaseService();
    final game = await _pumpTutorial(tester, databaseService: service);
    await _continue(tester, game);
    _steerBlock(_grid(game)!, script[1] as PlayStep);
    await _place(tester, game);
    expect(_tutorial(game).scoreKeeper.total, greaterThan(0));
    await _continueToBoard(tester, game);

    game.descendants().whereType<StopButton>().first.press();
    await tester.pump();
    game.descendants().whereType<StopGameDialog>().first.yesButton.press();
    await _settle(tester);

    expect(game.router.currentRoute.name, TetrisGame.welcomeRoute);
    expect(await service.loadGameMode(GameModeName.endless), isNull);
  });

  _tutorialTest('leads back to the welcome screen after the last message', (
    tester,
  ) async {
    final game = await _pumpTutorial(tester);
    final runner = _tutorial(game).runner;

    // play through the whole script without steering the block
    for (final step in script) {
      switch (step) {
        case MessageStep():
          runner.continueFromMessage();
        case PlayStep():
          runner.onRoundFinished(1);
        case CannonStep():
          runner.onCannonStepCompleted();
      }
      await tester.pump(const Duration(seconds: 1));
    }
    await _settle(tester);

    expect(game.router.currentRoute.name, TetrisGame.welcomeRoute);
    expect(game.descendants().whereType<TutorialGame>(), isEmpty);
  });

  _tutorialTest('blocks the board while a message is shown', (tester) async {
    final game = await _pumpTutorial(tester);

    expect(_overlay(game)!.priority, greaterThanOrEqualTo(1000));
    expect(_overlay(game)!.size, _tutorial(game).size);
  });

  group('the cannon', () {
    /// Goes through the steps until [reached], without playing them.
    Future<void> skipTo(
      WidgetTester tester,
      TetrisGame game,
      bool Function(TutorialStep) reached,
    ) async {
      final runner = _tutorial(game).runner;
      while (!reached(runner.current)) {
        switch (runner.current) {
          case MessageStep():
            runner.continueFromMessage();
          case PlayStep():
            runner.onRoundFinished(1);
          case CannonStep():
            runner.onCannonStepCompleted();
        }
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    final cannonStep = script.whereType<CannonStep>().single;
    final findingStep = script.whereType<PlayStep>().firstWhere(
      (s) => s.findsCannon,
    );

    Footer footer(TetrisGame game) =>
        game.descendants().whereType<Footer>().single;

    Future<TetrisGame> atCannonStep(
      WidgetTester tester, {
      SoundEffectPlayer? sounds,
    }) async {
      final game = await _pumpTutorial(tester, soundEffectPlayer: sounds);
      await skipTo(tester, game, (s) => s is CannonStep);
      return game;
    }

    Future<void> shoot(
      WidgetTester tester,
      TetrisGame game,
      int x,
      int y,
    ) async {
      final grid = _grid(game)!;
      await tester.tapAt(
        grid
            .absolutePositionOf(
              Vector2((x + 0.5) * grid.cellSize, (y + 0.5) * grid.cellSize),
            )
            .toOffset(),
      );
      await tester.pump();
    }

    Future<void> activate(WidgetTester tester, TetrisGame game) async {
      footer(game).cannonButton.press();
      await tester.pump();
    }

    _tutorialTest('has no footer before it is about the cannon', (
      tester,
    ) async {
      final game = await _pumpTutorial(tester);
      await _continue(tester, game);

      expect(game.descendants().whereType<Footer>(), isEmpty);
    });

    _tutorialTest('shows an empty cannon button in the finding step', (
      tester,
    ) async {
      final game = await _pumpTutorial(tester);

      await skipTo(
        tester,
        game,
        (s) => s is PlayStep && s.findsCannon,
      );

      expect(footer(game).cannonButton.count, 0);
    });

    _tutorialTest('finds a cannon when the equation is solved', (
      tester,
    ) async {
      final game = await _pumpTutorial(tester);
      await skipTo(tester, game, (s) => s is PlayStep && s.findsCannon);
      _steerBlock(_grid(game)!, findingStep);

      await _place(tester, game);

      expect(footer(game).cannonButton.count, 1);
      expect(game.descendants().whereType<PowerUpFoundAnimation>(), isEmpty);
      final next = script[script.indexOf(findingStep) + 1] as MessageStep;
      expect(_overlay(game)!.messageText.text, next.text);
    });

    _tutorialTest('waits with a cannon for the player to activate it', (
      tester,
    ) async {
      final game = await atCannonStep(tester);

      expect(_overlay(game), isNull);
      expect(_tutorial(game).hintText.text, cannonStep.hint);
      expect(footer(game).cannonButton.count, 1);
      expect(footer(game).cannonButton.activeUses, isNull);
    });

    _tutorialTest('explains shooting once the cannon is active', (
      tester,
    ) async {
      final game = await atCannonStep(tester);

      await activate(tester, game);

      expect(footer(game).cannonButton.activeUses, 8);
      expect(_tutorial(game).hintText.text, cannonStep.activeHint);
      expect(_grid(game)!.endlessController.currentBlock!.isLocked, isTrue);
    });

    _tutorialTest('goes on when all targets are shot away', (tester) async {
      final sounds = RecordingSoundEffectPlayer();
      final game = await atCannonStep(tester, sounds: sounds);
      await activate(tester, game);

      for (final target in cannonStep.targets) {
        await shoot(tester, game, target.x, target.y);
      }
      expect(
        sounds.played,
        List.filled(cannonStep.targets.length, SoundFiles.cannonShot),
      );
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      final next = script[script.indexOf(cannonStep) + 1] as MessageStep;
      expect(_overlay(game)!.messageText.text, next.text);
    });

    _tutorialTest('starts again when all shots are gone', (tester) async {
      final game = await atCannonStep(tester);
      await activate(tester, game);

      for (var i = 0; i < 8; i++) {
        await shoot(tester, game, i, 0);
      }
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(_tutorial(game).runner.current, isA<CannonStep>());
      expect(_tutorial(game).runner.attempt, 1);
      expect(_tutorial(game).hintText.text, TutorialGame.retryNotice);
      expect(footer(game).cannonButton.count, 1);
      expect(footer(game).cannonButton.activeUses, isNull);
      final target = cannonStep.targets.first;
      expect(_tutorial(game).gridContent[target.x][target.y], isNotNull);
    });

    _tutorialTest('starts again when the block is placed instead', (
      tester,
    ) async {
      final game = await atCannonStep(tester);

      await _place(tester, game);

      expect(_tutorial(game).runner.current, isA<CannonStep>());
      expect(_tutorial(game).runner.attempt, 1);
      expect(footer(game).cannonButton.count, 1);
    });
  });
}

/// Continues from the message that follows a solved step to the next board.
Future<void> _continueToBoard(WidgetTester tester, TetrisGame game) async {
  await _continue(tester, game); // message -> next message or board
  while (_overlay(game) != null) {
    await _continue(tester, game);
  }
}
