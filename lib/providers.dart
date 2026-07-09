import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/database_repository.dart';
import 'domain/models/meal.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final activeDatabaseIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user?.uid;
});

final mealsStreamProvider = StreamProvider<List<Meal>>((ref) {
  final dbId = ref.watch(activeDatabaseIdProvider);
  if (dbId == null) {
    return Stream.value([]);
  }
  return ref.watch(databaseRepositoryProvider).streamMeals(dbId);
});
