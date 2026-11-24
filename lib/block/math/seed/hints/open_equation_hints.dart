/// Tokens that would help the player to finish equations on the grid.
class OpenEquationHints {
  /// Tokens that turn the whole run of connected blocks into a correct
  /// equation.
  final Set<String> completions;

  /// The points the best equation earns that each token of [completions]
  /// completes. A token without an entry earns nothing known.
  final Map<String, int> completionPoints;

  /// Tokens that complete an equation inside a longer run. The solver removes
  /// that equation, but other blocks of the run stay behind.
  final Set<String> partialCompletions;

  /// The points the best equation earns that each token of
  /// [partialCompletions] completes.
  final Map<String, int> partialCompletionPoints;

  /// Tokens that can be placed next to a block without breaking the syntax of
  /// a possible equation.
  final Set<String> extensions;

  OpenEquationHints({
    required this.completions,
    required this.extensions,
    this.partialCompletions = const {},
    this.completionPoints = const {},
    this.partialCompletionPoints = const {},
  });
}
