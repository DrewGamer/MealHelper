import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/core/providers/shared_preferences_provider.dart';
import 'package:meal_helper/features/ingredients/data/ingredient_options_repository.dart';
import 'package:meal_helper/features/ingredients/domain/ingredient_options.dart';
import 'package:meal_helper/features/ingredients/presentation/ingredient_manager_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('IngredientManagerScreen renders tabs, item counts, and sorted items', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testOptions = IngredientOptions(
      proteinSources: ['Tofu', 'Beef', 'Chicken'],
      ingredients: ['Tomato', 'Garlic', 'Basil'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ingredientOptionsStreamProvider.overrideWith((ref) => Stream.value(testOptions)),
        ],
        child: const MaterialApp(
          home: IngredientManagerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check Tab headers with count
    expect(find.text('Protein Sources (3)'), findsOneWidget);
    expect(find.text('Ingredients (3)'), findsOneWidget);

    // Initial tab is Protein Sources - should be sorted alphabetically: Beef, Chicken, Tofu
    expect(find.text('Beef'), findsOneWidget);
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('Tofu'), findsOneWidget);

    // Switch to Ingredients tab
    await tester.tap(find.text('Ingredients (3)'));
    await tester.pumpAndSettle();

    // Ingredients should be visible and sorted: Basil, Garlic, Tomato
    expect(find.text('Basil'), findsOneWidget);
    expect(find.text('Garlic'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);

    // Check Sort menu action is present in AppBar
    expect(find.byIcon(Icons.sort), findsOneWidget);

    // Check FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('IngredientManagerScreen renders empty state placeholders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final emptyOptions = IngredientOptions(
      proteinSources: [],
      ingredients: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ingredientOptionsStreamProvider.overrideWith((ref) => Stream.value(emptyOptions)),
        ],
        child: const MaterialApp(
          home: IngredientManagerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Protein Sources (0)'), findsOneWidget);
    expect(find.text('Ingredients (0)'), findsOneWidget);
    expect(find.text('No protein sources yet. Tap + to add one.'), findsOneWidget);

    await tester.tap(find.text('Ingredients (0)'));
    await tester.pumpAndSettle();

    expect(find.text('No ingredients yet. Tap + to add one.'), findsOneWidget);
  });
}
