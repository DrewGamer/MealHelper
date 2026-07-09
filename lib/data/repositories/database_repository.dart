import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/meal.dart';

class DatabaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _mealsRef(String databaseId) {
    return _firestore.collection('databases').doc(databaseId).collection('meals');
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
      return snapshot.docs.map((doc) => Meal.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}
