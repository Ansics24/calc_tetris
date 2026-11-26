import 'package:flutter_test/flutter_test.dart';
import 'package:magic_blocks/block/active_block_outline.dart';

import '../support/pump_outline_grid.dart';
import '../support/test_grid.dart';

Future<ActiveBlockOutline> _outline(WidgetTester tester) async {
  final pumped = await pumpOutlineGrid(tester);
  return pumped.grid.endlessController.currentBlock!.children
      .whereType<ActiveBlockOutline>()
      .single;
}

void main() {
  testWidgets('surrounds the visible blocks only', (tester) async {
    final outline = await _outline(tester);

    expect(outline.contours, [
      [(0, 0), (2, 0), (2, 1), (1, 1), (1, 2), (0, 2)],
    ]);
  });

  testWidgets('follows a rotation of the block', (tester) async {
    final outline = await _outline(tester);

    outline.parent.rotate();
    await tester.pump(const Duration(milliseconds: 200));

    expect(outline.contours, [
      [(0, 0), (2, 0), (2, 2), (1, 2), (1, 1), (0, 1)],
    ]);
  });

  testWidgets('moves its dashes slowly forward over time', (tester) async {
    final outline = await _outline(tester);
    final before = outline.phase;

    outline.update(0.5);

    expect(ActiveBlockOutline.cellsPerSecond, inInclusiveRange(0.1, 1));
    expect(
      outline.phase,
      closeTo(
        (before +
                0.5 *
                    ActiveBlockOutline.cellsPerSecond /
                    ActiveBlockOutline.dashSpacingInCells) %
            1,
        1e-9,
      ),
    );
  });

  testWidgets('keeps the phase between 0 and 1', (tester) async {
    final outline = await _outline(tester);

    outline.update(1000.3);

    expect(outline.phase, greaterThanOrEqualTo(0));
    expect(outline.phase, lessThan(1));
  });

  testWidgets('is not shown while the block is locked', (tester) async {
    final outline = await _outline(tester);
    expect(outline.isShown, isTrue);

    outline.parent.isLocked = true;

    expect(outline.isShown, isFalse);
  });
}
