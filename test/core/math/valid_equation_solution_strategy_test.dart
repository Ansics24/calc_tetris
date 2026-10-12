import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/math/valid_equation_solution_strategy.dart';
import 'package:test/test.dart';

import 'sample_grids/sample_grid_7x7.dart';

void main() {
  final strategy = ValidEquationSolutionStrategy();

  final gridModel = get7x7SampleModel();

  group('no valid equation', () {
    test('too few blocks', () {
      var solvedBlocks = strategy.findSolvedBlocks(
        gridModel,
        triggeringPositions: [IntVector2(2, 5)],
      );
      expect(solvedBlocks, isEmpty);
    });

    test('invalid horizontal equation', () {
      var solvedBlocks = strategy.findSolvedBlocks(
        gridModel,
        triggeringPositions: [IntVector2(2, 3)],
      );
      expect(solvedBlocks, isEmpty);
    });

    test('invalid vertical equation', () {
      var solvedBlocks = strategy.findSolvedBlocks(
        gridModel,
        triggeringPositions: [IntVector2(6, 1)],
      );
      expect(solvedBlocks, isEmpty);
    });

    test('detects horizonal 5+3=8 on single target block', () {
      var solvedBlocks = strategy.findSolvedBlocks(
        gridModel,
        triggeringPositions: [IntVector2(2, 2)],
      );
      expect(solvedBlocks, hasLength(5));
      expect(
        solvedBlocks
            .map((e) => e.component)
            .map((c) => c.model.toString())
            .join(''),
        equals("5+3=8"),
      );
    });

    test('detects vertical 2+4=6 on single target block', () {
      var solvedBlocks = strategy.findSolvedBlocks(
        gridModel,
        triggeringPositions: [IntVector2(1, 1)],
      );
      expect(solvedBlocks, hasLength(5));
      expect(
        solvedBlocks
            .map((e) => e.component)
            .map((c) => c.model.toString())
            .join(''),
        equals("5+3=8"),
      );
    });

    test(
      'detects vertical 2+4=6 and horizontal 5+3=8 on two target blocks',
      () {
        var solvedBlocks = strategy.findSolvedBlocks(
          gridModel,
          triggeringPositions: [IntVector2(1, 1), IntVector2(1, 2)],
        );
        expect(solvedBlocks, hasLength(5));
        expect(
          solvedBlocks
              .map((e) => e.component)
              .map((c) => c.model.toString())
              .join(''),
          equals("5+3=824=6"), // + at 1/2 is not detected twice
        );
      },
    );
  });
}
