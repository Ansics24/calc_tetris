import 'dart:async';

import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:flame/components.dart';

class BlockBoard extends PositionComponent {
  final ScoreRecorder? _scoreRecorder;

  BlockBoard({this._scoreRecorder, super.size, super.position});

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(Grid(blockCount: IntVector2(9, 14), scoreRecorder: _scoreRecorder));
  }
}
