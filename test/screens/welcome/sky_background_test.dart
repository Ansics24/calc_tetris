import 'dart:ui';

import 'package:calc_tetris/screens/welcome/sky_background.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  test('takes the size it is given', () {
    expect(SkyBackground(size: Vector2(400, 800)).size, Vector2(400, 800));
  });

  test('fades from the top to the bottom color of the palette', () {
    final sky = SkyBackground(size: Vector2(400, 800));

    expect(sky.topColor, WelcomePalette.skyTop);
    expect(sky.bottomColor, WelcomePalette.skyBottom);
  });

  test('can be rendered after it was resized', () {
    final sky = SkyBackground(size: Vector2.zero())..size = Vector2(400, 800);

    expect(() => sky.render(Canvas(PictureRecorder())), returnsNormally);
  });
}
