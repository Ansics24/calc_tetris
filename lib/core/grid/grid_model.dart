import 'dart:developer';

import 'package:calc_tetris/core/block/math_block_model.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_position.dart';
import 'package:calc_tetris/core/grid/grid_queryable.dart';
import 'package:flame/components.dart';

class GridModel implements GridQueryable {
  late List<List<MathBlockModel?>> _model;
  late double _cellSize;
  final Grid gridComponent;
  final Map<ComponentKey, Component> _setBlocks = {};

  GridModel({required GridPosition size, required this.gridComponent}) {
    _model = List.generate(
      size.x,
      (index) => List.generate(
        size.y,
        (index) => null,
      ),
    );
  }

  GridModel addBlock({
    required MathBlockModel blockModel,
    required GridPosition position,
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
  bool hasBlocksUnder(ComponentKey key) {
    // TODO implement me
    log('Deection of unserlying blocks called');
    return false;
  }
}
