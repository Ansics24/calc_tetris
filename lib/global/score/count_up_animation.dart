import 'package:flutter/animation.dart';

/// Tweens an integer towards a target value. A new target continues from the
/// currently shown value, so consecutive updates never jump.
class CountUpAnimation {
  final double duration;
  final Curve curve;

  int _value;
  int _from;
  int _target;
  double _elapsed = 0;

  CountUpAnimation({
    this.duration = 1.2,
    this.curve = Curves.easeOutCubic,
    int initial = 0,
  }) : _value = initial,
       _from = initial,
       _target = initial;

  int get value => _value;

  bool get isAnimating => _value != _target;

  void animateTo(int target) {
    _from = _value;
    _target = target;
    _elapsed = 0;
  }

  void update(double dt) {
    if (!isAnimating) {
      return;
    }
    _elapsed += dt;
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    _value = progress >= 1
        ? _target
        : (_from + (_target - _from) * curve.transform(progress)).round();
  }
}
