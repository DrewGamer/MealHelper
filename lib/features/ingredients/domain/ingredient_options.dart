class IngredientOptions {
  final List<String> proteinSources;
  final List<String> ingredients;

  IngredientOptions({
    this.proteinSources = const [],
    this.ingredients = const [],
  });

  factory IngredientOptions.fromMap(Map<String, dynamic>? data) {
    if (data == null) return IngredientOptions();
    return IngredientOptions(
      proteinSources: List<String>.from(data['protein_sources'] ?? []),
      ingredients: List<String>.from(data['ingredients'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'protein_sources': proteinSources,
      'ingredients': ingredients,
    };
  }
}
