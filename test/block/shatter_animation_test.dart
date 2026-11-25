import 'package:calc_tetris/block/shatter_animation.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

Future<FlameGame> _pump(WidgetTester tester, ShatterAnimation animation) async {
  final game = FlameGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  game.add(animation);
  await tester.pump();
  return game;
}

ShatterAnimation _animation() => ShatterAnimation(
  color: const Color(0xFF00AA00),
  size: Vector2.all(40),
  position: Vector2(100, 100),
);

void main() {
  test('breaks into many particles', () {
    expect(ShatterAnimation.particleCount, greaterThanOrEqualTo(20));
  });

  test('takes the color of the block', () {
    expect(_animation().color, const Color(0xFF00AA00));
  });

  testWidgets('shows the particles where the block was', (tester) async {
    final animation = _animation();

    await _pump(tester, animation);

    expect(animation.position, Vector2(100, 100));
    expect(animation.children.whereType<ParticleSystemComponent>(), isNotEmpty);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('removes itself when the particles are gone', (tester) async {
    final game = await _pump(tester, _animation());

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(game.descendants().whereType<ShatterAnimation>(), isEmpty);
  });
}
