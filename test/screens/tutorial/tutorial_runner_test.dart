import 'package:magic_blocks/screens/tutorial/tutorial_runner.dart';
import 'package:magic_blocks/screens/tutorial/tutorial_step.dart';
import 'package:magic_blocks/util/int_vector_2.dart';
import 'package:test/test.dart';

PlayStep _play(String hint) => PlayStep(
  hint: hint,
  gridRows: const ['2+3'],
  blockRows: const ['=5'],
  spawnPosition: IntVector2(0, 0),
  solutionPosition: IntVector2(0, 0),
  solutionRotations: 0,
);

CannonStep _cannon() => CannonStep(
  hint: 'Aktiviere',
  activeHint: 'Schieße',
  gridRows: const ['2+3'],
  blockRows: const ['=5'],
  spawnPosition: IntVector2(0, 0),
  targets: [IntVector2(0, 0)],
);

TutorialRunner _runner({void Function()? onFinished}) => TutorialRunner(
  steps: [MessageStep('Start'), _play('Ziehe'), MessageStep('Ende')],
  onFinished: onFinished ?? () {},
);

void main() {
  test('starts with the first step', () {
    final runner = _runner();

    expect((runner.current as MessageStep).text, 'Start');
    expect(runner.isFinished, isFalse);
    expect(runner.attempt, 0);
  });

  test('refuses an empty script', () {
    expect(
      () => TutorialRunner(steps: [], onFinished: () {}),
      throwsArgumentError,
    );
  });

  group('message steps', () {
    test('go on to the next step when continued', () {
      final runner = _runner();

      runner.continueFromMessage();

      expect(runner.current, isA<PlayStep>());
    });

    test('announce the change', () {
      final runner = _runner();
      var changes = 0;
      runner.changes.listen((_) => changes++);

      runner.continueFromMessage();

      expect(changes, 1);
    });
  });

  group('play steps', () {
    test('ignore continue, only solving them goes on', () {
      final runner = _runner()..continueFromMessage();

      runner.continueFromMessage();

      expect(runner.current, isA<PlayStep>());
    });

    test('go on when a round earned points', () {
      final runner = _runner()..continueFromMessage();

      runner.onRoundFinished(6);

      expect((runner.current as MessageStep).text, 'Ende');
    });

    test('start over when a round earned nothing', () {
      final runner = _runner()..continueFromMessage();
      var changes = 0;
      runner.changes.listen((_) => changes++);

      runner.onRoundFinished(0);

      expect(runner.current, isA<PlayStep>());
      expect(runner.attempt, 1);
      expect(changes, 1);
    });

    test('count every failed attempt', () {
      final runner = _runner()..continueFromMessage();

      runner.onRoundFinished(0);
      runner.onRoundFinished(0);

      expect(runner.attempt, 2);
    });

    test('begin the next step with a fresh attempt count', () {
      final runner = _runner()..continueFromMessage();
      runner.onRoundFinished(0);

      runner.onRoundFinished(6);

      expect(runner.attempt, 0);
    });
  });

  group('message steps ignore a round result', () {
    test('even if it earned points', () {
      final runner = _runner();

      runner.onRoundFinished(6);

      expect((runner.current as MessageStep).text, 'Start');
    });
  });

  group('the end', () {
    test('is reached by continuing the last message', () {
      var finished = 0;
      final runner = _runner(onFinished: () => finished++)
        ..continueFromMessage()
        ..onRoundFinished(6);
      expect(finished, 0);

      runner.continueFromMessage();

      expect(finished, 1);
      expect(runner.isFinished, isTrue);
    });

    test('is announced only once', () {
      var finished = 0;
      final runner = _runner(onFinished: () => finished++)
        ..continueFromMessage()
        ..onRoundFinished(6)
        ..continueFromMessage();

      runner.continueFromMessage();
      runner.onRoundFinished(6);

      expect(finished, 1);
    });
  });

  group('cannon steps', () {
    TutorialRunner cannonRunner() => TutorialRunner(
      steps: [_cannon(), MessageStep('Ende')],
      onFinished: () {},
    );

    test('go on when the cannon step is completed', () {
      final runner = cannonRunner();

      runner.onCannonStepCompleted();

      expect((runner.current as MessageStep).text, 'Ende');
    });

    test('start over when restarted', () {
      final runner = cannonRunner();
      var changes = 0;
      runner.changes.listen((_) => changes++);

      runner.restartStep();

      expect(runner.current, isA<CannonStep>());
      expect(runner.attempt, 1);
      expect(changes, 1);
    });

    test('ignore continue and round results', () {
      final runner = cannonRunner();

      runner.continueFromMessage();
      runner.onRoundFinished(6);

      expect(runner.current, isA<CannonStep>());
    });

    test('are the only steps that can be completed that way', () {
      final runner = _runner();

      runner.onCannonStepCompleted();

      expect((runner.current as MessageStep).text, 'Start');
    });
  });
}
