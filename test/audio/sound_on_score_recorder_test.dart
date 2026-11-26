import 'package:magic_blocks/audio/sound_on_score_recorder.dart';
import 'package:magic_blocks/block/math/scoring/score_keeper.dart';
import 'package:test/test.dart';

import '../support/recording_sound_effect_player.dart';

class _RecordingScoreRecorder implements ScoreRecorder {
  final List<int> added = [];

  @override
  void add(int points) => added.add(points);
}

void main() {
  late _RecordingScoreRecorder inner;
  late RecordingSoundEffectPlayer player;
  late SoundOnScoreRecorder recorder;

  setUp(() {
    inner = _RecordingScoreRecorder();
    player = RecordingSoundEffectPlayer();
    recorder = SoundOnScoreRecorder(
      inner: inner,
      player: player,
      fileName: 'bell.m4a',
    );
  });

  test('is a score recorder', () {
    expect(recorder, isA<ScoreRecorder>());
  });

  test('passes the points on to the wrapped recorder', () {
    recorder.add(6);
    recorder.add(8);

    expect(inner.added, [6, 8]);
  });

  test('plays the sound when points were earned', () {
    recorder.add(6);

    expect(player.played, ['bell.m4a']);
  });

  test('plays the sound once for every solved result', () {
    recorder.add(6);
    recorder.add(8);

    expect(player.played, ['bell.m4a', 'bell.m4a']);
  });

  test('stays silent without points', () {
    recorder.add(0);

    expect(player.played, isEmpty);
    expect(inner.added, [0]);
  });

  test('plays nothing when the wrapped recorder refuses the points', () {
    final strict = SoundOnScoreRecorder(
      inner: ScoreKeeper(),
      player: player,
      fileName: 'bell.m4a',
    );

    expect(() => strict.add(-1), throwsArgumentError);
    expect(player.played, isEmpty);
  });

  test('keeps counting the points when the audio is broken', () async {
    final broken = SoundOnScoreRecorder(
      inner: inner,
      player: RecordingSoundEffectPlayer(failing: true),
      fileName: 'bell.m4a',
    );

    expect(() => broken.add(6), returnsNormally);
    await Future<void>.delayed(Duration.zero);

    expect(inner.added, [6]);
  });
}
