import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/in_memory_database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

WelcomeScreen _screen({
  DatabaseService? databaseService,
  void Function()? onStart,
}) {
  return WelcomeScreen(
    databaseService: databaseService,
    onStartEndless: onStart,
  )..onGameResize(Vector2(400, 800));
}

class _FailingDatabaseService implements DatabaseService {
  @override
  Future<GameMode?> loadGameMode(GameModeName name) =>
      Future.error(StateError('database is broken'));

  @override
  Future<bool> saveHighscoreIfHigher(GameModeName name, int score) =>
      Future.error(StateError('database is broken'));
}

void main() {
  _friendlyLookTests();

  test('takes over the size of the game when it is resized', () {
    expect(_screen().size, Vector2(400, 800));
  });

  group('mascot', () {
    test('is drawn above the sky but behind the cards', () {
      final screen = _screen();

      expect(screen.mascot.priority, greaterThan(screen.background.priority));
      expect(screen.mascot.priority, lessThan(screen.cards.first.priority));
    });

    test('reaches behind the first card', () {
      final screen = _screen();

      expect(
        screen.mascot.toRect().overlaps(screen.cards.first.toRect()),
        isTrue,
      );
    });

    test('sits behind the title', () {
      final screen = _screen();

      expect(
        screen.mascot.toRect().contains(screen.title.position.toOffset()),
        isTrue,
      );
      expect(screen.mascot.priority, lessThan(screen.title.priority + 1));
    });

    test('stays inside the screen horizontally', () {
      final screen = _screen();

      expect(screen.mascot.x, greaterThanOrEqualTo(0));
      expect(screen.mascot.x + screen.mascot.width, lessThanOrEqualTo(400));
    });

    test('stays inside the screen vertically', () {
      final screen = _screen();

      expect(screen.mascot.y, greaterThanOrEqualTo(0));
      expect(screen.mascot.y + screen.mascot.height, lessThanOrEqualTo(800));
    });
  });

  test('shows the game name above the cards', () {
    final screen = _screen();

    expect(screen.title.text, 'Magic Blocks');
    expect(screen.title.y, lessThan(screen.cards.first.y));
  });

  test('lets the cards fill the width apart from a margin', () {
    final card = _screen().cards.first;

    expect(card.width, lessThan(400));
    expect(card.x * 2 + card.width, 400);
  });

  test('shows the endless game card with lorem ipsum description', () {
    final screen = _screen();

    expect(screen.cards, hasLength(1));
    expect(screen.cards.first.titleText.text, 'Endlosspiel');
    expect(screen.cards.first.descriptionText.text, startsWith('Lorem ipsum'));
  });

  group('high score of the endless game', () {
    test('is 0 before it was loaded', () {
      final screen = _screen();

      expect(screen.cards.first.highScoreValue.text, '0');
    });

    test('is loaded from the database service', () async {
      final service = InMemoryDatabaseService();
      await service.saveHighscoreIfHigher(GameModeName.endless, 4711);
      final screen = _screen(databaseService: service);

      await screen.loadHighScores();

      expect(screen.cards.first.highScoreValue.text, '4.711');
    });

    test('stays 0 when nothing was saved yet', () async {
      final screen = _screen(databaseService: InMemoryDatabaseService());

      await screen.loadHighScores();

      expect(screen.cards.first.highScoreValue.text, '0');
    });

    test('stays 0 when the database can not be read', () async {
      final screen = _screen(databaseService: _FailingDatabaseService());

      await screen.loadHighScores();

      expect(screen.cards.first.highScoreValue.text, '0');
    });

    test('works without a given database service', () async {
      final screen = _screen();

      await screen.loadHighScores();

      expect(screen.cards.first.highScoreValue.text, '0');
    });
  });

  test('reports a press on the endless game card', () {
    var started = 0;
    final screen = _screen(onStart: () => started++);

    screen.cards.first.press();

    expect(started, 1);
  });
}

void _friendlyLookTests() {
  group('friendly look', () {
    test('has a sky background covering the whole screen', () {
      final screen = _screen();

      expect(screen.background.size, Vector2(400, 800));
      expect(screen.background.position, Vector2.zero());
    });

    test('draws the sky behind everything else', () {
      expect(_screen().background.priority, lessThan(0));
    });

    test('gives the cards enough height for the bigger texts', () {
      expect(_screen().cards.first.height, greaterThanOrEqualTo(150));
    });
  });
}
