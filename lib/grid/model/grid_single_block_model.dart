import 'package:magic_blocks/block/single_block_component.dart';

class GridSingleBlockModel {
  final SingleBlockComponent _blockComponent;

  /// Identifies the compound block placement this block belongs to. All
  /// single blocks of one landed compound block share the same id.
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
