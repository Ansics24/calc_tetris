import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:uuid/uuid.dart';

/// A single block indicating that no block component should sit at this position
class NullBlock extends MathSingleBlock {
  NullBlock() : super(id: Uuid());
}
