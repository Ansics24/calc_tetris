import 'dart:async';

import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/layout/header/hud/header_layout.dart';
import 'package:calc_tetris/layout/header/hud/hud_bar.dart';
import 'package:calc_tetris/layout/header/next_block_display.dart';
import 'package:calc_tetris/layout/header/next_block_display_style.dart';
import 'package:calc_tetris/theme/light_theme.dart';
import 'package:flame/components.dart';

/// Everything above the grid: score card and next block card.
class Header extends PositionComponent {
  final ScoreKeeper _scoreKeeper;
  final NextBlockPlanner _nextBlockPlanner;
  final NextBlockDisplay nextBlockDisplay;
  final HeaderLayout _layout;
  StreamSubscription<List<List<SingleBlock>>>? _nextBlockSubscription;

  Header({
    required this._scoreKeeper,
    required this._nextBlockPlanner,
    required double gridCellSize,
    super.size,
    super.position,
  }) : _layout = HeaderLayout(size!),
       nextBlockDisplay = NextBlockDisplay(
         cellSize: gridCellSize,
         model: _nextBlockPlanner.upcoming,
         size: HeaderLayout(size).cardSize,
         position: HeaderLayout(size).nextBlockCardPosition,
         style: NextBlockDisplayStyle.fromColorScheme(colorScheme),
       );

  @override
  FutureOr<void> onLoad() {
    add(
      HudBar(
        scoreKeeper: _scoreKeeper,
        size: _layout.cardSize,
        position: _layout.scoreCardPosition,
      ),
    );
    add(nextBlockDisplay);
    _nextBlockSubscription = _nextBlockPlanner.upcomingChanges.listen(
      (model) => nextBlockDisplay.model = model,
    );
    return super.onLoad();
  }

  @override
  void onRemove() {
    _nextBlockSubscription?.cancel();
    super.onRemove();
  }
}
