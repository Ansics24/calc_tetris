import 'dart:async';

import 'package:calc_tetris/block/math/model/math_single_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';

/// Plans the next compound block ahead of time, so it can be shown to the
/// player before it is handed to the grid.
class NextBlockPlanner {
  final CompoundblockModelGenerator _generator;
  final StreamController<List<List<MathSingleBlock>>> _controller =
      StreamController<List<List<MathSingleBlock>>>.broadcast(sync: true);
  List<List<MathSingleBlock>> _upcoming;

  NextBlockPlanner({required CompoundblockModelGenerator generator})
    : _generator = generator,
      _upcoming = generator.generate();

  /// The block that is handed out by the next call of [take].
  List<List<MathSingleBlock>> get upcoming => _upcoming;

  /// Emits every newly planned block, i.e. after each [take].
  Stream<List<List<MathSingleBlock>>> get upcomingChanges => _controller.stream;

  /// Hands out the planned block and plans the one after it.
  List<List<MathSingleBlock>> take() {
    final taken = _upcoming;
    _upcoming = _generator.generate();
    _controller.add(_upcoming);
    return taken;
  }
}
