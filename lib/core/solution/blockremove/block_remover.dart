import 'package:calc_tetris/core/grid/grid_single_block_model.dart';
import 'package:calc_tetris/core/solution/blockremove/shrink_and_remove_block.dart';

class BlockRemover {
  Future<void> removeAll(Iterable<GridSingleBlockModel> modelsToRemove) {
    var futures = modelsToRemove.map((sb) => sb.component).map((c) {
      var animation = ShrinkAndRemoveBlock();
      c.add(animation);
      return animation.execute();
    });
    return Future.wait(futures);
  }
}
