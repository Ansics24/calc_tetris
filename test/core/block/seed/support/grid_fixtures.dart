import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/block_tokens.dart';

/// Builds a grid snapshot (indexed `[x][y]`, y grows downwards) from rows of
/// text. A `.` is an empty cell, every other character is a block token.
List<List<MathSingleBlock?>> gridFromRows(List<String> rows) {
  final width = rows.first.length;
  return List.generate(
    width,
    (x) => List.generate(rows.length, (y) {
      final token = rows[y][x];
      return token == '.' ? null : BlockTokens.blockFor(token);
    }),
  );
}
