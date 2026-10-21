import 'dart:async';

import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/next_block_planner.dart';
import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:calc_tetris/global/next_block_display.dart';
import 'package:calc_tetris/global/score/score_display.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Header extends PositionComponent {
  final ScoreKeeper _scoreKeeper;
  final NextBlockPlanner _nextBlockPlanner;
  late final ScoreDisplay _scoreDisplay;
  final NextBlockDisplay nextBlockDisplay;
  StreamSubscription<int>? _scoreSubscription;
  StreamSubscription<List<List<MathSingleBlock>>>? _nextBlockSubscription;

  Header({
    required this._scoreKeeper,
    required this._nextBlockPlanner,
    required double gridCellSize,
    super.size,
    super.position,
  }) : nextBlockDisplay = NextBlockDisplay(
         cellSize: gridCellSize,
         model: _nextBlockPlanner.upcoming,
         size: Vector2(size!.x * 0.4, size.y * 0.8),
         position: Vector2(size.x * 0.97, size.y / 2),
         anchor: Anchor.centerRight,
       );

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color.fromARGB(180, 38, 32, 32),
      ),
    );
    _scoreDisplay = ScoreDisplay(
      size: Vector2(size.x * 0.4, size.y * 0.4),
      position: Vector2(size.x * 0.03, size.y / 2),
      anchor: Anchor.centerLeft,
    )..score = _scoreKeeper.total;
    add(_scoreDisplay);
    _scoreSubscription = _scoreKeeper.totals.listen(
      (total) => _scoreDisplay.score = total,
    );
    add(nextBlockDisplay);
    _nextBlockSubscription = _nextBlockPlanner.upcomingChanges.listen(
      (model) => nextBlockDisplay.model = model,
    );
    return super.onLoad();
  }

  @override
  void onRemove() {
    _scoreSubscription?.cancel();
    _nextBlockSubscription?.cancel();
    super.onRemove();
  }
}
