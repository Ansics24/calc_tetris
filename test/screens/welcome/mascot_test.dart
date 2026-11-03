import 'dart:io';
import 'dart:ui' show BlendMode;

import 'package:calc_tetris/screens/welcome/mascot.dart';
import 'package:test/test.dart';

void main() {
  test('its image exists and is registered as asset', () {
    expect(File('assets/images/${Mascot.imageName}').existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('assets/images/${Mascot.imageName}'),
    );
  });

  test('is only faintly visible so it does not distract', () {
    expect(Mascot().opacity, inExclusiveRange(0, 0.6));
  });

  test('its image has a transparent background', () {
    final header = File(
      'assets/images/${Mascot.imageName}',
    ).openSync().readSync(26);

    // Byte 25 of a PNG is the color type; 6 means RGBA.
    expect(header[25], 6);
  });

  test('is drawn as it is, without blending', () {
    expect(Mascot().paint.blendMode, BlendMode.srcOver);
  });
}
