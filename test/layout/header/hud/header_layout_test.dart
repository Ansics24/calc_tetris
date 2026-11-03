import 'package:calc_tetris/layout/header/hud/header_layout.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  _buttonsStayWithinCardsTests();

  final layout = HeaderLayout(Vector2(400, 200));

  group('stop button', () {
    test('is as big as the drop button', () {
      expect(layout.stopButtonSize, layout.dropButtonSize);
    });

    test('is centered horizontally like the drop button', () {
      expect(layout.stopButtonPosition.x, layout.dropButtonPosition.x);
    });

    test('sits above the drop button and inside the header', () {
      expect(layout.stopButtonPosition.y, greaterThanOrEqualTo(0));
      expect(
        layout.stopButtonPosition.y + layout.stopButtonSize.y,
        lessThan(layout.dropButtonPosition.y),
      );
    });

    test('keeps a gap to the drop button of at least half a button', () {
      final gap =
          layout.dropButtonPosition.y -
          (layout.stopButtonPosition.y + layout.stopButtonSize.y);

      expect(gap, greaterThanOrEqualTo(layout.dropButtonSize.y / 2));
    });
  });
}

void _buttonsStayWithinCardsTests() {
  final sizes = [
    Vector2(400, 200),
    Vector2(360, 180),
    Vector2(500, 200),
    Vector2(400, 120),
  ];

  for (final size in sizes) {
    group('buttons in a header of $size', () {
      final layout = HeaderLayout(size);
      final cardTop = layout.scoreCardPosition.y;
      final cardBottom = cardTop + layout.cardSize.y;
      final buttons = {
        'drop': (layout.dropButtonPosition, layout.dropButtonSize),
        'stop': (layout.stopButtonPosition, layout.stopButtonSize),
      };

      for (final entry in buttons.entries) {
        final (position, buttonSize) = entry.value;

        test('${entry.key} button does not exceed the cards upwards', () {
          expect(position.y, greaterThanOrEqualTo(cardTop));
        });

        test('${entry.key} button does not exceed the cards downwards', () {
          expect(position.y + buttonSize.y, lessThanOrEqualTo(cardBottom));
        });
      }

      test('the two buttons are centered vertically between the cards', () {
        final top = layout.stopButtonPosition.y;
        final bottom = layout.dropButtonPosition.y + layout.dropButtonSize.y;

        expect(top - cardTop, closeTo(cardBottom - bottom, 0.001));
      });
    });
  }
}
