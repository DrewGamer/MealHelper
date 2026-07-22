import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/domain/models/meal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Meal', () {
    test('fromMap parses new fields correctly', () {
      final data = {
        'name': 'Test Meal',
        'description': 'Test Description',
        'tags': ['deprecated_tag'],
        'protein_source': 'Chicken',
        'ingredients': ['Rice', 'Beans'],
        'last_used_date': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'created_by': 'user1',
      };

      final meal = Meal.fromMap(data, 'meal_1');

      expect(meal.id, 'meal_1');
      expect(meal.name, 'Test Meal');
      expect(meal.description, 'Test Description');
      expect(meal.tags, ['deprecated_tag']);
      expect(meal.proteinSource, 'Chicken');
      expect(meal.ingredients, ['Rice', 'Beans']);
      expect(meal.createdBy, 'user1');
      expect(meal.lastUsedDate, DateTime(2023, 1, 1));
    });

    test('toMap serializes new fields correctly', () {
      final meal = Meal(
        id: 'meal_1',
        name: 'Test Meal',
        description: 'Test Description',
        tags: ['old'],
        proteinSource: 'Chicken',
        ingredients: ['Rice'],
        createdBy: 'user1',
      );

      final map = meal.toMap();

      expect(map['protein_source'], 'Chicken');
      expect(map['ingredients'], ['Rice']);
      expect(map['tags'], ['old']);
    });

    test('copyWith updates new fields', () {
      final meal = Meal(
        id: '1',
        name: 'M',
        description: 'D',
        createdBy: 'U',
      );

      final updated = meal.copyWith(
        proteinSource: 'Beef',
        ingredients: ['Tomato'],
      );

      expect(updated.proteinSource, 'Beef');
      expect(updated.ingredients, ['Tomato']);
      expect(updated.name, 'M');
    });
  });
}
