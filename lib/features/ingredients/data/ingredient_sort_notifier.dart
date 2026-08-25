import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../domain/ingredient_sort_option.dart';

class IngredientSortNotifier extends Notifier<IngredientSortOption> {
  static const _sortPrefKey = 'ingredient_sort_preference';

  @override
  IngredientSortOption build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedOption = prefs.getString(_sortPrefKey);
    if (savedOption != null) {
      return IngredientSortOption.values.firstWhere(
        (e) => e.name == savedOption,
        orElse: () => IngredientSortOption.alphabetical,
      );
    }
    return IngredientSortOption.alphabetical;
  }

  void setSortOption(IngredientSortOption option) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_sortPrefKey, option.name);
    state = option;
  }
}

final ingredientSortProvider = NotifierProvider<IngredientSortNotifier, IngredientSortOption>(() {
  return IngredientSortNotifier();
});
