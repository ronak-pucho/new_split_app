import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

class SearchProvider extends ChangeNotifier {
  List<String> searchResult = [];

  // Fuzzy search implementation
  List<String> searchFuzzy(String text, List<String> listString) {
    final fuzzy = Fuzzy(listString);
    final searchFuzzy = fuzzy.search(text);
    final resultString = searchFuzzy.map((e) => e.item).toList();
    return resultString;
  }

  // Search event handler
  void searchEvent(String search, List<String> list) {
    searchResult = search.trim().isEmpty ? [] : searchFuzzy(search, list);
    print(searchResult);
    notifyListeners();
  }

  // Clear the search results
  void clearSearch() {
    searchResult = [];
    notifyListeners();
  }
}
