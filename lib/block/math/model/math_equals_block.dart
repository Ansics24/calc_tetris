import 'package:calc_tetris/block/math/model/math_single_block.dart';
import 'package:uuid/uuid.dart';

class MathEqualsBlock extends MathSingleBlock {
  MathEqualsBlock() : super(id: Uuid());
  @override
  String toString() {
    return "=";
  }
}
