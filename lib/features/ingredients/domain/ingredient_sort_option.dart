enum IngredientSortOption {
  alphabetical,
}

extension IngredientSortExtension on Iterable<String> {
  List<String> applySort(IngredientSortOption option) {
    final list = toList();
    switch (option) {
      case IngredientSortOption.alphabetical:
        list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        break;
    }
    return list;
  }
}
