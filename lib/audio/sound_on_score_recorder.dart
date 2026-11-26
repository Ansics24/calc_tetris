import 'package:magic_blocks/audio/sound_effect_player.dart';
import 'package:magic_blocks/block/math/scoring/score_keeper.dart';

/// Passes points on to another recorder and plays a sound whenever points
/// were earned. Broken audio must not disturb the game.
class SoundOnScoreRecorder implements ScoreRecorder {
  final ScoreRecorder _inner;
  final SoundEffectPlayer _player;
  final String _fileName;

  SoundOnScoreRecorder({
    required this._inner,
    required this._player,
    required this._fileName,
  });

  @override
  void add(int points) {
    _inner.add(points);
    if (points > 0) {
      _player.playSafely(_fileName);
    }
  }
}
