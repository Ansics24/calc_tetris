import 'dart:async';

import 'package:magic_blocks/screens/tutorial/tutorial_step.dart';

/// Leads through the steps of the tutorial. Knows nothing about the game, it
/// only reacts to the player pressing "continue" and to finished rounds.
class TutorialRunner {
  final List<TutorialStep> _steps;
  final void Function() _onFinished;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  int _index = 0;
  int _attempt = 0;
  bool _finished = false;

  TutorialRunner({
    required List<TutorialStep> steps,
    required this._onFinished,
  }) : _steps = steps {
    if (steps.isEmpty) {
      throw ArgumentError.value(steps, 'steps', 'must not be empty');
    }
  }

  TutorialStep get current => _steps[_index];

  /// How often the current play step failed so far.
  int get attempt => _attempt;

  bool get isFinished => _finished;

  /// Emits whenever the current step changes or a play step starts over.
  Stream<void> get changes => _changes.stream;

  /// The player pressed the button of the current message.
  void continueFromMessage() {
    if (_finished || current is! MessageStep) {
      return;
    }
    _next();
  }

  /// A round of the current play step ended with [pointsEarned] points.
  void onRoundFinished(int pointsEarned) {
    if (_finished || current is! PlayStep) {
      return;
    }
    if (pointsEarned > 0) {
      _next();
    } else {
      restartStep();
    }
  }

  /// The player reached the goal of the current cannon step.
  void onCannonStepCompleted() {
    if (_finished || current is! CannonStep) {
      return;
    }
    _next();
  }

  /// Starts the current step over, e.g. after a failed attempt.
  void restartStep() {
    if (_finished || current is MessageStep) {
      return;
    }
    _attempt++;
    _changes.add(null);
  }

  void _next() {
    _attempt = 0;
    if (_index == _steps.length - 1) {
      _finished = true;
      _onFinished();
      return;
    }
    _index++;
    _changes.add(null);
  }
}
