class MealPlan {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  // Day offset (0 to difference between start and end) mapped to Meal ID
  final Map<int, String> mealIdsByDay;

  MealPlan({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.mealIdsByDay,
  });

  bool coversDate(DateTime date) {
    final normDate = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return !normDate.isBefore(normStart) && !normDate.isAfter(normEnd);
  }

  bool overlapsWithRange(DateTime rangeStart, DateTime rangeEnd) {
    final normStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final normRangeStart = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
    final normRangeEnd = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
    return !(normEnd.isBefore(normRangeStart) || normStart.isAfter(normRangeEnd));
  }
  
  bool overlapsWith(MealPlan other) {
    return overlapsWithRange(other.startDate, other.endDate);
  }

  String? getMealIdForDate(DateTime date) {
    final normDate = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final offset = normDate.difference(normStart).inDays;
    if (offset >= 0 && !normDate.isAfter(normEnd)) {
      return mealIdsByDay[offset];
    }
    return null;
  }

  static String formatDateRange(DateTime start, DateTime end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final startMonth = months[start.month - 1];
    final endMonth = months[end.month - 1];

    if (start.month == end.month) {
      return '$startMonth ${start.day} - ${end.day}, ${start.year}';
    } else if (start.year == end.year) {
      return '$startMonth ${start.day} - $endMonth ${end.day}, ${start.year}';
    } else {
      return '$startMonth ${start.day}, ${start.year} - $endMonth ${end.day}, ${end.year}';
    }
  }

  factory MealPlan.fromMap(Map<String, dynamic> data, String documentId) {
    Map<String, dynamic> rawMap = data['mealIdsByDay'] ?? {};
    Map<int, String> parsedMap = {};
    rawMap.forEach((key, value) {
      if (value != null) {
        parsedMap[int.parse(key)] = value.toString();
      }
    });

    final startDate = data['startDate']?.toDate() ?? DateTime.now();
    final endDate = data['endDate']?.toDate() ?? startDate.add(const Duration(days: 6));

    return MealPlan(
      id: documentId,
      startDate: startDate,
      endDate: endDate,
      mealIdsByDay: parsedMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'mealIdsByDay': mealIdsByDay.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  MealPlan copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    Map<int, String>? mealIdsByDay,
  }) {
    return MealPlan(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      mealIdsByDay: mealIdsByDay ?? this.mealIdsByDay,
    );
  }
}
