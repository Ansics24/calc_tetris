import 'package:calc_tetris/core/grid/int_vector_2.dart';

enum CompoundBlockShape {
  b2x2(outerSizeX: 2, outerSizeY: 2),
  t3x2(outerSizeX: 3, outerSizeY: 2),
  l3x2(outerSizeX: 3, outerSizeY: 2),
  i4x1(outerSizeX: 4, outerSizeY: 1),
  s3x2(outerSizeX: 3, outerSizeY: 2);

  final int outerSizeX;
  final int outerSizeY;

  const CompoundBlockShape({
    required this.outerSizeX,
    required this.outerSizeY,
  });

  IntVector2 get outerSize => IntVector2(outerSizeX, outerSizeY);
}
