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
import 'package:calc_tetris/screens/stopgame/stop_game_dialog.dart';
import 'package:flame/components.dart';

class EndlessGame extends PositionComponent implements GameOverListener {
  /// Called when the player confirmed to end the game.
  final void Function()? onQuit;

  EndlessGame({this.onQuit});

  StopGameDialog? _stopDialog;
  final GameDimensions _gameDimensions = GameDimensions();
  final ScoreKeeper _scoreKeeper = ScoreKeeper();
  final GridContentHolder _gridContentHolder = GridContentHolder();
  late final NextBlockPlanner _nextBlockPlanner = NextBlockPlanner(
    generator: GuidedCompoundblockModelGenerator(
      gridContent: _gridContentHolder.call,
    ),
  );

  @override
  void onMount() {
    super.onMount();
    late final BlockBoard board;
    final header = Header(
      onDropPressed: () => board.dropCurrentBlock(),
      onStopPressed: _askToStop,
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

  void _askToStop() {
    if (_stopDialog != null) return;
    final dialog = StopGameDialog(
      size: size,
      onConfirm: () => onQuit?.call(),
      onCancel: _closeStopDialog,
    );
    _stopDialog = dialog;
    add(dialog);
  }

  void _closeStopDialog() {
    _stopDialog?.removeFromParent();
    _stopDialog = null;
  }

  @override
  void onGameOver() => add(GameOverHint(size: size));

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _gameDimensions.availableSize = size;
  }

  GameDimensions get gameDimensions => _gameDimensions;
}
