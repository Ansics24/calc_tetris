/// Tokens that would help the player to finish equations on the grid.
class OpenEquationHints {
  /// Tokens that turn the whole run of connected blocks into a correct
  /// equation.
  final Set<String> completions;

  /// Tokens that complete an equation inside a longer run. The solver removes
  /// that equation, but other blocks of the run stay behind.
  final Set<String> partialCompletions;

  /// Tokens that can be placed next to a block without breaking the syntax of
  /// a possible equation.
  final Set<String> extensions;

  OpenEquationHints({
    required this.completions,
    required this.extensions,
    this.partialCompletions = const {},
  });
}
