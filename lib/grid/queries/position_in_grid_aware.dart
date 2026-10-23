import 'package:calc_tetris/block/math/math_block_component.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

abstract interface class PositionInGridAware {
  IntVector2? positionInGrid(MathBlockComponent component);
}
