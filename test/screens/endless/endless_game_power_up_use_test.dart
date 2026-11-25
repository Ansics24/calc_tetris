import 'package:calc_tetris/audio/sound_effect_player.dart';
import 'package:calc_tetris/audio/sound_files.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/play_mode.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/layout/footer/cannon_button.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:calc_tetris/layout/header/confirm_button.dart';
import 'package:calc_tetris/screens/endless/endless_game.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/recording_sound_effect_player.dart';
import '../../support/test_grid.dart';

const _inUse = PlayMode.powerUpInUse(PowerUpType.cannon);

class _Pumped {
  final FlameGame game;
  final EndlessGame endless;

  _Pumped(this.game, this.endless);

  Grid get grid => game.descendants().whereType<Grid>().single;

  Footer get footer => game.descendants().whereType<Footer>().single;

  CannonButton get cannonButton => footer.cannonButton;
}

Future<_Pumped> _pump(WidgetTester tester, {SoundEffectPlayer? sounds}) async {
  final endless = EndlessGame(
    powerUpFindChances: {},
    soundEffectPlayer: sounds,
  );
  final game = FlameGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  game.add(endless);
  await tester.pump();
  // the first block arrives
  await tester.pump(const Duration(seconds: 1));
  return _Pumped(game, endless);
}

Future<void> _finish(WidgetTester tester) async {
  // delayed redraw timers of text boxes
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('starts in the default mode', (tester) async {
    final pumped = await _pump(tester);

    expect(pumped.endless.playMode, const PlayMode.defaultMode());
    await _finish(tester);
  });

  group('pressing the cannon button with cannons left', () {
    Future<_Pumped> pressed(WidgetTester tester) async {
      final pumped = await _pump(tester);
      pumped.cannonButton.count = 2;
      pumped.cannonButton.press();
      return pumped;
    }

    testWidgets('takes one cannon away', (tester) async {
      final pumped = await pressed(tester);

      expect(pumped.cannonButton.count, 1);
      expect(pumped.cannonButton.badgeText, '1');
      await _finish(tester);
    });

    testWidgets('switches the game to the cannon mode', (tester) async {
      final pumped = await pressed(tester);

      expect(pumped.endless.playMode, _inUse);
      await _finish(tester);
    });

    testWidgets('draws the current block half transparent', (tester) async {
      final pumped = await pressed(tester);

      final controller = pumped.grid.endlessController;
      expect(controller.currentBlock!.opacity, 0.2);
      await _finish(tester);
    });

    testWidgets('does not move the block on drags any more', (tester) async {
      final pumped = await pressed(tester);
      final controller = pumped.grid.endlessController;
      final before = controller.currentBlockGridPosition!;

      controller
        ..onBlockDraggedDown()
        ..onBlockDraggedUp()
        ..onBlockDraggedLeft()
        ..onBlockDraggedRight();

      expect(controller.currentBlockGridPosition!.x, before.x);
      expect(controller.currentBlockGridPosition!.y, before.y);
      await _finish(tester);
    });

    testWidgets('does not let the block be rotated', (tester) async {
      final pumped = await pressed(tester);
      final block = pumped.grid.endlessController.currentBlock!;
      final model = block.model;

      block.rotate();

      expect(block.model, same(model));
      await _finish(tester);
    });

    testWidgets('does not put the block into the grid on OK', (tester) async {
      final pumped = await pressed(tester);
      final controller = pumped.grid.endlessController;
      final block = controller.currentBlock;

      pumped.game.descendants().whereType<ConfirmButton>().single.press();
      await tester.pump(const Duration(seconds: 2));

      expect(controller.currentBlock, same(block));
      await _finish(tester);
    });

    testWidgets('locks the power-up buttons of the footer', (tester) async {
      final pumped = await pressed(tester);

      expect(pumped.footer.isLocked, isTrue);
      expect(pumped.cannonButton.isLocked, isTrue);
      await _finish(tester);
    });

    testWidgets('takes no second cannon while one is in use', (tester) async {
      final pumped = await pressed(tester);

      pumped.cannonButton.press();

      expect(pumped.cannonButton.count, 1);
      expect(pumped.endless.playMode, _inUse);
      await _finish(tester);
    });
  });

  testWidgets('does nothing when there is no cannon', (tester) async {
    final pumped = await _pump(tester);
    expect(pumped.footer.isLocked, isFalse);

    pumped.cannonButton.press();

    expect(pumped.cannonButton.count, 0);
    expect(pumped.endless.playMode, const PlayMode.defaultMode());
    expect(pumped.grid.endlessController.currentBlock!.opacity, 1);
    await _finish(tester);
  });

  testWidgets('can be told about a selected power-up directly', (
    tester,
  ) async {
    final pumped = await _pump(tester);
    pumped.cannonButton.count = 1;

    pumped.endless.onPowerUpSelected(PowerUpType.cannon);

    expect(pumped.endless.playMode, _inUse);
    expect(pumped.cannonButton.count, 0);
    await _finish(tester);
  });

  group('shooting', () {
    Future<_Pumped> active(WidgetTester tester) async {
      final pumped = await _pump(tester);
      pumped.cannonButton.count = 1;
      pumped.cannonButton.press();
      await tester.pump();
      return pumped;
    }

    /// Taps the middle of the given cell.
    Future<void> shoot(
      WidgetTester tester,
      _Pumped pumped,
      int x,
      int y,
    ) async {
      final cell = pumped.grid.cellSize;
      await tester.tapAt(
        pumped.grid
            .absolutePositionOf(Vector2((x + 0.5) * cell, (y + 0.5) * cell))
            .toOffset(),
      );
      await tester.pump();
    }

    testWidgets('starts with 8 shots shown on the button', (tester) async {
      final pumped = await active(tester);

      expect(pumped.cannonButton.activeUses, 8);
      await _finish(tester);
    });

    testWidgets('uses one shot for every tap on the grid', (tester) async {
      final pumped = await active(tester);

      await shoot(tester, pumped, 5, 5);
      expect(pumped.cannonButton.activeUses, 7);

      await shoot(tester, pumped, 6, 6);
      expect(pumped.cannonButton.activeUses, 6);
      await _finish(tester);
    });

    testWidgets('also counts a tap on the standing block', (tester) async {
      final pumped = await active(tester);
      final position = pumped.grid.endlessController.currentBlockGridPosition!;
      final local = pumped.grid.endlessController.currentBlock!
          .getLocalSingleBlockPositions()
          .first;

      await shoot(tester, pumped, position.x + local.x, position.y + local.y);

      expect(pumped.cannonButton.activeUses, 7);
      await _finish(tester);
    });

    testWidgets('returns to the default mode after the last shot', (
      tester,
    ) async {
      final pumped = await active(tester);

      for (var i = 0; i < 8; i++) {
        await shoot(tester, pumped, i, 5);
      }

      expect(pumped.endless.playMode, const PlayMode.defaultMode());
      expect(pumped.cannonButton.activeUses, isNull);
      expect(pumped.footer.isLocked, isFalse);
      expect(pumped.grid.endlessController.currentBlock!.opacity, 1);
      expect(pumped.grid.endlessController.currentBlock!.isLocked, isFalse);
      await _finish(tester);
    });

    testWidgets('stays in use while shots are left', (tester) async {
      final pumped = await active(tester);

      for (var i = 0; i < 7; i++) {
        await shoot(tester, pumped, i, 5);
      }

      expect(pumped.endless.playMode, _inUse);
      expect(pumped.cannonButton.activeUses, 1);
      await _finish(tester);
    });

    testWidgets('does not use a shot in the default mode', (tester) async {
      final pumped = await _pump(tester);

      await shoot(tester, pumped, 5, 5);

      expect(pumped.cannonButton.activeUses, isNull);
      await _finish(tester);
    });

    testWidgets('can use the next cannon after the last shot', (tester) async {
      final pumped = await active(tester);
      for (var i = 0; i < 8; i++) {
        await shoot(tester, pumped, i, 5);
      }
      pumped.cannonButton.count = 1;

      pumped.cannonButton.press();

      expect(pumped.cannonButton.activeUses, 8);
      await _finish(tester);
    });
  });

  group('sound of a shot', () {
    /// An endless game with the cannon in use.
    Future<_Pumped> active(
      WidgetTester tester,
      SoundEffectPlayer sounds,
    ) async {
      final pumped = await _pump(tester, sounds: sounds);
      pumped.cannonButton.count = 1;
      pumped.cannonButton.press();
      await tester.pump();
      return pumped;
    }

    Future<void> shoot(WidgetTester tester, _Pumped pumped, int x) async {
      final cell = pumped.grid.cellSize;
      await tester.tapAt(
        pumped.grid
            .absolutePositionOf(Vector2((x + 0.5) * cell, 5.5 * cell))
            .toOffset(),
      );
      await tester.pump();
    }

    testWidgets('plays when the cannon is fired', (tester) async {
      final sounds = RecordingSoundEffectPlayer();
      final pumped = await active(tester, sounds);
      expect(sounds.played, isEmpty);

      await shoot(tester, pumped, 1);

      expect(sounds.played, [SoundFiles.cannonShot]);
      await _finish(tester);
    });

    testWidgets('plays for every shot, hit or miss, up to the last one', (
      tester,
    ) async {
      final sounds = RecordingSoundEffectPlayer();
      final pumped = await active(tester, sounds);

      for (var i = 0; i < 8; i++) {
        await shoot(tester, pumped, i);
      }

      expect(sounds.played, List.filled(8, SoundFiles.cannonShot));
      await _finish(tester);
    });

    testWidgets('does not play for a tap in the default mode', (tester) async {
      final sounds = RecordingSoundEffectPlayer();
      final pumped = await _pump(tester, sounds: sounds);

      await shoot(tester, pumped, 1);

      expect(sounds.played, isEmpty);
      await _finish(tester);
    });

    testWidgets('does not disturb the game when the audio is broken', (
      tester,
    ) async {
      final pumped = await active(
        tester,
        RecordingSoundEffectPlayer(failing: true),
      );

      await shoot(tester, pumped, 1);

      expect(pumped.cannonButton.activeUses, 7);
      await _finish(tester);
    });
  });
}
