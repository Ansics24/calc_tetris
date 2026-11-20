import 'package:calc_tetris/audio/sound_effect_player.dart';

/// Remembers which sounds it was asked to play instead of making any noise.
class RecordingSoundEffectPlayer implements SoundEffectPlayer {
  final List<String> played = [];

  /// Makes every call fail, to see that the game survives broken audio.
  final bool failing;

  RecordingSoundEffectPlayer({this.failing = false});

  @override
  Future<void> play(String fileName) async {
    if (failing) {
      throw StateError('audio is broken');
    }
    played.add(fileName);
  }
}
