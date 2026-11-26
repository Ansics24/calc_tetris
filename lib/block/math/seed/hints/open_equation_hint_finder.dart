import 'dart:math';

import 'package:magic_blocks/block/math/model/equation.dart';
import 'package:magic_blocks/block/math/scoring/digit_multiplier_score_calculator.dart';
import 'package:magic_blocks/block/math/scoring/score_calculator.dart';
import 'package:magic_blocks/block/math/seed/block_tokens.dart';
import 'package:magic_blocks/block/math/seed/hints/open_equation_hints.dart';
import 'package:magic_blocks/block/model/single_block.dart';

/// Looks for empty cells next to existing blocks and finds out which tokens
/// would help to finish an equation there.
class OpenEquationHintFinder {
  final ScoreCalculator _scoreCalculator;

  OpenEquationHintFinder({ScoreCalculator? scoreCalculator})
    : _scoreCalculator = scoreCalculator ?? DigitMultiplierScoreCalculator();

  /// [grid] is indexed `[x][y]`, y grows downwards.
  OpenEquationHints find(List<List<SingleBlock?>> grid) {
    final completions = <String, int>{};
    final partials = <String, int>{};
    final extensions = <String>{};
    if (grid.isEmpty) {
      return OpenEquationHints(completions: {}, extensions: extensions);
    }
    // rows are read from left to right, columns from top to bottom
    for (final line in [..._rows(grid), ...grid]) {
      _scan(line, completions, partials, extensions);
    }
    return OpenEquationHints(
      completions: completions.keys.toSet(),
      completionPoints: completions,
      partialCompletions: partials.keys.toSet(),
      partialCompletionPoints: partials,
      extensions: extensions,
    );
  }

  Iterable<List<SingleBlock?>> _rows(List<List<SingleBlock?>> grid) {
    return List.generate(
      grid.first.length,
      (y) => List.generate(grid.length, (x) => grid[x][y]),
    );
  }

  void _scan(
    List<SingleBlock?> line,
    Map<String, int> completions,
    Map<String, int> partialCompletions,
    Set<String> extensions,
  ) {
    for (var i = 0; i < line.length; i++) {
      if (line[i] != null || !_touchesBlock(line, i)) {
        continue;
      }
      for (final token in BlockTokens.all) {
        final run = _runWith(line, i, token);
        final partialPoints = _bestPartialPoints(run, i - _runStart(line, i));
        if (_completesEquation(run)) {
          _keepBest(completions, token, _points(run));
        } else if (partialPoints != null) {
          _keepBest(partialCompletions, token, partialPoints);
        } else if (_canBePartOfEquation(run)) {
          extensions.add(token);
        }
      }
    }
  }

  void _keepBest(Map<String, int> points, String token, int value) {
    points[token] = max(points[token] ?? 0, value);
  }

  int _points(List<String> tokens) => _scoreCalculator.calculate(
    Equation.fromBlocks(tokens.map(BlockTokens.blockFor)),
  );

  int _runStart(List<SingleBlock?> line, int index) {
    var start = index;
    while (start > 0 && line[start - 1] != null) {
      start--;
    }
    return start;
  }

  bool _touchesBlock(List<SingleBlock?> line, int i) {
    return (i > 0 && line[i - 1] != null) ||
        (i + 1 < line.length && line[i + 1] != null);
  }

  /// The connected blocks around [index] if [token] were placed there.
  List<String> _runWith(
    List<SingleBlock?> line,
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

  /// The points of the best correct equation that is a part of the run and
  /// includes the token at [tokenIndex], or null if there is none.
  int? _bestPartialPoints(List<String> tokens, int tokenIndex) {
    int? best;
    for (var start = 0; start <= tokenIndex; start++) {
      for (var end = tokenIndex + 1; end <= tokens.length; end++) {
        final part = tokens.sublist(start, end);
        if (_completesEquation(part)) {
          best = max(best ?? 0, _points(part));
        }
      }
    }
    return best;
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
