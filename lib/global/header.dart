import 'dart:async';

import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:calc_tetris/global/score/score_display.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Header extends PositionComponent {
  final ScoreKeeper _scoreKeeper;
  late final ScoreDisplay _scoreDisplay;
  StreamSubscription<int>? _scoreSubscription;

  Header({required this._scoreKeeper, super.size, super.position});

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color.fromARGB(180, 38, 32, 32),
      ),
    );
    _scoreDisplay = ScoreDisplay(
      size: Vector2(size.x * 0.5, size.y * 0.4),
      position: size / 2,
      anchor: Anchor.center,
    )..score = _scoreKeeper.total;
    add(_scoreDisplay);
    _scoreSubscription = _scoreKeeper.totals.listen(
      (total) => _scoreDisplay.score = total,
    );
    return super.onLoad();
  }

  @override
  void onRemove() {
    _scoreSubscription?.cancel();
    super.onRemove();
  }
}
