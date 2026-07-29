import 'package:meal_helper/domain/models/meal.dart';

enum MealSortOption {
  alphabetical,
}

extension MealSortExtension on Iterable<Meal> {
  List<Meal> applySort(MealSortOption option) {
    final list = toList();
    switch (option) {
      case MealSortOption.alphabetical:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }
    return list;
  }
}
