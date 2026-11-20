/// Plays the background music of a screen.
abstract interface class MusicPlayer {
  /// Plays the music file endlessly. [fileName] is relative to the music
  /// assets.
  Future<void> playLoop(String fileName);

  Future<void> stop();
}

/// Makes no sound. Used where no music is wanted, e.g. in tests.
class SilentMusicPlayer implements MusicPlayer {
  @override
  Future<void> playLoop(String fileName) async {}

  @override
  Future<void> stop() async {}
}
