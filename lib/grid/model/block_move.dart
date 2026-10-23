import 'package:calc_tetris/grid/model/grid_single_block_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

/// Describes that a block moves from one grid cell to another.
class BlockMove {
  final GridSingleBlockModel block;
  final IntVector2 from;
  final IntVector2 to;

  BlockMove({required this.block, required this.from, required this.to});

  @override
  String toString() => '$block: $from -> $to';
}
