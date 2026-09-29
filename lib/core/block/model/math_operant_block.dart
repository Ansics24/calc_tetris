import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';

class MathOperantBlock extends MathSingleBlock {
  final MathOperandType type;

  MathOperantBlock({required this.type});
}
