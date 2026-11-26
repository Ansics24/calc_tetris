import 'package:magic_blocks/block/math/seed/compoundblock_model_generator.dart';
import 'package:magic_blocks/block/model/null_block.dart';
import 'package:magic_blocks/block/model/single_block.dart';
import 'package:magic_blocks/screens/tutorial/block_rows.dart';

/// Always generates the same prepared block, described by rows of text (see
/// [blocksFromRows]). Every call returns a fresh copy with new ids.
class ScriptedBlockGenerator implements CompoundblockModelGenerator {
  final List<String> _rows;

  ScriptedBlockGenerator(this._rows);

  @override
  List<List<SingleBlock>> generate() => [
    for (final column in blocksFromRows(_rows))
      [for (final block in column) block ?? NullBlock()],
  ];
}
