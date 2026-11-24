import 'dart:typed_data';
import 'dart:ui';

import 'package:calc_tetris/layout/footer/cannon_button.dart';
import 'package:calc_tetris/layout/footer/powerup_button.dart';
import 'package:calc_tetris/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

const double _size = 64;

CannonButton _button({int count = 0}) =>
    CannonButton(count: count, size: Vector2.all(_size));

/// Renders the button into an image with one pixel per unit.
Future<_Pixels> _render(CannonButton button) async {
  final recorder = PictureRecorder();
  button.render(Canvas(recorder));
  final image = await recorder.endRecording().toImage(
    _size.toInt(),
    _size.toInt(),
  );
  return _Pixels(image, (await image.toByteData())!);
}

class _Pixels {
  final Image image;
  final ByteData data;

  _Pixels(this.image, this.data);

  Color at(int x, int y) {
    final offset = (y * image.width + x) * 4;
    return Color.fromARGB(
      data.getUint8(offset + 3),
      data.getUint8(offset),
      data.getUint8(offset + 1),
      data.getUint8(offset + 2),
    );
  }

  int countOf(Color color) {
    var count = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (at(x, y) == color) {
          count++;
        }
      }
    }
    return count;
  }
}

void main() {
  test('is a power-up button', () {
    expect(_button(), isA<PowerUpButton>());
  });

  group('count', () {
    test('is 0 at the start', () {
      expect(CannonButton(size: Vector2.all(_size)).count, 0);
    });

    test('can be given', () {
      expect(_button(count: 3).count, 3);
    });

    test('can be changed', () {
      final button = _button()..count = 5;

      expect(button.count, 5);
      expect(button.badgeText, '5');
    });

    test('must not be negative', () {
      expect(() => _button().count = -1, throwsArgumentError);
      expect(() => _button(count: -1), throwsArgumentError);
    });
  });

  group('badge text', () {
    test('shows 0 when there is no power-up left', () {
      expect(_button().badgeText, '0');
    });

    test('shows the exact count up to 99', () {
      expect(_button(count: 99).badgeText, '99');
    });

    test('shows 99+ for more', () {
      expect(_button(count: 100).badgeText, '99+');
      expect(_button(count: 1234).badgeText, '99+');
    });
  });

  group('shape', () {
    test('is round: the circle fills the button and stays inside', () {
      final circle = _button().circleRect;

      expect(circle.width, circle.height);
      expect(circle.left, greaterThanOrEqualTo(0));
      expect(circle.top, greaterThanOrEqualTo(0));
      expect(circle.right, lessThanOrEqualTo(_size));
      expect(circle.bottom, lessThanOrEqualTo(_size));
      expect(circle.width, greaterThan(_size * 0.7));
    });

    test('has a badge on the upper left of the circle', () {
      final button = _button();

      expect(button.badgeRect.center.dx, lessThan(_size / 2));
      expect(button.badgeRect.center.dy, lessThan(_size / 2));
      expect(button.badgeRect.overlaps(button.circleRect), isTrue);
    });

    test('keeps the badge inside the component, so it can be hit', () {
      final badge = _button().badgeRect;

      expect(badge.left, greaterThanOrEqualTo(0));
      expect(badge.top, greaterThanOrEqualTo(0));
      expect(badge.right, lessThanOrEqualTo(_size));
      expect(badge.bottom, lessThanOrEqualTo(_size));
    });

    test('has a badge that is clearly smaller than the circle', () {
      final button = _button();

      expect(button.badgeRect.width, lessThan(button.circleRect.width / 2));
    });

    test('has a badge big enough to read its number', () {
      expect(_button().badgeRect.width, greaterThanOrEqualTo(_size * 0.3));
    });
  });

  group('look', () {
    test('renders for every kind of count', () {
      for (final count in [0, 1, 42, 99, 100]) {
        final button = _button(count: count);

        expect(() => button.render(Canvas(PictureRecorder())), returnsNormally);
      }
    });

    test('is transparent outside of the circle, so it looks round', () async {
      final pixels = await _render(_button());

      expect(pixels.at(2, _size.toInt() - 3).a, 0);
      expect(pixels.at(2, 2).a, 0);
    });

    test('has an opaque face', () async {
      final pixels = await _render(_button());

      expect(pixels.at(20, 44).a, 1);
    });

    test('paints the cannon in the color of the game theme', () async {
      final pixels = await _render(_button());

      expect(pixels.countOf(colorScheme.tertiary), greaterThan(40));
    });

    test('does not cover the muzzle of the cannon with the badge', () async {
      final pixels = await _render(_button());

      // the muzzle points to the upper right, where the badge used to sit
      expect(pixels.at(42, 22), colorScheme.tertiary);
      expect(
        _button().badgeRect.contains(const Offset(42, 22)),
        isFalse,
      );
    });

    test('shows no badge when it is switched off', () async {
      final button = CannonButton(showBadge: false, size: Vector2.all(_size));
      final badge = button.badgeRect;
      final pixels = await _render(button);

      expect(button.showBadge, isFalse);
      expect(
        pixels.at(badge.center.dx.toInt(), badge.top.toInt() + 3).a,
        isNot(1),
      );
    });

    test('shows the badge by default', () {
      expect(_button().showBadge, isTrue);
    });

    test('paints the badge in the error color of the game theme', () async {
      final pixels = await _render(_button());
      final badge = _button().badgeRect;

      expect(
        pixels.at(badge.center.dx.toInt(), badge.top.toInt() + 3),
        colorScheme.error,
      );
    });
  });
}
