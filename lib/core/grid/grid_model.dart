import 'dart:developer';

import 'package:calc_tetris/core/block/math_block_model.dart';
import 'package:calc_tetris/core/block/math_compound_block.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/grid/grid_queryable.dart';
import 'package:calc_tetris/core/grid/queries/position_in_grid_finder.dart';
import 'package:flame/components.dart';

class GridModel implements GridQueryable {
  late List<List<MathBlockModel?>> _model;
  late double _cellSize;
  final Grid gridComponent;
  late final PositionInGridFinder _positionInGridFinder;

  GridModel({required IntVector2 size, required this.gridComponent}) {
    _model = List.generate(
      size.x,
      (index) => List.generate(
        size.y,
        (index) => null,
      ),
    );
    _positionInGridFinder = PositionInGridFinder(gridModel: this);
  }

  GridModel addBlock({
    required MathBlockModel blockModel,
    required IntVector2 position,
  }) {
    log('Adding block at position: ${position.x} / ${position.y}');
    _model[position.x][position.y] = blockModel;
    var component = blockModel.component;
    component.position = Vector2(
      _cellSize * position.x,
      _cellSize * position.y,
    );
    gridComponent.add(component);
    return this;
  }

  set cellSize(double size) {
    _cellSize = size;
  }

  @override
  bool hasBlocksUnder(MathCompoundBlock compoundBlock) {
    log('Detection of underlying blocks called');
    var key = compoundBlock.key;
    final positionInGrid = _positionInGridFinder.findPosition(
      key!,
    );
    if (positionInGrid == null) {
      return false;
    }
    var gridPosition = positionInGrid.gridPosition;
    log(
      'Result of finding component $key in Grid: ${gridPosition.x} / ${gridPosition.y}',
    );
    final yToCheck = gridPosition.y + compoundBlock.modelSize.y;

    for (var i = 0; i < compoundBlock.modelSize.x; i++) {
      final xToCheck = positionInGrid.gridPosition.x + i;
      final IntVector2 positionToCheck = IntVector2(xToCheck, yToCheck);
      bool blockUnderneath = findExistingBlockAt(positionToCheck) != null;
      log("Is there a block at $positionToCheck ? $blockUnderneath");
      if (blockUnderneath) {
        return true;
      }
    }

    return false;
  }

  List<List<MathBlockModel?>> get model => _model;

  @override
  MathBlockModel? findExistingBlockAt(IntVector2 positionInGrid) {
    if (_model.isEmpty || positionInGrid.x >= _model.length) {
      return null;
    }
    if (positionInGrid.y >= model[0].length) {
      return null;
    }
    return _model[positionInGrid.x][positionInGrid.y];
  }
}
