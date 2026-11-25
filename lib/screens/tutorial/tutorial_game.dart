import 'dart:async';

import 'package:calc_tetris/audio/sound_effect_player.dart';
import 'package:calc_tetris/audio/sound_files.dart';
import 'package:calc_tetris/audio/sound_on_score_recorder.dart';
import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/endless_game_grid_controller.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_round_listener.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/grid/power_up_used_listener.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:calc_tetris/layout/footer/power_up_found_animation.dart';
import 'package:calc_tetris/layout/footer/power_up_handler.dart';
import 'package:calc_tetris/layout/game_dimensions.dart';
import 'package:calc_tetris/layout/header/header.dart';
import 'package:calc_tetris/screens/stopgame/stop_game_dialog.dart';
import 'package:calc_tetris/screens/tutorial/block_rows.dart';
import 'package:calc_tetris/screens/tutorial/fixed_spawn_position_chooser.dart';
import 'package:calc_tetris/screens/tutorial/scripted_block_generator.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_message_overlay.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_runner.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_script.dart';
import 'package:calc_tetris/screens/tutorial/tutorial_step.dart';
import 'package:calc_tetris/screens/welcome/sky_background.dart';
import 'package:calc_tetris/theme/light_theme.dart';
import 'package:calc_tetris/theme/text_theme.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/components.dart';

/// Explains the game with prepared boards. Its points are counted on its own
/// and never saved, so they can not reach the highscore.
class TutorialGame extends PositionComponent
    implements GridRoundListener, PowerUpFoundListener, PowerUpUsedListener {
  /// Pause after the score has counted up, so the player sees the result.
  static const double _afterCountUpPause = 0.5;

  /// Pause after the last shot, so the player sees the blocks break apart.
  static const double _afterShotsPause = 1;

  static const String retryNotice =
      'Das passt noch nicht. Versuche es noch einmal!';

  /// Called when the player leaves the tutorial.
  final void Function()? onQuit;

  final ScoreKeeper scoreKeeper;
  final SoundEffectPlayer _soundEffectPlayer;
  late final TutorialRunner runner;

  final SkyBackground background = SkyBackground();
  final GameDimensions _gameDimensions = GameDimensions(
    gridBlockCount: tutorialGridSize,
  );
  late final TextBoxComponent hintText = TextBoxComponent(
    text: '',
    textRenderer: TextPaint(
      style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
    ),
    boxConfig: const TextBoxConfig(),
  );

  GridContentHolder _gridContentHolder = GridContentHolder();
  final List<Component> _stepComponents = [];
  StopGameDialog? _stopDialog;
  StreamSubscription<void>? _runnerSubscription;
  Header? _header;

  /// Points of a solved round whose step change waits for the score display.
  int? _pendingPoints;
  double _pause = 0;

  /// Appears once the tutorial is about the cannon and stays from then on.
  Footer? _footer;

  /// Handles the cannon during a cannon step.
  PowerUpHandler? _powerUps;

  /// What happens after the shots of a cannon step, once they are shown.
  void Function()? _afterShots;

  TutorialGame({
    this.onQuit,
    ScoreKeeper? scoreKeeper,
    SoundEffectPlayer? soundEffectPlayer,
    List<TutorialStep>? steps,
  }) : scoreKeeper = scoreKeeper ?? ScoreKeeper(),
       _soundEffectPlayer = soundEffectPlayer ?? SilentSoundEffectPlayer() {
    runner = TutorialRunner(
      steps: steps ?? tutorialScript(),
      onFinished: () => onQuit?.call(),
    );
  }

  @override
  void onMount() {
    super.onMount();
    add(background);
    add(hintText);
    _layoutHint();
    _runnerSubscription = runner.changes.listen((_) => _showCurrentStep());
    _showCurrentStep();
  }

  @override
  void onRemove() {
    _runnerSubscription?.cancel();
    super.onRemove();
  }

  /// A round without points restarts the step at once. Points are first
  /// counted up in the score display, only then the tutorial goes on. Putting
  /// the block down in a cannon step restarts it.
  @override
  void onRoundFinished(int pointsEarned) {
    if (runner.current is CannonStep) {
      runner.restartStep();
      return;
    }
    if (pointsEarned > 0) {
      _pendingPoints = pointsEarned;
      _pause = 0;
      return;
    }
    runner.onRoundFinished(pointsEarned);
  }

  /// Lets the found power-up fly into the footer.
  @override
  void onPowerUpFound(PowerUpType type, Vector2 foundPositionAbsoluteCenter) {
    add(
      PowerUpFoundAnimation(
        type: type,
        foundPositionAbsoluteCenter: foundPositionAbsoluteCenter,
        targetButton: _requireFooter().buttonFor(type),
        startCellSize: _gameDimensions.gridCellSize,
      ),
    );
  }

  /// Counts the shot and looks whether the goal of the cannon step is reached.
  @override
  void onPowerUpUsed(PowerUpType type) {
    final step = runner.current;
    final powerUps = _powerUps;
    if (step is! CannonStep || powerUps == null || _afterShots != null) {
      return;
    }
    powerUps.onPowerUpUsed(type);
    if (step.targets.every(_isEmpty)) {
      _afterShots = runner.onCannonStepCompleted;
      _pause = 0;
    } else if (!powerUps.playMode.isPowerUpInUse) {
      _afterShots = runner.restartStep;
      _pause = 0;
    }
  }

  bool _isEmpty(IntVector2 cell) => gridContent[cell.x][cell.y] == null;

  @override
  void update(double dt) {
    super.update(dt);
    _continueAfterShots(dt);
    _continueAfterPoints(dt);
  }

  void _continueAfterShots(double dt) {
    final next = _afterShots;
    if (next == null) {
      return;
    }
    _pause += dt;
    if (_pause >= _afterShotsPause) {
      _afterShots = null;
      next();
    }
  }

  /// Waits for the score to count up and for a found power-up to arrive.
  void _continueAfterPoints(double dt) {
    final points = _pendingPoints;
    if (points == null ||
        (_header?.isScoreCountingUp ?? false) ||
        children.whereType<PowerUpFoundAnimation>().isNotEmpty) {
      return;
    }
    _pause += dt;
    if (_pause >= _afterCountUpPause) {
      _pendingPoints = null;
      runner.onRoundFinished(points);
    }
  }

  void _showCurrentStep() {
    for (final component in _stepComponents) {
      component.removeFromParent();
    }
    _stepComponents.clear();
    _header = null;
    _pendingPoints = null;
    _afterShots = null;
    _powerUps?.reset();
    _powerUps = null;
    final step = runner.current;
    switch (step) {
      case MessageStep():
        hintText.text = '';
        _addStepComponent(
          TutorialMessageOverlay(
            text: step.text,
            buttonLabel: step.buttonLabel,
            size: size.clone(),
            onContinue: runner.continueFromMessage,
          ),
        );
      case PlayStep():
        if (step.findsCannon) {
          _requireFooter();
        }
        hintText.text = runner.attempt > 0 ? retryNotice : step.hint;
        _showBoard(
          gridRows: step.gridRows,
          blockRows: step.blockRows,
          spawnPosition: step.spawnPosition,
          findsCannon: step.findsCannon,
        );
      case CannonStep():
        _showCannonStep(step);
    }
  }

  void _showCannonStep(CannonStep step) {
    final footer = _requireFooter();
    footer.cannonButton.count = 1;
    hintText.text = runner.attempt > 0 ? retryNotice : step.hint;
    final gridController = _showBoard(
      gridRows: step.gridRows,
      blockRows: step.blockRows,
      spawnPosition: step.spawnPosition,
    );
    _powerUps = PowerUpHandler(
      footer: footer,
      soundEffectPlayer: _soundEffectPlayer,
      onPlayModeChanged: (mode) {
        gridController.playMode = mode;
        if (mode.isPowerUpInUse) {
          hintText.text = step.activeHint;
        }
      },
    );
  }

  /// The footer, added on first use. It is narrow and sits on the right, the
  /// hint text uses the space left of it.
  Footer _requireFooter() {
    final existing = _footer;
    if (existing != null) {
      return existing;
    }
    final height = _gameDimensions.sizeFooter.y;
    final footer = Footer(
      size: Vector2.all(height),
      position: Vector2(
        size.x - height,
        _gameDimensions.sizeHeader.y + _gameDimensions.sizeBlockBoard.y,
      ),
      onPowerUpSelected: (type) => _powerUps?.onPowerUpSelected(type),
    );
    _footer = footer;
    add(footer);
    _layoutHint();
    return footer;
  }

  EndlessGameGridController _showBoard({
    required List<String> gridRows,
    required List<String> blockRows,
    required IntVector2 spawnPosition,
    bool findsCannon = false,
  }) {
    final planner = NextBlockPlanner(
      generator: ScriptedBlockGenerator(blockRows),
    );
    _gridContentHolder = GridContentHolder();
    late final EndlessGameGridController gridController;
    final grid = Grid(
      blockCount: _gameDimensions.gridBlockCount,
      singleBlockComponentFactory: newComponentFromBlockModel,
      gridContentHolder: _gridContentHolder,
      initialContent: blocksFromRows(gridRows),
      controllerFactory: (gridModel, grid) =>
          gridController = EndlessGameGridController(
            gridModel: gridModel,
            grid: grid,
            solutionStrategy: ValidEquationSolutionStrategy(),
            nextBlockPlanner: planner,
            singleBlockComponentFactory: newComponentFromBlockModel,
            scoreRecorder: SoundOnScoreRecorder(
              inner: scoreKeeper,
              player: _soundEffectPlayer,
              fileName: SoundFiles.solvedEquation,
            ),
            roundListener: this,
            spawnPositionChooser: FixedSpawnPositionChooser(spawnPosition),
            spawnNextBlockAfterRound: false,
            // only the prepared step finds a cannon, and surely
            powerUpFoundListener: findsCannon ? this : null,
            powerUpFindChances: {PowerUpType.cannon: 1},
            powerUpUsedListener: this,
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
      scoreKeeper: scoreKeeper,
      nextBlockPlanner: planner,
      gridCellSize: _gameDimensions.gridCellSize,
      size: _gameDimensions.sizeHeader,
      position: Vector2.zero(),
    );
    gridController.spawnOrigin = header.nextBlockDisplay;
    _header = header;
    _addStepComponent(header);
    _addStepComponent(grid);
    return gridController;
  }

  void _addStepComponent(Component component) {
    _stepComponents.add(component);
    add(component);
  }

  void _askToStop() {
    if (_stopDialog != null) return;
    final dialog = StopGameDialog(
      size: size,
      // Nothing to save: tutorial points never count.
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

  void _layoutHint() {
    const margin = 16.0;
    hintText
      ..position = Vector2(
        margin,
        _gameDimensions.sizeHeader.y + _gameDimensions.sizeBlockBoard.y + 8,
      )
      ..boxConfig = TextBoxConfig(
        maxWidth: (size.x - 2 * margin - (_footer?.width ?? 0)).clamp(
          40,
          double.infinity,
        ),
      );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _gameDimensions.availableSize = size;
    background.size = size.clone();
    if (isMounted) {
      _layoutHint();
    }
  }

  /// The blocks that landed in the grid, indexed `[x][y]`.
  List<List<SingleBlock?>> get gridContent => _gridContentHolder.call();
}
