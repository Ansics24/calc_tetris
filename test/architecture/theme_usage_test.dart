import 'dart:io';

import 'package:test/test.dart';

/// Code that makes up the look of the endless game. It must take its colors
/// from `theme/light_theme.dart` only.
const _themedPaths = [
  'lib/layout',
  'lib/grid/visuals',
  'lib/screens/endless',
  'lib/screens/gameover',
  'lib/screens/stopgame',
];

Iterable<File> _dartFilesBelow(String path) => Directory(path)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'));

void main() {
  test('the game palette is gone', () {
    expect(File('lib/theme/game_palette.dart').existsSync(), isFalse);
    for (final file in _dartFilesBelow('lib')) {
      expect(
        file.readAsStringSync(),
        isNot(contains('game_palette.dart')),
        reason: '${file.path} still imports the game palette',
      );
    }
  });

  test('the endless game defines no colors of its own', () {
    final colorLiteral = RegExp(r'Color\(0x|Colors\.');
    final offending = [
      for (final path in _themedPaths)
        for (final file in _dartFilesBelow(path))
          if (colorLiteral.hasMatch(file.readAsStringSync())) file.path,
    ];

    expect(offending, isEmpty);
  });

  test('the background image is not used any more but still exists', () {
    for (final file in _dartFilesBelow('lib')) {
      expect(
        file.readAsStringSync(),
        isNot(contains('background_mittelalter')),
        reason: '${file.path} still loads the background image',
      );
    }
    expect(
      File('assets/images/background_mittelalter.png').existsSync(),
      isTrue,
    );
  });
}
