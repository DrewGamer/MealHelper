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

  // --- Collaboration / Database Management ---

  Future<void> initializeUserIfNeeded(String uid, String? email) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      // Create default workspace
      final dbRef = _firestore.collection('databases').doc(uid);
      await dbRef.set({
        'id': uid,
        'owner_id': uid,
        'collaborator_ids': [uid],
        'name': email != null ? 'Database for $email' : 'My Database',
      });

      // Create user profile
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'display_name': email ?? 'Anonymous',
        'active_database_id': uid,
      });
    }
  }

  Stream<String?> streamActiveDatabaseId(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return uid; // Fallback to uid if profile deleted somehow
      return snapshot.data()?['active_database_id'] as String? ?? uid;
    });
  }

  Future<void> joinDatabase(String uid, String databaseId) async {
    // 1. Check if database exists
    final dbDoc = await _firestore.collection('databases').doc(databaseId).get();
    if (!dbDoc.exists) {
      throw Exception('Database not found');
    }
    
    // 2. Add user to collaborator_ids
    await dbDoc.reference.update({
      'collaborator_ids': FieldValue.arrayUnion([uid])
    });

    // 3. Update user's active_database_id
    await _firestore.collection('users').doc(uid).update({
      'active_database_id': databaseId
    });
  }

  Future<void> switchActiveDatabase(String uid, String databaseId) async {
    await _firestore.collection('users').doc(uid).update({
      'active_database_id': databaseId
    });
  }
}
