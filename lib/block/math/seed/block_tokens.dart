import 'package:calc_tetris/block/model/math_number_block.dart';
import 'package:calc_tetris/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_equals_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';

/// Text representation of the blocks that can be part of an equation.
class BlockTokens {
  static const List<String> digits = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', //
  ];
  static const List<String> operators = ['+', '-'];
  static const String equals = '=';
  static final List<String> all = [...digits, ...operators, equals];

  static bool isDigit(String token) => digits.contains(token);

  static MathSingleBlock blockFor(String token) {
    if (isDigit(token)) {
      return MathNumberBlock(number: int.parse(token));
    }
    return switch (token) {
      '+' => MathOperantBlock(type: MathOperandType.plus),
      '-' => MathOperantBlock(type: MathOperandType.minus),
      '=' => MathEqualsBlock(),
      _ => throw ArgumentError.value(token, 'token', 'Unknown block token'),
    };
  }
}
