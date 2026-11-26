import 'package:magic_blocks/grid/power_up_found_listener.dart';
import 'package:magic_blocks/layout/footer/cannon_button.dart';
import 'package:magic_blocks/layout/footer/power_up_found_animation.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

const double _cellSize = 40;
final _found = Vector2(150, 300);

class _Pumped {
  final FlameGame game;
  final CannonButton target;

  _Pumped(this.game, this.target);

  Iterable<PowerUpFoundAnimation> get animations =>
      game.descendants().whereType<PowerUpFoundAnimation>();

  PowerUpFoundAnimation get animation => animations.single;

  /// The size the animation is shown with right now.
  double get shownSize => animation.size.x * animation.scale.x;

  Vector2 get center => animation.absoluteCenter;

  Future<void> start(WidgetTester tester) async {
    game.add(
      PowerUpFoundAnimation(
        type: PowerUpType.cannon,
        foundPositionAbsoluteCenter: _found,
        targetButton: target,
        startCellSize: _cellSize,
      ),
    );
    await tester.pump();
  }
}

Future<_Pumped> _pump(WidgetTester tester, {int count = 0}) async {
  final game = FlameGame();
  final target = CannonButton(
    count: count,
    size: Vector2.all(60),
    position: Vector2(200, 700),
  );
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  game.add(target);
  await tester.pump();
  return _Pumped(game, target);
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

const double _grow = PowerUpFoundAnimation.growDuration;
const double _fly = PowerUpFoundAnimation.flyDuration;

void main() {
  testWidgets('starts at the found position, as big as a cell', (
    tester,
  ) async {
    final pumped = await _pump(tester);

    await pumped.start(tester);

    expect(pumped.center.x, closeTo(_found.x, 1));
    expect(pumped.center.y, closeTo(_found.y, 1));
    expect(pumped.shownSize, closeTo(_cellSize, 1));
    await _advance(tester, 3);
  });

  testWidgets('first grows quickly to a multiple of the cell size', (
    tester,
  ) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);

    await _advance(tester, _grow + 0.02);

    expect(pumped.shownSize, closeTo(_cellSize * 2.5, 2));
    expect(_grow, lessThanOrEqualTo(0.3));
    await _advance(tester, 3);
  });

  testWidgets('stands still while it grows', (tester) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);

    await _advance(tester, _grow / 2);

    expect(pumped.center.x, closeTo(_found.x, 1));
    expect(pumped.center.y, closeTo(_found.y, 1));
    expect(pumped.shownSize, greaterThan(_cellSize));
    await _advance(tester, 3);
  });

  testWidgets('then flies down to the center of the target button', (
    tester,
  ) async {
    final pumped = await _pump(tester);
    final target = pumped.target.absoluteCenter;
    await pumped.start(tester);
    await _advance(tester, _grow + 0.02);

    await _advance(tester, _fly / 2);
    final middle = pumped.center;

    expect(middle.y, greaterThan(_found.y));
    expect(middle.y, lessThan(target.y));

    // shortly before it arrives it is nearly there, as it speeds up
    await _advance(tester, _fly / 2 - 0.01);

    expect(pumped.center.x, closeTo(target.x, 25));
    expect(pumped.center.y, closeTo(target.y, 25));
    await _advance(tester, 3);
  });

  testWidgets('shrinks to the size of the button while flying', (
    tester,
  ) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);
    await _advance(tester, _grow + 0.02);
    final grown = pumped.shownSize;

    await _advance(tester, _fly / 2);
    expect(pumped.shownSize, lessThan(grown));

    await _advance(tester, _fly / 2 - 0.05);
    expect(pumped.shownSize, closeTo(60, 8));
    await _advance(tester, 3);
  });

  testWidgets('raises the count of the button only when it arrives', (
    tester,
  ) async {
    final pumped = await _pump(tester, count: 4);
    await pumped.start(tester);

    await _advance(tester, _grow + _fly - 0.1);
    expect(pumped.target.count, 4);

    await _advance(tester, 0.5);

    expect(pumped.target.count, 5);
    expect(pumped.target.badgeText, '5');
  });

  testWidgets('raises the count exactly once', (tester) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);

    await _advance(tester, 4);

    expect(pumped.target.count, 1);
  });

  testWidgets('removes itself after it has arrived', (tester) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);

    await _advance(tester, _grow + _fly + 0.5);

    expect(pumped.animations, isEmpty);
  });

  testWidgets('can run several times at once', (tester) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);
    await _advance(tester, 0.3);
    await pumped.start(tester);

    await _advance(tester, 4);

    expect(pumped.target.count, 2);
    expect(pumped.animations, isEmpty);
  });

  testWidgets('shows the cannon without a badge', (tester) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);

    final icons = pumped.animation.children.whereType<CannonButton>();

    expect(icons, hasLength(1));
    expect(icons.single.showBadge, isFalse);
    await _advance(tester, 3);
  });

  testWidgets('is drawn above the game but below dialogs', (tester) async {
    final pumped = await _pump(tester);
    await pumped.start(tester);

    expect(pumped.animation.priority, greaterThan(0));
    expect(pumped.animation.priority, lessThan(1000));
    await _advance(tester, 3);
  });
}
