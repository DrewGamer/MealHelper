import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/core/providers/shared_preferences_provider.dart';
import 'package:meal_helper/features/ingredients/data/ingredient_sort_notifier.dart';
import 'package:meal_helper/features/ingredients/domain/ingredient_sort_option.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('IngredientSortNotifier', () {
    test('initializes with default alphabetical if no preference is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final sortOption = container.read(ingredientSortProvider);
      expect(sortOption, IngredientSortOption.alphabetical);
    });

    test('initializes with saved preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'ingredient_sort_preference': 'alphabetical',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final sortOption = container.read(ingredientSortProvider);
      expect(sortOption, IngredientSortOption.alphabetical);
    });

    test('falls back to default if saved preference is unknown', () async {
      SharedPreferences.setMockInitialValues({
        'ingredient_sort_preference': 'unknown_option',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final sortOption = container.read(ingredientSortProvider);
      expect(sortOption, IngredientSortOption.alphabetical);
    });

    test('setSortOption updates state and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      container.read(ingredientSortProvider.notifier).setSortOption(IngredientSortOption.alphabetical);

      expect(container.read(ingredientSortProvider), IngredientSortOption.alphabetical);
      expect(prefs.getString('ingredient_sort_preference'), 'alphabetical');
    });
  });
}
