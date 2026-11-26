import 'dart:io';

import 'package:magic_blocks/theme/text_theme.dart';
import 'package:flutter/painting.dart';
import 'package:test/test.dart';

void main() {
  final styles = {
    'displayLarge': textTheme.displayLarge!,
    'displaySmall': textTheme.displaySmall!,
    'headlineLarge': textTheme.headlineLarge!,
    'headlineMedium': textTheme.headlineMedium!,
    'titleLarge': textTheme.titleLarge!,
    'titleMedium': textTheme.titleMedium!,
    'bodyLarge': textTheme.bodyLarge!,
    'bodyMedium': textTheme.bodyMedium!,
    'labelLarge': textTheme.labelLarge!,
    'labelMedium': textTheme.labelMedium!,
  };

  test('every text style uses the playful game font', () {
    for (final entry in styles.entries) {
      expect(entry.value.fontFamily, gameFontFamily, reason: entry.key);
    }
  });

  test('the font family is Fredoka', () {
    expect(gameFontFamily, 'Fredoka');
  });

  test('sizes get smaller from display down to body', () {
    final sizes = [
      for (final name in [
        'displayLarge',
        'headlineLarge',
        'headlineMedium',
        'titleLarge',
        'titleMedium',
        'bodyLarge',
        'bodyMedium',
      ])
        styles[name]!.fontSize!,
    ];

    expect(sizes, orderedEquals([...sizes]..sort((a, b) => b.compareTo(a))));
  });

  test('even the smallest text is readable for children', () {
    for (final entry in styles.entries) {
      expect(entry.value.fontSize, greaterThanOrEqualTo(13), reason: entry.key);
    }
  });

  test('headlines and numbers are bold', () {
    for (final name in ['displayLarge', 'displaySmall', 'headlineLarge']) {
      expect(styles[name]!.fontWeight, FontWeight.bold, reason: name);
    }
  });

  test('styles carry no color, the colors come from the color scheme', () {
    for (final entry in styles.entries) {
      expect(entry.value.color, isNull, reason: entry.key);
    }
  });

  group('font files', () {
    test('Fredoka and its license are part of the project', () {
      expect(File('assets/fonts/Fredoka.ttf').existsSync(), isTrue);
      expect(File('assets/fonts/OFL.txt').existsSync(), isTrue);
    });

    test('Fredoka is registered in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('family: $gameFontFamily'));
      expect(pubspec, contains('asset: assets/fonts/Fredoka.ttf'));
    });
  });
}
