import 'package:calc_tetris/core/math/equation.dart';

abstract interface class ScoreCalculator {
  /// Returns the points earned for [equation], or 0 if it is not a correct
  /// equation.
  int calculate(Equation equation);
}
