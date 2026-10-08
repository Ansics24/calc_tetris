import 'package:calc_tetris/core/block/model/math_equals_block.dart';
import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/math/equation.dart';
import 'package:test/test.dart';

void main() {
  test("To String", () {
    final equation = Equation.fromBlocks([
      MathNumberBlock(number: 2),
      MathOperantBlock(type: MathOperandType.plus),
      MathNumberBlock(number: 4),
      MathEqualsBlock(),
      MathNumberBlock(number: 6),
    ]);
    expect(equation.toString(), equals("2+4=6"));
  });
  group("Equations are invalid", () {
    test('Equation empty', () {
      final equation = Equation.fromBlocks(List.empty());

      expect(equation.isValid(), isFalse);
    });

    test('Equation has no equals', () {
      final equation = Equation.fromBlocks([MathNumberBlock(number: 2)]);

      expect(equation.isValid(), isFalse);
    });

    test('Equation has two equals in a row', () {
      final equation = Equation.fromBlocks([
        MathEqualsBlock(),
        MathEqualsBlock(),
      ]);

      expect(equation.isValid(), isFalse);
    });

    test('Equation has two operands in a row', () {
      final equation = Equation.fromBlocks([
        MathOperantBlock(type: MathOperandType.minus),
        MathOperantBlock(type: MathOperandType.minus),
      ]);

      expect(equation.isValid(), isFalse);
    });

    test('Equation has += in there', () {
      final equation = Equation.fromBlocks([
        MathOperantBlock(type: MathOperandType.minus),
        MathEqualsBlock(),
      ]);

      expect(equation.isValid(), isFalse);
    });

    test("Equation has to many equals", () {
      final equation = Equation.fromBlocks([
        MathNumberBlock(number: 2),
        MathEqualsBlock(),
        MathNumberBlock(number: 2),
        MathEqualsBlock(),
        MathNumberBlock(number: 2),
      ]);
      expect(equation.isValid(), isFalse);
    });
  });

  group("Equation is valid", () {
    test("5+4+1=10", () {
      final equation = Equation.fromBlocks([
        MathNumberBlock(number: 5),
        MathOperantBlock(type: MathOperandType.plus),
        MathNumberBlock(number: 4),
        MathOperantBlock(type: MathOperandType.plus),
        MathNumberBlock(number: 1),
        MathEqualsBlock(),
        MathNumberBlock(number: 10),
      ]);
      expect(equation.isValid(), isTrue);
    });
  });
}
