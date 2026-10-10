import 'package:calc_tetris/core/block/math_equals_block_component.dart';
import 'package:calc_tetris/core/block/model/math_equals_block.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group("Adjacent blocks in row", () {
    final gridModel = GridModel(
      size: IntVector2(5, 5),
      gridComponent: Grid(blockCount: IntVector2(5, 5)),
    );
    gridModel.cellSize = 50;

    // First line (x,x,-,-,-)
    gridModel.addSingleBlock(
      Uuid().toString(),
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(0, 0),
    );
    gridModel.addSingleBlock(
      Uuid().toString(),
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(1, 0),
    );

    // Second line (x,x,x,x,x)
    gridModel.addSingleBlock(
      Uuid().toString(),
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(0, 1),
    );
    gridModel.addSingleBlock(
      Uuid().toString(),
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(1, 1),
    );
    gridModel.addSingleBlock(
      Uuid().toString(),
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(2, 1),
    );
    gridModel.addSingleBlock(
      Uuid().toString(),
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(3, 1),
    );
    gridModel.addSingleBlock(
      Uuid().toString(),
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(4, 1),
    );

    test("No block in row => Empty list", () {
      var blocks = gridModel.findAllConnectedBlocks(
        IntVector2(2, 2),
        .horizontal,
      );

      expect(blocks, isEmpty);
    });

    test("two blocks in row hitted => List(2)", () {
      var blocks = gridModel.findAllConnectedBlocks(
        IntVector2(0, 0),
        .horizontal,
      );

      expect(blocks, hasLength(2));
    });

    test("two blocks in row not hitted => empty", () {
      var blocks = gridModel.findAllConnectedBlocks(
        IntVector2(2, 0),
        .horizontal,
      );

      expect(blocks, isEmpty);
    });

    test("full row hitted left", () {
      var blocks = gridModel.findAllConnectedBlocks(
        IntVector2(1, 1),
        .horizontal,
      );

      expect(blocks, hasLength(5));
    });

    test("full row hitted right", () {
      var blocks = gridModel.findAllConnectedBlocks(
        IntVector2(4, 1),
        .horizontal,
      );

      expect(blocks, hasLength(5));
    });
  });
}
