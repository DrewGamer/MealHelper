import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/core/providers/shared_preferences_provider.dart';
import 'package:meal_helper/features/ingredients/data/ingredient_options_repository.dart';
import 'package:meal_helper/features/ingredients/domain/ingredient_options.dart';
import 'package:meal_helper/features/meals/presentation/meal_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MealDetailScreen displays sorted protein sources dropdown', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testOptions = IngredientOptions(
      proteinSources: ['Salmon', 'Beef', 'Chicken', 'Tofu'],
      ingredients: ['Garlic', 'Salt'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ingredientOptionsStreamProvider.overrideWith((ref) => Stream.value(testOptions)),
        ],
        child: const MaterialApp(
          home: MealDetailScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Dropdown is present
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    expect(dropdownFinder, findsOneWidget);

    // Tap dropdown to expand items
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Verify items are displayed in alphabetical order: Beef, Chicken, Salmon, Tofu
    expect(find.text('Beef').last, findsOneWidget);
    expect(find.text('Chicken').last, findsOneWidget);
    expect(find.text('Salmon').last, findsOneWidget);
    expect(find.text('Tofu').last, findsOneWidget);

    final beefY = tester.getTopLeft(find.text('Beef').last).dy;
    final tofuY = tester.getTopLeft(find.text('Tofu').last).dy;
    expect(beefY < tofuY, isTrue);
  });
}
