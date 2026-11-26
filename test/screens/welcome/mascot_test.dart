import 'dart:io';

import 'package:magic_blocks/screens/welcome/mascot.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('its image exists and is registered as asset', () {
    expect(File('assets/images/${Mascot.imageName}').existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('assets/images/${Mascot.imageName}'),
    );
  });

  test('its image has a transparent background', () {
    final header = File(
      'assets/images/${Mascot.imageName}',
    ).openSync().readSync(26);

    // Byte 25 of a PNG is the color type; 6 means RGBA.
    expect(header[25], 6);
  });

  testWidgets('is only faintly visible so it does not distract', (
    tester,
  ) async {
    await tester.pumpWidget(const Mascot());

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.opacity!.value, inExclusiveRange(0, 0.6));
  });
}
