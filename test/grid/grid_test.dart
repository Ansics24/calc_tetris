import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_origin.dart';
import 'package:calc_tetris/block/math/seed/spawn_position_chooser.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/shatter_animation.dart';
import 'package:calc_tetris/block/single_block_component.dart';
import 'package:calc_tetris/grid/endless_game_grid_controller.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:calc_tetris/grid/grid_round_listener.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/play_mode.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_grid.dart';

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

class _FakeGridController implements GridController {
  int spawns = 0;
  int placements = 0;
  final List<String> moves = [];
  final List<(int, int)> taps = [];

  @override
  void spawnNextBlock() => spawns++;

  @override
  void onCellTapped(IntVector2 cell) => taps.add((cell.x, cell.y));

  @override
  bool placeCurrentBlock() {
    placements++;
    return true;
  }

  @override
  void onBlockDraggedLeft() => moves.add('left');

  @override
  void onBlockDraggedRight() => moves.add('right');

  @override
  void onBlockDraggedUp() => moves.add('up');

  @override
  void onBlockDraggedDown() => moves.add('down');
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

GridControllerFactory _controllerFactory({
  SpawnPositionChooser? chooser,
  GridRoundListener? listener,
  bool spawnNextBlockAfterRound = true,
  SpawnOrigin? spawnOrigin,
}) =>
    (gridModel, grid) => EndlessGameGridController(
      gridModel: gridModel,
      grid: grid,
      solutionStrategy: ValidEquationSolutionStrategy(),
      nextBlockPlanner: NextBlockPlanner(generator: _OneCellGenerator()),
      singleBlockComponentFactory: newComponentFromBlockModel,
      spawnPositionChooser: chooser,
      roundListener: listener,
      spawnNextBlockAfterRound: spawnNextBlockAfterRound,
      spawnOrigin: spawnOrigin,
    );

Future<({FlameGame game, Grid grid, GridContentHolder holder})> _pump(
  WidgetTester tester, {
  List<List<SingleBlock?>>? initialContent,
  SpawnPositionChooser? chooser,
  GridRoundListener? listener,
  bool spawnNextBlockAfterRound = true,
  SpawnOrigin? spawnOrigin,
  GridControllerFactory? controllerFactory,
  Vector2? areaSize,
  Vector2? areaPosition,
  bool settle = true,
}) async {
  final holder = GridContentHolder();
  final game = FlameGame();
  final grid = Grid(
    blockCount: _blockCount,
    singleBlockComponentFactory: newComponentFromBlockModel,
    controllerFactory:
        controllerFactory ??
        _controllerFactory(
          chooser: chooser,
          listener: listener,
          spawnNextBlockAfterRound: spawnNextBlockAfterRound,
          spawnOrigin: spawnOrigin,
        ),
    gridContentHolder: holder,
    initialContent: initialContent,
    size: areaSize ?? Vector2(440, 440),
    position: areaPosition,
  );
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
  group('controller of the game mode', () {
    testWidgets('is created by the mode with the model and the grid', (
      tester,
    ) async {
      GridModel? givenModel;
      Grid? givenGrid;
      final control = _FakeGridController();

      final pumped = await _pump(
        tester,
        controllerFactory: (gridModel, grid) {
          givenModel = gridModel;
          givenGrid = grid;
          return control;
        },
      );

      expect(givenGrid, same(pumped.grid));
      expect(givenModel, isNotNull);
      expect(givenModel!.gridComponent, same(pumped.grid));
      expect(pumped.grid.controller, same(control));
    });

    testWidgets('can be any grid control', (tester) async {
      final control = _FakeGridController();

      final pumped = await _pump(
        tester,
        controllerFactory: (gridModel, grid) => control,
      );

      pumped.grid.controller.onBlockDraggedLeft();
      expect(pumped.grid.controller.placeCurrentBlock(), isTrue);
      expect(control.moves, ['left']);
      expect(control.placements, 1);
    });

    testWidgets('is told to spawn the first block once the grid is loaded', (
      tester,
    ) async {
      final control = _FakeGridController();

      await _pump(tester, controllerFactory: (gridModel, grid) => control);

      expect(control.spawns, 1);
    });

    testWidgets('is created only once', (tester) async {
      var created = 0;

      await _pump(
        tester,
        controllerFactory: (gridModel, grid) {
          created++;
          return _FakeGridController();
        },
      );

      expect(created, 1);
    });

    test(
      'is the grid controller interface when it is an EndlessGameGridController',
      () {
        final grid = newTestGrid(IntVector2(3, 3));

        expect(grid.controller, isA<GridController>());
        expect(grid.endlessController, isA<EndlessGameGridController>());
      },
    );
  });

  group('taps on the grid', () {
    Future<void> tapAt(WidgetTester tester, Grid grid, Vector2 local) async {
      await tester.tapAt(grid.absolutePositionOf(local).toOffset());
      await tester.pump();
    }

    testWidgets('are told to the controller as the tapped cell', (
      tester,
    ) async {
      final control = _FakeGridController();
      final pumped = await _pump(
        tester,
        controllerFactory: (gridModel, grid) => control,
      );
      final cell = pumped.grid.cellSize;

      await tapAt(tester, pumped.grid, Vector2(2.5 * cell, 1.5 * cell));
      await tapAt(tester, pumped.grid, Vector2(0.1 * cell, 10.9 * cell));

      expect(control.taps, [(2, 1), (0, 10)]);
      // let the delayed timers of the tap run out
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shatter the block a cannon shot hits', (tester) async {
      final pumped = await _pump(tester, initialContent: _initialContent());
      pumped.grid.endlessController.playMode = const PlayMode.powerUpInUse(
        PowerUpType.cannon,
      );
      final cell = pumped.grid.cellSize;

      await tapAt(tester, pumped.grid, Vector2(2.5 * cell, 9.5 * cell));
      await tester.pump(const Duration(milliseconds: 50));

      expect(pumped.holder()[2][9], isNull);
      expect(pumped.holder()[3][9], isNotNull);
      expect(
        pumped.grid.children.whereType<SingleBlockComponent>(),
        hasLength(1),
      );
      final shatter = pumped.grid.children.whereType<ShatterAnimation>();
      expect(shatter, hasLength(1));
      expect(shatter.single.position, Vector2(2 * cell, 9 * cell));
      await tester.pump(const Duration(seconds: 2));
    });
  });

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
    testWidgets('is the one the controller of the mode got', (tester) async {
      final pumped = await _pump(
        tester,
        spawnOrigin: _Origin(Vector2(200, 100), 20),
        chooser: _Chooser(),
        settle: false,
      );

      // the first block starts as big as the cells of the origin
      expect(
        pumped.grid.endlessController.currentBlock!.scale.x,
        closeTo(20 / pumped.grid.cellSize, 0.2),
      );
    });

    testWidgets('lets the block start without it, in its place', (
      tester,
    ) async {
      final pumped = await _pump(tester, chooser: _Chooser());

      expect(pumped.grid.endlessController.currentBlock!.scale.x, 1);
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

      final spawn = pumped.grid.endlessController.currentBlockGridPosition!;
      expect(spawn.y == 9 && (spawn.x == 2 || spawn.x == 3), isFalse);
    });
  });

  group('spawn position chooser', () {
    testWidgets('decides where the first block enters the grid', (
      tester,
    ) async {
      final pumped = await _pump(tester, chooser: _Chooser());

      final position = pumped.grid.endlessController.currentBlockGridPosition!;
      expect(position.x, 4);
      expect(position.y, 3);
    });
  });

  group('placing the current block', () {
    testWidgets('says whether the block is being placed', (tester) async {
      final pumped = await _pump(tester, chooser: _Chooser());

      expect(pumped.grid.endlessController.placeCurrentBlock(), isTrue);
      expect(pumped.grid.endlessController.placeCurrentBlock(), isFalse);

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
      final controller = pumped.grid.endlessController;

      pumped.grid.endlessController.placeCurrentBlock();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(listener.points, [0]);
      expect(controller.currentBlock, isNull);
    });
  });
}
