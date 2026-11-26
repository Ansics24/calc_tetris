import 'package:magic_blocks/audio/music_player.dart';
import 'package:magic_blocks/persistence/database_service.dart';
import 'package:magic_blocks/persistence/in_memory_database_service.dart';
import 'package:magic_blocks/persistence/model/game_mode.dart';
import 'package:magic_blocks/persistence/model/game_mode_name.dart';
import 'package:magic_blocks/screens/welcome/card_button.dart';
import 'package:magic_blocks/screens/welcome/game_mode_card.dart';
import 'package:magic_blocks/screens/welcome/mascot.dart';
import 'package:magic_blocks/screens/welcome/welcome_screen.dart';
import 'package:magic_blocks/theme/welcome_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/load_game_font.dart';
import '../../support/recording_music_player.dart';

class _FailingDatabaseService implements DatabaseService {
  @override
  Future<GameMode?> loadGameMode(GameModeName name) =>
      Future.error(StateError('database is broken'));

  @override
  Future<bool> saveHighscoreIfHigher(GameModeName name, int score) =>
      Future.error(StateError('database is broken'));
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  Size size = const Size(400, 800),
  DatabaseService? databaseService,
  MusicPlayer? musicPlayer,
  void Function()? onStart,
  void Function()? onStartTutorial,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WelcomeScreen(
          databaseService: databaseService,
          musicPlayer: musicPlayer,
          onStartEndless: onStart,
          onStartTutorial: onStartTutorial,
        ),
      ),
    ),
  );
  await tester.pump();
}

Rect _card(WidgetTester tester) => tester.getRect(find.byType(GameModeCard));

Rect _title(WidgetTester tester) =>
    tester.getRect(find.text(WelcomeScreen.gameName));

void main() {
  setUpAll(loadGameFont);

  _layoutTests();
  _mascotTests();
  _buttonTests();
  _highScoreTests();
  _musicTests();
}

void _layoutTests() {
  testWidgets('shows the game name above the card', (tester) async {
    await _pumpScreen(tester);

    expect(WelcomeScreen.gameName, 'Magic Blocks');
    expect(_title(tester).bottom, lessThanOrEqualTo(_card(tester).top));
  });

  testWidgets('lets the card fill the width apart from a margin', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(_card(tester).left, 16);
    expect(_card(tester).right, 400 - 16);
  });

  testWidgets('shows the endless game card with a describing text', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.byType(GameModeCard), findsOneWidget);
    expect(find.text('Endlosspiel'), findsOneWidget);
    expect(find.text(WelcomeScreen.endlessDescription), findsOneWidget);
  });

  testWidgets('covers the whole screen with the sky', (tester) async {
    await _pumpScreen(tester);

    final sky = find.byKey(WelcomeScreen.skyKey);
    final decoration =
        tester.widget<DecoratedBox>(sky).decoration as BoxDecoration;
    expect(tester.getSize(sky), const Size(400, 800));
    expect((decoration.gradient! as LinearGradient).colors, [
      WelcomePalette.skyTop,
      WelcomePalette.skyBottom,
    ]);
  });

  testWidgets('scrolls instead of overflowing on a small screen', (
    tester,
  ) async {
    await _pumpScreen(tester, size: const Size(320, 300));

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(CardButton));
    await tester.pump();
    expect(_card(tester).bottom, lessThanOrEqualTo(300));
  });

  testWidgets('copes with a large system font', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpScreen(tester);

    expect(tester.takeException(), isNull);
  });
}

void _mascotTests() {
  group('mascot on the screen', () {
    Rect mascot(WidgetTester tester) => tester.getRect(find.byType(Mascot));

    testWidgets('sits behind the title', (tester) async {
      await _pumpScreen(tester);

      expect(mascot(tester).contains(_title(tester).center), isTrue);
    });

    testWidgets('reaches behind the card', (tester) async {
      await _pumpScreen(tester);

      expect(mascot(tester).overlaps(_card(tester)), isTrue);
    });

    testWidgets('is painted before title and card', (tester) async {
      await _pumpScreen(tester);
      final widgets = tester.allWidgets.toList();
      int position(Finder finder) => widgets.indexOf(tester.widget(finder));

      final mascotPosition = position(find.byType(Mascot));
      expect(
        mascotPosition,
        lessThan(position(find.text(WelcomeScreen.gameName))),
      );
      expect(mascotPosition, lessThan(position(find.byType(GameModeCard))));
    });

    testWidgets('stays inside the screen', (tester) async {
      await _pumpScreen(tester);
      final rect = mascot(tester);

      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(400));
      expect(rect.bottom, lessThanOrEqualTo(800));
    });
  });
}

void _buttonTests() {
  testWidgets('reports a press on the endless game card', (tester) async {
    var endless = 0;
    var tutorial = 0;
    await _pumpScreen(
      tester,
      onStart: () => endless++,
      onStartTutorial: () => tutorial++,
    );

    await tester.tap(find.text('Endlosspiel'));

    expect(endless, 1);
    expect(tutorial, 0);
  });

  testWidgets('reports a press on the tutorial button as tutorial start', (
    tester,
  ) async {
    var endless = 0;
    var tutorial = 0;
    await _pumpScreen(
      tester,
      onStart: () => endless++,
      onStartTutorial: () => tutorial++,
    );

    await tester.tap(find.text('Tutorial'));

    expect(tutorial, 1);
    expect(endless, 0);
  });
}

void _highScoreTests() {
  group('high score of the endless game', () {
    testWidgets('is loaded from the database service', (tester) async {
      final service = InMemoryDatabaseService();
      await service.saveHighscoreIfHigher(GameModeName.endless, 4711);

      await _pumpScreen(tester, databaseService: service);

      expect(find.text('4.711'), findsOneWidget);
    });

    testWidgets('stays 0 when nothing was saved yet', (tester) async {
      await _pumpScreen(tester, databaseService: InMemoryDatabaseService());

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('stays 0 when the database can not be read', (tester) async {
      await _pumpScreen(tester, databaseService: _FailingDatabaseService());

      expect(find.text('0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is 0 without a given database service', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('0'), findsOneWidget);
    });
  });
}

void _musicTests() {
  group('music', () {
    testWidgets('starts when the screen appears', (tester) async {
      final music = RecordingMusicPlayer();

      await _pumpScreen(tester, musicPlayer: music);

      expect(music.played, [WelcomeScreen.musicFile]);
    });

    testWidgets('stops when the screen disappears', (tester) async {
      final music = RecordingMusicPlayer();
      await _pumpScreen(tester, musicPlayer: music);

      await tester.pumpWidget(const SizedBox());

      expect(music.isSilent, isTrue);
    });

    testWidgets('does not disturb the screen when the audio is broken', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        musicPlayer: RecordingMusicPlayer(failing: true),
      );
      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    });
  });
}
