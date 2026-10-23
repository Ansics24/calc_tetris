import 'package:calc_tetris/block/shrink_and_remove_block.dart';
import 'package:calc_tetris/grid/model/grid_single_block_model.dart';

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
