import 'package:calc_tetris/block/math/model/equation.dart';
import 'package:calc_tetris/block/math/scoring/score_calculator.dart';
import 'package:calc_tetris/block/math/seed/hints/open_equation_hint_finder.dart';
import 'package:calc_tetris/block/math/seed/hints/open_equation_hints.dart';
import 'package:test/test.dart';

import '../support/grid_fixtures.dart';

class _ConstantScore implements ScoreCalculator {
  final int points;

  _ConstantScore(this.points);

  @override
  int calculate(Equation equation) => points;
}

void main() {
  final finder = OpenEquationHintFinder();

  group('completions', () {
    test('finds the token that completes a row at its right end', () {
      final hints = finder.find(gridFromRows(['1+2=.']));

      expect(hints.completions, {'3'});
    });

    test('finds the token that completes a row at its left end', () {
      final hints = finder.find(gridFromRows(['.+2=3']));

      expect(hints.completions, {'1'});
    });

    test('finds the token that fills a gap inside a row', () {
      final hints = finder.find(gridFromRows(['1+.=3']));

      expect(hints.completions, {'2'});
    });

    test('finds the equals sign when the numbers are already there', () {
      final hints = finder.find(gridFromRows(['1+2.3']));

      expect(hints.completions, {'='});
    });

    test('finds the token that completes a column on top of its stack', () {
      final hints = finder.find(gridFromRows(['.', '+', '2', '=', '3']));

      expect(hints.completions, {'1'});
    });

    test('ignores column cells the falling block could not rest on', () {
      final hints = finder.find(
        gridFromRows(['1', '+', '2', '=', '.', '.']),
      );

      expect(hints.completions, isEmpty);
    });

    test('offers the same token for every possible completion', () {
      final hints = finder.find(
        gridFromRows([
          '1+2=.',
          '.....',
          '4-1=.',
        ]),
      );

      expect(hints.completions, {'3'});
    });

    test('completes an equation that contains multi digit numbers', () {
      final hints = finder.find(gridFromRows(['24+12=3.']));

      expect(hints.completions, {'6'});
    });

    test('completes a multi digit number in the middle of an equation', () {
      final hints = finder.find(gridFromRows(['24+12=3.+0']));

      expect(hints.completions, {'6'});
    });

    test('finds no completion when two or more tokens are missing', () {
      final hints = finder.find(gridFromRows(['24+12=10+..']));

      expect(hints.completions, isEmpty);
    });

    test('keeps whole-row completions separate from partial ones', () {
      final hints = finder.find(gridFromRows(['1+2=.']));

      expect(hints.completions, {'3'});
    });

    test('completes an equation that sits inside a longer row of blocks', () {
      final hints = finder.find(gridFromRows(['=8+1=.']));

      expect(hints.partialCompletions, contains('9'));
    });

    test('completes an equation that has stray blocks on both sides', () {
      final hints = finder.find(gridFromRows(['7=8+1=.-']));

      expect(hints.partialCompletions, contains('9'));
    });

    test('has no completions on an empty grid', () {
      final hints = finder.find(gridFromRows(['.....', '.....']));

      expect(hints.completions, isEmpty);
    });
  });

  group('extensions', () {
    test('offers digits after an operator', () {
      final hints = finder.find(gridFromRows(['1+.']));

      expect(hints.extensions, containsAll(['0', '5', '9']));
      expect(hints.extensions, isNot(contains('+')));
      expect(hints.extensions, isNot(contains('-')));
      expect(hints.extensions, isNot(contains('=')));
    });

    test('offers operators and equals sign after a number', () {
      final hints = finder.find(gridFromRows(['1+2.']));

      expect(hints.extensions, containsAll(['+', '-', '=', '5']));
    });

    test('does not offer a second equals sign', () {
      final hints = finder.find(gridFromRows(['1=1.']));

      expect(hints.extensions, isNot(contains('=')));
    });

    test('has no extensions on an empty grid', () {
      final hints = finder.find(gridFromRows(['.....', '.....']));

      expect(hints.extensions, isEmpty);
    });
  });

  group('points of the completions', () {
    test('are the points the completed equation earns', () {
      final hints = finder.find(gridFromRows(['1+2=.']));

      expect(hints.completionPoints, {'3': 6});
    });

    test('count every number of the equation', () {
      final hints = finder.find(gridFromRows(['1+2+3=.']));

      expect(hints.completionPoints, {'6': 8});
    });

    test('count the digits of multi digit numbers', () {
      final hints = finder.find(gridFromRows(['24+12=3.']));

      // three numbers, two digits each for 24, 12 and 36: 3 * 2 * (2+2+2)
      expect(hints.completionPoints, {'6': 36});
    });

    test('tell the better completion apart from the worse one', () {
      final hints = finder.find(
        gridFromRows([
          '1+2+3=.',
          '.......',
          '2+3=...',
        ]),
      );

      expect(hints.completionPoints['6'], 8);
      expect(hints.completionPoints['5'], 6);
    });

    test('keep the best points when a token completes several equations', () {
      final hints = finder.find(
        gridFromRows([
          '1+2=...',
          '.......',
          '1+1+1=.',
        ]),
      );

      expect(hints.completions, contains('3'));
      expect(hints.completionPoints['3'], 8);
    });

    test('exist for every completion', () {
      final hints = finder.find(
        gridFromRows(['1+2=.', '.....', '9-4=.', '.....', '1+.=3']),
      );

      expect(hints.completionPoints.keys.toSet(), hints.completions);
    });

    test('use the given score calculator', () {
      final hints = OpenEquationHintFinder(
        scoreCalculator: _ConstantScore(100),
      ).find(gridFromRows(['1+2=.']));

      expect(hints.completionPoints, {'3': 100});
    });

    test('are empty on an empty grid', () {
      final hints = finder.find(gridFromRows(['.....', '.....']));

      expect(hints.completionPoints, isEmpty);
      expect(hints.partialCompletionPoints, isEmpty);
    });
  });

  group('points of the partial completions', () {
    test('are the points of the equation inside the longer row', () {
      final hints = finder.find(gridFromRows(['=8+1=.']));

      expect(hints.partialCompletionPoints['9'], 6);
    });

    test('exist for every partial completion', () {
      final hints = finder.find(gridFromRows(['7=8+1=.-']));

      expect(
        hints.partialCompletionPoints.keys.toSet(),
        hints.partialCompletions,
      );
    });

    test('use the given score calculator', () {
      final hints = OpenEquationHintFinder(
        scoreCalculator: _ConstantScore(100),
      ).find(gridFromRows(['=8+1=.']));

      expect(hints.partialCompletionPoints['9'], 100);
    });
  });

  group('hints without points', () {
    test('know no points by default', () {
      final hints = OpenEquationHints(completions: {'3'}, extensions: {});

      expect(hints.completionPoints, isEmpty);
      expect(hints.partialCompletionPoints, isEmpty);
    });
  });
}
