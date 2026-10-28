import 'package:calc_tetris/layout/header/stop_button.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  test('calls onPressed when pressed', () {
    var presses = 0;
    final button = StopButton(
      onPressed: () => presses++,
      size: Vector2.all(40),
    );

    button.press();

    expect(presses, 1);
  });
}
