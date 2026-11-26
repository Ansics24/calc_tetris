import 'package:magic_blocks/grid/power_up_found_listener.dart';
import 'package:magic_blocks/layout/footer/cannon_button.dart';
import 'package:magic_blocks/layout/footer/footer.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:test/test.dart';

void main() {
  group('power-up button', () {
    test('reacts to taps', () {
      expect(CannonButton(size: Vector2.all(60)), isA<TapCallbacks>());
    });

    test('reports a press when there is a power-up left', () {
      var presses = 0;
      final button = CannonButton(count: 2, size: Vector2.all(60))
        ..onPressed = (() => presses++);

      button.press();

      expect(presses, 1);
    });

    test('reports nothing without a power-up left', () {
      var presses = 0;
      final button = CannonButton(size: Vector2.all(60))
        ..onPressed = (() => presses++);

      button.press();

      expect(presses, 0);
    });

    test('does not change the count itself, the game decides', () {
      final button = CannonButton(count: 2, size: Vector2.all(60))
        ..onPressed = () {};

      button.press();

      expect(button.count, 2);
    });

    test('can be pressed without anybody listening', () {
      expect(CannonButton(count: 1).press, returnsNormally);
    });
  });

  group('locked power-up button', () {
    test('is not locked at the start', () {
      expect(CannonButton().isLocked, isFalse);
    });

    test('reports nothing, even with power-ups left', () {
      var presses = 0;
      final button = CannonButton(count: 3, size: Vector2.all(60))
        ..onPressed = (() => presses++)
        ..isLocked = true;

      button.press();

      expect(presses, 0);
      expect(button.count, 3);
    });

    test('reports again once it is unlocked', () {
      var presses = 0;
      final button = CannonButton(count: 3, size: Vector2.all(60))
        ..onPressed = (() => presses++)
        ..isLocked = true
        ..isLocked = false;

      button.press();

      expect(presses, 1);
    });
  });

  group('locking the footer', () {
    test('locks all power-up buttons', () {
      final footer = Footer(size: Vector2(400, 80));

      footer.isLocked = true;

      for (final type in PowerUpType.values) {
        expect(footer.buttonFor(type).isLocked, isTrue);
      }
    });

    test('unlocks all power-up buttons again', () {
      final footer = Footer(size: Vector2(400, 80))..isLocked = true;

      footer.isLocked = false;

      for (final type in PowerUpType.values) {
        expect(footer.buttonFor(type).isLocked, isFalse);
      }
    });
  });

  group('footer', () {
    test('tells which power-up was selected', () {
      final selected = <PowerUpType>[];
      final footer = Footer(
        size: Vector2(400, 80),
        onPowerUpSelected: selected.add,
      );
      footer.cannonButton.count = 1;

      footer.cannonButton.press();

      expect(selected, [PowerUpType.cannon]);
    });

    test('tells nothing while there is no power-up left', () {
      final selected = <PowerUpType>[];
      final footer = Footer(
        size: Vector2(400, 80),
        onPowerUpSelected: selected.add,
      );

      footer.cannonButton.press();

      expect(selected, isEmpty);
    });
  });
}
