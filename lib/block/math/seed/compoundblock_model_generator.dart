import 'package:calc_tetris/block/model/single_block.dart';

abstract interface class CompoundblockModelGenerator {
  List<List<SingleBlock>> generate();
}
