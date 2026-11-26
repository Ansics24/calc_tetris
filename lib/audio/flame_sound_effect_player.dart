import 'package:magic_blocks/audio/sound_effect_player.dart';
import 'package:flame_audio/flame_audio.dart';

/// Plays sound effects with the audio player of `flame_audio`. Uses a cache of
/// its own, so it never interferes with the music.
class FlameSoundEffectPlayer implements SoundEffectPlayer {
  static const String _assetFolder = 'assets/sounds/';

  late final AudioPlayer _player = AudioPlayer()
    ..audioCache = AudioCache(prefix: _assetFolder);

  @override
  Future<void> play(String fileName) async {
    await _player.stop();
    await _player.play(AssetSource(fileName), mode: PlayerMode.lowLatency);
  }
}
