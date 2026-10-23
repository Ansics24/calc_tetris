import 'package:calc_tetris/block/single_block_component.dart';

class GridSingleBlockModel {
  final SingleBlockComponent _blockComponent;
  final String _placementId;

  GridSingleBlockModel({
    required this._blockComponent,
    required this._placementId,
  });

  SingleBlockComponent get component => _blockComponent;

  String get placementId => _placementId;

  @override
  toString() {
    return '$placementId mit Model "${_blockComponent.model}"';
  }
}
