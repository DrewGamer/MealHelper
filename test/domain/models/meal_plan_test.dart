import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/domain/models/meal_plan.dart';

void main() {
  group('MealPlan Tests', () {
    test('endDate returns correct date', () {
      final monday = DateTime(2026, 7, 20);
      final sunday = DateTime(2026, 7, 26);
      final plan = MealPlan(
        id: 'plan_1',
        startDate: monday,
        endDate: sunday,
        mealIdsByDay: {},
      );

      expect(plan.endDate, sunday);
    });

    test('formatDateRange formats correctly', () {
      final start = DateTime(2026, 7, 20);
      final end = DateTime(2026, 7, 26);
      final formatted = MealPlan.formatDateRange(start, end);
      expect(formatted, 'Jul 20 - 26, 2026');
    });

    test('coversDate and getMealIdForDate correctly resolve target dates', () {
      final plan = MealPlan(
        id: 'plan_1',
        startDate: DateTime(2026, 7, 20), // Monday
        endDate: DateTime(2026, 7, 26),
        mealIdsByDay: {0: 'meal_mon', 2: 'meal_wed'},
      );

      expect(plan.coversDate(DateTime(2026, 7, 20)), isTrue);
      expect(plan.coversDate(DateTime(2026, 7, 22)), isTrue);
      expect(plan.coversDate(DateTime(2026, 7, 27)), isFalse);

      expect(plan.getMealIdForDate(DateTime(2026, 7, 20)), 'meal_mon');
      expect(plan.getMealIdForDate(DateTime(2026, 7, 22)), 'meal_wed');
      expect(plan.getMealIdForDate(DateTime(2026, 7, 21)), isNull);
    });

    test('overlapsWithRange correctly identifies overlapping date ranges', () {
      final plan = MealPlan(
        id: 'plan_1',
        startDate: DateTime(2026, 7, 20), // Jul 20 - Jul 26
        endDate: DateTime(2026, 7, 26),
        mealIdsByDay: {},
      );

      expect(plan.overlapsWithRange(DateTime(2026, 7, 19), DateTime(2026, 7, 25)), isTrue);
      expect(plan.overlapsWithRange(DateTime(2026, 7, 27), DateTime(2026, 8, 2)), isFalse);
    });

    test('overlapsWith correctly identifies overlapping MealPlans', () {
      final plan1 = MealPlan(
        id: 'plan_1',
        startDate: DateTime(2026, 7, 20), // Jul 20 - Jul 26
        endDate: DateTime(2026, 7, 26),
        mealIdsByDay: {},
      );

      final plan2 = MealPlan(
        id: 'plan_2',
        startDate: DateTime(2026, 7, 25), // Jul 25 - Jul 31
        endDate: DateTime(2026, 7, 31),
        mealIdsByDay: {},
      );

      final plan3 = MealPlan(
        id: 'plan_3',
        startDate: DateTime(2026, 7, 27), // Jul 27 - Aug 2
        endDate: DateTime(2026, 8, 2),
        mealIdsByDay: {},
      );

      expect(plan1.overlapsWith(plan2), isTrue);
      expect(plan1.overlapsWith(plan3), isFalse);
    });
  });
}
