import 'dart:math';

import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/model/null_block.dart';
import 'package:calc_tetris/core/block/seed/generators/guided_compoundblock_model_generator.dart';
import 'package:calc_tetris/core/block/seed/shape_chooser.dart';
import 'package:calc_tetris/core/block/seed/shapes/compound_block_shape.dart';
import 'package:test/test.dart';

import '../support/grid_fixtures.dart';

class _FixedShapeChooser implements ShapeChooser {
  final CompoundBlockShape shape;

  _FixedShapeChooser(this.shape);

  @override
  CompoundBlockShape next() => shape;
}

List<String> _tokensOf(List<List<MathSingleBlock>> model) => model
    .expand((column) => column)
    .where((block) => block is! NullBlock)
    .map((block) => block.toString())
    .toList();

bool _isDigit(String token) => RegExp(r'^\d$').hasMatch(token);

GuidedCompoundblockModelGenerator _generator({
  CompoundBlockShape shape = CompoundBlockShape.i1x1,
  List<String> Function()? gridRows,
  double hintChance = 0.7,
  int seed = 42,
}) {
  return GuidedCompoundblockModelGenerator(
    gridContent: () => gridFromRows(gridRows?.call() ?? ['.....']),
    shapeChooser: _FixedShapeChooser(shape),
    random: Random(seed),
    hintChance: hintChance,
  );
}

void main() {
  group('block content', () {
    test('keeps the layout of the chosen shape', () {
      final model = _generator(shape: CompoundBlockShape.l2x2l).generate();

      final expected = CompoundBlockShape.l2x2l.maskedModel;
      expect(model.length, expected.length);
      for (var x = 0; x < model.length; x++) {
        for (var y = 0; y < model[x].length; y++) {
          expect(model[x][y] is NullBlock, expected[x][y] is NullBlock);
        }
      }
    });

    test('only generates digits 0-9, plus, minus and equals', () {
      final generator = GuidedCompoundblockModelGenerator(
        gridContent: () => gridFromRows(['.....']),
        random: Random(1),
      );

      final tokens = List.generate(
        500,
        (_) => _tokensOf(generator.generate()),
      ).expand((t) => t).toSet();

      expect(tokens, everyElement(matches(RegExp(r'^[0-9+\-=]$'))));
      expect(tokens.where(_isDigit).length, 10);
    });

    test('generates a fresh block instance on every call', () {
      final generator = _generator();

      final first = generator.generate().first.first;
      final second = generator.generate().first.first;

      expect(first.id, isNot(second.id));
    });
  });

  group('distribution', () {
    test('mostly generates digits for single blocks', () {
      final generator = _generator(hintChance: 0);

      final tokens = List.generate(
        2000,
        (_) => _tokensOf(generator.generate()).single,
      );

      final digitShare = tokens.where(_isDigit).length / tokens.length;
      final equalsShare = tokens.where((t) => t == '=').length / tokens.length;
      expect(digitShare, greaterThan(0.5));
      expect(equalsShare, lessThan(0.25));
      expect(equalsShare, greaterThan(0.05));
    });

    test('never creates blocks that consist only of symbols', () {
      for (final shape in [CompoundBlockShape.i2x1, CompoundBlockShape.l2x2l]) {
        final generator = _generator(shape: shape, hintChance: 0);

        for (var i = 0; i < 1000; i++) {
          final tokens = _tokensOf(generator.generate());
          expect(tokens.where(_isDigit), isNotEmpty, reason: '$tokens');
        }
      }
    });

    test('puts at most one symbol into a multi block', () {
      for (final shape in [CompoundBlockShape.i2x1, CompoundBlockShape.l2x2l]) {
        final generator = _generator(shape: shape, hintChance: 0);

        for (var i = 0; i < 1000; i++) {
          final tokens = _tokensOf(generator.generate());
          expect(
            tokens.where((t) => !_isDigit(t)).length,
            lessThanOrEqualTo(1),
            reason: '$tokens',
          );
        }
      }
    });
  });

  group('guided by the grid', () {
    test('completes an open equation when the hint always applies', () {
      final generator = _generator(
        gridRows: () => ['1+2=.'],
        hintChance: 1,
      );

      for (var i = 0; i < 50; i++) {
        expect(_tokensOf(generator.generate()), ['3']);
      }
    });

    test('completes an equation inside a longer row of blocks', () {
      final generator = _generator(
        gridRows: () => ['=8+1=.'],
        hintChance: 1,
      );

      final tokens = List.generate(
        50,
        (_) => _tokensOf(generator.generate()).single,
      );

      expect(tokens, everyElement(isIn(['1', '9'])));
      expect(tokens, contains('9'));
    });

    test('ignores the grid when hints are disabled', () {
      final generator = _generator(
        gridRows: () => ['1+2=.'],
        hintChance: 0,
      );

      final tokens = List.generate(
        200,
        (_) => _tokensOf(generator.generate()).single,
      );

      expect(tokens.toSet().length, greaterThan(1));
    });

    test('completes open equations more often than not by default', () {
      final generator = GuidedCompoundblockModelGenerator(
        gridContent: () => gridFromRows(['1+2=.']),
        shapeChooser: _FixedShapeChooser(CompoundBlockShape.i1x1),
        random: Random(7),
      );

      final tokens = List.generate(
        1000,
        (_) => _tokensOf(generator.generate()).single,
      );

      expect(tokens.where((t) => t == '3').length, greaterThan(500));
    });

    test('includes the completing token in a multi block', () {
      final generator = _generator(
        shape: CompoundBlockShape.l2x2l,
        gridRows: () => ['1+2=.'],
        hintChance: 1,
      );

      for (var i = 0; i < 100; i++) {
        expect(_tokensOf(generator.generate()), contains('3'));
      }
    });

    test('fills the remaining slots with digits next to a needed symbol', () {
      final generator = _generator(
        shape: CompoundBlockShape.l2x2l,
        gridRows: () => ['1+2.3'],
        hintChance: 1,
      );

      for (var i = 0; i < 100; i++) {
        final tokens = _tokensOf(generator.generate());
        expect(tokens.where((t) => t == '=').length, 1);
        expect(tokens.where(_isDigit).length, 2);
      }
    });

    test('falls back to extending an equation without a completion', () {
      final generator = _generator(
        gridRows: () => ['1+.'],
        hintChance: 1,
      );

      for (var i = 0; i < 100; i++) {
        expect(_isDigit(_tokensOf(generator.generate()).single), isTrue);
      }
    });

    test('looks at the current grid on every call', () {
      var rows = ['1+2=.'];
      final generator = _generator(gridRows: () => rows, hintChance: 1);

      expect(_tokensOf(generator.generate()), ['3']);

      rows = ['3+4=.'];
      expect(_tokensOf(generator.generate()), ['7']);
    });
  });
}
