import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/single_block_component.dart';

/// Creates the component for a single block model, or null if the model
/// stands for an empty cell.
typedef SingleBlockComponentFactory =
    SingleBlockComponent? Function(SingleBlock model);
