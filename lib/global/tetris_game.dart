import 'dart:async';

import 'package:calc_tetris/core/block/seed/generators/random_compoundblock_model_generator.dart';
import 'package:calc_tetris/core/block/seed/next_block_planner.dart';
import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:calc_tetris/global/block_board.dart';
import 'package:calc_tetris/global/footer.dart';
import 'package:calc_tetris/global/game_dimensions.dart';
import 'package:calc_tetris/global/header.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class TetrisGame extends FlameGame {
  final GameDimensions _gameDimensions = GameDimensions();
  final ScoreKeeper _scoreKeeper = ScoreKeeper();
  final NextBlockPlanner _nextBlockPlanner = NextBlockPlanner(
    generator: RandomCompoundblockModelGenerator(),
  );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    final background = await Sprite.load("background_mittelalter.png");
    await add(
      SpriteComponent(
        sprite: background,
        anchor: Anchor.topLeft,
        position: Vector2(0, 200),
        scale: Vector2.all(0.4),
        priority: -1,
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    final header = Header(
      scoreKeeper: _scoreKeeper,
      nextBlockPlanner: _nextBlockPlanner,
      gridCellSize: _gameDimensions.gridCellSize,
      size: _gameDimensions.sizeHeader,
      position: Vector2.zero(),
    );
    add(header);
    add(
      BlockBoard(
        scoreRecorder: _scoreKeeper,
        nextBlockPlanner: _nextBlockPlanner,
        spawnOrigin: header.nextBlockDisplay,
        size: _gameDimensions.sizeBlockBoard,
        position: Vector2(0, _gameDimensions.sizeHeader.y),
      ),
    );
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _gameDimensions.availableSize = size;
  }

  GameDimensions get gameDimensions => _gameDimensions;
}
