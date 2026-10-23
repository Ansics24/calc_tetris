import 'package:calc_tetris/block/compound_block_component.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:flame/components.dart';

abstract class CompoundBlockBehaviour extends PositionComponent {
  late double cellSize;
  late GridController gridController;
  late CompoundBlockComponent owner;

  @override
  void onMount() {
    final grid = findParent<Grid>();
    cellSize = grid!.cellSize;
    owner = findParent<CompoundBlockComponent>()!;
    gridController = grid.controller;
    size = owner.size;
  }
}
