import 'package:calc_tetris/block/math/model/equation.dart';
import 'package:calc_tetris/block/math/scoring/score_calculator.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';

import 'sample_grids/sample_grid_7x7.dart';

void main() {
  final strategy = ValidEquationSolutionStrategy();

  final gridModel = get7x7SampleModel();

  group('no valid equation', () {
    test('too few blocks', () {
      var solvedBlocks = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(2, 5)],
      );
      expect(solvedBlocks.solvedBlocks, isEmpty);
    });

    test('invalid horizontal equation', () {
      var solvedBlocks = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(2, 3)],
      );
      expect(solvedBlocks.solvedBlocks, isEmpty);
    });

    test('invalid vertical equation', () {
      var solvedBlocks = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(6, 1)],
      );
      expect(solvedBlocks.solvedBlocks, isEmpty);
    });

    test('detects horizonal 5+3=8 on single target block', () {
      var solvedBlocks = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(2, 2)],
      );
      expect(solvedBlocks.solvedBlocks, hasLength(5));
      expect(
        solvedBlocks.solvedBlocks
            .map((e) => e.component)
            .map((c) => c.model.toString())
            .join(''),
        equals("5+3=8"),
      );
    });

    test('detects vertical 2+4=6 on single target block', () {
      var solvedBlocks = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(1, 1)],
      );
      expect(solvedBlocks.solvedBlocks, hasLength(5));
      expect(
        solvedBlocks.solvedBlocks
            .map((e) => e.component)
            .map((c) => c.model.toString())
            .join(''),
        equals("2+4=6"),
      );
    });

    test(
      'detects vertical 2+4=6 and horizontal 5+3=8 on two target blocks',
      () {
        var solvedBlocks = strategy.execute(
          gridModel,
          triggeringPositions: [IntVector2(1, 1), IntVector2(1, 2)],
        );
        expect(solvedBlocks.solvedBlocks, hasLength(9));
        expect(
          solvedBlocks.solvedBlocks
              .map((e) => e.component)
              .map((c) => c.model.toString())
              .join(''),
          equals("5+3=824=6"), // + at 1/2 is not detected twice
        );
      },
    );
  });

  group('points earned', () {
    test('no equation earns 0 points', () {
      final result = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(2, 3)],
      );
      expect(result.pointsEarned, 0);
    });

    test('horizontal 5+3=8 earns 6 points', () {
      final result = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(2, 2)],
      );
      expect(result.pointsEarned, 6);
    });

    test('same equation hit by two triggering blocks is scored once', () {
      final result = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(0, 2), IntVector2(2, 2)],
      );
      expect(result.pointsEarned, 6);
    });

    test('horizontal and vertical equation are both scored', () {
      final result = strategy.execute(
        gridModel,
        triggeringPositions: [IntVector2(1, 1), IntVector2(1, 2)],
      );
      expect(result.pointsEarned, 12);
    });

    test('uses the injected score calculator once per equation', () {
      final custom = ValidEquationSolutionStrategy(
        scoreCalculator: _FixedScoreCalculator(7),
      );
      final result = custom.execute(
        gridModel,
        triggeringPositions: [IntVector2(1, 1), IntVector2(1, 2)],
      );
      expect(result.pointsEarned, 14);
    });
  });
}

class _FixedScoreCalculator implements ScoreCalculator {
  final int points;

  _FixedScoreCalculator(this.points);

  @override
  int calculate(Equation equation) => points;
}
