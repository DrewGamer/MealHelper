class Meal {
  final String id;
  final String name;
  final String description;
  @Deprecated('Use proteinSource and ingredients instead')
  final List<String> tags;
  final String? proteinSource;
  final List<String> ingredients;
  final DateTime? lastUsedDate;
  final String createdBy;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    this.tags = const [],
    this.proteinSource,
    this.ingredients = const [],
    this.lastUsedDate,
    required this.createdBy,
  });

  factory Meal.fromMap(Map<String, dynamic> data, String documentId) {
    return Meal(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      proteinSource: data['protein_source'],
      ingredients: List<String>.from(data['ingredients'] ?? []),
      lastUsedDate: data['last_used_date']?.toDate(),
      createdBy: data['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'tags': tags,
      'protein_source': proteinSource,
      'ingredients': ingredients,
      'last_used_date': lastUsedDate,
      'created_by': createdBy,
    };
  }

  Meal copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    String? proteinSource,
    List<String>? ingredients,
    DateTime? lastUsedDate,
    String? createdBy,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      proteinSource: proteinSource ?? this.proteinSource,
      ingredients: ingredients ?? this.ingredients,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
