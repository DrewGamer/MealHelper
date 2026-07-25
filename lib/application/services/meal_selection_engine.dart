import 'dart:math';
import '../../domain/models/meal.dart';

abstract class SelectionStrategy {
  Map<String, double> scoreMeals(List<Meal> meals, DateTime targetDate);
}

class RecencyStrategy implements SelectionStrategy {
  final double penaltyBase;

  RecencyStrategy({this.penaltyBase = 10.0});

  @override
  Map<String, double> scoreMeals(List<Meal> meals, DateTime targetDate) {
    Map<String, double> scores = {};
    for (var meal in meals) {
      double score = 100.0; // Base score

      // Penalize based on lastUsedDate
      if (meal.lastUsedDate != null) {
        final daysSince = targetDate.difference(meal.lastUsedDate!).inDays;
        if (daysSince >= 0 && daysSince < 14) {
          score -= (14 - daysSince) * penaltyBase;
        }
      }

      // Penalize based on nextUpcomingDate
      if (meal.nextUpcomingDate != null) {
        final daysUntil = meal.nextUpcomingDate!.difference(targetDate).inDays;
        if (daysUntil >= 0 && daysUntil < 14) {
          score -= (14 - daysUntil) * penaltyBase;
        }
      }
      
      scores[meal.id] = max(1.0, score);
    }
    return scores;
  }
}

class MealSelectionEngine {
  final List<SelectionStrategy> strategies;
  final Random _random;

  MealSelectionEngine({required this.strategies, Random? random}) : _random = random ?? Random();

  /// Accepts a list of empty slot target dates and available meals.
  /// Returns a map of slot date to assigned Meal.
  Map<DateTime, Meal> populateSlots(List<DateTime> emptySlots, List<Meal> availableMeals) {
    Map<DateTime, Meal> assignments = {};
    
    final sortedSlots = List<DateTime>.from(emptySlots)..sort();
    List<Meal> currentMeals = List.from(availableMeals);

    for (var slotDate in sortedSlots) {
      if (currentMeals.isEmpty) break;

      Map<String, double> combinedScores = {};
      
      // Initialize with base 0 for addition
      for (var meal in currentMeals) {
        combinedScores[meal.id] = 0.0; 
      }

      for (var strategy in strategies) {
        final scores = strategy.scoreMeals(currentMeals, slotDate);
        for (var mealId in scores.keys) {
          combinedScores[mealId] = (combinedScores[mealId] ?? 0.0) + scores[mealId]!;
        }
      }

      final selectedMeal = _weightedRandomSelection(currentMeals, combinedScores);
      if (selectedMeal != null) {
        assignments[slotDate] = selectedMeal;
        
        // Optimistically update lastUsedDate so subsequent days penalize using this meal repeatedly
        final updatedMeal = selectedMeal.copyWith(lastUsedDate: slotDate);
        final index = currentMeals.indexWhere((m) => m.id == selectedMeal.id);
        if (index != -1) {
          currentMeals[index] = updatedMeal;
        }
      }
    }

    return assignments;
  }

  Meal? _weightedRandomSelection(List<Meal> meals, Map<String, double> weights) {
    if (meals.isEmpty) return null;
    
    double totalWeight = 0.0;
    for (var meal in meals) {
      totalWeight += weights[meal.id] ?? 0.0;
    }

    if (totalWeight <= 0) return meals[_random.nextInt(meals.length)];

    double randomVal = _random.nextDouble() * totalWeight;
    double cumulative = 0.0;

    for (var meal in meals) {
      cumulative += weights[meal.id] ?? 0.0;
      if (randomVal <= cumulative) {
        return meal;
      }
    }
    
    return meals.last;
  }
}
