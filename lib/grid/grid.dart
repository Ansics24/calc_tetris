import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/single_block_component_factory.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/grid/visuals/grid_frame.dart';
import 'package:calc_tetris/grid/visuals/grid_line.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class Grid extends PositionComponent with TapCallbacks {
  final IntVector2 _blockCount;
  double _cellSize = 0;
  late final GridModel _gridModel;
  late final GridController _gridController;
  final SingleBlockComponentFactory _singleBlockComponentFactory;
  final List<List<SingleBlock?>>? _initialContent;

  Grid({
    required this._blockCount,
    required this._singleBlockComponentFactory,
    required GridControllerFactory controllerFactory,
    GridContentHolder? gridContentHolder,
    this._initialContent,
    super.size,
    super.position,
  }) {
    _gridModel = GridModel(
      size: _blockCount,
      gridComponent: this,
    );
    gridContentHolder?.attach(_gridModel);
    _gridController = controllerFactory(_gridModel, this);
  }

  /// The grid is given the area it may use ([size] and [position]). Once
  /// loaded it makes its cells as big as the area allows, centers itself in
  /// the area and takes the size of its cells as its own.
  @override
  FutureOr<void> onLoad() {
    final boardSize = size.clone();
    final boardPosition = position.clone();

    final double calcCellSizeBasedOnY = boardSize.y / _blockCount.y;
    final double calcCellSizeBasedOnX = boardSize.x / _blockCount.x;
    _cellSize = min(calcCellSizeBasedOnX, calcCellSizeBasedOnY);
    _gridModel.cellSize = _cellSize;

    final gridSize = Vector2(
      _cellSize * _blockCount.x,
      _cellSize * _blockCount.y,
    );
    size = gridSize;
    position = boardPosition + (boardSize - gridSize) / 2;

    dev.log('Cell based on x: $calcCellSizeBasedOnX');
    dev.log('Cell based on y: $calcCellSizeBasedOnY');
    dev.log('Cell size used: $_cellSize');
    dev.log('BoardSize: $boardSize');
    dev.log('Position of Grid: $position');

    addGridVisualization();
    _placeInitialContent();

    _gridController.spawnNextBlock();

    return super.onLoad();
  }

  /// Puts the blocks the grid starts with in place, before the first spawn.
  void _placeInitialContent() {
    final content = _initialContent;
    if (content == null) {
      return;
    }
    for (var x = 0; x < content.length; x++) {
      for (var y = 0; y < content[x].length; y++) {
        final block = content[x][y];
        final component = block == null
            ? null
            : _singleBlockComponentFactory(block);
        if (component != null) {
          _gridModel.addSingleBlock('initial', component, IntVector2(x, y));
        }
      }
    }
  }

  void addGridVisualization() {
    add(
      GridFrame(
        size: Vector2(_blockCount.x * _cellSize, _blockCount.y * _cellSize),
      ),
    );
    for (var i = 0; i <= _blockCount.x; i++) {
      add(
        GridLine(
          Vector2(
            i * _cellSize,
            0,
          ),
          Vector2(
            i * _cellSize,
            _blockCount.y * _cellSize,
          ),
        ),
      );
    }
    for (var i = 0; i <= _blockCount.y; i++) {
      add(
        GridLine(
          Vector2(
            0,
            i * _cellSize,
          ),
          Vector2(_blockCount.x * _cellSize, i * _cellSize),
        ),
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    final position = event.localPosition;
    _gridController.onCellTapped(
      IntVector2(
        (position.x / _cellSize).floor(),
        (position.y / _cellSize).floor(),
      ),
    );
  }

  double get cellSize => _cellSize;

  IntVector2 get gridSize =>
      IntVector2(_gridModel.model.length, _gridModel.model[0].length);

  GridController get controller => _gridController;
}
