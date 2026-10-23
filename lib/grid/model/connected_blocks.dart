import 'package:calc_tetris/grid/model/grid_single_block_model.dart';

class ConnectedBlocks {
  final List<GridSingleBlockModel> _horizontal;
  final List<GridSingleBlockModel> _vertical;

  ConnectedBlocks({required this._horizontal, required this._vertical});

  ConnectedBlocks.empty()
    : _horizontal = List.empty(),
      _vertical = List.empty();

  List<GridSingleBlockModel> get horizontal => _horizontal;
  List<GridSingleBlockModel> get vertical => _vertical;

  bool get isEmpty => _horizontal.isEmpty && _vertical.isEmpty;
}
