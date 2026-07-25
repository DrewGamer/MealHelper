import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/domain/models/meal.dart';
import 'package:meal_helper/application/services/meal_selection_engine.dart';
import 'dart:math';

void main() {
  group('MealSelectionEngine', () {
    test('RecencyStrategy penalizes recent meals', () {
      final strategy = RecencyStrategy();
      final targetDate = DateTime(2023, 1, 15);
      
      final meal1 = Meal(id: '1', name: 'Meal 1', description: 'desc', createdBy: 'u1', lastUsedDate: DateTime(2023, 1, 14)); // 1 day ago
      final meal2 = Meal(id: '2', name: 'Meal 2', description: 'desc', createdBy: 'u1', lastUsedDate: DateTime(2023, 1, 1));  // 14 days ago
      
      final scores = strategy.scoreMeals([meal1, meal2], targetDate);
      
      // meal1 should have a lower score than meal2
      expect(scores['1']! < scores['2']!, isTrue);
    });

    test('Engine populates slots without crashing', () {
      final engine = MealSelectionEngine(
        strategies: [RecencyStrategy()],
        random: Random(42), // Fixed seed for reproducibility
      );

      final List<Meal> meals = [
        Meal(id: '1', name: 'M1', description: 'desc', createdBy: 'u'),
        Meal(id: '2', name: 'M2', description: 'desc', createdBy: 'u'),
        Meal(id: '3', name: 'M3', description: 'desc', createdBy: 'u'),
      ];

      final slots = [
        DateTime(2023, 2, 1),
        DateTime(2023, 2, 2),
        DateTime(2023, 2, 3),
      ];

      final assignments = engine.populateSlots(slots, meals);

      expect(assignments.length, 3);
      expect(assignments.keys.contains(slots[0]), isTrue);
      expect(assignments.keys.contains(slots[1]), isTrue);
      expect(assignments.keys.contains(slots[2]), isTrue);
    });
  });
}
