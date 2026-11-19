import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/layout/game_dimensions.dart';
import 'package:calc_tetris/screens/tutorial/scripted_block_generator.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_script.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_step.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';

import '../../block/math/sample_grids/sample_grid_from_rows.dart';

/// Points the player must earn in the play steps, in the order of the script.
/// 2 points per number, multiplied by the digits of all multi digit numbers.
const _expectedPoints = [
  6, // 2+3=5          3 numbers
  6, // 4+4=8          3 numbers, the block has to be rotated
  6, // 6-2=4 vertical 3 numbers
  8, // 1+2+3=6        4 numbers
  24, // 12+3=15       3 numbers, multiplier 2+2
];

List<List<T>> _rotate<T>(List<List<T>> model) => List.generate(
  model[0].length,
  (i) => List.generate(model.length, (j) => model[j][model[0].length - 1 - i]),
);

/// The grid of the step with its block put at [position] after [rotations]
/// rotations. Returns the positions of the cells the block covers as well.
(GridModel, List<IntVector2>) _gridWithBlockPlaced(
  PlayStep step,
  IntVector2 position,
  int rotations,
) {
  final gridModel = sampleGridFromRows(step.gridRows);
  var block = ScriptedBlockGenerator(step.blockRows).generate();
  for (var i = 0; i < rotations; i++) {
    block = _rotate<SingleBlock>(block);
  }
  final covered = <IntVector2>[];
  for (var x = 0; x < block.length; x++) {
    for (var y = 0; y < block[x].length; y++) {
      if (block[x][y] is NullBlock) {
        continue;
      }
      final target = position.add(x, y);
      gridModel.addSingleBlock(
        'block',
        newComponentFromBlockModel(block[x][y])!,
        target,
      );
      covered.add(target);
    }
  }
  return (gridModel, covered);
}

int _pointsAt(PlayStep step, IntVector2 position, int rotations) {
  final (gridModel, covered) = _gridWithBlockPlaced(step, position, rotations);
  return ValidEquationSolutionStrategy()
      .execute(gridModel, triggeringPositions: covered)
      .pointsEarned;
}

void main() {
  final script = tutorialScript();
  final playSteps = script.whereType<PlayStep>().toList();
  final messages = script.whereType<MessageStep>().toList();

  group('structure', () {
    test('starts and ends with a message', () {
      expect(script.first, isA<MessageStep>());
      expect(script.last, isA<MessageStep>());
    });

    test('has a play step for every expected points value', () {
      expect(playSteps, hasLength(_expectedPoints.length));
    });

    test('never shows two play steps without an explanation in between', () {
      for (var i = 1; i < script.length; i++) {
        expect(
          script[i] is PlayStep && script[i - 1] is PlayStep,
          isFalse,
          reason: 'step $i follows another play step directly',
        );
      }
    });

    test('has texts for every step', () {
      for (final message in messages) {
        expect(message.text.trim(), isNotEmpty);
      }
      for (final step in playSteps) {
        expect(step.hint.trim(), isNotEmpty);
      }
    });

    test('lets the player continue and leave at the very end', () {
      for (final message in messages.take(messages.length - 1)) {
        expect(message.buttonLabel, 'Weiter');
      }
      expect(messages.last.buttonLabel, 'Zurück zum Start');
    });

    test('builds a fresh script on every call', () {
      expect(identical(tutorialScript(), tutorialScript()), isFalse);
    });
  });

  group('explains the topics in this order', () {
    // First message that mentions the keyword, in lower case.
    int firstMention(String keyword) => script.indexWhere(
      (step) =>
          step is MessageStep && step.text.toLowerCase().contains(keyword),
    );

    test('1. moving, 2. rotating, 3. horizontal, 4. vertical, 5. points', () {
      final order = [
        'ziehe',
        'dreh',
        'horizontal',
        'vertikal',
        'punkte',
      ].map(firstMention).toList();

      expect(order, everyElement(greaterThanOrEqualTo(0)));
      expect(order, orderedEquals([...order]..sort()));
      expect(order.toSet(), hasLength(order.length));
    });

    test('mentions that more numbers and more digits give more points', () {
      final text = messages.map((m) => m.text.toLowerCase()).join(' ');

      expect(text, contains('mehr zahlen'));
      expect(text, contains('mehrstellig'));
    });
  });

  group('play steps', () {
    test('fit into the grid of the game', () {
      for (final step in playSteps) {
        expect(step.gridRows, hasLength(GameDimensions.gridBlockCount.y));
        for (final row in step.gridRows) {
          expect(row, hasLength(GameDimensions.gridBlockCount.x));
        }
      }
    });

    test('have an equation that is not solved before the block arrives', () {
      for (final step in playSteps) {
        final gridModel = sampleGridFromRows(step.gridRows);
        final filled = <IntVector2>[
          for (var x = 0; x < gridModel.model.length; x++)
            for (var y = 0; y < gridModel.model[x].length; y++)
              if (gridModel.model[x][y] != null) IntVector2(x, y),
        ];

        final result = ValidEquationSolutionStrategy().execute(
          gridModel,
          triggeringPositions: filled,
        );

        expect(result.solvedBlocks, isEmpty);
      }
    });

    test('let the block spawn on free cells', () {
      for (final step in playSteps) {
        final emptyCells = sampleGridFromRows(step.gridRows);
        final (_, covered) = _gridWithBlockPlaced(step, step.spawnPosition, 0);

        expect(covered, isNotEmpty);
        expect(emptyCells.anyPositionBlocked(covered), isFalse);
      }
    });

    test('do not solve at the spawn position, the player has to act', () {
      for (final step in playSteps) {
        expect(_pointsAt(step, step.spawnPosition, 0), 0);
      }
    });

    test('can be solved at the solution position for the expected points', () {
      for (var i = 0; i < playSteps.length; i++) {
        final step = playSteps[i];

        expect(
          _pointsAt(step, step.solutionPosition, step.solutionRotations),
          _expectedPoints[i],
          reason: 'play step $i',
        );
      }
    });

    test('need a rotation for exactly one step, the one about rotating', () {
      final rotating = playSteps.where((s) => s.solutionRotations > 0);

      expect(rotating, hasLength(1));
      expect(
        _pointsAt(rotating.single, rotating.single.solutionPosition, 0),
        0,
        reason: 'without the rotation the block must not solve',
      );
    });

    test('contain a vertical equation in one step', () {
      final vertical = playSteps.where(
        (s) =>
            s.gridRows.where((r) => r.replaceAll('.', '').isNotEmpty).length >
            1,
      );

      expect(vertical, hasLength(1));
    });
  });
}
