class WeeklyPlan {
  final String id;
  final DateTime startDate;
  // Day offset (0-6) mapped to Meal ID
  final Map<int, String> mealIdsByDay;

  WeeklyPlan({
    required this.id,
    required this.startDate,
    required this.mealIdsByDay,
  });

  factory WeeklyPlan.fromMap(Map<String, dynamic> data, String documentId) {
    Map<String, dynamic> rawMap = data['mealIdsByDay'] ?? {};
    Map<int, String> parsedMap = {};
    rawMap.forEach((key, value) {
      if (value != null) {
        parsedMap[int.parse(key)] = value.toString();
      }
    });

    return WeeklyPlan(
      id: documentId,
      startDate: data['startDate']?.toDate() ?? DateTime.now(),
      mealIdsByDay: parsedMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'mealIdsByDay': mealIdsByDay.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  WeeklyPlan copyWith({
    String? id,
    DateTime? startDate,
    Map<int, String>? mealIdsByDay,
  }) {
    return WeeklyPlan(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      mealIdsByDay: mealIdsByDay ?? this.mealIdsByDay,
    );
  }
}
