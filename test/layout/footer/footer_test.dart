import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/layout/footer/cannon_button.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

Footer _footer() => Footer(size: Vector2(400, 80), position: Vector2(0, 720));

void main() {
  test('gives the button of a power-up kind', () {
    final footer = _footer();

    expect(footer.buttonFor(PowerUpType.cannon), same(footer.cannonButton));
  });

  group('cannon button', () {
    test('is part of the footer', () {
      final footer = _footer();

      expect(footer.cannonButton, isA<CannonButton>());
      expect(footer.children.contains(footer.cannonButton), isTrue);
    });

    test('shows no power-up at the start', () {
      expect(_footer().cannonButton.count, 0);
      expect(_footer().cannonButton.badgeText, '0');
    });

    test('is a square, so the button is round', () {
      final size = _footer().cannonButton.size;

      expect(size.x, size.y);
    });

    test('fits into the footer with some air around it', () {
      final footer = _footer();
      final button = footer.cannonButton;

      expect(button.y, greaterThan(0));
      expect(button.y + button.height, lessThan(footer.height));
      expect(button.height, greaterThanOrEqualTo(footer.height * 0.6));
    });

    test('is centered in the footer', () {
      final footer = _footer();
      final button = footer.cannonButton;

      expect(button.x + button.width / 2, closeTo(footer.width / 2, 0.5));
      expect(button.y + button.height / 2, closeTo(footer.height / 2, 0.5));
    });

    test('keeps its size inside narrow footers', () {
      final footer = Footer(size: Vector2(40, 80));
      final button = footer.cannonButton;

      expect(button.width, lessThanOrEqualTo(40));
    });
  });
}
