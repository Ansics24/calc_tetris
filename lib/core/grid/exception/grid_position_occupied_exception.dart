import 'package:calc_tetris/core/grid/int_vector_2.dart';

class GridPositionOccupiedException implements Exception {
  late String _message;

  GridPositionOccupiedException({required IntVector2 position}) {
    _message = "Grid-position $position is occupied";
  }

  @override
  String toString() {
    return _message;
  }
}
