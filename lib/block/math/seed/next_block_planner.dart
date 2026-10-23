import 'dart:async';

import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/model/single_block.dart';

/// Plans the next compound block ahead of time, so it can be shown to the
/// player before it is handed to the grid.
class NextBlockPlanner {
  final CompoundblockModelGenerator _generator;
  final StreamController<List<List<SingleBlock>>> _controller =
      StreamController<List<List<SingleBlock>>>.broadcast(sync: true);
  List<List<SingleBlock>> _upcoming;

  NextBlockPlanner({required CompoundblockModelGenerator generator})
    : _generator = generator,
      _upcoming = generator.generate();

  /// The block that is handed out by the next call of [take].
  List<List<SingleBlock>> get upcoming => _upcoming;

  /// Emits every newly planned block, i.e. after each [take].
  Stream<List<List<SingleBlock>>> get upcomingChanges => _controller.stream;

  /// Hands out the planned block and plans the one after it.
  List<List<SingleBlock>> take() {
    final taken = _upcoming;
    _upcoming = _generator.generate();
    _controller.add(_upcoming);
    return taken;
  }
}
