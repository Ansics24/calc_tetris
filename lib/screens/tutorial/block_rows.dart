import 'package:magic_blocks/block/math/seed/block_tokens.dart';
import 'package:magic_blocks/block/model/single_block.dart';

/// Builds blocks from rows of text, indexed `[x][y]` with y growing
/// downwards. A `.` is an empty cell, every other character is a block token
/// (digit, `+`, `-` or `=`). All rows need the same length.
List<List<SingleBlock?>> blocksFromRows(List<String> rows) {
  final width = rows.first.length;
  return List.generate(
    width,
    (x) => List.generate(rows.length, (y) {
      final token = rows[y][x];
      return token == '.' ? null : BlockTokens.blockFor(token);
    }),
  );
}
