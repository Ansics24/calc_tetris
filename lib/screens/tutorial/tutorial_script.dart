import 'package:calc_tetris/screens/tutorial/tutorial_step.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

/// The size of the grid all tutorial boards use.
final IntVector2 tutorialGridSize = IntVector2.square(11);

/// The steps of the tutorial in the order the player goes through them.
///
/// Explains: 1. moving the block, 2. rotating it, 3. horizontal equations,
/// 4. vertical equations, 5. that more numbers and multi digit numbers earn
/// more points, 6. the cannon power-up.
///
/// Blocks enter the grid at its upper border, and a block is moved down
/// first and sideways afterwards, so it never has to cross the prepared
/// blocks.
List<TutorialStep> tutorialScript() => [
  MessageStep(
    'Willkommen! Du bewegst die Steine mit dem Finger. '
    'Ziehe den Stein neben die Aufgabe und tippe auf den Haken oben, '
    'um ihn abzulegen.',
  ),
  PlayStep(
    hint: 'Ziehe den Stein hinter die 3 und tippe auf den Haken.',
    gridRows: _grid({9: '..2+3'}),
    blockRows: ['=5'],
    spawnPosition: IntVector2(7, 0),
    solutionPosition: IntVector2(5, 9),
    solutionRotations: 0,
  ),
  MessageStep(
    'Sehr gut! Manche Steine passen nur gedreht. '
    'Tippe einfach auf den Stein, dann dreht er sich.',
  ),
  PlayStep(
    hint: 'Tippe auf den Stein, um ihn zu drehen, und lege ihn hinter die 4.',
    gridRows: _grid({9: '..4+4'}),
    blockRows: ['8', '='],
    spawnPosition: IntVector2(8, 0),
    solutionPosition: IntVector2(5, 9),
    solutionRotations: 1,
  ),
  MessageStep(
    'Das war eine horizontale Gleichung: '
    'Sie wird von links nach rechts gelesen und muss stimmen. '
    'Richtig gelöste Gleichungen verschwinden.',
  ),
  MessageStep(
    'Gleichungen funktionieren auch vertikal, '
    'also von oben nach unten. Lege den Stein unter die Aufgabe.',
  ),
  PlayStep(
    hint: 'Lege den Stein unter die 2, damit 6 - 2 = 4 entsteht.',
    gridRows: _grid({6: '.....6', 7: '.....-', 8: '.....2'}),
    blockRows: ['=', '4'],
    spawnPosition: IntVector2(8, 0),
    solutionPosition: IntVector2(5, 9),
    solutionRotations: 0,
  ),
  MessageStep(
    'Für jede gelöste Gleichung gibt es Punkte. '
    'Je mehr Zahlen in der Gleichung stehen, desto mehr Punkte bekommst du.',
  ),
  PlayStep(
    hint: 'Lege den Stein hinter die 3: Mit vier Zahlen gibt es mehr Punkte.',
    gridRows: _grid({9: '.1+2+3'}),
    blockRows: ['=6'],
    spawnPosition: IntVector2(7, 0),
    solutionPosition: IntVector2(6, 9),
    solutionRotations: 0,
  ),
  MessageStep(
    'Noch mehr Punkte gibt es für mehrstellige Zahlen, '
    'zum Beispiel für 12 oder 15.',
  ),
  PlayStep(
    hint: 'Lege den Stein hinter die 3: Mehrstellige Zahlen zählen extra.',
    gridRows: _grid({9: '.12+3'}),
    blockRows: ['=15'],
    spawnPosition: IntVector2(7, 0),
    solutionPosition: IntVector2(5, 9),
    solutionRotations: 0,
    findsCannon: true,
  ),
  MessageStep(
    'Glückwunsch, du hast eine Kanone gefunden! '
    'Powerups kannst du beim Lösen von Gleichungen finden.',
  ),
  MessageStep(
    'Die Kanone zerstört Steine, die schon im Feld liegen. '
    'Sie hat mehrere Schüsse, jeder Tipp ins Feld ist einer.',
  ),
  CannonStep(
    hint: 'Tippe unten auf die Kanone.',
    activeHint: 'Tippe auf die drei Steine unten.',
    gridRows: _grid({10: '...7+9'}),
    blockRows: ['=5'],
    spawnPosition: IntVector2(7, 0),
    targets: [IntVector2(3, 10), IntVector2(4, 10), IntVector2(5, 10)],
  ),
  MessageStep(
    'Sehr gut! Im Spiel bleibt die Kanone aktiv, bis alle Schüsse '
    'verbraucht sind. Dann geht es normal weiter.',
  ),
  MessageStep(
    'Geschafft! Jetzt kennst du alles, was du fürs Spielen brauchst. '
    'Viel Spaß beim Endlosspiel!',
    buttonLabel: 'Zurück zum Start',
  ),
];

/// The rows of a grid that is empty except for the given [rows]. A text of a
/// row starts at the left border of the grid; `.` marks an empty cell.
List<String> _grid(Map<int, String> rows) {
  final width = tutorialGridSize.x;
  final height = tutorialGridSize.y;
  return List.generate(
    height,
    (y) => (rows[y] ?? '').padRight(width, '.'),
  );
}
