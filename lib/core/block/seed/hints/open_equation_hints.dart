/// Tokens that would help the player to finish equations on the grid.
class OpenEquationHints {
  /// Tokens that complete a correct equation right away.
  final Set<String> completions;

  /// Tokens that can be placed next to a block without breaking the syntax of
  /// a possible equation.
  final Set<String> extensions;

  OpenEquationHints({required this.completions, required this.extensions});
}
