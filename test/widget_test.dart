// Tests for the tip calculator (replaces the old counter test).

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:tip_calculator/main.dart';

void main() {
  // Unit test: bill 500 at 15% gives tip 75 and total 575.
  test('computeTip returns the correct tip and total', () {
    final result = computeTip(500, 15);
    expect(result.tip, 75.0);
    expect(result.total, 575.0);
  });

  // Unit test: other percentages.
  test('computeTip works for 10% and 20%', () {
    expect(computeTip(200, 10).total, 220.0);
    expect(computeTip(200, 20).total, 240.0);
  });

  // Unit test: invalid text returns null.
  test('parseBill returns null for invalid input', () {
    expect(parseBill('500'), 500.0);
    expect(parseBill(''), isNull);
    expect(parseBill('abc'), isNull);
  });

  // Widget test: typing 500 shows the tip and total with two decimals.
  testWidgets('shows tip and total for a valid bill', (tester) async {
    await tester.pumpWidget(const TipApp());
    await tester.enterText(find.byType(TextField), '500');
    await tester.pump();

    expect(find.text('Tip: 75.00'), findsOneWidget);
    expect(find.text('Total: 575.00'), findsOneWidget);
  });

  // Widget test: changing the percent updates the totals right away.
  testWidgets('changing the percent updates the totals', (tester) async {
    await tester.pumpWidget(const TipApp());
    await tester.enterText(find.byType(TextField), '500');
    await tester.pump();
    await tester.tap(find.text('20%'));
    await tester.pumpAndSettle();

    expect(find.text('Tip: 100.00'), findsOneWidget);
    expect(find.text('Total: 600.00'), findsOneWidget);
  });

  // Widget test: invalid input shows a message instead of crashing.
  testWidgets('shows a message for invalid input', (tester) async {
    await tester.pumpWidget(const TipApp());
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();

    expect(find.text('Enter a valid amount'), findsOneWidget);
  });
}
