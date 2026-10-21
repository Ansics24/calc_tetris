import 'package:calc_tetris/core/block/model/math_equals_block.dart';
import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/math/equation.dart';
import 'package:calc_tetris/core/scoring/digit_multiplier_score_calculator.dart';
import 'package:calc_tetris/core/scoring/score_calculator.dart';
import 'package:test/test.dart';

MathNumberBlock n(int digit) => MathNumberBlock(number: digit);
MathOperantBlock plus() => MathOperantBlock(type: MathOperandType.plus);
MathOperantBlock minus() => MathOperantBlock(type: MathOperandType.minus);
MathEqualsBlock eq() => MathEqualsBlock();

Equation equationOf(List<MathSingleBlock> blocks) =>
    Equation.fromBlocks(blocks);

void main() {
  final ScoreCalculator calculator = DigitMultiplierScoreCalculator();

  group("Single digit numbers only (multiplier 1)", () {
    test("2+3=5 earns 6 points", () {
      expect(
        calculator.calculate(equationOf([n(2), plus(), n(3), eq(), n(5)])),
        6,
      );
    });

    test("3+5=2+6 earns 8 points", () {
      expect(
        calculator.calculate(
          equationOf([n(3), plus(), n(5), eq(), n(2), plus(), n(6)]),
        ),
        8,
      );
    });

    test("5-2=3 earns 6 points", () {
      expect(
        calculator.calculate(equationOf([n(5), minus(), n(2), eq(), n(3)])),
        6,
      );
    });
  });

  group("Multi digit numbers add a multiplier", () {
    test("8+2=10 earns 12 points (6 base * 2)", () {
      expect(
        calculator.calculate(
          equationOf([n(8), plus(), n(2), eq(), n(1), n(0)]),
        ),
        12,
      );
    });

    test("10+5=13+2 earns 32 points (8 base * (2 + 2))", () {
      expect(
        calculator.calculate(
          equationOf([
            n(1),
            n(0),
            plus(),
            n(5),
            eq(),
            n(1),
            n(3),
            plus(),
            n(2),
          ]),
        ),
        32,
      );
    });

    test("200-150=50 earns 48 points (6 base * (3 + 3 + 2))", () {
      expect(
        calculator.calculate(
          equationOf([
            n(2),
            n(0),
            n(0),
            minus(),
            n(1),
            n(5),
            n(0),
            eq(),
            n(5),
            n(0),
          ]),
        ),
        48,
      );
    });
  });

  group("Invalid or incorrect equations earn nothing", () {
    test("empty equation", () {
      expect(calculator.calculate(equationOf([])), 0);
    });

    test("valid but incorrect equation 2+3=6", () {
      expect(
        calculator.calculate(equationOf([n(2), plus(), n(3), eq(), n(6)])),
        0,
      );
    });

    test("invalid equation 2+=3", () {
      expect(calculator.calculate(equationOf([n(2), plus(), eq(), n(3)])), 0);
    });
  });
}
