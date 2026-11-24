import 'dart:developer' as dev;

import 'package:calc_tetris/audio/sound_effect_player.dart';
import 'package:calc_tetris/audio/sound_files.dart';
import 'package:calc_tetris/audio/sound_on_score_recorder.dart';
import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/generators/guided_compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/endless_game_grid_controller.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:calc_tetris/layout/game_dimensions.dart';
import 'package:calc_tetris/layout/header/header.dart';
import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/in_memory_database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:calc_tetris/screens/gameover/game_over_hint.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:calc_tetris/screens/stopgame/stop_game_dialog.dart';
import 'package:calc_tetris/screens/welcome/sky_background.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/components.dart';

class EndlessGame extends PositionComponent implements GameOverListener {
  /// Called when the player confirmed to end the game.
  final void Function()? onQuit;

  final DatabaseService _databaseService;
  final ScoreKeeper _scoreKeeper;
  final SoundEffectPlayer _soundEffectPlayer;

  EndlessGame({
    this.onQuit,
    DatabaseService? databaseService,
    ScoreKeeper? scoreKeeper,
    SoundEffectPlayer? soundEffectPlayer,
  }) : _databaseService = databaseService ?? InMemoryDatabaseService(),
       _scoreKeeper = scoreKeeper ?? ScoreKeeper(),
       _soundEffectPlayer = soundEffectPlayer ?? SilentSoundEffectPlayer();

  final SkyBackground background = SkyBackground();

  StopGameDialog? _stopDialog;
  final GameDimensions _gameDimensions = GameDimensions(
    gridBlockCount: IntVector2.square(11),
  );
  final GridContentHolder _gridContentHolder = GridContentHolder();
  late final NextBlockPlanner _nextBlockPlanner = NextBlockPlanner(
    generator: GuidedCompoundblockModelGenerator(
      gridContent: _gridContentHolder.call,
    ),
  );

  @override
  void onMount() {
    super.onMount();
    add(background);

    late final EndlessGameGridController gridController;
    final grid = Grid(
      blockCount: _gameDimensions.gridBlockCount,
      singleBlockComponentFactory: newComponentFromBlockModel,
      gridContentHolder: _gridContentHolder,
      controllerFactory: (gridModel, grid) =>
          gridController = EndlessGameGridController(
            gridModel: gridModel,
            grid: grid,
            solutionStrategy: ValidEquationSolutionStrategy(),
            nextBlockPlanner: _nextBlockPlanner,
            singleBlockComponentFactory: newComponentFromBlockModel,
            scoreRecorder: SoundOnScoreRecorder(
              inner: _scoreKeeper,
              player: _soundEffectPlayer,
              fileName: SoundFiles.solvedEquation,
            ),
            gameOverListener: this,
          ),
      size: _gameDimensions.sizeBlockBoard,
      position: Vector2(0, _gameDimensions.sizeHeader.y),
    );

    final header = Header(
      onConfirmPressed: () {
        if (grid.controller.placeCurrentBlock()) {
          _soundEffectPlayer.playSafely(SoundFiles.blockPlaced);
        }
      },
      onStopPressed: _askToStop,
      scoreKeeper: _scoreKeeper,
      nextBlockPlanner: _nextBlockPlanner,
      gridCellSize: _gameDimensions.gridCellSize,
      size: _gameDimensions.sizeHeader,
      position: Vector2.zero(),
    );
    add(header);

    gridController.spawnOrigin = header.nextBlockDisplay;
    add(grid);
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
      // Quits only after saving, so the welcome screen shows the new score.
      onConfirm: () => _saveScore().then((_) => onQuit?.call()),
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
  void onGameOver() {
    _saveScore();
    add(GameOverHint(size: size));
  }

  /// Stores the reached score if it beats the highscore. A failing database
  /// must not disturb the game.
  Future<void> _saveScore() {
    return _databaseService
        .saveHighscoreIfHigher(GameModeName.endless, _scoreKeeper.total)
        .then<void>((_) {})
        .catchError((Object error) {
          dev.log('Could not save the score: $error');
        });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _gameDimensions.availableSize = size;
    background.size = size.clone();
  }

  GameDimensions get gameDimensions => _gameDimensions;

  ScoreKeeper get scoreKeeper => _scoreKeeper;

  /// The blocks that landed in the grid, indexed `[x][y]`.
  List<List<SingleBlock?>> get gridContent => _gridContentHolder.call();
}
