/// Gets told when a round is over, i.e. after a landed block was checked for
/// solved equations.
abstract interface class GridRoundListener {
  /// [pointsEarned] is the sum of the points of this round, 0 if nothing was
  /// solved.
  void onRoundFinished(int pointsEarned);
}
