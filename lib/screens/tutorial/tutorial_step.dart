import 'package:calc_tetris/util/int_vector_2.dart';

/// One step of the tutorial.
sealed class TutorialStep {}

/// A pause: the text explains what happens next, the button goes on.
class MessageStep extends TutorialStep {
  final String text;
  final String buttonLabel;

  MessageStep(this.text, {this.buttonLabel = 'Weiter'});
}

/// A prepared board the player has to solve.
///
/// [gridRows] describe the prepared grid (one text row per grid row, see
/// `blocksFromRows`), [blockRows] the block to move. The block enters the grid
/// at [spawnPosition]. Rotated [solutionRotations] times and put at
/// [solutionPosition] it solves an equation.
class PlayStep extends TutorialStep {
  final String hint;
  final List<String> gridRows;
  final List<String> blockRows;
  final IntVector2 spawnPosition;
  final IntVector2 solutionPosition;
  final int solutionRotations;

  PlayStep({
    required this.hint,
    required this.gridRows,
    required this.blockRows,
    required this.spawnPosition,
    required this.solutionPosition,
    required this.solutionRotations,
  });
}
