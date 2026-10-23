import 'package:calc_tetris/core/block/appearance/block_tile.dart';
import 'package:calc_tetris/core/block/appearance/tile_colors.dart';
import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';

class MathOperantBlockComponent
    extends MathSingleBlockComponent<MathOperantBlock> {
  final MathOperantBlock _model;

  MathOperantBlockComponent({required this._model, super.cellSize});

  bool get _isPlus => _model.type == MathOperandType.plus;

  @override
  void onLoad() async {
    await super.onLoad();
    add(
      BlockTile(
        color: _isPlus ? TileColors.plus : TileColors.minus,
        symbol: _isPlus ? '+' : '−',
        size: size,
      ),
    );
  }

  @override
  MathOperantBlock get model => _model;
}
