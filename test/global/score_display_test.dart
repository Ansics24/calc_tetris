import 'dart:ui';

import 'package:calc_tetris/global/score/score_display.dart';
import 'package:calc_tetris/global/score/score_display_style.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  test('shows 0 initially', () {
    expect(ScoreDisplay(size: Vector2(200, 50)).displayedScore, 0);
  });

  test('counts up to a new score over time', () {
    final display = ScoreDisplay(
      size: Vector2(200, 50),
      countUpDuration: 1.0,
    )..score = 48;

    display.update(0.5);
    expect(display.displayedScore, inExclusiveRange(0, 48));

    display.update(0.5);
    expect(display.displayedScore, 48);
  });

  test('renders with a custom decoration and text style', () {
    final display = ScoreDisplay(
      size: Vector2(200, 50),
      style: ScoreDisplayStyle(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.amber, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    )..score = 10;
    display.update(2.0);

    expect(
      () => display.render(Canvas(PictureRecorder())),
      returnsNormally,
    );
  });
}
