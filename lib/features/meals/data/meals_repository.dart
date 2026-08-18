import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../collaboration/data/workspace_repository.dart';
import '../domain/meal.dart';

class MealsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _mealsRef(String databaseId) {
    return _firestore
        .collection(FirestoreCollections.databases)
        .doc(databaseId)
        .collection(FirestoreCollections.meals);
  }

  Future<void> addMeal(String databaseId, Meal meal) async {
    await _mealsRef(databaseId).doc(meal.id).set(meal.toMap());
  }

  Future<void> updateMeal(String databaseId, Meal meal) async {
    await _mealsRef(databaseId).doc(meal.id).update(meal.toMap());
  }

  Future<void> deleteMeal(String databaseId, String mealId) async {
    await _mealsRef(databaseId).doc(mealId).delete();
  }

  Stream<List<Meal>> streamMeals(String databaseId) {
    return _mealsRef(databaseId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Meal.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  return MealsRepository();
});

final mealsStreamProvider = StreamProvider<List<Meal>>((ref) {
  final dbId = ref.watch(activeDatabaseIdStreamProvider).value;
  if (dbId == null) {
    return Stream.value([]);
  }
  return ref.watch(mealsRepositoryProvider).streamMeals(dbId);
});
