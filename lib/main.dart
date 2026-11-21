// =============================================================================
// Lab 01b - Hello Flutter: Tip Calculator
// MOBPROG | Mobile App Development (Flutter) - 2nd Term, A.Y. 2026-2027
//
// A single-screen Flutter app that computes the tip and the total of a bill.
//
//   * The user types the bill amount in a TextField (numeric keyboard).
//   * The user picks a tip percentage (10%, 15%, or 20%) with a
//     SegmentedButton<int>. The default is 15%.
//   * The tip and the total redraw immediately (setState) and are always
//     shown with exactly two decimals (toStringAsFixed(2)).
//   * Empty or invalid input shows "Enter a valid amount" instead of a number,
//     so the app never crashes on bad input.
//   * Extension challenge: a "split between N people" stepper shows the amount
//     each person pays. The chosen percentage is kept in State, so it is
//     remembered for as long as the app is open.
//
// The app uses a Material 3 theme generated with ColorScheme.fromSeed.
//
// Example (from the lab's expected results):
//   Bill 500, 15%  ->  Tip 75.00, Total 575.00
//   Bill abc       ->  Enter a valid amount
// =============================================================================

// Flutter 3.47+ moved the Material widgets out of package:flutter/material.dart
// (now deprecated) into the material_ui package, which `flutter create` adds to
// pubspec.yaml. Importing it keeps `flutter analyze` free of issues.
import 'package:material_ui/material_ui.dart';

/// Entry point of the app: [runApp] inflates the root widget, [TipApp].
void main() => runApp(const TipApp());

// -----------------------------------------------------------------------------
// Root widget
// -----------------------------------------------------------------------------

/// The root of the app.
///
/// It is a [StatelessWidget] because it only configures the [MaterialApp]
/// (title and Material 3 theme) and never changes after it is built.
class TipApp extends StatelessWidget {
  /// Creates the root widget of the tip calculator.
  const TipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Calculator',
      debugShowCheckedModeBanner: false,
      // Material 3 theme: every color in the scheme is derived from one seed.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // The same seed in dark mode, used when the device is in dark mode.
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TipPage(),
    );
  }
}

// -----------------------------------------------------------------------------
// Pure helper functions (no UI, easy to unit test)
// -----------------------------------------------------------------------------

/// Parses the text typed in the bill field.
///
/// Leading and trailing spaces are ignored. Returns `null` when [input] is
/// empty or is not a number, for example `'abc'`. Using [double.tryParse]
/// instead of [double.parse] means bad input never throws a FormatException.
double? parseBill(String input) => double.tryParse(input.trim());

/// Computes the tip and the total for a [bill] and a tip [percent].
///
/// Returns a record with named fields, so callers can read `result.tip` and
/// `result.total` without declaring a class. For example,
/// `computeTip(500, 15)` returns `(tip: 75.0, total: 575.0)`.
({double tip, double total}) computeTip(double bill, int percent) {
  final tip = bill * percent / 100;
  return (tip: tip, total: bill + tip);
}

// -----------------------------------------------------------------------------
// Tip calculator screen
// -----------------------------------------------------------------------------

/// The tip calculator screen.
///
/// It is a [StatefulWidget] because the bill text, the selected percentage,
/// and the number of people change while the app runs, and the screen must
/// redraw every time one of them changes.
class TipPage extends StatefulWidget {
  /// Creates the tip calculator screen.
  const TipPage({super.key});

  @override
  State<TipPage> createState() => _TipPageState();
}

/// Holds the mutable state of [TipPage] and builds its UI.
class _TipPageState extends State<TipPage> {
  /// The tip percentages offered by the segmented button.
  static const List<int> _percentOptions = [10, 15, 20];

  /// The smallest and largest number of people for the split stepper.
  static const int _minPeople = 1;
  static const int _maxPeople = 20;

  /// Reads and controls the text of the bill [TextField].
  final TextEditingController _billController = TextEditingController();

  /// The selected tip percentage. The lab requires it to start at 15.
  int _percent = 15;

  /// Extension challenge: how many people share the bill.
  int _people = 1;

  /// Releases the controller's resources when the screen is removed.
  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  /// Formats a money value with exactly two decimals, for example `75.00`.
  String _money(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Validate the input on every build. A bill is valid only when it parses,
    // is a finite number ('NaN' and 'Infinity' also parse), and is not
    // negative. Anything else is shown as "Enter a valid amount".
    final bill = parseBill(_billController.text);
    final isValid = bill != null && bill.isFinite && bill >= 0;
    final result = isValid ? computeTip(bill, _percent) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip Calculator'),
        centerTitle: true,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
      ),
      // SafeArea + scroll view: the layout stays usable on small screens and
      // when the on-screen keyboard is open.
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              // Keeps the form readable on wide screens such as Chrome.
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------------- Bill amount ----------------
                  TextField(
                    key: const Key('billField'),
                    controller: _billController,
                    // Numeric keyboard that also allows a decimal point.
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Bill amount',
                      hintText: 'e.g. 500',
                      prefixIcon: Icon(Icons.receipt_long),
                      border: OutlineInputBorder(),
                    ),
                    // Redraw on every keystroke so the totals update as the
                    // user types.
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // ---------------- Tip percentage ----------------
                  Text('Tip percentage', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: [
                      for (final p in _percentOptions)
                        ButtonSegment<int>(value: p, label: Text('$p%')),
                    ],
                    selected: {_percent},
                    // Redraw right away when a new percentage is chosen.
                    onSelectionChanged: (selection) {
                      setState(() => _percent = selection.first);
                    },
                  ),
                  const SizedBox(height: 24),

                  // ---------------- Split (extension challenge) ----------------
                  _PeopleStepper(
                    people: _people,
                    onDecrement: _people > _minPeople
                        ? () => setState(() => _people--)
                        : null,
                    onIncrement: _people < _maxPeople
                        ? () => setState(() => _people++)
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ---------------- Results ----------------
                  Card(
                    color: colors.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: result == null
                          // Invalid or empty input: a message, not a number.
                          ? Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: colors.onSecondaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Enter a valid amount',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colors.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _ResultRow(
                                  label: 'Tip ($_percent%)',
                                  value: _money(result.tip),
                                ),
                                const Divider(height: 24),
                                _ResultRow(
                                  label: 'Total',
                                  value: _money(result.total),
                                  emphasize: true,
                                ),
                                // Only shown when the bill is actually split.
                                if (_people > 1) ...[
                                  const Divider(height: 24),
                                  _ResultRow(
                                    label: 'Per person',
                                    value: _money(result.total / _people),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small reusable widgets
// -----------------------------------------------------------------------------

/// One labelled line in the results card, such as "Total   575.00".
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  /// The text on the left, for example `Tip (15%)`.
  final String label;

  /// The formatted amount on the right, for example `75.00`.
  final String value;

  /// When true (used for the total), the row uses a larger, bolder style.
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme.onSecondaryContainer;
    final style = (emphasize ? textTheme.headlineSmall : textTheme.titleMedium)
        ?.copyWith(
          color: color,
          fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

/// Extension challenge: a stepper that picks how many people share the bill.
///
/// A button is disabled (its callback is `null`) when the count is at its
/// minimum or maximum.
class _PeopleStepper extends StatelessWidget {
  const _PeopleStepper({
    required this.people,
    required this.onDecrement,
    required this.onIncrement,
  });

  /// The current number of people.
  final int people;

  /// Called when the minus button is pressed, or `null` to disable it.
  final VoidCallback? onDecrement;

  /// Called when the plus button is pressed, or `null` to disable it.
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text('Split between', style: textTheme.titleMedium),
        ),
        IconButton.filledTonal(
          key: const Key('decrementPeople'),
          tooltip: 'Fewer people',
          onPressed: onDecrement,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 88,
          child: Text(
            people == 1 ? '1 person' : '$people people',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          key: const Key('incrementPeople'),
          tooltip: 'More people',
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
