import 'dart:async';

import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:calc_tetris/global/hud/hud_panel.dart';
import 'package:calc_tetris/global/score/score_display.dart';
import 'package:calc_tetris/global/score/score_display_style.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Card showing the running score.
class HudBar extends PositionComponent with HudPanelBackground {
  final ScoreKeeper _scoreKeeper;
  late final ScoreDisplay _scoreDisplay;
  StreamSubscription<int>? _scoreSubscription;

  HudBar({required this._scoreKeeper, super.size, super.position});

  @override
  FutureOr<void> onLoad() {
    _scoreDisplay = ScoreDisplay(
      size: size,
      style: const ScoreDisplayStyle(
        decoration: BoxDecoration(),
        textStyle: ScoreDisplayStyle.standardTextStyle,
        labelStyle: ScoreDisplayStyle.standardLabelStyle,
      ),
    )..score = _scoreKeeper.total;
    add(_scoreDisplay);
    _scoreSubscription = _scoreKeeper.totals.listen(
      (total) => _scoreDisplay.score = total,
    );
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    renderPanel(canvas);
    super.render(canvas);
  }

  @override
  void onRemove() {
    _scoreSubscription?.cancel();
    super.onRemove();
  }
}
