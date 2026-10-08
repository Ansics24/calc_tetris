import 'package:calc_tetris/core/block/model/math_single_block.dart';

class Equation {
  static final regExp = RegExp(r'^\d+(?:[+-]\d+)*=\d+(?:[+-]\d+)*$');
  final List<MathSingleBlock> _blocks;

  Equation.fromBlocks(this._blocks);

  bool isValid() {
    if (_blocks.isEmpty) {
      return false;
    }
    if (!_matchesregExp()) {
      return false;
    }
    return true;
  }

  bool _matchesregExp() {
    return regExp.hasMatch(toString());
  }

  @override
  String toString() {
    return _blocks.map((b) => b.toString()).join();
  }
}
