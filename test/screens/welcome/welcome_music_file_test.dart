import 'dart:io';

import 'package:magic_blocks/screens/welcome/welcome_screen.dart';
import 'package:test/test.dart';

void main() {
  group('welcome music file', () {
    test('is an m4a that plays on every platform', () {
      expect(WelcomeScreen.musicFile, 'welcome.m4a');
    });

    test('exists in the music assets', () {
      expect(
        File('assets/music/${WelcomeScreen.musicFile}').existsSync(),
        isTrue,
      );
    });

    test('is declared in the pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('assets/music/${WelcomeScreen.musicFile}'));
    });
  });
}
