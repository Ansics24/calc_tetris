import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:test/test.dart';

/// Behaviour every [DatabaseService] has to show, independent of where it
/// keeps its data.
void databaseServiceContract(Future<DatabaseService> Function() create) {
  late DatabaseService service;

  setUp(() async {
    service = await create();
  });

  test('has no game mode before anything was saved', () async {
    expect(await service.loadGameMode(GameModeName.endless), isNull);
  });

  test('saves the first score', () async {
    final saved = await service.saveHighscoreIfHigher(GameModeName.endless, 40);

    final mode = await service.loadGameMode(GameModeName.endless);
    expect(saved, isTrue);
    expect(mode!.name, 'endless');
    expect(mode.highscore, 40);
  });

  test('remembers when the highscore was achieved', () async {
    final before = DateTime.now().subtract(const Duration(seconds: 1));

    await service.saveHighscoreIfHigher(GameModeName.endless, 40);

    final achievedAt = (await service.loadGameMode(
      GameModeName.endless,
    ))!.achievedAt;
    expect(achievedAt.isAfter(before), isTrue);
    expect(
      achievedAt.isBefore(DateTime.now().add(const Duration(seconds: 1))),
      isTrue,
    );
  });

  test('replaces the highscore by a higher score', () async {
    await service.saveHighscoreIfHigher(GameModeName.endless, 40);

    final saved = await service.saveHighscoreIfHigher(GameModeName.endless, 90);

    expect(saved, isTrue);
    expect((await service.loadGameMode(GameModeName.endless))!.highscore, 90);
  });

  test('updates the time when the highscore was replaced', () async {
    await service.saveHighscoreIfHigher(GameModeName.endless, 40);
    final first = (await service.loadGameMode(
      GameModeName.endless,
    ))!.achievedAt;
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await service.saveHighscoreIfHigher(GameModeName.endless, 90);

    final second = (await service.loadGameMode(
      GameModeName.endless,
    ))!.achievedAt;
    expect(second.isAfter(first), isTrue);
  });

  test('keeps the highscore on a lower score', () async {
    await service.saveHighscoreIfHigher(GameModeName.endless, 90);
    final first = (await service.loadGameMode(
      GameModeName.endless,
    ))!.achievedAt;

    final saved = await service.saveHighscoreIfHigher(GameModeName.endless, 40);

    final mode = await service.loadGameMode(GameModeName.endless);
    expect(saved, isFalse);
    expect(mode!.highscore, 90);
    expect(mode.achievedAt, first);
  });

  test('keeps the highscore on an equal score', () async {
    await service.saveHighscoreIfHigher(GameModeName.endless, 90);

    final saved = await service.saveHighscoreIfHigher(GameModeName.endless, 90);

    expect(saved, isFalse);
  });

  test('does not save a score of 0', () async {
    final saved = await service.saveHighscoreIfHigher(GameModeName.endless, 0);

    expect(saved, isFalse);
    expect(await service.loadGameMode(GameModeName.endless), isNull);
  });

  test('rejects a negative score', () async {
    expect(
      () => service.saveHighscoreIfHigher(GameModeName.endless, -1),
      throwsArgumentError,
    );
  });
}
