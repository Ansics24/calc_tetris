import 'package:calc_tetris/core/math/equation.dart';
import 'package:calc_tetris/core/scoring/score_calculator.dart';

/// Every number earns [basePointsPerNumber]. Numbers with more than one digit
/// add their digit count to a shared multiplier (1 if there are none).
class DigitMultiplierScoreCalculator implements ScoreCalculator {
  static const basePointsPerNumber = 2;
  static final _numberRegExp = RegExp(r'\d+');

  @override
  int calculate(Equation equation) {
    if (!equation.isCorrect()) {
      return 0;
    }
    final numbers = _numberRegExp
        .allMatches(equation.toString())
        .map((m) => m.group(0)!)
        .toList();
    final multiplier = numbers
        .where((n) => n.length > 1)
        .fold(0, (sum, n) => sum + n.length);
    return numbers.length *
        basePointsPerNumber *
        (multiplier == 0 ? 1 : multiplier);
  }
}
