import 'package:magic_blocks/audio/sound_effect_player.dart';
import 'package:test/test.dart';

import '../support/recording_sound_effect_player.dart';

void main() {
  group('SilentSoundEffectPlayer', () {
    test('is a sound effect player', () {
      expect(SilentSoundEffectPlayer(), isA<SoundEffectPlayer>());
    });

    test('plays without doing anything', () async {
      await SilentSoundEffectPlayer().play('bell.m4a');
    });
  });

  group('playSafely', () {
    test('plays the sound', () async {
      final player = RecordingSoundEffectPlayer();

      await player.playSafely('cork.m4a');

      expect(player.played, ['cork.m4a']);
    });

    test('does not throw when the audio is broken', () async {
      final player = RecordingSoundEffectPlayer(failing: true);

      await player.playSafely('cork.m4a');
    });
  });
}
