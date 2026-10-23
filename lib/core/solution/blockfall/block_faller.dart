import 'dart:async';

import 'package:calc_tetris/core/grid/block_move.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

/// Animates blocks falling to their new grid positions.
class BlockFaller {
  static const double secondsPerCell = 0.15;

  final GridModel _gridModel;

  BlockFaller({required this._gridModel});

  Future<void> fallAll(Iterable<BlockMove> moves) {
    final futures = moves.map((move) {
      final completer = Completer<void>();
      final distance = move.to.y - move.from.y;
      move.block.component.add(
        MoveToEffect(
          _gridModel.gridPositionToAbsolutePosition(move.to),
          EffectController(
            duration: secondsPerCell * distance,
            curve: Curves.easeIn,
          ),
          onComplete: completer.complete,
        ),
      );
      return completer.future;
    });
    return Future.wait(futures);
  }
}
