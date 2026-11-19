import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_position_chooser.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/single_block_component.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_round_listener.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/layout/board/block_board.dart';
import 'package:calc_tetris/layout/game_dimensions.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

class _OneCellGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 9)],
  ];
}

class _Chooser implements SpawnPositionChooser {
  @override
  IntVector2 choose(List<IntVector2> candidates) => IntVector2(4, 3);
}

class _Listener implements GridRoundListener {
  final List<int> points = [];

  @override
  void onRoundFinished(int pointsEarned) => points.add(pointsEarned);
}

/// An empty grid of the game size with a `2` at (2, 9) and a `=` at (3, 9).
List<List<SingleBlock?>> _initialContent() {
  final size = GameDimensions.gridBlockCount;
  final content = List.generate(
    size.x,
    (_) => List<SingleBlock?>.filled(size.y, null),
  );
  content[2][9] = MathNumberBlock(number: 2);
  content[3][9] = MathEqualsBlock();
  return content;
}

Future<({FlameGame game, BlockBoard board, GridContentHolder holder})> _pump(
  WidgetTester tester, {
  List<List<SingleBlock?>>? initialContent,
  SpawnPositionChooser? chooser,
  GridRoundListener? listener,
  bool spawnNextBlockAfterRound = true,
}) async {
  final holder = GridContentHolder();
  final game = FlameGame();
  final board = BlockBoard(
    solutionStrategy: ValidEquationSolutionStrategy(),
    singleBlockComponentFactory: newComponentFromBlockModel,
    nextBlockPlanner: NextBlockPlanner(generator: _OneCellGenerator()),
    gridContentHolder: holder,
    initialContent: initialContent,
    spawnPositionChooser: chooser,
    roundListener: listener,
    spawnNextBlockAfterRound: spawnNextBlockAfterRound,
    size: Vector2(440, 440),
  );
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  game.add(board);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  return (game: game, board: board, holder: holder);
}

void main() {
  group('initial content', () {
    testWidgets('is empty by default', (tester) async {
      final pumped = await _pump(tester);

      expect(
        pumped.holder().expand((column) => column).whereType<SingleBlock>(),
        isEmpty,
      );
    });

    testWidgets('puts the given blocks into the grid', (tester) async {
      final content = _initialContent();

      final pumped = await _pump(tester, initialContent: content);

      final landed = pumped.holder();
      expect(landed[2][9], same(content[2][9]));
      expect(landed[3][9], same(content[3][9]));
      expect(
        landed.expand((column) => column).whereType<SingleBlock>(),
        hasLength(2),
      );
    });

    testWidgets('shows the blocks as components of the grid', (tester) async {
      final pumped = await _pump(tester, initialContent: _initialContent());

      final grid = pumped.game.descendants().whereType<Grid>().single;
      final positions = grid.children
          .whereType<SingleBlockComponent>()
          .map((c) => c.position)
          .toSet();
      expect(positions, {
        Vector2(2 * grid.cellSize, 9 * grid.cellSize),
        Vector2(3 * grid.cellSize, 9 * grid.cellSize),
      });
    });

    testWidgets('is in place before the first block spawns', (tester) async {
      final pumped = await _pump(tester, initialContent: _initialContent());

      final spawn = pumped.game
          .descendants()
          .whereType<Grid>()
          .single
          .controller
          .currentBlockGridPosition!;
      expect(spawn.y == 9 && (spawn.x == 2 || spawn.x == 3), isFalse);
    });
  });

  group('spawn position chooser', () {
    testWidgets('decides where the first block enters the grid', (
      tester,
    ) async {
      final pumped = await _pump(tester, chooser: _Chooser());

      final position = pumped.game
          .descendants()
          .whereType<Grid>()
          .single
          .controller
          .currentBlockGridPosition!;
      expect(position.x, 4);
      expect(position.y, 3);
    });
  });

  group('round listener and spawning', () {
    testWidgets('informs the listener and spawns nothing when switched off', (
      tester,
    ) async {
      final listener = _Listener();
      final pumped = await _pump(
        tester,
        listener: listener,
        chooser: _Chooser(),
        spawnNextBlockAfterRound: false,
      );
      final controller = pumped.game
          .descendants()
          .whereType<Grid>()
          .single
          .controller;

      pumped.board.placeCurrentBlock();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(listener.points, [0]);
      expect(controller.currentBlock, isNull);
    });
  });
}
