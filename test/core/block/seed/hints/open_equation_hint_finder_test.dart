import 'package:calc_tetris/core/block/seed/hints/open_equation_hint_finder.dart';
import 'package:test/test.dart';

import '../support/grid_fixtures.dart';

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
}
