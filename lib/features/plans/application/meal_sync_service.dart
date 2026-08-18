import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_constants.dart';
import '../data/plan_repository.dart';
import '../domain/meal_plan.dart';

class MealSyncService {
  final PlanRepository _planRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MealSyncService(this._planRepo);

  Future<void> savePlan(String databaseId, MealPlan plan) async {
    await _planRepo.savePlan(databaseId, plan);
    await _recalculateUsageDates(databaseId);
  }

  Future<void> updatePlan(String databaseId, MealPlan plan) async {
    await _planRepo.updatePlan(databaseId, plan);
    await _recalculateUsageDates(databaseId);
  }

  Future<void> deletePlan(String databaseId, String planId) async {
    await _planRepo.deletePlan(databaseId, planId);
    await _recalculateUsageDates(databaseId);
  }

  Future<void> _recalculateUsageDates(String databaseId) async {
    final plans = await _planRepo.getPlans(databaseId);
    
    // mealId -> [List of Dates]
    final Map<String, List<DateTime>> mealDates = {};

    for (final plan in plans) {
      plan.mealIdsByDay.forEach((offset, mealId) {
        final date = plan.startDate.add(Duration(days: offset));
        final normDate = DateTime(date.year, date.month, date.day);
        if (!mealDates.containsKey(mealId)) {
          mealDates[mealId] = [];
        }
        mealDates[mealId]!.add(normDate);
      });
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final batch = _firestore.batch();
    
    final mealsSnapshot = await _firestore
        .collection(FirestoreCollections.databases)
        .doc(databaseId)
        .collection(FirestoreCollections.meals)
        .get();

    for (final doc in mealsSnapshot.docs) {
      final mealId = doc.id;
      final dates = mealDates[mealId] ?? [];
      
      dates.sort((a, b) => a.compareTo(b));
      
      DateTime? lastUsed;
      DateTime? nextUpcoming;

      for (final date in dates) {
        if (date.isBefore(today)) {
          lastUsed = date;
        } else if (date.isAtSameMomentAs(today) || date.isAfter(today)) {
          nextUpcoming ??= date;
        }
      }

      batch.update(doc.reference, {
        'last_used_date': lastUsed,
        'next_upcoming_date': nextUpcoming,
      });
    }

    await batch.commit();
  }
}

final mealSyncServiceProvider = Provider<MealSyncService>((ref) {
  final planRepo = ref.watch(planRepositoryProvider);
  return MealSyncService(planRepo);
});
