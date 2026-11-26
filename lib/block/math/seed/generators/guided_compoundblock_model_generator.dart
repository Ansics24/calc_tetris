import 'dart:math';

import 'package:magic_blocks/block/math/model/math_single_block.dart';
import 'package:magic_blocks/block/math/seed/block_tokens.dart';
import 'package:magic_blocks/block/math/seed/compoundblock_model_generator.dart';
import 'package:magic_blocks/block/math/seed/hints/open_equation_hint_finder.dart';
import 'package:magic_blocks/block/model/single_block.dart';
import 'package:magic_blocks/block/shapes/shape_chooser.dart';

/// Generates blocks that are balanced (mostly digits, few symbols) and that
/// often help to complete equations which already exist on the grid.
class GuidedCompoundblockModelGenerator implements CompoundblockModelGenerator {
  final List<List<SingleBlock?>> Function() _gridContent;
  final ShapeChooser _shapeChooser;
  final Random _random;
  final OpenEquationHintFinder _hintFinder;
  final double _hintChance;

  GuidedCompoundblockModelGenerator({
    required this._gridContent,
    ShapeChooser? shapeChooser,
    Random? random,
    OpenEquationHintFinder? hintFinder,
    this._hintChance = 0.8,
  }) : _shapeChooser = shapeChooser ?? ShapeChooser(),
       _random = random ?? Random(),
       _hintFinder = hintFinder ?? OpenEquationHintFinder();

  @override
  List<List<SingleBlock>> generate() {
    final maskedModel = _shapeChooser.next().maskedModel;
    final slotCount = maskedModel
        .expand((column) => column)
        .where((block) => block == null)
        .length;
    final tokens = _chooseTokens(slotCount).iterator;
    return [
      for (final column in maskedModel)
        [
          for (final block in column)
            block ?? (tokens..moveNext()).current.toBlock(),
        ],
    ];
  }

  List<String> _chooseTokens(int count) {
    final hint = _random.nextDouble() < _hintChance ? _pickHint() : null;
    if (count == 1) {
      return [hint ?? _randomSingleToken()];
    }
    final tokens = [?hint];
    while (tokens.length < count) {
      tokens.add(_randomSingleToken());
    }
    final hasSymbol = hint != null && !BlockTokens.isDigit(hint);
    if (!hasSymbol && _random.nextBool()) {
      // replace a generated digit, never the hint
      tokens[tokens.length - 1] = _randomSymbol();
    }
    if (!tokens.any(BlockTokens.isDigit)) {
      // a block of only symbols can never help; replace a filler, not the hint
      tokens[tokens.length - 1] = _randomDigit();
    }
    return tokens..shuffle(_random);
  }

  /// A token that helps with an open equation: the one that earns the most
  /// points among the completions, or among the partial completions if there
  /// is no completion. Extensions are picked at random.
  String? _pickHint() {
    final hints = _hintFinder.find(_gridContent());
    if (hints.completions.isNotEmpty) {
      return _pickBest(hints.completions, hints.completionPoints);
    }
    if (hints.partialCompletions.isNotEmpty) {
      return _pickBest(hints.partialCompletions, hints.partialCompletionPoints);
    }
    if (hints.extensions.isEmpty) {
      return null;
    }
    return _pickRandom(hints.extensions);
  }

  /// One of the candidates with the most points, picked at random if several
  /// earn the same. Candidates without known points count as 0.
  String _pickBest(Set<String> candidates, Map<String, int> points) {
    final best = candidates.map((c) => points[c] ?? 0).reduce(max);
    return _pickRandom(
      candidates.where((c) => (points[c] ?? 0) == best).toList(),
    );
  }

  String _pickRandom(Iterable<String> candidates) =>
      candidates.elementAt(_random.nextInt(candidates.length));

  String _randomSingleToken() {
    final roll = _random.nextInt(100);
    if (roll < 60) {
      return _randomDigit();
    }
    return roll < 85 ? _randomOperator() : BlockTokens.equals;
  }

  String _randomSymbol() {
    return _random.nextInt(100) < 65 ? _randomOperator() : BlockTokens.equals;
  }

  String _randomDigit() =>
      BlockTokens.digits[_random.nextInt(BlockTokens.digits.length)];

  String _randomOperator() =>
      BlockTokens.operators[_random.nextInt(BlockTokens.operators.length)];
}

extension on String {
  MathSingleBlock toBlock() => BlockTokens.blockFor(this);
}
