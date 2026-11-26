import 'package:magic_blocks/magic_blocks_app.dart';
import 'package:magic_blocks/magic_blocks_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps the game out of the safe area of the device', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    tester.view.padding = const FakeViewPadding(
      top: 40,
      bottom: 30,
      left: 10,
      right: 20,
    );
    tester.view.viewPadding = tester.view.padding;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MagicBlocksApp(game: MagicBlocksGame()));
    await tester.pump();
    await tester.pump();

    final rect = tester.getRect(find.byType(GameWidget<MagicBlocksGame>));
    expect(rect.top, 40);
    expect(rect.bottom, 800 - 30);
    expect(rect.left, 10);
    expect(rect.right, 400 - 20);

    // let delayed text redraw timers run out
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('starts its own game when none is given', (tester) async {
    await tester.pumpWidget(MagicBlocksApp());
    await tester.pump();
    await tester.pump();

    expect(find.byType(GameWidget<MagicBlocksGame>), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('paints the area around the game in the colors of the game', (
    tester,
  ) async {
    final game = MagicBlocksGame();
    await tester.pumpWidget(MagicBlocksApp(game: game));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(_surroundGradientColors(tester), game.surroundColors.value);

    game.surroundColors.value = const [Color(0xFFFF0000), Color(0xFF0000FF)];
    await tester.pump();

    expect(_surroundGradientColors(tester), [
      const Color(0xFFFF0000),
      const Color(0xFF0000FF),
    ]);

    await tester.pump(const Duration(seconds: 1));
  });
}

List<Color>? _surroundGradientColors(WidgetTester tester) {
  final surround = tester.widget<DecoratedBox>(
    find.byKey(MagicBlocksApp.surroundKey),
  );
  final decoration = surround.decoration as BoxDecoration;
  return (decoration.gradient as LinearGradient?)?.colors;
}
