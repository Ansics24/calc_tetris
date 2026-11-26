import 'package:magic_blocks/block/block_component.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

abstract interface class PositionInGridAware {
  IntVector2? positionInGrid(BlockComponent component);
}
