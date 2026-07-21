import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/domain/models/ingredient_options.dart';

void main() {
  group('IngredientOptions', () {
    test('fromMap parses correctly', () {
      final data = {
        'protein_sources': ['Chicken', 'Beef'],
        'ingredients': ['Rice', 'Beans'],
      };

      final options = IngredientOptions.fromMap(data);

      expect(options.proteinSources, ['Chicken', 'Beef']);
      expect(options.ingredients, ['Rice', 'Beans']);
    });

    test('fromMap handles null gracefully', () {
      final options = IngredientOptions.fromMap(null);

      expect(options.proteinSources, isEmpty);
      expect(options.ingredients, isEmpty);
    });

    test('toMap serializes correctly', () {
      final options = IngredientOptions(
        proteinSources: ['Chicken'],
        ingredients: ['Rice'],
      );

      final map = options.toMap();

      expect(map['protein_sources'], ['Chicken']);
      expect(map['ingredients'], ['Rice']);
    });
  });
}
