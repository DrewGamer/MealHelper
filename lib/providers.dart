import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/database_repository.dart';
import 'data/repositories/plan_repository.dart';
import 'data/repositories/ingredient_options_repository.dart';
import 'domain/models/meal.dart';
import 'domain/models/weekly_plan.dart';
import 'domain/models/ingredient_options.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository();
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository();
});

final ingredientOptionsRepositoryProvider = Provider<IngredientOptionsRepository>((ref) {
  return IngredientOptionsRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class IsAuthenticatingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }

  void reset() {
    state = false;
  }
}

final isAuthenticatingProvider = NotifierProvider<IsAuthenticatingNotifier, bool>(() {
  return IsAuthenticatingNotifier();
});

final activeDatabaseIdStreamProvider = StreamProvider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(databaseRepositoryProvider).streamActiveDatabaseId(user.uid);
});

final mealsStreamProvider = StreamProvider<List<Meal>>((ref) {
  final dbId = ref.watch(activeDatabaseIdStreamProvider).value;
  if (dbId == null) {
    return Stream.value([]);
  }
  return ref.watch(databaseRepositoryProvider).streamMeals(dbId);
});

final plansStreamProvider = StreamProvider<List<WeeklyPlan>>((ref) {
  final dbId = ref.watch(activeDatabaseIdStreamProvider).value;
  if (dbId == null) {
    return Stream.value([]);
  }
  return ref.watch(planRepositoryProvider).streamPlans(dbId);
});

final ingredientOptionsStreamProvider = StreamProvider<IngredientOptions>((ref) {
  final dbId = ref.watch(activeDatabaseIdStreamProvider).value;
  if (dbId == null) {
    return Stream.value(IngredientOptions());
  }
  return ref.watch(ingredientOptionsRepositoryProvider).streamIngredientOptions(dbId);
});

final databaseNameProvider = StreamProvider.family<String, String>((ref, String dbId) {
  return ref.watch(databaseRepositoryProvider).streamDatabaseName(dbId);
});
