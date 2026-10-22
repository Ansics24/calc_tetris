import 'dart:math';

import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/block_tokens.dart';
import 'package:calc_tetris/core/block/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/core/block/seed/hints/open_equation_hint_finder.dart';
import 'package:calc_tetris/core/block/seed/shape_chooser.dart';

/// Generates blocks that are balanced (mostly digits, few symbols) and that
/// often help to complete equations which already exist on the grid.
class GuidedCompoundblockModelGenerator implements CompoundblockModelGenerator {
  final List<List<MathSingleBlock?>> Function() _gridContent;
  final ShapeChooser _shapeChooser;
  final Random _random;
  final OpenEquationHintFinder _hintFinder;
  final double _hintChance;

  GuidedCompoundblockModelGenerator({
    required List<List<MathSingleBlock?>> Function() gridContent,
    ShapeChooser? shapeChooser,
    Random? random,
    OpenEquationHintFinder? hintFinder,
    double hintChance = 0.9,
  }) : _gridContent = gridContent,
       _shapeChooser = shapeChooser ?? ShapeChooser(),
       _random = random ?? Random(),
       _hintFinder = hintFinder ?? OpenEquationHintFinder(),
       _hintChance = hintChance;

  @override
  List<List<MathSingleBlock>> generate() {
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
      tokens.add(_randomDigit());
    }
    final hasSymbol = hint != null && !BlockTokens.isDigit(hint);
    if (!hasSymbol && _random.nextBool()) {
      // replace a generated digit, never the hint
      tokens[tokens.length - 1] = _randomSymbol();
    }
    return tokens..shuffle(_random);
  }

  String? _pickHint() {
    final hints = _hintFinder.find(_gridContent());
    final candidates = hints.completions.isNotEmpty
        ? hints.completions
        : hints.extensions;
    if (candidates.isEmpty) {
      return null;
    }
    return candidates.elementAt(_random.nextInt(candidates.length));
  }

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
