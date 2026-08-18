class FirestoreCollections {
  static const String databases = 'databases';
  static const String users = 'users';
  static const String meals = 'meals';
  static const String plans = 'plans';
  static const String settings = 'settings';
}

class FirestoreDocs {
  static const String ingredientOptions = 'ingredient_options';
}

class FirestoreFields {
  // Common / Database
  static const String id = 'id';
  static const String ownerId = 'owner_id';
  static const String collaboratorIds = 'collaborator_ids';
  static const String name = 'name';

  // User
  static const String uid = 'uid';
  static const String displayName = 'display_name';
  static const String activeDatabaseId = 'active_database_id';

  // Ingredients / Settings
  static const String proteinSources = 'protein_sources';
  static const String ingredients = 'ingredients';

  // Meal
  static const String title = 'title';
  static const String description = 'description';
  static const String proteinSource = 'protein_source';
  static const String lastUsed = 'lastUsed';
  static const String nextUpcoming = 'nextUpcoming';
  static const String isExcludedFromAutoGeneration = 'isExcludedFromAutoGeneration';

  // Plan
  static const String startDate = 'startDate';
  static const String targetDays = 'targetDays';
  static const String assignments = 'assignments';
}
