class Meal {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final DateTime? lastUsedDate;
  final String createdBy;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.lastUsedDate,
    required this.createdBy,
  });

  factory Meal.fromMap(Map<String, dynamic> data, String documentId) {
    return Meal(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      lastUsedDate: data['last_used_date']?.toDate(),
      createdBy: data['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'tags': tags,
      'last_used_date': lastUsedDate,
      'created_by': createdBy,
    };
  }

  Meal copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    DateTime? lastUsedDate,
    String? createdBy,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
