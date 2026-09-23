import 'dart:developer';

import 'package:calc_tetris/core/block/math_compound_block.dart';
import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_queryable.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/grid/queries/position_in_grid_finder.dart';
import 'package:flame/components.dart';

class GridModel implements GridQueryable {
  late List<List<MathSingleBlockComponent?>> _model;
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
    required MathSingleBlockComponent blockComponent,
    required IntVector2 position,
  }) {
    log('Adding block at position: ${position.x} / ${position.y}');
    _model[position.x][position.y] = blockComponent;
    blockComponent.position = Vector2(
      _cellSize * position.x,
      _cellSize * position.y,
    );
    gridComponent.add(blockComponent);
    return this;
  }

  set cellSize(double size) {
    _cellSize = size;
  }

  IntVector2? findPositionOfComponent(MathSingleBlockComponent component) {
    return _positionInGridFinder.findPosition(
      component,
    );
  }

  Vector2 gridPositionToAbsolutePosition(IntVector2 targetPosition) {
    return Vector2(targetPosition.x * _cellSize, targetPosition.y * _cellSize);
  }

  bool isPositionBlocked(IntVector2 gridPosition) {
    log('Detection of block called with $gridPosition');

    if (gridPosition.x >= _model.length) {
      log('$gridPosition is out of grid by x');
      return true;
    }

    if (gridPosition.y >= _model[0].length) {
      log('$gridPosition is out of grid by y');
      return true;
    }

    final componentAtPosition = _model[gridPosition.x][gridPosition.y];
    if (componentAtPosition == null) {
      log('$gridPosition is free');
      return false;
    }
    log('$gridPosition is blocked by $componentAtPosition');
    return true;
  }

  List<List<MathSingleBlockComponent?>> get model => _model;

  @override
  MathSingleBlockComponent? findExistingBlockAt(IntVector2 positionInGrid) {
    if (_model.isEmpty || positionInGrid.x >= _model.length) {
      return null;
    }
    if (positionInGrid.y >= model[0].length) {
      return null;
    }
    return _model[positionInGrid.x][positionInGrid.y];
  }
}
