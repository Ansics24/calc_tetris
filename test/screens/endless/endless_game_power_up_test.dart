import 'package:magic_blocks/block/solution_strategy_singlerun_result.dart';
import 'package:magic_blocks/grid/grid.dart';
import 'package:magic_blocks/grid/power_up_found_listener.dart';
import 'package:magic_blocks/layout/footer/cannon_button.dart';
import 'package:magic_blocks/layout/footer/footer.dart';
import 'package:magic_blocks/layout/footer/power_up_found_animation.dart';
import 'package:magic_blocks/screens/endless/endless_game.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_grid.dart';

class _Pumped {
  final FlameGame game;
  final EndlessGame endless;

  _Pumped(this.game, this.endless);

  Grid get grid => game.descendants().whereType<Grid>().single;

  CannonButton get cannonButton =>
      game.descendants().whereType<Footer>().single.cannonButton;

  Iterable<PowerUpFoundAnimation> get animations =>
      game.descendants().whereType<PowerUpFoundAnimation>();

  /// Lets the player solve an equation.
  void solveEquation() => grid.endlessController.onStrategyResult(
    SolutionStrategySinglerunResult(solvedBlocks: [], pointsEarned: 6),
  );
}

Future<_Pumped> _pump(
  WidgetTester tester, {
  Map<PowerUpType, double>? chances,
}) async {
  final endless = EndlessGame(powerUpFindChances: chances);
  final game = FlameGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  game.add(endless);
  await tester.pump();
  // the first block arrives
  await tester.pump(const Duration(seconds: 1));
  return _Pumped(game, endless);
}

/// Lets [seconds] pass in small steps, like frames of a running game.
Future<void> _advance(WidgetTester tester, double seconds) async {
  var left = seconds;
  while (left > 0) {
    final step = left < 0.05 ? left : 0.05;
    await tester.pump(Duration(microseconds: (step * 1000000).round()));
    left -= step;
  }
}

Future<void> _finish(WidgetTester tester) async {
  // delayed redraw timers of text boxes
  await tester.pump(const Duration(seconds: 2));
}

const _sure = {PowerUpType.cannon: 1.0};
const _never = {PowerUpType.cannon: 0.0};

void main() {
  group('finding a cannon in the endless game', () {
    testWidgets('shows the found cannon where the equation was solved', (
      tester,
    ) async {
      final pumped = await _pump(tester, chances: _sure);
      final origin = pumped.grid.absoluteCenter;

      pumped.solveEquation();
      await tester.pump();

      final animation = pumped.animations.single;
      expect(animation.absoluteCenter.x, closeTo(origin.x, 1));
      expect(animation.absoluteCenter.y, closeTo(origin.y, 1));
      await _advance(tester, 3);
      await _finish(tester);
    });

    testWidgets('starts the cannon as big as a cell of the grid', (
      tester,
    ) async {
      final pumped = await _pump(tester, chances: _sure);

      pumped.solveEquation();
      await tester.pump();

      final animation = pumped.animations.single;
      expect(
        animation.size.x * animation.scale.x,
        closeTo(pumped.grid.cellSize, 1),
      );
      await _advance(tester, 3);
      await _finish(tester);
    });

    testWidgets('raises the badge of the cannon button when it arrives', (
      tester,
    ) async {
      final pumped = await _pump(tester, chances: _sure);

      pumped.solveEquation();
      await _advance(tester, 0.3);
      expect(pumped.cannonButton.count, 0);

      await _advance(tester, 3);

      expect(pumped.cannonButton.count, 1);
      expect(pumped.cannonButton.badgeText, '1');
      expect(pumped.animations, isEmpty);
      await _finish(tester);
    });

    testWidgets('finds nothing when the chance is 0', (tester) async {
      final pumped = await _pump(tester, chances: _never);

      pumped.solveEquation();
      await _advance(tester, 3);

      expect(pumped.animations, isEmpty);
      expect(pumped.cannonButton.count, 0);
      await _finish(tester);
    });

    testWidgets('counts every cannon that was found', (tester) async {
      final pumped = await _pump(tester, chances: _sure);

      pumped.solveEquation();
      await _advance(tester, 0.3);
      pumped.solveEquation();
      await _advance(tester, 4);

      expect(pumped.cannonButton.count, 2);
      await _finish(tester);
    });

    testWidgets('shows the animation above the grid, below dialogs', (
      tester,
    ) async {
      final pumped = await _pump(tester, chances: _sure);

      pumped.solveEquation();
      await tester.pump();

      final priority = pumped.animations.single.priority;
      expect(priority, greaterThan(pumped.grid.priority));
      expect(priority, lessThan(1000));
      await _advance(tester, 3);
      await _finish(tester);
    });

    testWidgets('can be told about a found power-up directly', (tester) async {
      final pumped = await _pump(tester, chances: _never);

      pumped.endless.onPowerUpFound(
        PowerUpType.cannon,
        pumped.grid.absoluteCenter,
      );
      await _advance(tester, 4);

      expect(pumped.cannonButton.count, 1);
      await _finish(tester);
    });
  });
}
