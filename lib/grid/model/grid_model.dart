import 'dart:developer';

import 'package:calc_tetris/block/compound_block_component.dart';
import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/block/single_block_component.dart';
import 'package:calc_tetris/grid/exception/grid_position_occupied_exception.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/model/block_move.dart';
import 'package:calc_tetris/grid/model/connected_blocks.dart';
import 'package:calc_tetris/grid/model/grid_single_block_model.dart';
import 'package:calc_tetris/grid/queries/grid_model_aware.dart';
import 'package:calc_tetris/grid/queries/position_in_grid_finder.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

class GridModel implements GridModelAware {
  late List<List<GridSingleBlockModel?>> _model;
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

  List<IntVector2> addCompoundBlock({
    required CompoundBlockComponent blockComponent,
    required IntVector2 position,
  }) {
    final placementId = Uuid().toString();

    final blockModel = blockComponent.model;
    for (var x = 0; x < blockComponent.model.length; x++) {
      for (var y = 0; y < blockComponent.model[0].length; y++) {
        final targetPosition = position.add(x, y);
        if (blockModel[x][y] is NullBlock) {
          continue;
        }
        if (isPositionBlocked(targetPosition)) {
          throw GridPositionOccupiedException(position: targetPosition);
        }
      }
    }

    final List<IntVector2> addedPositions = List.empty(growable: true);

    for (var x = 0; x < blockModel.length; x++) {
      for (var y = 0; y < blockModel[x].length; y++) {
        var blockModelAtXY = blockModel[x][y];
        final targetPosition = position.add(x, y);
        if (blockModelAtXY is NullBlock) {
          continue;
        }
        addSingleBlock(
          placementId,
          blockComponent.componentForSingleBlockModel(
            blockModelAtXY,
          )!,
          targetPosition,
        );
        addedPositions.add(targetPosition);
      }
    }

    return addedPositions;
  }

  void addSingleBlock(
    String placementId,
    SingleBlockComponent blockComponent,
    IntVector2 position,
  ) {
    _model[position.x][position.y] = GridSingleBlockModel(
      blockComponent: blockComponent,
      placementId: placementId,
    );
    blockComponent.position = Vector2(
      _cellSize * position.x,
      _cellSize * position.y,
    );
    gridComponent.add(blockComponent);
  }

  void removeAll(Iterable<GridSingleBlockModel> blocks) {
    for (var b in blocks) {
      remove(b);
    }
  }

  void remove(GridSingleBlockModel block) {
    for (int x = 0; x < _model.length; x++) {
      for (int y = 0; y < _model[x].length; y++) {
        if (_model[x][y] == block) {
          _model[x][y] = null;
        }
      }
    }
  }

  /// Moves blocks to their target cells. Only the model is changed,
  /// animating the components is up to the caller.
  void applyMoves(Iterable<BlockMove> moves) {
    for (final move in moves) {
      _model[move.from.x][move.from.y] = null;
    }
    for (final move in moves) {
      _model[move.to.x][move.to.y] = move.block;
    }
  }

  set cellSize(double size) {
    _cellSize = size;
  }

  IntVector2? findPositionOfComponent(SingleBlockComponent component) {
    return _positionInGridFinder.findPosition(
      component,
    );
  }

  Vector2 gridPositionToAbsolutePosition(IntVector2 targetPosition) {
    return Vector2(targetPosition.x * _cellSize, targetPosition.y * _cellSize);
  }

  @override
  bool anyPositionBlocked(Iterable<IntVector2> listOfPositions) {
    return listOfPositions.any((position) => isPositionBlocked(position));
  }

  bool isPositionBlocked(IntVector2 gridPosition) {
    if (gridPosition.x >= _model.length || gridPosition.x < 0) {
      log('$gridPosition is out of grid by x');
      return true;
    }

    if (gridPosition.y >= _model[0].length || gridPosition.y < 0) {
      log('$gridPosition is out of grid by y');
      return true;
    }

    final componentAtPosition = _model[gridPosition.x][gridPosition.y];
    if (componentAtPosition == null) {
      return false;
    }
    log('$gridPosition is blocked by $componentAtPosition');
    return true;
  }

  List<List<GridSingleBlockModel?>> get model => _model;

  GridSingleBlockModel? findExistingBlockAt(IntVector2 positionInGrid) {
    if (_model.isEmpty || positionInGrid.x >= _model.length) {
      return null;
    }
    if (positionInGrid.y >= model[0].length) {
      return null;
    }
    return _model[positionInGrid.x][positionInGrid.y];
  }

  ConnectedBlocks findAllConnectedBlocks(
    IntVector2 position,
  ) {
    final modelAtPosition = findExistingBlockAt(position);
    if (modelAtPosition == null) {
      return ConnectedBlocks.empty();
    }
    return ConnectedBlocks(
      horizontal: _findAllConnectedBlocksHorizontally(position),
      vertical: _findAllConnectedBlocksVertically(position),
    );
  }

  List<GridSingleBlockModel> _findAllConnectedBlocksHorizontally(
    IntVector2 position,
  ) {
    var xStarting = 0;
    for (var x = position.x; x >= 0; x--) {
      if (findExistingBlockAt(IntVector2(x, position.y)) != null) {
        xStarting = x;
      } else {
        break;
      }
    }

    final List<GridSingleBlockModel> result = List.empty(growable: true);
    GridSingleBlockModel? found;
    do {
      found = findExistingBlockAt(IntVector2(xStarting, position.y));
      if (found != null) {
        result.add(found);
      }
      xStarting++;
    } while (found != null && xStarting < model.length);
    return result;
  }

  List<GridSingleBlockModel> _findAllConnectedBlocksVertically(
    IntVector2 position,
  ) {
    var yStarting = 0;
    for (var y = position.y; y >= 0; y--) {
      if (findExistingBlockAt(IntVector2(position.x, y)) != null) {
        yStarting = y;
      } else {
        break;
      }
    }

    final List<GridSingleBlockModel> result = List.empty(growable: true);
    GridSingleBlockModel? found;
    do {
      found = findExistingBlockAt(IntVector2(position.x, yStarting));
      if (found != null) {
        result.add(found);
      }
      yStarting++;
    } while (found != null && yStarting < model[position.x].length);
    return result;
  }
}
