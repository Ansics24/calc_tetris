import 'package:magic_blocks/audio/music_player.dart';
import 'package:test/test.dart';

void main() {
  group('SilentMusicPlayer', () {
    test('is a music player', () {
      expect(SilentMusicPlayer(), isA<MusicPlayer>());
    });

    test('plays and stops without doing anything', () async {
      final player = SilentMusicPlayer();

      await player.playLoop('welcome.m4a');
      await player.stop();
    });
  });
}
