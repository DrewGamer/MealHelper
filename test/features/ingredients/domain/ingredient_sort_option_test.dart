import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/features/ingredients/domain/ingredient_sort_option.dart';

void main() {
  group('IngredientSortOption', () {
    test('contains expected values', () {
      expect(IngredientSortOption.values, [
        IngredientSortOption.alphabetical,
      ]);
    });
  });

  group('IngredientSortExtension.applySort', () {
    test('sorts alphabetically case-insensitively', () {
      final items = ['banana', 'Apple', 'cherry', 'avocado'];
      final sorted = items.applySort(IngredientSortOption.alphabetical);

      expect(sorted, ['Apple', 'avocado', 'banana', 'cherry']);
    });

    test('does not mutate original list (immutability)', () {
      final items = ['banana', 'apple'];
      final sorted = items.applySort(IngredientSortOption.alphabetical);

      expect(items, ['banana', 'apple']);
      expect(sorted, ['apple', 'banana']);
    });

    test('handles empty list', () {
      final items = <String>[];
      final sorted = items.applySort(IngredientSortOption.alphabetical);

      expect(sorted, isEmpty);
    });

    test('handles single item', () {
      final items = ['Tofu'];
      final sorted = items.applySort(IngredientSortOption.alphabetical);

      expect(sorted, ['Tofu']);
    });

    test('handles duplicates and identical casing', () {
      final items = ['Chicken', 'chicken', 'Beef', 'Chicken'];
      final sorted = items.applySort(IngredientSortOption.alphabetical);

      expect(sorted.length, 4);
      expect(sorted.first.toLowerCase(), 'beef');
      expect(sorted.sublist(1).every((e) => e.toLowerCase() == 'chicken'), isTrue);
    });
  });
}
