import 'dart:async';
import 'dart:math';

import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/generators/guided_compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/layout/board/block_board.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:calc_tetris/layout/game_dimensions.dart';
import 'package:calc_tetris/layout/header/header.dart';
import 'package:calc_tetris/screens/gameover/game_over_hint.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class EndlessGame extends PositionComponent implements GameOverListener {
  final GameDimensions _gameDimensions = GameDimensions();
  final ScoreKeeper _scoreKeeper = ScoreKeeper();
  final GridContentHolder _gridContentHolder = GridContentHolder();
  late final NextBlockPlanner _nextBlockPlanner = NextBlockPlanner(
    generator: GuidedCompoundblockModelGenerator(
      gridContent: _gridContentHolder.call,
    ),
  );

  late final SpriteComponent _background;
  late final RectangleComponent _backgroundShade;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    _background = SpriteComponent(
      sprite: await Sprite.load("background_mittelalter.png"),
      anchor: Anchor.center,
      priority: -2,
    );
    await add(_background);
    _backgroundShade = RectangleComponent(
      paint: Paint()..color = const Color(0x66050A18),
      priority: -1,
    );
    await add(_backgroundShade);
    _fitBackground();
  }

  /// Scales the background image to cover the whole screen.
  void _fitBackground() {
    final imageSize = _background.sprite!.srcSize;
    _background.scale = Vector2.all(
      max(size.x / imageSize.x, size.y / imageSize.y),
    );
    _background.position = size / 2;
    _backgroundShade.size = size;
  }

  @override
  void onMount() {
    super.onMount();
    late final BlockBoard board;
    final header = Header(
      onDropPressed: () => board.dropCurrentBlock(),
      scoreKeeper: _scoreKeeper,
      nextBlockPlanner: _nextBlockPlanner,
      gridCellSize: _gameDimensions.gridCellSize,
      size: _gameDimensions.sizeHeader,
      position: Vector2.zero(),
    );
    add(header);
    board = BlockBoard(
      scoreRecorder: _scoreKeeper,
      solutionStrategy: ValidEquationSolutionStrategy(),
      singleBlockComponentFactory: newComponentFromBlockModel,
      nextBlockPlanner: _nextBlockPlanner,
      gridContentHolder: _gridContentHolder,
      spawnOrigin: header.nextBlockDisplay,
      gameOverListener: this,
      size: _gameDimensions.sizeBlockBoard,
      position: Vector2(0, _gameDimensions.sizeHeader.y),
    );
    add(board);
    add(
      Footer(
        size: _gameDimensions.sizeFooter,
        position: Vector2(
          0,
          gameDimensions.sizeHeader.y + gameDimensions.sizeBlockBoard.y,
        ),
      ),
    );
  }

  @override
  void onGameOver() => add(GameOverHint(size: size));

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _gameDimensions.availableSize = size;
    if (isLoaded) {
      _fitBackground();
    }
  }

  GameDimensions get gameDimensions => _gameDimensions;
}
