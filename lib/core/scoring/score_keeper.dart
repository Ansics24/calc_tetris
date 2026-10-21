import 'dart:async';

/// Receives points earned by solved equations.
abstract interface class ScoreRecorder {
  void add(int points);
}

/// Holds the running total of earned points and announces every change.
class ScoreKeeper implements ScoreRecorder {
  final StreamController<int> _controller = StreamController<int>.broadcast(
    sync: true,
  );
  int _total = 0;

  int get total => _total;

  Stream<int> get totals => _controller.stream;

  @override
  void add(int points) {
    if (points < 0) {
      throw ArgumentError.value(points, 'points', 'must not be negative');
    }
    if (points == 0) {
      return;
    }
    _total += points;
    _controller.add(_total);
  }
}
