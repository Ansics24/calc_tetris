import 'package:calc_tetris/core/block/math_single_block_component.dart';

class GridSingleBlockModel {
  final MathSingleBlockComponent _blockComponent;
  final String _placementId;

  GridSingleBlockModel({
    required this._blockComponent,
    required this._placementId,
  });

  MathSingleBlockComponent get component => _blockComponent;

  String get placementId => _placementId;
}
