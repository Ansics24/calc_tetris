import 'package:calc_tetris/global/score/count_up_animation.dart';
import 'package:test/test.dart';

void main() {
  test('starts at the initial value and is idle', () {
    final animation = CountUpAnimation(initial: 5);
    expect(animation.value, 5);
    expect(animation.isAnimating, isFalse);
  });

  test('counts up gradually and ends exactly at the target', () {
    final animation = CountUpAnimation(duration: 1.0)..animateTo(100);

    animation.update(0.5);
    expect(animation.value, inExclusiveRange(0, 100));
    expect(animation.isAnimating, isTrue);

    animation.update(0.5);
    expect(animation.value, 100);
    expect(animation.isAnimating, isFalse);
  });

  test('value never decreases while counting up', () {
    final animation = CountUpAnimation(duration: 1.0)..animateTo(1000);
    var previous = animation.value;
    for (var i = 0; i < 20; i++) {
      animation.update(0.05);
      expect(animation.value, greaterThanOrEqualTo(previous));
      previous = animation.value;
    }
  });

  test('a new target continues from the currently shown value', () {
    final animation = CountUpAnimation(duration: 1.0)..animateTo(100);
    animation.update(0.5);
    final shown = animation.value;

    animation.animateTo(200);
    expect(animation.value, shown);

    animation.update(1.0);
    expect(animation.value, 200);
  });

  test('animating to the current value does not start an animation', () {
    final animation = CountUpAnimation(initial: 7)..animateTo(7);
    expect(animation.isAnimating, isFalse);
  });

  test('update without a running animation changes nothing', () {
    final animation = CountUpAnimation(initial: 3)..update(1.0);
    expect(animation.value, 3);
  });
}
