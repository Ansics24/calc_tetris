import 'package:calc_tetris/core/block/model/math_single_block.dart';

class Equation {
  static final regExp = RegExp(r'^\d+(?:[+-]\d+)*=\d+(?:[+-]\d+)*$');
  final List<MathSingleBlock> _blocks;

  Equation.fromBlocks(this._blocks);

  bool isValid() {
    return _matchesregExp() ? true : false;
  }

  bool _matchesregExp() {
    return regExp.hasMatch(toString());
  }

  @override
  String toString() {
    return _blocks.map((b) => b.toString()).join();
  }

  bool isCorrect() {
    if (!isValid()) {
      return false;
    }
    final input = toString().replaceAll(' ', '');
    final sides = input.split('=');
    if (sides.length != 2) {
      return false;
    }
    final leftResult = _evaluate(sides[0]);
    final rightResult = _evaluate(sides[1]);
    return leftResult == rightResult;
  }

  int _evaluate(String expression) {
    final numbers = expression.split(RegExp(r'[+-]'));
    final operators = RegExp(
      r'[+-]',
    ).allMatches(expression).map((match) => match.group(0)!).toList();
    var result = int.parse(numbers[0]);
    for (var i = 0; i < operators.length; i++) {
      final number = int.parse(numbers[i + 1]);
      if (operators[i] == '+') {
        result += number;
      } else {
        result -= number;
      }
    }
    return result;
  }
}
