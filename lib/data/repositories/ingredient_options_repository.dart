import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/ingredient_options.dart';

class IngredientOptionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _optionsRef(String databaseId) {
    return _firestore.collection('databases').doc(databaseId).collection('settings').doc('ingredient_options');
  }

  Stream<IngredientOptions> streamIngredientOptions(String databaseId) {
    return _optionsRef(databaseId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return IngredientOptions();
      }
      return IngredientOptions.fromMap(snapshot.data() as Map<String, dynamic>?);
    });
  }

  Future<void> addProteinSource(String databaseId, String protein) async {
    await _optionsRef(databaseId).set({
      'protein_sources': FieldValue.arrayUnion([protein])
    }, SetOptions(merge: true));
  }

  Future<void> addIngredient(String databaseId, String ingredient) async {
    await _optionsRef(databaseId).set({
      'ingredients': FieldValue.arrayUnion([ingredient])
    }, SetOptions(merge: true));
  }

  Future<void> removeProteinSource(String databaseId, String protein) async {
    final batch = _firestore.batch();
    
    // Remove from options
    batch.set(_optionsRef(databaseId), {
      'protein_sources': FieldValue.arrayRemove([protein])
    }, SetOptions(merge: true));

    // Update meals (cascade delete)
    final mealsQuery = await _firestore
        .collection('databases')
        .doc(databaseId)
        .collection('meals')
        .where('protein_source', isEqualTo: protein)
        .get();

    for (var doc in mealsQuery.docs) {
      batch.update(doc.reference, {'protein_source': null});
    }

    await batch.commit();
  }

  Future<void> removeIngredient(String databaseId, String ingredient) async {
    final batch = _firestore.batch();
    
    // Remove from options
    batch.set(_optionsRef(databaseId), {
      'ingredients': FieldValue.arrayRemove([ingredient])
    }, SetOptions(merge: true));

    // Update meals (cascade delete)
    final mealsQuery = await _firestore
        .collection('databases')
        .doc(databaseId)
        .collection('meals')
        .where('ingredients', arrayContains: ingredient)
        .get();

    for (var doc in mealsQuery.docs) {
      batch.update(doc.reference, {
        'ingredients': FieldValue.arrayRemove([ingredient])
      });
    }

    await batch.commit();
  }

  Future<void> renameProteinSource(String databaseId, String oldProtein, String newProtein) async {
    final batch = _firestore.batch();
    
    // Update options (remove old, add new)
    batch.set(_optionsRef(databaseId), {
      'protein_sources': FieldValue.arrayRemove([oldProtein])
    }, SetOptions(merge: true));
    batch.set(_optionsRef(databaseId), {
      'protein_sources': FieldValue.arrayUnion([newProtein])
    }, SetOptions(merge: true));

    // Update meals (cascade rename)
    final mealsQuery = await _firestore
        .collection('databases')
        .doc(databaseId)
        .collection('meals')
        .where('protein_source', isEqualTo: oldProtein)
        .get();

    for (var doc in mealsQuery.docs) {
      batch.update(doc.reference, {'protein_source': newProtein});
    }

    await batch.commit();
  }

  Future<void> renameIngredient(String databaseId, String oldIngredient, String newIngredient) async {
    final batch = _firestore.batch();
    
    // Update options (remove old, add new)
    batch.set(_optionsRef(databaseId), {
      'ingredients': FieldValue.arrayRemove([oldIngredient])
    }, SetOptions(merge: true));
    batch.set(_optionsRef(databaseId), {
      'ingredients': FieldValue.arrayUnion([newIngredient])
    }, SetOptions(merge: true));

    // Update meals (cascade rename)
    final mealsQuery = await _firestore
        .collection('databases')
        .doc(databaseId)
        .collection('meals')
        .where('ingredients', arrayContains: oldIngredient)
        .get();

    for (var doc in mealsQuery.docs) {
      // Due to the limitation of arrayRemove and arrayUnion in the same document update in a batch,
      // read the current array, modify it locally, and update.
      final data = doc.data();
      List<String> ingredients = List<String>.from(data['ingredients'] ?? []);
      if (ingredients.contains(oldIngredient)) {
        ingredients.remove(oldIngredient);
        if (!ingredients.contains(newIngredient)) {
          ingredients.add(newIngredient);
        }
        batch.update(doc.reference, {'ingredients': ingredients});
      }
    }

    await batch.commit();
  }

  Future<int> getAffectedMealsCountByProtein(String databaseId, String protein) async {
    final query = await _firestore
        .collection('databases')
        .doc(databaseId)
        .collection('meals')
        .where('protein_source', isEqualTo: protein)
        .count()
        .get();
    return query.count ?? 0;
  }

  Future<int> getAffectedMealsCountByIngredient(String databaseId, String ingredient) async {
    final query = await _firestore
        .collection('databases')
        .doc(databaseId)
        .collection('meals')
        .where('ingredients', arrayContains: ingredient)
        .count()
        .get();
    return query.count ?? 0;
  }
}
