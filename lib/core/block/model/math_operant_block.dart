import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:uuid/uuid.dart';

class MathOperantBlock extends MathSingleBlock {
  final MathOperandType type;

  MathOperantBlock({required this.type}) : super(id: Uuid());

  @override
  String toString() {
    if (type == MathOperandType.plus) {
      return "+";
    }
    if (type == MathOperandType.minus) {
      return "-";
    }
    return super.toString();
  }
}
