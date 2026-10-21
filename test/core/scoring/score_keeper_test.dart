import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:test/test.dart';

void main() {
  test('starts with 0 points', () {
    expect(ScoreKeeper().total, 0);
  });

  test('adds up earned points', () {
    final keeper = ScoreKeeper()
      ..add(6)
      ..add(12);
    expect(keeper.total, 18);
  });

  test('emits the new total after each addition', () {
    final keeper = ScoreKeeper();
    final totals = <int>[];
    keeper.totals.listen(totals.add);

    keeper
      ..add(6)
      ..add(12);

    expect(totals, [6, 18]);
  });

  test('adding 0 points emits nothing', () {
    final keeper = ScoreKeeper();
    final totals = <int>[];
    keeper.totals.listen(totals.add);

    keeper.add(0);

    expect(totals, isEmpty);
    expect(keeper.total, 0);
  });

  test('negative points are rejected', () {
    expect(() => ScoreKeeper().add(-1), throwsArgumentError);
  });

  test('can be used as ScoreRecorder', () {
    final ScoreRecorder recorder = ScoreKeeper();
    recorder.add(2);
    expect((recorder as ScoreKeeper).total, 2);
  });
}
