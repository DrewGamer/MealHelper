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

  static DateTime normalizeToStartOfWeek(DateTime date) {
    final daysToMonday = date.weekday - DateTime.monday;
    final monday = date.subtract(Duration(days: daysToMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }

  DateTime get endDate => startDate.add(const Duration(days: 6));

  bool isSameWeek(DateTime date) {
    final targetStart = normalizeToStartOfWeek(date);
    final currentStart = normalizeToStartOfWeek(startDate);
    return targetStart.year == currentStart.year &&
        targetStart.month == currentStart.month &&
        targetStart.day == currentStart.day;
  }

  static String formatDateRange(DateTime date) {
    final mon = normalizeToStartOfWeek(date);
    final sun = mon.add(const Duration(days: 6));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final startMonth = months[mon.month - 1];
    final endMonth = months[sun.month - 1];

    if (mon.month == sun.month) {
      return '$startMonth ${mon.day} - ${sun.day}, ${mon.year}';
    } else if (mon.year == sun.year) {
      return '$startMonth ${mon.day} - $endMonth ${sun.day}, ${mon.year}';
    } else {
      return '$startMonth ${mon.day}, ${mon.year} - $endMonth ${sun.day}, ${sun.year}';
    }
  }

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
