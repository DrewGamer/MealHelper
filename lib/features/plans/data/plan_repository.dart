import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../collaboration/data/workspace_repository.dart';
import '../domain/meal_plan.dart';

class PlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _plansRef(String databaseId) {
    return _firestore
        .collection(FirestoreCollections.databases)
        .doc(databaseId)
        .collection(FirestoreCollections.plans);
  }

  Future<void> savePlan(String databaseId, MealPlan plan) async {
    await _plansRef(databaseId).doc(plan.id).set(plan.toMap());
  }

  Future<void> updatePlan(String databaseId, MealPlan plan) async {
    await _plansRef(databaseId).doc(plan.id).update(plan.toMap());
  }

  Future<void> deletePlan(String databaseId, String planId) async {
    await _plansRef(databaseId).doc(planId).delete();
  }

  Stream<List<MealPlan>> streamPlans(String databaseId) {
    return _plansRef(databaseId)
        .orderBy(FirestoreFields.startDate, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MealPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<List<MealPlan>> getPlans(String databaseId) async {
    final snapshot = await _plansRef(databaseId).get();
    return snapshot.docs
        .map((doc) => MealPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository();
});

final plansStreamProvider = StreamProvider<List<MealPlan>>((ref) {
  final dbId = ref.watch(activeDatabaseIdStreamProvider).value;
  if (dbId == null) {
    return Stream.value([]);
  }
  return ref.watch(planRepositoryProvider).streamPlans(dbId);
});
