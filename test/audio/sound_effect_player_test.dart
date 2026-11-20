import 'package:calc_tetris/audio/sound_effect_player.dart';
import 'package:test/test.dart';

void main() {
  group('SilentSoundEffectPlayer', () {
    test('is a sound effect player', () {
      expect(SilentSoundEffectPlayer(), isA<SoundEffectPlayer>());
    });

    test('plays without doing anything', () async {
      await SilentSoundEffectPlayer().play('bell.m4a');
    });
  });
}
