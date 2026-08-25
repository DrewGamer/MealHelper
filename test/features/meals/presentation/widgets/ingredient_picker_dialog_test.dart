import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/core/providers/shared_preferences_provider.dart';
import 'package:meal_helper/features/meals/presentation/widgets/ingredient_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('IngredientPickerDialog sorts available ingredients and allows selection', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final available = ['Zucchini', 'Carrot', 'Avocado', 'Broccoli'];
    final initial = ['Carrot'];
    List<String>? selectedResult;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedResult = await IngredientPickerDialog.show(
                    context,
                    availableIngredients: available,
                    initialSelectedIngredients: initial,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify all items are displayed
    expect(find.text('Select Ingredients'), findsOneWidget);
    expect(find.text('Avocado'), findsOneWidget);
    expect(find.text('Broccoli'), findsOneWidget);
    expect(find.text('Carrot'), findsOneWidget);
    expect(find.text('Zucchini'), findsOneWidget);

    // Check that items are ordered alphabetically in the widget tree
    final avocadoFinder = find.text('Avocado');
    final zucchiniFinder = find.text('Zucchini');
    expect(
      tester.getTopLeft(avocadoFinder).dy < tester.getTopLeft(zucchiniFinder).dy,
      isTrue,
    );

    // Toggle Avocado
    await tester.tap(find.text('Avocado'));
    await tester.pumpAndSettle();

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(selectedResult, containsAll(['Carrot', 'Avocado']));
  });
}
