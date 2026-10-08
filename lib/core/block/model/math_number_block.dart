import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:uuid/uuid.dart';

class MathNumberBlock extends MathSingleBlock {
  final int number;

  MathNumberBlock({required this.number}) : super(id: Uuid());

  @override
  String toString() {
    return number.toString();
  }
}
