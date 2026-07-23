import 'package:flutter_test/flutter_test.dart';
import 'package:meal_helper/domain/models/weekly_plan.dart';

void main() {
  group('WeeklyPlan Tests', () {
    test('normalizeToStartOfWeek normalizes dates to Monday 00:00:00', () {
      // Wednesday July 22, 2026 14:30:00
      final wednesday = DateTime(2026, 7, 22, 14, 30);
      final monday = WeeklyPlan.normalizeToStartOfWeek(wednesday);

      expect(monday, DateTime(2026, 7, 20, 0, 0, 0));
      expect(monday.weekday, DateTime.monday);
    });

    test('endDate returns Sunday (6 days after start)', () {
      final monday = DateTime(2026, 7, 20);
      final plan = WeeklyPlan(
        id: 'plan_1',
        startDate: monday,
        mealIdsByDay: {},
      );

      expect(plan.endDate, DateTime(2026, 7, 26));
    });

    test('isSameWeek correctly identifies dates in the same week', () {
      final monday = DateTime(2026, 7, 20);
      final plan = WeeklyPlan(
        id: 'plan_1',
        startDate: monday,
        mealIdsByDay: {},
      );

      final wednesday = DateTime(2026, 7, 22);
      final sunday = DateTime(2026, 7, 26);
      final nextMonday = DateTime(2026, 7, 27);

      expect(plan.isSameWeek(wednesday), isTrue);
      expect(plan.isSameWeek(sunday), isTrue);
      expect(plan.isSameWeek(nextMonday), isFalse);
    });

    test('formatDateRange formats correctly', () {
      final date = DateTime(2026, 7, 22);
      final formatted = WeeklyPlan.formatDateRange(date);
      expect(formatted, 'Jul 20 - 26, 2026');
    });
  });
}
