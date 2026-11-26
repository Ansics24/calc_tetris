import 'package:magic_blocks/block/block_contour.dart';
import 'package:test/test.dart';

/// Cells and corners are `(x, y)` in grid units, y points downwards.
void main() {
  test('there is no contour without cells', () {
    expect(blockContours([]), isEmpty);
  });

  test('goes clockwise around a single cell, starting top left', () {
    expect(blockContours([(0, 0)]), [
      [(0, 0), (1, 0), (1, 1), (0, 1)],
    ]);
  });

  test('surrounds neighbouring cells as one shape without inner lines', () {
    expect(blockContours([(0, 0), (1, 0), (2, 0)]), [
      [(0, 0), (3, 0), (3, 1), (0, 1)],
    ]);
  });

  test('follows the notch of an L shape', () {
    expect(blockContours([(0, 0), (1, 0), (0, 1)]), [
      [(0, 0), (2, 0), (2, 1), (1, 1), (1, 2), (0, 2)],
    ]);
  });

  test('keeps the offset of cells away from the origin of the block', () {
    expect(blockContours([(1, 1)]), [
      [(1, 1), (2, 1), (2, 2), (1, 2)],
    ]);
  });

  test('surrounds cells which only touch at a corner one by one', () {
    expect(blockContours([(0, 0), (1, 1)]), [
      [(0, 0), (1, 0), (1, 1), (0, 1)],
      [(1, 1), (2, 1), (2, 2), (1, 2)],
    ]);
  });
}
