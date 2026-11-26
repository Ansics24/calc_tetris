import 'package:flutter_test/flutter_test.dart';
import 'package:magic_blocks/block/active_block_outline.dart';
import 'package:magic_blocks/grid/play_mode.dart';
import 'package:magic_blocks/grid/power_up_found_listener.dart';

import '../support/pump_outline_grid.dart';
import '../support/test_grid.dart';

void main() {
  testWidgets('outlines the block in play', (tester) async {
    final pumped = await pumpOutlineGrid(tester);

    final block = pumped.grid.endlessController.currentBlock!;

    expect(block.children.whereType<ActiveBlockOutline>(), hasLength(1));
  });

  testWidgets('drops the outline as soon as the block lands', (tester) async {
    final pumped = await pumpOutlineGrid(tester);

    pumped.grid.endlessController.placeCurrentBlock();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      pumped.game.descendants().whereType<ActiveBlockOutline>(),
      isEmpty,
    );
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('outlines the next block only', (tester) async {
    final pumped = await pumpOutlineGrid(tester);
    final controller = pumped.grid.endlessController;
    final first = controller.currentBlock;

    controller.placeCurrentBlock();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(controller.currentBlock, isNot(same(first)));
    final outlines = pumped.game.descendants().whereType<ActiveBlockOutline>();
    expect(outlines.single.parent, same(controller.currentBlock));
  });

  testWidgets('hides the outline while a power-up is in use', (tester) async {
    final pumped = await pumpOutlineGrid(tester);
    final controller = pumped.grid.endlessController;
    final outline = controller.currentBlock!.children
        .whereType<ActiveBlockOutline>()
        .single;

    controller.playMode = const PlayMode.powerUpInUse(PowerUpType.cannon);
    expect(outline.isShown, isFalse);

    controller.playMode = const PlayMode.defaultMode();
    expect(outline.isShown, isTrue);
  });
}
