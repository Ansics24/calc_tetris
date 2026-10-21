import 'dart:async';

import 'package:calc_tetris/core/block/math_single_block_component_factory.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/spawn_origin.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Shows the upcoming compound block, a bit smaller than it will be in the
/// grid.
class NextBlockDisplay extends PositionComponent implements SpawnOrigin {
  static const double previewScale = 0.8;
  static const String labelText = 'Nächster Block';

  /// Edge length of a cell as it is in the grid, i.e. before scaling.
  final double _gridCellSize;
  List<List<MathSingleBlock>> _model;
  final PositionComponent _content = PositionComponent();

  NextBlockDisplay({
    required double cellSize,
    required List<List<MathSingleBlock>> model,
    super.size,
    super.position,
    super.anchor,
  }) : _gridCellSize = cellSize,
       _model = model {
    _content.scale = Vector2.all(previewScale);
    _layoutContent();
  }

  @override
  FutureOr<void> onLoad() {
    add(
      TextComponent(
        text: labelText,
        textRenderer: TextPaint(
          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
        ),
        position: Vector2(size.x / 2, 0),
        anchor: Anchor.topCenter,
      ),
    );
    add(_content);
    _populateContent();
    return super.onLoad();
  }

  set model(List<List<MathSingleBlock>> model) {
    _model = model;
    _layoutContent();
    if (isLoaded) {
      _content.removeAll(_content.children);
      _populateContent();
    }
  }

  /// On-screen size of one cell.
  @override
  double get cellSize => _gridCellSize * previewScale;

  double get previewCellSize => cellSize;

  /// On-screen size of the whole shown block.
  Vector2 get previewBlockSize =>
      Vector2(_model.length * cellSize, _model[0].length * cellSize);

  Vector2 get previewBlockAbsoluteTopLeft =>
      absoluteTopLeftPosition + (size - previewBlockSize) / 2;

  @override
  Vector2 get absoluteTopLeft => previewBlockAbsoluteTopLeft;

  void _layoutContent() {
    _content.size = Vector2(
      _model.length * _gridCellSize,
      _model[0].length * _gridCellSize,
    );
    _content.position = (size - previewBlockSize) / 2;
  }

  void _populateContent() {
    for (var x = 0; x < _model.length; x++) {
      for (var y = 0; y < _model[x].length; y++) {
        final component = newComponentFromBlockModel(
          _model[x][y],
          cellSize: _gridCellSize,
        );
        if (component == null) {
          continue;
        }
        component.position = Vector2(x * _gridCellSize, y * _gridCellSize);
        _content.add(component);
      }
    }
  }
}
