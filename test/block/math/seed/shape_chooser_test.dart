import 'package:calc_tetris/block/math/seed/shape_chooser.dart';
import 'package:test/test.dart';

void main() {
  test('Shape chooser chooses shape', () {
    final chooser = ShapeChooser();
    var next = chooser.next();

    expect(next, isNotNull);
  });
}
