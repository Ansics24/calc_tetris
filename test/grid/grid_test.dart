import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_origin.dart';
import 'package:calc_tetris/block/math/seed/spawn_position_chooser.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/single_block_component.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_round_listener.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
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

final _blockCount = IntVector2.square(11);

class _Origin implements SpawnOrigin {
  @override
  final Vector2 absoluteTopLeft;

  @override
  final double cellSize;

  _Origin(this.absoluteTopLeft, this.cellSize);
}

/// An empty grid of the game size with a `2` at (2, 9) and a `=` at (3, 9).
List<List<SingleBlock?>> _initialContent() {
  final size = _blockCount;
  final content = List.generate(
    size.x,
    (_) => List<SingleBlock?>.filled(size.y, null),
  );
  content[2][9] = MathNumberBlock(number: 2);
  content[3][9] = MathEqualsBlock();
  return content;
}

Future<({FlameGame game, Grid grid, GridContentHolder holder})> _pump(
  WidgetTester tester, {
  List<List<SingleBlock?>>? initialContent,
  SpawnPositionChooser? chooser,
  GridRoundListener? listener,
  bool spawnNextBlockAfterRound = true,
  SpawnOrigin? spawnOrigin,
  Vector2? areaSize,
  Vector2? areaPosition,
  bool settle = true,
}) async {
  final holder = GridContentHolder();
  final game = FlameGame();
  final grid = Grid(
    blockCount: _blockCount,
    solutionStrategy: ValidEquationSolutionStrategy(),
    singleBlockComponentFactory: newComponentFromBlockModel,
    nextBlockPlanner: NextBlockPlanner(generator: _OneCellGenerator()),
    gridContentHolder: holder,
    initialContent: initialContent,
    spawnPositionChooser: chooser,
    roundListener: listener,
    spawnNextBlockAfterRound: spawnNextBlockAfterRound,
    size: areaSize ?? Vector2(440, 440),
    position: areaPosition,
  );
  if (spawnOrigin != null) {
    grid.spawnOrigin = spawnOrigin;
  }
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  game.add(grid);
  await tester.pump();
  if (settle) {
    // lets the first block arrive
    await tester.pump(const Duration(seconds: 1));
  }
  return (game: game, grid: grid, holder: holder);
}

void main() {
  group('layout in its area', () {
    testWidgets('makes the cells as big as the area allows', (tester) async {
      final pumped = await _pump(tester, areaSize: Vector2(440, 330));

      expect(pumped.grid.cellSize, 30);
    });

    testWidgets('takes the size of the cells for its own size', (tester) async {
      final pumped = await _pump(tester, areaSize: Vector2(440, 330));

      expect(pumped.grid.size, Vector2(330, 330));
    });

    testWidgets('centers itself horizontally in a wide area', (tester) async {
      final pumped = await _pump(
        tester,
        areaSize: Vector2(440, 330),
        areaPosition: Vector2(10, 20),
      );

      expect(pumped.grid.position, Vector2(10 + (440 - 330) / 2, 20));
    });

    testWidgets('centers itself vertically in a tall area', (tester) async {
      final pumped = await _pump(
        tester,
        areaSize: Vector2(330, 440),
        areaPosition: Vector2(0, 100),
      );

      expect(pumped.grid.position, Vector2(0, 100 + (440 - 330) / 2));
    });

    testWidgets('fills a square area completely', (tester) async {
      final pumped = await _pump(
        tester,
        areaSize: Vector2(440, 440),
        areaPosition: Vector2(0, 50),
      );

      expect(pumped.grid.position, Vector2(0, 50));
      expect(pumped.grid.size, Vector2(440, 440));
    });
  });

  group('spawn origin', () {
    testWidgets('can be set after the grid was created', (tester) async {
      final pumped = await _pump(
        tester,
        spawnOrigin: _Origin(Vector2(200, 100), 20),
        chooser: _Chooser(),
        settle: false,
      );

      // the first block starts as big as the cells of the origin
      expect(
        pumped.grid.controller.currentBlock!.scale.x,
        closeTo(20 / pumped.grid.cellSize, 0.2),
      );
    });

    testWidgets('lets the block start without it, in its place', (
      tester,
    ) async {
      final pumped = await _pump(tester, chooser: _Chooser());

      expect(pumped.grid.controller.currentBlock!.scale.x, 1);
    });
  });

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

      final grid = pumped.grid;
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

      final spawn = pumped.grid.controller.currentBlockGridPosition!;
      expect(spawn.y == 9 && (spawn.x == 2 || spawn.x == 3), isFalse);
    });
  });

  group('spawn position chooser', () {
    testWidgets('decides where the first block enters the grid', (
      tester,
    ) async {
      final pumped = await _pump(tester, chooser: _Chooser());

      final position = pumped.grid.controller.currentBlockGridPosition!;
      expect(position.x, 4);
      expect(position.y, 3);
    });
  });

  group('placing the current block', () {
    testWidgets('says whether the block is being placed', (tester) async {
      final pumped = await _pump(tester, chooser: _Chooser());

      expect(pumped.grid.controller.placeCurrentBlock(), isTrue);
      expect(pumped.grid.controller.placeCurrentBlock(), isFalse);

      await tester.pump(const Duration(seconds: 2));
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
      final controller = pumped.grid.controller;

      pumped.grid.controller.placeCurrentBlock();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(listener.points, [0]);
      expect(controller.currentBlock, isNull);
    });
  });
}
