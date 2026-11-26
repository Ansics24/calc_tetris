import 'dart:io';

import 'package:magic_blocks/audio/sound_files.dart';
import 'package:test/test.dart';

void main() {
  group('cannon shot sound', () {
    test('is an m4a that plays on every platform', () {
      expect(SoundFiles.cannonShot, 'canon.m4a');
    });

    test('exists in the sound assets', () {
      expect(
        File('assets/sounds/${SoundFiles.cannonShot}').existsSync(),
        isTrue,
      );
    });

    test('is declared in the pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('assets/sounds/${SoundFiles.cannonShot}'));
    });
  });

  group('placed block sound', () {
    test('is an m4a that plays on every platform', () {
      expect(SoundFiles.blockPlaced, 'cork.m4a');
    });

    test('exists in the sound assets', () {
      expect(
        File('assets/sounds/${SoundFiles.blockPlaced}').existsSync(),
        isTrue,
      );
    });

    test('is declared in the pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('assets/sounds/${SoundFiles.blockPlaced}'));
    });
  });

  group('solved equation sound', () {
    test('is an m4a that plays on every platform', () {
      expect(SoundFiles.solvedEquation, 'bell.m4a');
    });

    test('exists in the sound assets', () {
      expect(
        File('assets/sounds/${SoundFiles.solvedEquation}').existsSync(),
        isTrue,
      );
    });

    test('is declared in the pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('assets/sounds/${SoundFiles.solvedEquation}'));
    });
  });
}
