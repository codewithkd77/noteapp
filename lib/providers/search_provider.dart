import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class SearchProvider extends ChangeNotifier {
  List<dynamic> _searchResults = [];
  String _searchQuery = '';
  bool _isSearching = false;

  List<dynamic> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  Future<void> search(String query) async {
    _searchQuery = query;
    _isSearching = true;
    notifyListeners();

    try {
      if (query.trim().isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = DatabaseService.search(query);
      }
    } catch (e) {
      debugPrint('Error searching: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }
}
