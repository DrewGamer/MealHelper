import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../domain/meal_sort_option.dart';

class MealSortNotifier extends Notifier<MealSortOption> {
  static const _sortPrefKey = 'meal_sort_preference';

  @override
  MealSortOption build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedOption = prefs.getString(_sortPrefKey);
    if (savedOption != null) {
      return MealSortOption.values.firstWhere(
        (e) => e.name == savedOption,
        orElse: () => MealSortOption.alphabetical,
      );
    }
    return MealSortOption.alphabetical;
  }

  void setSortOption(MealSortOption option) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_sortPrefKey, option.name);
    state = option;
  }
}

final mealSortProvider = NotifierProvider<MealSortNotifier, MealSortOption>(() {
  return MealSortNotifier();
});
