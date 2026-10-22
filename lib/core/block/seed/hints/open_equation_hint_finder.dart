import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/block_tokens.dart';
import 'package:calc_tetris/core/block/seed/hints/open_equation_hints.dart';
import 'package:calc_tetris/core/math/equation.dart';

/// Looks for empty cells next to existing blocks and finds out which tokens
/// would help to finish an equation there.
class OpenEquationHintFinder {
  /// [grid] is indexed `[x][y]`, y grows downwards.
  OpenEquationHints find(List<List<MathSingleBlock?>> grid) {
    final completions = <String>{};
    final extensions = <String>{};
    if (grid.isEmpty) {
      return OpenEquationHints(
        completions: completions,
        extensions: extensions,
      );
    }
    for (final row in _rows(grid)) {
      _scan(row, requireSupport: false, completions, extensions);
    }
    for (final column in grid) {
      _scan(column, requireSupport: true, completions, extensions);
    }
    return OpenEquationHints(completions: completions, extensions: extensions);
  }

  Iterable<List<MathSingleBlock?>> _rows(List<List<MathSingleBlock?>> grid) {
    return List.generate(
      grid.first.length,
      (y) => List.generate(grid.length, (x) => grid[x][y]),
    );
  }

  void _scan(
    List<MathSingleBlock?> line,
    Set<String> completions,
    Set<String> extensions, {
    required bool requireSupport,
  }) {
    for (var i = 0; i < line.length; i++) {
      if (line[i] != null || !_touchesBlock(line, i)) {
        continue;
      }
      // falling blocks only rest on the floor or on another block
      if (requireSupport && i + 1 < line.length && line[i + 1] == null) {
        continue;
      }
      for (final token in BlockTokens.all) {
        final run = _runWith(line, i, token);
        if (_completesEquation(run)) {
          completions.add(token);
        } else if (_canBePartOfEquation(run)) {
          extensions.add(token);
        }
      }
    }
  }

  bool _touchesBlock(List<MathSingleBlock?> line, int i) {
    return (i > 0 && line[i - 1] != null) ||
        (i + 1 < line.length && line[i + 1] != null);
  }

  /// The connected blocks around [index] if [token] were placed there.
  List<String> _runWith(
    List<MathSingleBlock?> line,
    int index,
    String token,
  ) {
    var start = index;
    while (start > 0 && line[start - 1] != null) {
      start--;
    }
    var end = index;
    while (end + 1 < line.length && line[end + 1] != null) {
      end++;
    }
    return [
      for (var i = start; i <= end; i++) i == index ? token : '${line[i]}',
    ];
  }

  /// Whether the whole run turns into a correct equation. Equations that
  /// only use a part of the run are ignored, they would leave blocks behind.
  bool _completesEquation(List<String> tokens) {
    if (tokens.length < Equation.minLength) {
      return false;
    }
    return Equation.fromBlocks(tokens.map(BlockTokens.blockFor)).isCorrect();
  }

  /// Whether [tokens] could be a part of a valid equation.
  bool _canBePartOfEquation(List<String> tokens) {
    if (tokens.where((t) => t == BlockTokens.equals).length > 1) {
      return false;
    }
    for (var i = 1; i < tokens.length; i++) {
      if (!BlockTokens.isDigit(tokens[i - 1]) &&
          !BlockTokens.isDigit(tokens[i])) {
        return false;
      }
    }
    return true;
  }
}
