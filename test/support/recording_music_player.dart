import 'package:calc_tetris/audio/music_player.dart';

/// Remembers what it was asked to play instead of making any sound.
class RecordingMusicPlayer implements MusicPlayer {
  final List<String> played = [];
  int stops = 0;

  /// Makes every call fail, to see that the game survives broken audio.
  final bool failing;

  RecordingMusicPlayer({this.failing = false});

  /// True if the last call was a stop or nothing was played yet.
  bool get isSilent => stops >= played.length;

  @override
  Future<void> playLoop(String fileName) async {
    if (failing) {
      throw StateError('audio is broken');
    }
    played.add(fileName);
  }

  @override
  Future<void> stop() async {
    if (failing) {
      throw StateError('audio is broken');
    }
    stops++;
  }
}
