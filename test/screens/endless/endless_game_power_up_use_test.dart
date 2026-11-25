import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/play_mode.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/layout/footer/cannon_button.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:calc_tetris/layout/header/confirm_button.dart';
import 'package:calc_tetris/screens/endless/endless_game.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<_Pumped> _pump(WidgetTester tester) async {
  final endless = EndlessGame(powerUpFindChances: {});
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
      expect(controller.currentBlock!.opacity, 0.5);
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
}
