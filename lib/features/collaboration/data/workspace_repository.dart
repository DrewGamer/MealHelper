import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../auth/data/auth_repository.dart';

class WorkspaceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeUserIfNeeded(String uid, String? email) async {
    final userDoc = await _firestore.collection(FirestoreCollections.users).doc(uid).get();
    if (!userDoc.exists) {
      // Create default workspace
      final dbRef = _firestore.collection(FirestoreCollections.databases).doc(uid);
      await dbRef.set({
        FirestoreFields.id: uid,
        FirestoreFields.ownerId: uid,
        FirestoreFields.collaboratorIds: [uid],
        FirestoreFields.name: 'My Personal Database',
      });

      // Create user profile
      await _firestore.collection(FirestoreCollections.users).doc(uid).set({
        FirestoreFields.uid: uid,
        FirestoreFields.displayName: email ?? 'Anonymous',
        FirestoreFields.activeDatabaseId: uid,
      });
    }
  }

  Stream<String?> streamActiveDatabaseId(String uid) {
    return _firestore.collection(FirestoreCollections.users).doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return uid; // Fallback to uid if profile deleted somehow
      return snapshot.data()?[FirestoreFields.activeDatabaseId] as String? ?? uid;
    });
  }

  Future<void> joinDatabase(String uid, String databaseId) async {
    // 1. Check if database exists
    final dbDoc = await _firestore.collection(FirestoreCollections.databases).doc(databaseId).get();
    if (!dbDoc.exists) {
      throw Exception('Database not found');
    }

    // 2. Add user to collaborator_ids
    await dbDoc.reference.update({
      FirestoreFields.collaboratorIds: FieldValue.arrayUnion([uid])
    });

    // 3. Update user's active_database_id
    await _firestore.collection(FirestoreCollections.users).doc(uid).update({
      FirestoreFields.activeDatabaseId: databaseId
    });
  }

  Future<void> switchActiveDatabase(String uid, String databaseId) async {
    await _firestore.collection(FirestoreCollections.users).doc(uid).update({
      FirestoreFields.activeDatabaseId: databaseId
    });
  }

  Future<void> updateDatabaseName(String databaseId, String newName) async {
    await _firestore.collection(FirestoreCollections.databases).doc(databaseId).update({
      FirestoreFields.name: newName,
    });
  }

  Stream<String> streamDatabaseName(String databaseId) {
    return _firestore.collection(FirestoreCollections.databases).doc(databaseId).snapshots().map((snapshot) {
      if (!snapshot.exists) return 'Unknown Database';
      return snapshot.data()?[FirestoreFields.name] as String? ?? 'Unknown Database';
    });
  }
}

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return WorkspaceRepository();
});

final activeDatabaseIdStreamProvider = StreamProvider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(workspaceRepositoryProvider).streamActiveDatabaseId(user.uid);
});

final databaseNameProvider = StreamProvider.family<String, String>((ref, String dbId) {
  return ref.watch(workspaceRepositoryProvider).streamDatabaseName(dbId);
});
