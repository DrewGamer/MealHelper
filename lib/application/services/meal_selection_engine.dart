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

class VaryProteinStrategy implements SelectionStrategy {
  final int windowDays;
  final double penaltyBase;

  VaryProteinStrategy({this.windowDays = 3, this.penaltyBase = 50.0});

  @override
  Map<String, double> scoreMeals(List<Meal> meals, DateTime targetDate) {
    Set<String> recentlyUsedProteins = {};

    final normalizedTarget = DateTime(targetDate.year, targetDate.month, targetDate.day);

    for (var meal in meals) {
      if (meal.proteinSource != null && meal.proteinSource!.trim().isNotEmpty) {
        bool isRecent = false;
        
        if (meal.lastUsedDate != null) {
          final normalizedLastUsed = DateTime(meal.lastUsedDate!.year, meal.lastUsedDate!.month, meal.lastUsedDate!.day);
          final daysSince = normalizedTarget.difference(normalizedLastUsed).inDays.abs();
          if (daysSince <= windowDays) {
            isRecent = true;
          }
        }
        
        if (!isRecent && meal.nextUpcomingDate != null) {
          final normalizedNextUpcoming = DateTime(meal.nextUpcomingDate!.year, meal.nextUpcomingDate!.month, meal.nextUpcomingDate!.day);
          final daysUntil = normalizedNextUpcoming.difference(normalizedTarget).inDays.abs();
          if (daysUntil <= windowDays) {
            isRecent = true;
          }
        }

        if (isRecent) {
          recentlyUsedProteins.add(meal.proteinSource!.trim().toLowerCase());
        }
      }
    }

    Map<String, double> scores = {};
    for (var meal in meals) {
      double score = 100.0;
      
      if (meal.proteinSource != null && meal.proteinSource!.trim().isNotEmpty) {
        final protein = meal.proteinSource!.trim().toLowerCase();
        if (recentlyUsedProteins.contains(protein)) {
          score -= penaltyBase;
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
  Map<DateTime, Meal> populateSlots(
    List<DateTime> emptySlots,
    List<Meal> availableMeals, {
    int consecutiveDays = 1,
    bool fillPartial = true,
  }) {
    Map<DateTime, Meal> assignments = {};
    
    if (emptySlots.isEmpty || availableMeals.isEmpty) return assignments;

    final sortedSlots = List<DateTime>.from(emptySlots)..sort();
    List<Meal> currentMeals = List.from(availableMeals.where((m) => !m.excludeFromAuto));

    // Break into contiguous sub-lists
    List<List<DateTime>> contiguousSubLists = [];
    List<DateTime> currentSubList = [sortedSlots.first];

    for (int i = 1; i < sortedSlots.length; i++) {
      final prevDate = sortedSlots[i - 1];
      final currDate = sortedSlots[i];

      // Use start of day for accurate 1-day difference calculation
      final prevDay = DateTime(prevDate.year, prevDate.month, prevDate.day);
      final currDay = DateTime(currDate.year, currDate.month, currDate.day);
      
      if (currDay.difference(prevDay).inDays == 1) {
        currentSubList.add(currDate);
      } else {
        contiguousSubLists.add(currentSubList);
        currentSubList = [currDate];
      }
    }
    contiguousSubLists.add(currentSubList);

    // Split each sub-list into chunks of size up to consecutiveDays
    List<List<DateTime>> chunks = [];
    for (var subList in contiguousSubLists) {
      for (int i = 0; i < subList.length; i += consecutiveDays) {
        int end = (i + consecutiveDays < subList.length)
            ? i + consecutiveDays
            : subList.length;
        chunks.add(subList.sublist(i, end));
      }
    }

    for (var chunk in chunks) {
      if (currentMeals.isEmpty) break;

      if (chunk.length < consecutiveDays && !fillPartial) {
        continue;
      }

      final targetDate = chunk.first;
      Map<String, double> combinedScores = {};
      
      // Initialize with base 0 for addition
      for (var meal in currentMeals) {
        combinedScores[meal.id] = 0.0; 
      }

      for (var strategy in strategies) {
        final scores = strategy.scoreMeals(currentMeals, targetDate);
        for (var mealId in scores.keys) {
          combinedScores[mealId] = (combinedScores[mealId] ?? 0.0) + scores[mealId]!;
        }
      }

      final selectedMeal = _weightedRandomSelection(currentMeals, combinedScores);
      if (selectedMeal != null) {
        for (var slotDate in chunk) {
          assignments[slotDate] = selectedMeal;
        }
        
        // Optimistically update lastUsedDate so subsequent iterations penalize correctly
        final lastDay = chunk.last;
        final updatedMeal = selectedMeal.copyWith(lastUsedDate: lastDay);
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
