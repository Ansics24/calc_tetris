import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/model/math_single_block.dart';
import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/layout/header/next_block_display.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

List<List<MathSingleBlock>> _model(int width, int height) => List.generate(
  width,
  (_) => List.generate(height, (_) => MathNumberBlock(number: 1)),
);

void main() {
  test('renders the block at 80 percent of the grid scale', () {
    expect(NextBlockDisplay.previewScale, 0.8);
  });

  test('is labeled in german', () {
    expect(NextBlockDisplay.labelText, 'Nächster Stein');
  });

  test('a cell is 80 percent as big as a cell in the grid', () {
    final display = NextBlockDisplay(
      cellSize: 50,
      model: _model(1, 1),
      size: Vector2(200, 100),
    );

    expect(display.previewCellSize, 40);
  });

  test('the shown block is as big as its cells are', () {
    final display = NextBlockDisplay(
      cellSize: 50,
      model: _model(2, 3),
      size: Vector2(200, 100),
    );

    expect(display.previewBlockSize, Vector2(2 * 40, 3 * 40));
  });

  test('showing another block updates the size', () {
    final display = NextBlockDisplay(
      cellSize: 50,
      model: _model(2, 3),
      size: Vector2(200, 100),
    );

    display.model = _model(4, 1);

    expect(display.previewBlockSize, Vector2(4 * 40, 1 * 40));
  });

  test('empty cells of the model take space as well', () {
    final model = [
      [MathNumberBlock(number: 1), NullBlock()],
      [NullBlock(), MathNumberBlock(number: 2)],
    ];
    final display = NextBlockDisplay(
      cellSize: 50,
      model: model,
      size: Vector2(200, 100),
    );

    expect(display.previewBlockSize, Vector2(2 * 40, 2 * 40));
  });

  test('the block is centered inside the display', () {
    final display = NextBlockDisplay(
      cellSize: 50,
      model: _model(2, 1),
      size: Vector2(200, 100),
      position: Vector2(10, 20),
    );

    // display center (110, 70) minus half of the shown block (40, 20)
    expect(display.previewBlockAbsoluteTopLeft, Vector2(70, 50));
  });
}
