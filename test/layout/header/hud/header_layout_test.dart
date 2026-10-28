import 'package:calc_tetris/layout/header/hud/header_layout.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
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
