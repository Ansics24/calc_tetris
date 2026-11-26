import 'package:magic_blocks/block/math/model/equation.dart';

abstract interface class ScoreCalculator {
  /// Returns the points earned for [equation], or 0 if it is not a correct
  /// equation.
  int calculate(Equation equation);
}
