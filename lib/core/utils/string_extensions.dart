extension StringListExtension on List<String> {
  void sortAlphabetically() {
    sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  List<String> sortedAlphabetically() {
    final copy = List<String>.from(this);
    copy.sortAlphabetically();
    return copy;
  }
}
