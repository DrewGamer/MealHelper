import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/database_repository.dart';
import 'data/repositories/plan_repository.dart';
import 'data/repositories/ingredient_options_repository.dart';
import 'domain/models/meal.dart';
import 'domain/models/meal_plan.dart';
import 'domain/models/ingredient_options.dart';
import 'application/services/meal_sync_service.dart';
import 'application/services/meal_selection_engine.dart';

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

final mealSyncServiceProvider = Provider<MealSyncService>((ref) {
  final planRepo = ref.watch(planRepositoryProvider);
  final dbRepo = ref.watch(databaseRepositoryProvider);
  return MealSyncService(planRepo, dbRepo);
});

class EngineConfig {
  final bool useRecency;
  final bool useVaryProtein;
  
  EngineConfig({this.useRecency = true, this.useVaryProtein = true});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EngineConfig &&
          runtimeType == other.runtimeType &&
          useRecency == other.useRecency &&
          useVaryProtein == other.useVaryProtein;

  @override
  int get hashCode => useRecency.hashCode ^ useVaryProtein.hashCode;
}

final mealSelectionEngineProvider = Provider.family<MealSelectionEngine, EngineConfig>((ref, config) {
  List<SelectionStrategy> activeStrategies = [];
  if (config.useRecency) activeStrategies.add(RecencyStrategy());
  if (config.useVaryProtein) activeStrategies.add(VaryProteinStrategy());
  
  return MealSelectionEngine(strategies: activeStrategies);
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

final plansStreamProvider = StreamProvider<List<MealPlan>>((ref) {
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
