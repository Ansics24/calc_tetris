import 'dart:async';

import 'package:calc_tetris/audio/sound_effect_player.dart';
import 'package:calc_tetris/audio/sound_files.dart';
import 'package:calc_tetris/audio/sound_on_score_recorder.dart';
import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/valid_equation_solution_strategy.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_round_listener.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
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
import 'package:flame/components.dart';

/// Explains the game with prepared boards. Its points are counted on its own
/// and never saved, so they can not reach the highscore.
class TutorialGame extends PositionComponent implements GridRoundListener {
  /// Pause after the score has counted up, so the player sees the result.
  static const double _afterCountUpPause = 0.5;

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
  /// counted up in the score display, only then the tutorial goes on.
  @override
  void onRoundFinished(int pointsEarned) {
    if (pointsEarned > 0) {
      _pendingPoints = pointsEarned;
      _pause = 0;
      return;
    }
    runner.onRoundFinished(pointsEarned);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final points = _pendingPoints;
    if (points == null || (_header?.isScoreCountingUp ?? false)) {
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
        hintText.text = runner.attempt > 0 ? retryNotice : step.hint;
        _showBoard(step);
    }
  }

  void _showBoard(PlayStep step) {
    final planner = NextBlockPlanner(
      generator: ScriptedBlockGenerator(step.blockRows),
    );
    _gridContentHolder = GridContentHolder();
    final grid = Grid(
      blockCount: _gameDimensions.gridBlockCount,
      solutionStrategy: ValidEquationSolutionStrategy(),
      nextBlockPlanner: planner,
      singleBlockComponentFactory: newComponentFromBlockModel,
      gridContentHolder: _gridContentHolder,
      scoreRecorder: SoundOnScoreRecorder(
        inner: scoreKeeper,
        player: _soundEffectPlayer,
        fileName: SoundFiles.solvedEquation,
      ),
      roundListener: this,
      spawnPositionChooser: FixedSpawnPositionChooser(step.spawnPosition),
      spawnNextBlockAfterRound: false,
      initialContent: blocksFromRows(step.gridRows),
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
    grid.spawnOrigin = header.nextBlockDisplay;
    _header = header;
    _addStepComponent(header);
    _addStepComponent(grid);
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
        maxWidth: (size.x - 2 * margin).clamp(40, double.infinity),
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
