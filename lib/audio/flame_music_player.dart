import 'package:magic_blocks/audio/music_player.dart';
import 'package:flame_audio/flame_audio.dart';

/// Plays music with the background music player of `flame_audio`. It pauses
/// when the app goes to the background and goes on when it comes back.
class FlameMusicPlayer implements MusicPlayer {
  static const String _assetFolder = 'assets/music/';

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }
    FlameAudio.updatePrefix(_assetFolder);
    await FlameAudio.bgm.initialize();
    _initialized = true;
  }

  @override
  Future<void> playLoop(String fileName) async {
    await _initialize();
    await FlameAudio.bgm.play(fileName);
  }

  @override
  Future<void> stop() async {
    if (!_initialized) {
      return;
    }
    await FlameAudio.bgm.stop();
  }
}
