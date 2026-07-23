import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/meal_plan.dart';

class PlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _plansRef(String databaseId) {
    return _firestore.collection('databases').doc(databaseId).collection('plans');
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
    return _plansRef(databaseId).orderBy('startDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MealPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}
