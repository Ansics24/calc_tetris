import 'dart:async';

import 'package:magic_blocks/block/math/scoring/score_keeper.dart';
import 'package:magic_blocks/layout/header/stop_button.dart';
import 'package:magic_blocks/persistence/database_service.dart';
import 'package:magic_blocks/persistence/in_memory_database_service.dart';
import 'package:magic_blocks/persistence/model/game_mode.dart';
import 'package:magic_blocks/persistence/model/game_mode_name.dart';
import 'package:magic_blocks/screens/endless/endless_game.dart';
import 'package:magic_blocks/screens/stopgame/stop_game_dialog.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

/// Saving does not finish until the test says so.
class _SlowDatabaseService implements DatabaseService {
  final Completer<bool> _saving = Completer<bool>();

  void finishSaving() => _saving.complete(true);

  void failSaving() => _saving.completeError(StateError('database is broken'));

  @override
  Future<GameMode?> loadGameMode(GameModeName name) async => null;

  @override
  Future<bool> saveHighscoreIfHigher(GameModeName name, int score) =>
      _saving.future;
}

class _Host extends FlameGame {
  final EndlessGame endless;

  _Host(this.endless);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(endless);
  }
}

Future<_Host> _pump(
  WidgetTester tester, {
  required DatabaseService service,
  required int score,
  void Function()? onQuit,
}) async {
  final host = _Host(
    EndlessGame(
      onQuit: onQuit,
      databaseService: service,
      scoreKeeper: ScoreKeeper()..add(score),
    ),
  );
  await tester.pumpWidget(GameWidget(game: host));
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 500)),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  // Text boxes redraw delayed; let those timers run out.
  await tester.pump(const Duration(seconds: 1));
  return host;
}

Future<StopGameDialog> _askToStop(WidgetTester tester, _Host host) async {
  host.descendants().whereType<StopButton>().first.press();
  await tester.pump();
  return host.descendants().whereType<StopGameDialog>().first;
}

void main() {
  testWidgets('saves the reached score when the player confirms to quit', (
    tester,
  ) async {
    final service = InMemoryDatabaseService();
    final host = await _pump(tester, service: service, score: 55);
    final dialog = await _askToStop(tester, host);

    dialog.yesButton.press();
    await tester.pump();

    final mode = await service.loadGameMode(GameModeName.endless);
    expect(mode!.highscore, 55);
  });

  testWidgets('still quits after the score was saved', (tester) async {
    var quit = false;
    final host = await _pump(
      tester,
      service: InMemoryDatabaseService(),
      score: 55,
      onQuit: () => quit = true,
    );
    final dialog = await _askToStop(tester, host);

    dialog.yesButton.press();
    await tester.pump();

    expect(quit, isTrue);
  });

  testWidgets('quits only after the score was saved', (tester) async {
    final service = _SlowDatabaseService();
    var quit = false;
    final host = await _pump(
      tester,
      service: service,
      score: 55,
      onQuit: () => quit = true,
    );
    final dialog = await _askToStop(tester, host);

    dialog.yesButton.press();
    await tester.pump();
    expect(quit, isFalse);

    service.finishSaving();
    await tester.pump();

    expect(quit, isTrue);
  });

  testWidgets('still quits when saving the score fails', (tester) async {
    final service = _SlowDatabaseService();
    var quit = false;
    final host = await _pump(
      tester,
      service: service,
      score: 55,
      onQuit: () => quit = true,
    );
    final dialog = await _askToStop(tester, host);
    dialog.yesButton.press();
    await tester.pump();

    service.failSaving();
    await tester.pump();

    expect(quit, isTrue);
  });

  testWidgets('saves nothing when the player does not want to quit', (
    tester,
  ) async {
    final service = InMemoryDatabaseService();
    final host = await _pump(tester, service: service, score: 55);
    final dialog = await _askToStop(tester, host);

    dialog.noButton.press();
    await tester.pump();

    expect(await service.loadGameMode(GameModeName.endless), isNull);
  });
}
