import 'package:calc_tetris/core/grid/int_vector_2.dart';

abstract interface class GridModelAware {
  bool anyPositionBlocked(Iterable<IntVector2> listOfPositions);
}
