// Lab 01b - Hello Flutter: Tip Calculator
// MOBPROG | Mobile App Development (Flutter)
// This app computes the tip and the total of a bill.
// The user types the bill and picks 10%, 15%, or 20%.

// Material widgets (MaterialApp, Scaffold, TextField, SegmentedButton).
// Flutter 3.47+ moved them from package:flutter/material.dart to material_ui.
import 'package:material_ui/material_ui.dart';

// main() starts the app by calling runApp with the root widget.
void main() => runApp(const TipApp());

// Root widget of the app. It sets the title and the Material 3 theme.
class TipApp extends StatelessWidget {
  const TipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Calculator',
      // Material 3 theme with colors generated from one seed color.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const TipPage(),
    );
  }
}

// Converts the bill text to a number.
// Returns null if the text is empty or not a number (for example "abc").
double? parseBill(String input) => double.tryParse(input.trim());

// Computes the tip and the total.
// Returns a record so we can use result.tip and result.total.
({double tip, double total}) computeTip(double bill, int percent) {
  final tip = bill * percent / 100;
  return (tip: tip, total: bill + tip);
}

// The tip calculator screen.
// It is a StatefulWidget because the bill and the percent can change.
class TipPage extends StatefulWidget {
  const TipPage({super.key});

  @override
  State<TipPage> createState() => _TipPageState();
}

class _TipPageState extends State<TipPage> {
  // Controller that holds the text typed in the bill field.
  final _billController = TextEditingController();

  // The selected tip percentage. It starts at 15.
  int _percent = 15;

  // Free the controller when the screen is closed.
  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the bill. It is valid only if it is a finite number, 0 or more.
    final bill = parseBill(_billController.text);
    final isValid = bill != null && bill.isFinite && bill >= 0;
    final result = isValid ? computeTip(bill, _percent) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill amount field with a numeric keyboard.
            TextField(
              controller: _billController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Bill amount',
                border: OutlineInputBorder(),
              ),
              // Redraw the screen every time the user types.
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Buttons for choosing the tip percentage.
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 10, label: Text('10%')),
                ButtonSegment(value: 15, label: Text('15%')),
                ButtonSegment(value: 20, label: Text('20%')),
              ],
              selected: {_percent},
              // Save the new percent and redraw the screen.
              onSelectionChanged: (selection) {
                setState(() => _percent = selection.first);
              },
            ),
            const SizedBox(height: 24),

            // Show the tip and total, or a message if the input is invalid.
            if (result != null) ...[
              Text(
                'Tip: ${result.tip.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${result.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ] else
              Text(
                'Enter a valid amount',
                style: Theme.of(context).textTheme.titleLarge,
              ),
          ],
        ),
      ),
    );
  }
}
