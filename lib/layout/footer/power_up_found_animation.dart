import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/layout/footer/cannon_button.dart';
import 'package:calc_tetris/layout/footer/powerup_button.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

/// Shows that a power-up was found: it appears where it was found, grows
/// quickly, flies to the button of the power-up and raises the count there. It
/// removes itself afterwards. Needs nothing but its data, the game only adds
/// it.
class PowerUpFoundAnimation extends PositionComponent {
  /// The power-up grows this long, standing still.
  static const double growDuration = 0.25;

  /// Then it flies to the button this long.
  static const double flyDuration = 0.6;

  /// How big the power-up gets, in cells.
  static const double _grownCellFactor = 2.5;

  final PowerUpButton _targetButton;
  final Vector2 _foundPositionAbsoluteCenter;

  PowerUpFoundAnimation({
    required PowerUpType type,
    required Vector2 foundPositionAbsoluteCenter,
    required this._targetButton,
    required double startCellSize,
  }) : _foundPositionAbsoluteCenter = foundPositionAbsoluteCenter.clone(),
       super(
         size: Vector2.all(startCellSize * _grownCellFactor),
         anchor: Anchor.center,
         priority: 500,
       ) {
    // it starts as big as one cell and grows to its full size
    scale = Vector2.all(1 / _grownCellFactor);
    add(_iconFor(type)..size = size.clone());
  }

  static PowerUpButton _iconFor(PowerUpType type) => switch (type) {
    PowerUpType.cannon => CannonButton(showBadge: false),
  };

  @override
  void onMount() {
    super.onMount();
    position = _toLocal(_foundPositionAbsoluteCenter);
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: growDuration, curve: Curves.easeOut),
        onComplete: _fly,
      ),
    );
  }

  void _fly() {
    add(
      ScaleEffect.to(
        Vector2.all(_targetButton.size.x / size.x),
        EffectController(duration: flyDuration, curve: Curves.easeIn),
      ),
    );
    add(
      MoveToEffect(
        _toLocal(_targetButton.absoluteCenter),
        EffectController(duration: flyDuration, curve: Curves.easeIn),
        onComplete: _arrive,
      ),
    );
  }

  void _arrive() {
    _targetButton.count += 1;
    removeFromParent();
  }

  /// The positions are given on screen, the parent may sit somewhere else.
  Vector2 _toLocal(Vector2 absolutePosition) {
    final parent = this.parent;
    return parent is PositionComponent
        ? parent.absoluteToLocal(absolutePosition)
        : absolutePosition.clone();
  }
}
